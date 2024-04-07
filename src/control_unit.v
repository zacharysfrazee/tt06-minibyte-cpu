/*
 * Copyright (c) 2024 Zachary Frazee
 * SPDX-License-Identifier: Apache-2.0
 */

//---------------------------------
//Control Unit
//---------------------------------
module minibyte_cu(
    //Basic Inputs
    input  wire       clk_in, rst_in,

    //IR Input
    input  wire [7:0] ir_op_buss_in,

    //ALU Flags Input
    input  wire [1:0] ccr_flag_zn_in,

    //Control signal outputs
    output reg        set_a_out,
    output reg        set_m_out,
    output reg        set_pc_out,
    output reg        set_ir_out,
    output reg        set_ccr_out,
    output reg        inc_pc_out,

    //Addr select signals
    output reg        addr_mux_out,

    //Alu control signals
    output reg [3:0]  alu_op_out,

    //Write to memory
    output reg        we_out,

    //Drive enable on data bus
    output reg        drive_out,

    //DFT Output
    output reg  [7:0] dft_curr_state
);

    //State machine memory
    //--------------------------
    reg [7:0] curr_state, next_state;

    //DFT Output
    //--------------------------
    assign dft_curr_state = curr_state;

    //CPU IR opcodes
    //--------------------------
    parameter IR_NOP     = 8'h00;
    parameter IR_LDA_IMM = 8'h01;
    parameter IR_LDA_DIR = 8'h02;
    parameter IR_STA_IMM = 8'h03;
    parameter IR_STA_DIR = 8'h04;
    parameter IR_ADD_IMM = 8'h05;
    parameter IR_ADD_DIR = 8'h06;
    parameter IR_SUB_IMM = 8'h07;
    parameter IR_SUB_DIR = 8'h08;
    parameter IR_AND_IMM = 8'h09;
    parameter IR_AND_DIR = 8'h0A;
    parameter IR_OR_IMM  = 8'h0B;
    parameter IR_OR_DIR  = 8'h0C;
    parameter IR_XOR_IMM = 8'h0D;
    parameter IR_XOR_DIR = 8'h0E;
    parameter IR_LSL_IMM = 8'h0F;
    parameter IR_LSL_DIR = 8'h10;
    parameter IR_LSR_IMM = 8'h11;
    parameter IR_LSR_DIR = 8'h12;
    parameter IR_ASL_IMM = 8'h13;
    parameter IR_ASL_DIR = 8'h14;
    parameter IR_ASR_IMM = 8'h15;
    parameter IR_ASR_DIR = 8'h16;
    parameter IR_RSL_IMM = 8'h17;
    parameter IR_RSL_DIR = 8'h18;
    parameter IR_RSR_IMM = 8'h19;
    parameter IR_RSR_DIR = 8'h1A;
    parameter IR_JMP_IMM = 8'h1B;
    parameter IR_JMP_DIR = 8'h1C;

    //State machine opcodes
    //--------------------------
    parameter S_RESET_0   = 8'h00;
    parameter S_PC_INC_0  = 8'h01;
    parameter S_FETCH_0   = 8'h02;
    parameter S_FETCH_1   = 8'h03;
    parameter S_FETCH_2   = 8'h04;
    parameter S_DECODE_0  = 8'h05;
    parameter S_LDA_IMM_0 = 8'h06;
    parameter S_LDA_IMM_1 = 8'h07;
    parameter S_LDA_DIR_0 = 8'h08;
    parameter S_LDA_DIR_1 = 8'h09;
    parameter S_LDA_DIR_2 = 8'h0A;
    parameter S_LDA_DIR_3 = 8'h0B;
    parameter S_STA_IMM_0 = 8'h0C;
    parameter S_STA_IMM_1 = 8'h0D;
    parameter S_STA_IMM_2 = 8'h0E;
    parameter S_STA_IMM_3 = 8'h0F;
    parameter S_STA_DIR_0 = 8'h10;
    parameter S_STA_DIR_1 = 8'h11;
    parameter S_STA_DIR_2 = 8'h12;
    parameter S_STA_DIR_3 = 8'h13;
    parameter S_STA_DIR_4 = 8'h14;
    parameter S_STA_DIR_5 = 8'h15;
    parameter S_ADD_IMM_0 = 8'h16;
    parameter S_ADD_IMM_1 = 8'h17;
    parameter S_ADD_DIR_0 = 8'h18;
    parameter S_ADD_DIR_1 = 8'h19;
    parameter S_ADD_DIR_2 = 8'h1A;
    parameter S_ADD_DIR_3 = 8'h1B;
    parameter S_SUB_IMM_0 = 8'h1C;
    parameter S_SUB_IMM_1 = 8'h1D;
    parameter S_SUB_DIR_0 = 8'h1E;
    parameter S_SUB_DIR_1 = 8'h1F;
    parameter S_SUB_DIR_2 = 8'h20;
    parameter S_SUB_DIR_3 = 8'h21;
    parameter S_AND_IMM_0 = 8'h22;
    parameter S_AND_IMM_1 = 8'h23;
    parameter S_AND_DIR_0 = 8'h24;
    parameter S_AND_DIR_1 = 8'h25;
    parameter S_AND_DIR_2 = 8'h26;
    parameter S_AND_DIR_3 = 8'h27;
    parameter S_OR_IMM_0  = 8'h28;
    parameter S_OR_IMM_1  = 8'h29;
    parameter S_OR_DIR_0  = 8'h2A;
    parameter S_OR_DIR_1  = 8'h2B;
    parameter S_OR_DIR_2  = 8'h2C;
    parameter S_OR_DIR_3  = 8'h2D;
    parameter S_XOR_IMM_0 = 8'h2E;
    parameter S_XOR_IMM_1 = 8'h2F;
    parameter S_XOR_DIR_0 = 8'h30;
    parameter S_XOR_DIR_1 = 8'h31;
    parameter S_XOR_DIR_2 = 8'h32;
    parameter S_XOR_DIR_3 = 8'h33;
    parameter S_LSL_IMM_0 = 8'h34;
    parameter S_LSL_IMM_1 = 8'h35;
    parameter S_LSL_DIR_0 = 8'h36;
    parameter S_LSL_DIR_1 = 8'h37;
    parameter S_LSL_DIR_2 = 8'h38;
    parameter S_LSL_DIR_3 = 8'h39;
    parameter S_LSR_IMM_0 = 8'h3A;
    parameter S_LSR_IMM_1 = 8'h3B;
    parameter S_LSR_DIR_0 = 8'h3C;
    parameter S_LSR_DIR_1 = 8'h3D;
    parameter S_LSR_DIR_2 = 8'h3E;
    parameter S_LSR_DIR_3 = 8'h3F;
    parameter S_ASL_IMM_0 = 8'h40;
    parameter S_ASL_IMM_1 = 8'h41;
    parameter S_ASL_DIR_0 = 8'h42;
    parameter S_ASL_DIR_1 = 8'h43;
    parameter S_ASL_DIR_2 = 8'h44;
    parameter S_ASL_DIR_3 = 8'h45;
    parameter S_ASR_IMM_0 = 8'h46;
    parameter S_ASR_IMM_1 = 8'h47;
    parameter S_ASR_DIR_0 = 8'h48;
    parameter S_ASR_DIR_1 = 8'h49;
    parameter S_ASR_DIR_2 = 8'h4A;
    parameter S_ASR_DIR_3 = 8'h4B;
    parameter S_RSL_IMM_0 = 8'h4C;
    parameter S_RSL_IMM_1 = 8'h4D;
    parameter S_RSL_DIR_0 = 8'h4E;
    parameter S_RSL_DIR_1 = 8'h4F;
    parameter S_RSL_DIR_2 = 8'h50;
    parameter S_RSL_DIR_3 = 8'h51;
    parameter S_RSR_IMM_0 = 8'h52;
    parameter S_RSR_IMM_1 = 8'h53;
    parameter S_RSR_DIR_0 = 8'h54;
    parameter S_RSR_DIR_1 = 8'h55;
    parameter S_RSR_DIR_2 = 8'h56;
    parameter S_RSR_DIR_3 = 8'h57;
    parameter S_JMP_IMM_0 = 8'h58;
    parameter S_JMP_IMM_1 = 8'h59;
    parameter S_JMP_DIR_0 = 8'h5A;
    parameter S_JMP_DIR_1 = 8'h5B;
    parameter S_JMP_DIR_2 = 8'h5C;
    parameter S_JMP_DIR_3 = 8'h5D;

    //--------------------------
    //ALU OPS
    //--------------------------
    parameter OP_ALU_PASSA = 4'b0000;
    parameter OP_ALU_PASSB = 4'b0001;
    parameter OP_ALU_ADD   = 4'b0010;
    parameter OP_ALU_SUB   = 4'b0011;
    parameter OP_ALU_AND   = 4'b0100;
    parameter OP_ALU_OR    = 4'b0101;
    parameter OP_ALU_XOR   = 4'b0110;
    parameter OP_ALU_LSL   = 4'b0111;
    parameter OP_ALU_LSR   = 4'b1000;
    parameter OP_ALU_ASL   = 4'b1001;
    parameter OP_ALU_ASR   = 4'b1010;
    parameter OP_ALU_RSL   = 4'b1011;
    parameter OP_ALU_RSR   = 4'b1100;

    //State memory block
    //--------------------------
    always @ (posedge clk_in or negedge rst_in) begin
        //Reset to S_RESET_0 on reset
        if(!rst_in)
            curr_state <= S_RESET_0;

        //Otherwise go to next state on every clk
        else
            curr_state <= next_state;
    end


    //Output logic
    //--------------------------
    always @ (curr_state) begin
        case(curr_state)

            //Reset sequence
            //-----

            //Do nothing until the next state
            S_RESET_0: begin
                //Dont set or inc any registers
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //PC selected
                addr_mux_out = 0;

                //ALU dont care
                alu_op_out   = 0;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //PC Increment
            //-----

            //Increment PC
            S_PC_INC_0: begin
                //Increment program counter
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 1;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //PC selected
                addr_mux_out = 0;

                //ALU dont care
                alu_op_out   = 0;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //Fetch sequence
            //-----

            //Send PC addr out
            S_FETCH_0: begin
                //Dont set or inc any registers
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //PC selected
                addr_mux_out = 0;

                //B (mem input) passthrough to main bus
                alu_op_out   = OP_ALU_PASSB;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //Load IR from memory
            S_FETCH_1: begin
                //Set IR Reg
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 1;
                set_ccr_out  = 0;

                //PC selected
                addr_mux_out = 0;

                //B (mem input) passthrough to main bus
                alu_op_out   = OP_ALU_PASSB;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //Inc PC now that IR is loaded
            S_FETCH_2: begin
                //Inc PC
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 1;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //PC selected
                addr_mux_out = 0;

                //B (mem input) passthrough to main bus
                alu_op_out   = OP_ALU_PASSB;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //Decode sequence
            //-----

            //Do nothing until the next state
            S_DECODE_0: begin
                //Dont set or inc any registers
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //PC selected
                addr_mux_out = 0;

                //ALU dont care
                alu_op_out   = 0;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //LDA_IMM sequence
            //-----

            //Pass incoming data from memory to the main buss
            S_LDA_IMM_0: begin
                //Dont set or inc any registers
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //PC selected
                addr_mux_out = 0;

                //B (mem input) passthrough to main bus
                alu_op_out   = OP_ALU_PASSB;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //Latch data to A
            S_LDA_IMM_1: begin
                //Latch A
                set_a_out    = 1;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //PC selected
                addr_mux_out = 0;

                //B (mem input) passthrough to main bus
                alu_op_out   = OP_ALU_PASSB;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //LDA_DIR sequence
            //-----

            //Pass incoming data from memory to the main buss
            S_LDA_DIR_0: begin
                //Dont set or inc any registers
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //PC selected
                addr_mux_out = 0;

                //B (mem input) passthrough to main bus
                alu_op_out   = OP_ALU_PASSB;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //Latch data to M
            S_LDA_DIR_1: begin
                //Latch M
                set_a_out    = 0;
                set_m_out    = 1;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //PC selected
                addr_mux_out = 0;

                //B (mem input) passthrough to main bus
                alu_op_out   = OP_ALU_PASSB;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //Set addr out to M
            S_LDA_DIR_2: begin
                //Dont set or inc any registers
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //M selected
                addr_mux_out = 1;

                //B (mem input) passthrough to main bus
                alu_op_out   = OP_ALU_PASSB;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //Latch data to A
            S_LDA_DIR_3: begin
                //Latch A
                set_a_out    = 1;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //M selected
                addr_mux_out = 1;

                //B (mem input) passthrough to main bus
                alu_op_out   = OP_ALU_PASSB;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //STA_IMM sequence
            //-----

            //Pass incoming data from memory to the main buss
            S_STA_IMM_0: begin
                //Dont set or inc any registers
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //PC selected
                addr_mux_out = 0;

                //B (mem input) passthrough to main bus
                alu_op_out   = OP_ALU_PASSB;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //Latch data to M
            S_STA_IMM_1: begin
                //Latch M
                set_a_out    = 0;
                set_m_out    = 1;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //PC selected
                addr_mux_out = 0;

                //B (mem input) passthrough to main bus
                alu_op_out   = OP_ALU_PASSB;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //Set address and WE, also prepare A data on the main buss
            S_STA_IMM_2: begin
                //Dont set or inc any registers
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //M selected
                addr_mux_out = 1;

                //A (A input) passthrough to main bus
                alu_op_out   = OP_ALU_PASSA;

                //Set WE so that the receiving device is ready for us to drive data
                we_out       = 1;
                drive_out    = 0;
            end

            //Drive the data out
            S_STA_IMM_3: begin
                //Dont set or inc any registers
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //M selected
                addr_mux_out = 1;

                //A (A input) passthrough to main bus
                alu_op_out   = OP_ALU_PASSA;

                //Drive out A data
                we_out       = 1;
                drive_out    = 1;
            end

            //STA_DIR sequence
            //-----

            //Pass incoming data from memory to the main buss
            S_STA_DIR_0: begin
                //Dont set or inc any registers
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //PC selected
                addr_mux_out = 0;

                //B (mem input) passthrough to main bus
                alu_op_out   = OP_ALU_PASSB;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //Latch data to M
            S_STA_DIR_1: begin
                //Latch M
                set_a_out    = 0;
                set_m_out    = 1;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //PC selected
                addr_mux_out = 0;

                //B (mem input) passthrough to main bus
                alu_op_out   = OP_ALU_PASSB;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end


            //Fetch data located at this address
            S_STA_DIR_2: begin
                //Latch M
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //M selected
                addr_mux_out = 1;

                //B (mem input) passthrough to main bus
                alu_op_out   = OP_ALU_PASSB;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //Latch data to M
            S_STA_DIR_3: begin
                //Latch M
                set_a_out    = 0;
                set_m_out    = 1;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //M selected
                addr_mux_out = 1;

                //B (mem input) passthrough to main bus
                alu_op_out   = OP_ALU_PASSB;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //Set address and WE, also prepare A data on the main buss
            S_STA_DIR_4: begin
                //Dont set or inc any registers
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //M selected
                addr_mux_out = 1;

                //A (A input) passthrough to main bus
                alu_op_out   = OP_ALU_PASSA;

                //Set WE so that the receiving device is ready for us to drive data
                we_out       = 1;
                drive_out    = 0;
            end

            //Drive the data out
            S_STA_DIR_5: begin
                //Dont set or inc any registers
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //M selected
                addr_mux_out = 1;

                //A (A input) passthrough to main bus
                alu_op_out   = OP_ALU_PASSA;

                //Drive out A data
                we_out       = 1;
                drive_out    = 1;
            end

            //ADD_IMM sequence
            //-----

            //Add the incoming data from the operand that the PC is pointing to
            S_ADD_IMM_0: begin
                //Dont set or inc any registers
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //PC selected
                addr_mux_out = 0;

                //ALU->Addition
                alu_op_out   = OP_ALU_ADD;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //Latch data to A/CCR
            S_ADD_IMM_1: begin
                //Latch A and CCR
                set_a_out    = 1;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 1;

                //PC selected
                addr_mux_out = 0;

                //ALU->Addition
                alu_op_out   = OP_ALU_ADD;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //ADD_DIR sequence
            //-----

            //Pass incoming data from memory to the main buss
            S_ADD_DIR_0: begin
                //Dont set or inc any registers
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //PC selected
                addr_mux_out = 0;

                //B (mem input) passthrough to main bus
                alu_op_out   = OP_ALU_PASSB;

                //Dont write
                we_out       = 0;
                drive_out    = 0;
            end

            //Latch data to M
            S_ADD_DIR_1: begin
                //Latch M
                set_a_out    = 0;
                set_m_out    = 1;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //PC selected
                addr_mux_out = 0;

                //B (mem input) passthrough to main bus
                alu_op_out   = OP_ALU_PASSB;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //Set addr out to M and prep to add incoming data
            S_ADD_DIR_2: begin
                //Dont set or inc any registers
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //M selected
                addr_mux_out = 1;

                //ALU->Addition
                alu_op_out   = OP_ALU_ADD;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //Latch data to A/CCR
            S_ADD_DIR_3: begin
                //Latch A and CCR
                set_a_out    = 1;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 1;

                //M selected
                addr_mux_out = 1;

                //ALU->Addition
                alu_op_out   = OP_ALU_ADD;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //SUB_IMM sequence
            //-----

            //Subtract the incoming data from the operand that the PC is pointing to
            S_SUB_IMM_0: begin
                //Dont set or inc any registers
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //PC selected
                addr_mux_out = 0;

                //ALU->Subtraction
                alu_op_out   = OP_ALU_SUB;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //Latch data to A/CCR
            S_SUB_IMM_1: begin
                //Latch A and CCR
                set_a_out    = 1;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 1;

                //PC selected
                addr_mux_out = 0;

                //ALU->Subtraction
                alu_op_out   = OP_ALU_SUB;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //SUB_DIR sequence
            //-----

            //Pass incoming data from memory to the main buss
            S_SUB_DIR_0: begin
                //Dont set or inc any registers
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //PC selected
                addr_mux_out = 0;

                //B (mem input) passthrough to main bus
                alu_op_out   = OP_ALU_PASSB;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //Latch data to M
            S_SUB_DIR_1: begin
                //Latch M
                set_a_out    = 0;
                set_m_out    = 1;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //PC selected
                addr_mux_out = 0;

                //B (mem input) passthrough to main bus
                alu_op_out   = OP_ALU_PASSB;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //Set addr out to M and prep to subtract incoming data
            S_SUB_DIR_2: begin
                //Dont set or inc any registers
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //M selected
                addr_mux_out = 1;

                //ALU->Subtraction
                alu_op_out   = OP_ALU_SUB;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //Latch data to A/CCR
            S_SUB_DIR_3: begin
                //Latch A and CCR
                set_a_out    = 1;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 1;

                //M selected
                addr_mux_out = 1;

                //ALU->Subtraction
                alu_op_out   = OP_ALU_SUB;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //AND_IMM sequence
            //-----

            //And the incoming data from the operand that the PC is pointing to
            S_AND_IMM_0: begin
                //Dont set or inc any registers
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //PC selected
                addr_mux_out = 0;

                //ALU->Logical AND
                alu_op_out   = OP_ALU_AND;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //Latch data to A/CCR
            S_AND_IMM_1: begin
                //Latch A and CCR
                set_a_out    = 1;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 1;

                //PC selected
                addr_mux_out = 0;

                //ALU->Logical AND
                alu_op_out   = OP_ALU_AND;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //AND_DIR sequence
            //-----

            //Pass incoming data from memory to the main buss
            S_AND_DIR_0: begin
                //Dont set or inc any registers
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //PC selected
                addr_mux_out = 0;

                //B (mem input) passthrough to main bus
                alu_op_out   = OP_ALU_PASSB;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //Latch data to M
            S_AND_DIR_1: begin
                //Latch M
                set_a_out    = 0;
                set_m_out    = 1;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //PC selected
                addr_mux_out = 0;

                //B (mem input) passthrough to main bus
                alu_op_out   = OP_ALU_PASSB;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //Set addr out to M and prep to AND incoming data
            S_AND_DIR_2: begin
                //Dont set or inc any registers
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //M selected
                addr_mux_out = 1;

                //ALU->Logical AND
                alu_op_out   = OP_ALU_AND;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //Latch data to A/CCR
            S_AND_DIR_3: begin
                //Latch A and CCR
                set_a_out    = 1;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 1;

                //M selected
                addr_mux_out = 1;

                //ALU->Logical AND
                alu_op_out   = OP_ALU_AND;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //OR_IMM sequence
            //-----

            //And the incoming data from the operand that the PC is pointing to
            S_OR_IMM_0: begin
                //Dont set or inc any registers
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //PC selected
                addr_mux_out = 0;

                //ALU->Logical OR
                alu_op_out   = OP_ALU_OR;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //Latch data to A/CCR
            S_OR_IMM_1: begin
                //Latch A and CCR
                set_a_out    = 1;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 1;

                //PC selected
                addr_mux_out = 0;

                //ALU->Logical OR
                alu_op_out   = OP_ALU_OR;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //OR_DIR sequence
            //-----

            //Pass incoming data from memory to the main buss
            S_OR_DIR_0: begin
                //Dont set or inc any registers
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //PC selected
                addr_mux_out = 0;

                //B (mem input) passthrough to main bus
                alu_op_out   = OP_ALU_PASSB;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //Latch data to M
            S_OR_DIR_1: begin
                //Latch M
                set_a_out    = 0;
                set_m_out    = 1;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //PC selected
                addr_mux_out = 0;

                //B (mem input) passthrough to main bus
                alu_op_out   = OP_ALU_PASSB;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //Set addr out to M and prep to OR incoming data
            S_OR_DIR_2: begin
                //Dont set or inc any registers
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //M selected
                addr_mux_out = 1;

                //ALU->Logical OR
                alu_op_out   = OP_ALU_OR;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //Latch data to A/CCR
            S_OR_DIR_3: begin
                //Latch A and CCR
                set_a_out    = 1;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 1;

                //M selected
                addr_mux_out = 1;

                //ALU->Logical OR
                alu_op_out   = OP_ALU_OR;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //XOR_IMM sequence
            //-----

            //And the incoming data from the operand that the PC is pointing to
            S_XOR_IMM_0: begin
                //Dont set or inc any registers
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //PC selected
                addr_mux_out = 0;

                //ALU->Logical XOR
                alu_op_out   = OP_ALU_XOR;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //Latch data to A/CCR
            S_XOR_IMM_1: begin
                //Latch A and CCR
                set_a_out    = 1;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 1;

                //PC selected
                addr_mux_out = 0;

                //ALU->Logical XOR
                alu_op_out   = OP_ALU_XOR;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //XOR_DIR sequence
            //-----

            //Pass incoming data from memory to the main buss
            S_XOR_DIR_0: begin
                //Dont set or inc any registers
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //PC selected
                addr_mux_out = 0;

                //B (mem input) passthrough to main bus
                alu_op_out   = OP_ALU_PASSB;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //Latch data to M
            S_XOR_DIR_1: begin
                //Latch M
                set_a_out    = 0;
                set_m_out    = 1;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //PC selected
                addr_mux_out = 0;

                //B (mem input) passthrough to main bus
                alu_op_out   = OP_ALU_PASSB;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //Set addr out to M and prep to XOR incoming data
            S_XOR_DIR_2: begin
                //Dont set or inc any registers
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //M selected
                addr_mux_out = 1;

                //ALU->Logical XOR
                alu_op_out   = OP_ALU_XOR;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //Latch data to A/CCR
            S_XOR_DIR_3: begin
                //Latch A and CCR
                set_a_out    = 1;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 1;

                //M selected
                addr_mux_out = 1;

                //ALU->Logical XOR
                alu_op_out   = OP_ALU_XOR;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //LSL_IMM sequence
            //-----

            //Add the incoming data from the operand that the PC is pointing to
            S_LSL_IMM_0: begin
                //Dont set or inc any registers
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //PC selected
                addr_mux_out = 0;

                //ALU->Logical Shift Left
                alu_op_out   = OP_ALU_LSL;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //Latch data to A/CCR
            S_LSL_IMM_1: begin
                //Latch A and CCR
                set_a_out    = 1;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 1;

                //PC selected
                addr_mux_out = 0;

                //ALU->Logical Shift Left
                alu_op_out   = OP_ALU_LSL;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //LSL_DIR sequence
            //-----

            //Pass incoming data from memory to the main buss
            S_LSL_DIR_0: begin
                //Dont set or inc any registers
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //PC selected
                addr_mux_out = 0;

                //B (mem input) passthrough to main bus
                alu_op_out   = OP_ALU_PASSB;

                //Dont write
                we_out       = 0;
                drive_out    = 0;
            end

            //Latch data to M
            S_LSL_DIR_1: begin
                //Latch M
                set_a_out    = 0;
                set_m_out    = 1;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //PC selected
                addr_mux_out = 0;

                //B (mem input) passthrough to main bus
                alu_op_out   = OP_ALU_PASSB;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //Set addr out to M and prep to add incoming data
            S_LSL_DIR_2: begin
                //Dont set or inc any registers
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //M selected
                addr_mux_out = 1;

                //ALU->Logical Shift Left
                alu_op_out   = OP_ALU_LSL;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //Latch data to A/CCR
            S_LSL_DIR_3: begin
                //Latch A and CCR
                set_a_out    = 1;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 1;

                //M selected
                addr_mux_out = 1;

                //ALU->Logical Shift Left
                alu_op_out   = OP_ALU_LSL;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //LSR_IMM sequence
            //-----

            //Add the incoming data from the operand that the PC is pointing to
            S_LSR_IMM_0: begin
                //Dont set or inc any registers
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //PC selected
                addr_mux_out = 0;

                //ALU->Logical Shift Right
                alu_op_out   = OP_ALU_LSR;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //Latch data to A/CCR
            S_LSR_IMM_1: begin
                //Latch A and CCR
                set_a_out    = 1;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 1;

                //PC selected
                addr_mux_out = 0;

                //ALU->Logical Shift Right
                alu_op_out   = OP_ALU_LSR;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //LSR_DIR sequence
            //-----

            //Pass incoming data from memory to the main buss
            S_LSR_DIR_0: begin
                //Dont set or inc any registers
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //PC selected
                addr_mux_out = 0;

                //B (mem input) passthrough to main bus
                alu_op_out   = OP_ALU_PASSB;

                //Dont write
                we_out       = 0;
                drive_out    = 0;
            end

            //Latch data to M
            S_LSR_DIR_1: begin
                //Latch M
                set_a_out    = 0;
                set_m_out    = 1;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //PC selected
                addr_mux_out = 0;

                //B (mem input) passthrough to main bus
                alu_op_out   = OP_ALU_PASSB;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //Set addr out to M and prep to add incoming data
            S_LSR_DIR_2: begin
                //Dont set or inc any registers
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //M selected
                addr_mux_out = 1;

                //ALU->Logical Shift Right
                alu_op_out   = OP_ALU_LSR;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //Latch data to A/CCR
            S_LSR_DIR_3: begin
                //Latch A and CCR
                set_a_out    = 1;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 1;

                //M selected
                addr_mux_out = 1;

                //ALU->Logical Shift Right
                alu_op_out   = OP_ALU_LSR;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //ASL_IMM sequence
            //-----

            //Add the incoming data from the operand that the PC is pointing to
            S_ASL_IMM_0: begin
                //Dont set or inc any registers
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //PC selected
                addr_mux_out = 0;

                //ALU->Arithmetic Shift Left
                alu_op_out   = OP_ALU_ASL;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //Latch data to A/CCR
            S_ASL_IMM_1: begin
                //Latch A and CCR
                set_a_out    = 1;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 1;

                //PC selected
                addr_mux_out = 0;

                //ALU->Arithmetic Shift Left
                alu_op_out   = OP_ALU_ASL;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //ASL_DIR sequence
            //-----

            //Pass incoming data from memory to the main buss
            S_ASL_DIR_0: begin
                //Dont set or inc any registers
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //PC selected
                addr_mux_out = 0;

                //B (mem input) passthrough to main bus
                alu_op_out   = OP_ALU_PASSB;

                //Dont write
                we_out       = 0;
                drive_out    = 0;
            end

            //Latch data to M
            S_ASL_DIR_1: begin
                //Latch M
                set_a_out    = 0;
                set_m_out    = 1;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //PC selected
                addr_mux_out = 0;

                //B (mem input) passthrough to main bus
                alu_op_out   = OP_ALU_PASSB;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //Set addr out to M and prep to add incoming data
            S_ASL_DIR_2: begin
                //Dont set or inc any registers
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //M selected
                addr_mux_out = 1;

                //ALU->Arithmetic Shift Left
                alu_op_out   = OP_ALU_ASL;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //Latch data to A/CCR
            S_ASL_DIR_3: begin
                //Latch A and CCR
                set_a_out    = 1;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 1;

                //M selected
                addr_mux_out = 1;

                //ALU->Arithmetic Shift Left
                alu_op_out   = OP_ALU_ASL;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //ASR_IMM sequence
            //-----

            //Add the incoming data from the operand that the PC is pointing to
            S_ASR_IMM_0: begin
                //Dont set or inc any registers
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //PC selected
                addr_mux_out = 0;

                //ALU->Arithmetic Shift Right
                alu_op_out   = OP_ALU_ASR;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //Latch data to A/CCR
            S_ASR_IMM_1: begin
                //Latch A and CCR
                set_a_out    = 1;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 1;

                //PC selected
                addr_mux_out = 0;

                //ALU->Arithmetic Shift Right
                alu_op_out   = OP_ALU_ASR;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //ASR_DIR sequence
            //-----

            //Pass incoming data from memory to the main buss
            S_ASR_DIR_0: begin
                //Dont set or inc any registers
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //PC selected
                addr_mux_out = 0;

                //B (mem input) passthrough to main bus
                alu_op_out   = OP_ALU_PASSB;

                //Dont write
                we_out       = 0;
                drive_out    = 0;
            end

            //Latch data to M
            S_ASR_DIR_1: begin
                //Latch M
                set_a_out    = 0;
                set_m_out    = 1;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //PC selected
                addr_mux_out = 0;

                //B (mem input) passthrough to main bus
                alu_op_out   = OP_ALU_PASSB;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //Set addr out to M and prep to add incoming data
            S_ASR_DIR_2: begin
                //Dont set or inc any registers
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //M selected
                addr_mux_out = 1;

                //ALU->Arithmetic Shift Right
                alu_op_out   = OP_ALU_ASR;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //Latch data to A/CCR
            S_ASR_DIR_3: begin
                //Latch A and CCR
                set_a_out    = 1;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 1;

                //M selected
                addr_mux_out = 1;

                //ALU->Arithmetic Shift Right
                alu_op_out   = OP_ALU_ASR;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //RSL_IMM sequence
            //-----

            //Add the incoming data from the operand that the PC is pointing to
            S_RSL_IMM_0: begin
                //Dont set or inc any registers
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //PC selected
                addr_mux_out = 0;

                //ALU->Rotary Shift Left
                alu_op_out   = OP_ALU_RSL;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //Latch data to A/CCR
            S_RSL_IMM_1: begin
                //Latch A and CCR
                set_a_out    = 1;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 1;

                //PC selected
                addr_mux_out = 0;

                //ALU->Rotary Shift Left
                alu_op_out   = OP_ALU_RSL;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //RSL_DIR sequence
            //-----

            //Pass incoming data from memory to the main buss
            S_RSL_DIR_0: begin
                //Dont set or inc any registers
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //PC selected
                addr_mux_out = 0;

                //B (mem input) passthrough to main bus
                alu_op_out   = OP_ALU_PASSB;

                //Dont write
                we_out       = 0;
                drive_out    = 0;
            end

            //Latch data to M
            S_RSL_DIR_1: begin
                //Latch M
                set_a_out    = 0;
                set_m_out    = 1;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //PC selected
                addr_mux_out = 0;

                //B (mem input) passthrough to main bus
                alu_op_out   = OP_ALU_PASSB;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //Set addr out to M and prep to add incoming data
            S_RSL_DIR_2: begin
                //Dont set or inc any registers
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //M selected
                addr_mux_out = 1;

                //ALU->Rotary Shift Left
                alu_op_out   = OP_ALU_RSL;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //Latch data to A/CCR
            S_RSL_DIR_3: begin
                //Latch A and CCR
                set_a_out    = 1;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 1;

                //M selected
                addr_mux_out = 1;

                //ALU->Rotary Shift Left
                alu_op_out   = OP_ALU_RSL;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //RSR_IMM sequence
            //-----

            //Add the incoming data from the operand that the PC is pointing to
            S_RSR_IMM_0: begin
                //Dont set or inc any registers
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //PC selected
                addr_mux_out = 0;

                //ALU->Rotary Shift Right
                alu_op_out   = OP_ALU_RSR;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //Latch data to A/CCR
            S_RSR_IMM_1: begin
                //Latch A and CCR
                set_a_out    = 1;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 1;

                //PC selected
                addr_mux_out = 0;

                //ALU->Rotary Shift Right
                alu_op_out   = OP_ALU_RSR;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //RSR_DIR sequence
            //-----

            //Pass incoming data from memory to the main buss
            S_RSR_DIR_0: begin
                //Dont set or inc any registers
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //PC selected
                addr_mux_out = 0;

                //B (mem input) passthrough to main bus
                alu_op_out   = OP_ALU_PASSB;

                //Dont write
                we_out       = 0;
                drive_out    = 0;
            end

            //Latch data to M
            S_RSR_DIR_1: begin
                //Latch M
                set_a_out    = 0;
                set_m_out    = 1;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //PC selected
                addr_mux_out = 0;

                //B (mem input) passthrough to main bus
                alu_op_out   = OP_ALU_PASSB;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //Set addr out to M and prep to add incoming data
            S_RSR_DIR_2: begin
                //Dont set or inc any registers
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //M selected
                addr_mux_out = 1;

                //ALU->Rotary Shift Right
                alu_op_out   = OP_ALU_RSR;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //Latch data to A/CCR
            S_RSR_DIR_3: begin
                //Latch A and CCR
                set_a_out    = 1;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 1;

                //M selected
                addr_mux_out = 1;

                //ALU->Rotary Shift Right
                alu_op_out   = OP_ALU_RSR;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //JMP_IMM sequence
            //-----

            //Pass incoming data from memory to the main buss
            S_JMP_IMM_0: begin
                //Dont set or inc any registers
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //PC selected
                addr_mux_out = 0;

                //B (mem input) passthrough to main bus
                alu_op_out   = OP_ALU_PASSB;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //Latch data to PC
            S_JMP_IMM_1: begin
                //Latch PC
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 1;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //PC selected
                addr_mux_out = 0;

                //B (mem input) passthrough to main bus
                alu_op_out   = OP_ALU_PASSB;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //JMP_DIR sequence
            //-----

            //Pass incoming data from memory to the main buss
            S_JMP_DIR_0: begin
                //Dont set or inc any registers
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //PC selected
                addr_mux_out = 0;

                //B (mem input) passthrough to main bus
                alu_op_out   = OP_ALU_PASSB;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //Latch data to M
            S_JMP_DIR_1: begin
                //Latch M
                set_a_out    = 0;
                set_m_out    = 1;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //PC selected
                addr_mux_out = 0;

                //B (mem input) passthrough to main bus
                alu_op_out   = OP_ALU_PASSB;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //Set addr out to M
            S_JMP_DIR_2: begin
                //Dont set or inc any registers
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //M selected
                addr_mux_out = 1;

                //B (mem input) passthrough to main bus
                alu_op_out   = OP_ALU_PASSB;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //Latch data to PC
            S_JMP_DIR_3: begin
                //Latch PC
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 1;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //M selected
                addr_mux_out = 1;

                //B (mem input) passthrough to main bus
                alu_op_out   = OP_ALU_PASSB;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

            //Default (INVALID) sequence
            //-----
            default: begin
                //Dont set or inc any registers
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;
                set_ccr_out  = 0;

                //PC selected
                addr_mux_out = 0;

                //ALU dont care
                alu_op_out   = 0;

                //Dont write or drive
                we_out       = 0;
                drive_out    = 0;
            end

        endcase
    end


    //Next state logic
    //--------------------------
    always @ (curr_state, ir_op_buss_in, ccr_flag_zn_in) begin
        case(curr_state)
            //Reset sequence (skips PC increment on boot)
            S_RESET_0: next_state = S_FETCH_0;

            //PC Increment
            S_PC_INC_0: next_state = S_FETCH_0;

            //Fetch sequence
            S_FETCH_0: next_state = S_FETCH_1;
            S_FETCH_1: next_state = S_FETCH_2;
            S_FETCH_2: next_state = S_DECODE_0;

            //Decode IR Opcode
            S_DECODE_0: begin
                case(ir_op_buss_in)
                    //IR_NOP (does nothing)
                    IR_NOP: next_state = S_FETCH_0;

                    //IR_LDA_IMM (load immediate value to A)
                    IR_LDA_IMM: next_state = S_LDA_IMM_0;

                    //IR_LDA_DIR (load direct value to A)
                    IR_LDA_DIR: next_state = S_LDA_DIR_0;

                    //IR_STA_IMM (store A at immediate address)
                    IR_STA_IMM: next_state = S_STA_IMM_0;

                    //IR_STA_DIR (store A at direct address)
                    IR_STA_DIR: next_state = S_STA_DIR_0;

                    //IR_ADD_IMM (add immediate value to A)
                    IR_ADD_IMM: next_state = S_ADD_IMM_0;

                    //IR_ADD_DIR (add direct value to A)
                    IR_ADD_DIR: next_state = S_ADD_DIR_0;

                    //IR_SUB_IMM (subtract immediate value from A)
                    IR_SUB_IMM: next_state = S_SUB_IMM_0;

                    //IR_SUB_DIR (subtract direct value from A)
                    IR_SUB_DIR: next_state = S_SUB_DIR_0;

                    //IR_AND_IMM (logical AND immediate value with A)
                    IR_AND_IMM: next_state = S_AND_IMM_0;

                    //IR_AND_DIR (logical AND direct value with A)
                    IR_AND_DIR: next_state = S_AND_DIR_0;

                    //IR_OR_IMM (logical OR immediate value with A)
                    IR_OR_IMM: next_state = S_OR_IMM_0;

                    //IR_OR_DIR (logical OR direct value with A)
                    IR_OR_DIR: next_state = S_OR_DIR_0;

                    //IR_XOR_IMM (logical XOR immediate value with A)
                    IR_XOR_IMM: next_state = S_XOR_IMM_0;

                    //IR_XOR_DIR (logical XOR direct value with A)
                    IR_XOR_DIR: next_state = S_XOR_DIR_0;

                    //IR_LSL_IMM (logical left shift immediate value with A)
                    IR_LSL_IMM: next_state = S_LSL_IMM_0;

                    //IR_LSL_DIR (logical left shift direct value with A)
                    IR_LSL_DIR: next_state = S_LSL_DIR_0;

                    //IR_LSR_IMM (logical right shift immediate value with A)
                    IR_LSR_IMM: next_state = S_LSR_IMM_0;

                    //IR_LSR_DIR (logical right shift direct value with A)
                    IR_LSR_DIR: next_state = S_LSR_DIR_0;

                    //IR_ASL_IMM (arithmetic left shift immediate value with A)
                    IR_ASL_IMM: next_state = S_ASL_IMM_0;

                    //IR_ASL_DIR (arithmetic left shift direct value with A)
                    IR_ASL_DIR: next_state = S_ASL_DIR_0;

                    //IR_ASR_IMM (arithmetic right shift immediate value with A)
                    IR_ASR_IMM: next_state = S_ASR_IMM_0;

                    //IR_ASR_DIR (arithmetic right shift direct value with A)
                    IR_ASR_DIR: next_state = S_ASR_DIR_0;

                    //IR_RSL_IMM (rotary left shift immediate value with A)
                    IR_RSL_IMM: next_state = S_RSL_IMM_0;

                    //IR_RSL_DIR (rotary left shift direct value with A)
                    IR_RSL_DIR: next_state = S_RSL_DIR_0;

                    //IR_RSR_IMM (rotary right shift immediate value with A)
                    IR_RSR_IMM: next_state = S_RSR_IMM_0;

                    //IR_RSR_DIR (rotary right shift direct value with A)
                    IR_RSR_DIR: next_state = S_RSR_DIR_0;

                    //IR_JMP_IMM (load immediate value to PC)
                    IR_JMP_IMM: next_state = S_JMP_IMM_0;

                    //IR_LDA_DIR (load direct value to PC)
                    IR_JMP_DIR: next_state = S_JMP_DIR_0;


                    //Invalid IR, goto fetch_0
                    default: next_state = S_FETCH_0;

                endcase
            end

            //LDA_IMM sequence
            S_LDA_IMM_0: next_state = S_LDA_IMM_1;
            S_LDA_IMM_1: next_state = S_PC_INC_0;

            //LDA_DIR sequence
            S_LDA_DIR_0: next_state = S_LDA_DIR_1;
            S_LDA_DIR_1: next_state = S_LDA_DIR_2;
            S_LDA_DIR_2: next_state = S_LDA_DIR_3;
            S_LDA_DIR_3: next_state = S_PC_INC_0;

            //STA_IMM sequence
            S_STA_IMM_0: next_state = S_STA_IMM_1;
            S_STA_IMM_1: next_state = S_STA_IMM_2;
            S_STA_IMM_2: next_state = S_STA_IMM_3;
            S_STA_IMM_3: next_state = S_PC_INC_0;

            //STA_DIR sequence
            S_STA_DIR_0: next_state = S_STA_DIR_1;
            S_STA_DIR_1: next_state = S_STA_DIR_2;
            S_STA_DIR_2: next_state = S_STA_DIR_3;
            S_STA_DIR_3: next_state = S_STA_DIR_4;
            S_STA_DIR_4: next_state = S_STA_DIR_5;
            S_STA_DIR_5: next_state = S_PC_INC_0;

            //ADD_IMM sequence
            S_ADD_IMM_0: next_state = S_ADD_IMM_1;
            S_ADD_IMM_1: next_state = S_PC_INC_0;

            //ADD_DIR sequence
            S_ADD_DIR_0: next_state = S_ADD_DIR_1;
            S_ADD_DIR_1: next_state = S_ADD_DIR_2;
            S_ADD_DIR_2: next_state = S_ADD_DIR_3;
            S_ADD_DIR_3: next_state = S_PC_INC_0;

            //SUB_IMM sequence
            S_SUB_IMM_0: next_state = S_SUB_IMM_1;
            S_SUB_IMM_1: next_state = S_PC_INC_0;

            //SUB_DIR sequence
            S_SUB_DIR_0: next_state = S_SUB_DIR_1;
            S_SUB_DIR_1: next_state = S_SUB_DIR_2;
            S_SUB_DIR_2: next_state = S_SUB_DIR_3;
            S_SUB_DIR_3: next_state = S_PC_INC_0;

            //AND_IMM sequence
            S_AND_IMM_0: next_state = S_AND_IMM_1;
            S_AND_IMM_1: next_state = S_PC_INC_0;

            //AND_DIR sequence
            S_AND_DIR_0: next_state = S_AND_DIR_1;
            S_AND_DIR_1: next_state = S_AND_DIR_2;
            S_AND_DIR_2: next_state = S_AND_DIR_3;
            S_AND_DIR_3: next_state = S_PC_INC_0;

            //OR_IMM sequence
            S_OR_IMM_0: next_state = S_OR_IMM_1;
            S_OR_IMM_1: next_state = S_PC_INC_0;

            //OR_DIR sequence
            S_OR_DIR_0: next_state = S_OR_DIR_1;
            S_OR_DIR_1: next_state = S_OR_DIR_2;
            S_OR_DIR_2: next_state = S_OR_DIR_3;
            S_OR_DIR_3: next_state = S_PC_INC_0;

            //XOR_IMM sequence
            S_XOR_IMM_0: next_state = S_XOR_IMM_1;
            S_XOR_IMM_1: next_state = S_PC_INC_0;

            //XOR_DIR sequence
            S_XOR_DIR_0: next_state = S_XOR_DIR_1;
            S_XOR_DIR_1: next_state = S_XOR_DIR_2;
            S_XOR_DIR_2: next_state = S_XOR_DIR_3;
            S_XOR_DIR_3: next_state = S_PC_INC_0;

            //LSL_IMM sequence
            S_LSL_IMM_0: next_state = S_LSL_IMM_1;
            S_LSL_IMM_1: next_state = S_PC_INC_0;

            //LSL_DIR sequence
            S_LSL_DIR_0: next_state = S_LSL_DIR_1;
            S_LSL_DIR_1: next_state = S_LSL_DIR_2;
            S_LSL_DIR_2: next_state = S_LSL_DIR_3;
            S_LSL_DIR_3: next_state = S_PC_INC_0;

            //LSR_IMM sequence
            S_LSR_IMM_0: next_state = S_LSR_IMM_1;
            S_LSR_IMM_1: next_state = S_PC_INC_0;

            //LSR_DIR sequence
            S_LSR_DIR_0: next_state = S_LSR_DIR_1;
            S_LSR_DIR_1: next_state = S_LSR_DIR_2;
            S_LSR_DIR_2: next_state = S_LSR_DIR_3;
            S_LSR_DIR_3: next_state = S_PC_INC_0;

            //ASL_IMM sequence
            S_ASL_IMM_0: next_state = S_ASL_IMM_1;
            S_ASL_IMM_1: next_state = S_PC_INC_0;

            //ASL_DIR sequence
            S_ASL_DIR_0: next_state = S_ASL_DIR_1;
            S_ASL_DIR_1: next_state = S_ASL_DIR_2;
            S_ASL_DIR_2: next_state = S_ASL_DIR_3;
            S_ASL_DIR_3: next_state = S_PC_INC_0;

            //ASR_IMM sequence
            S_ASR_IMM_0: next_state = S_ASR_IMM_1;
            S_ASR_IMM_1: next_state = S_PC_INC_0;

            //ASR_DIR sequence
            S_ASR_DIR_0: next_state = S_ASR_DIR_1;
            S_ASR_DIR_1: next_state = S_ASR_DIR_2;
            S_ASR_DIR_2: next_state = S_ASR_DIR_3;
            S_ASR_DIR_3: next_state = S_PC_INC_0;

            //RSL_IMM sequence
            S_RSL_IMM_0: next_state = S_RSL_IMM_1;
            S_RSL_IMM_1: next_state = S_PC_INC_0;

            //RSL_DIR sequence
            S_RSL_DIR_0: next_state = S_RSL_DIR_1;
            S_RSL_DIR_1: next_state = S_RSL_DIR_2;
            S_RSL_DIR_2: next_state = S_RSL_DIR_3;
            S_RSL_DIR_3: next_state = S_PC_INC_0;

            //RSR_IMM sequence
            S_RSR_IMM_0: next_state = S_RSR_IMM_1;
            S_RSR_IMM_1: next_state = S_PC_INC_0;

            //RSR_DIR sequence
            S_RSR_DIR_0: next_state = S_RSR_DIR_1;
            S_RSR_DIR_1: next_state = S_RSR_DIR_2;
            S_RSR_DIR_2: next_state = S_RSR_DIR_3;
            S_RSR_DIR_3: next_state = S_PC_INC_0;

            //JMP_IMM sequence
            S_JMP_IMM_0: next_state = S_JMP_IMM_1;
            S_JMP_IMM_1: next_state = S_FETCH_0;

            //JMP_DIR sequence
            S_JMP_DIR_0: next_state = S_JMP_DIR_1;
            S_JMP_DIR_1: next_state = S_JMP_DIR_2;
            S_JMP_DIR_2: next_state = S_JMP_DIR_3;
            S_JMP_DIR_3: next_state = S_FETCH_0;

            //Should never get here
            default:
                next_state = S_PC_INC_0;
        endcase
    end
endmodule
