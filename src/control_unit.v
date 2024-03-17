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
    input  wire       alu_flag_z_in,
    input  wire       alu_flag_n_in,

    //Control signal outputs
    output reg        set_a_out,
    output reg        set_m_out,
    output reg        set_pc_out,
    output reg        set_ir_out,
    output reg        inc_pc_out,

    //Addr select signals
    output reg        addr_mux_out,

    //Alu control signals
    output reg [2:0]  alu_op_out,

    //Write to memory
    output reg        we_out
);

    //State machine memory
    //--------------------------
    reg [7:0] curr_state, next_state;


    //CPU IR opcodes
    //--------------------------
    parameter IR_NOP     = 0;
    parameter IR_LDA_IMM = 1;
    parameter IR_LDA_DIR = 2;
    parameter IR_ADD_IMM = 3;
    parameter IR_ADD_DIR = 4;
    parameter IR_SUB_IMM = 5;
    parameter IR_SUB_DIR = 6;
    parameter IR_AND_IMM = 7;
    parameter IR_AND_DIR = 8;
    parameter IR_OR_IMM  = 9;
    parameter IR_OR_DIR  = 10;
    parameter IR_XOR_IMM = 11;
    parameter IR_XOR_DIR = 12;


    //State machine opcodes
    //--------------------------
    parameter S_RESET_0   = 0;

    parameter S_FETCH_0   = 1;
    parameter S_FETCH_1   = 2;
    parameter S_FETCH_2   = 3;

    parameter S_DECODE_0  = 4;

    parameter S_LDA_IMM_0 = 5;
    parameter S_LDA_IMM_1 = 6;

    parameter S_LDA_DIR_0 = 7;
    parameter S_LDA_DIR_1 = 8;
    parameter S_LDA_DIR_2 = 9;
    parameter S_LDA_DIR_3 = 10;

    parameter S_ADD_IMM_0 = 11;
    parameter S_ADD_IMM_1 = 12;

    parameter S_ADD_DIR_0 = 13;
    parameter S_ADD_DIR_1 = 14;
    parameter S_ADD_DIR_2 = 15;
    parameter S_ADD_DIR_3 = 16;

    parameter S_SUB_IMM_0 = 17;
    parameter S_SUB_IMM_1 = 18;

    parameter S_SUB_DIR_0 = 19;
    parameter S_SUB_DIR_1 = 20;
    parameter S_SUB_DIR_2 = 21;
    parameter S_SUB_DIR_3 = 22;

    parameter S_AND_IMM_0 = 23;
    parameter S_AND_IMM_1 = 24;

    parameter S_AND_DIR_0 = 25;
    parameter S_AND_DIR_1 = 26;
    parameter S_AND_DIR_2 = 27;
    parameter S_AND_DIR_3 = 28;

    parameter S_OR_IMM_0  = 29;
    parameter S_OR_IMM_1  = 30;

    parameter S_OR_DIR_0  = 31;
    parameter S_OR_DIR_1  = 32;
    parameter S_OR_DIR_2  = 33;
    parameter S_OR_DIR_3  = 34;

    parameter S_XOR_IMM_0 = 35;
    parameter S_XOR_IMM_1 = 36;

    parameter S_XOR_DIR_0 = 37;
    parameter S_XOR_DIR_1 = 38;
    parameter S_XOR_DIR_2 = 39;
    parameter S_XOR_DIR_3 = 40;

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

                //PC selected
                addr_mux_out = 0;

                //ALU dont care
                alu_op_out   = 0;

                //Dont write
                we_out       = 0;
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

                //PC selected
                addr_mux_out = 0;

                //B (mem input) passthrough to main bus
                alu_op_out   = 3'b001;

                //Dont write
                we_out       = 0;
            end

            //Load IR from memory
            S_FETCH_1: begin
                //Set IR Reg
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 1;

                //PC selected
                addr_mux_out = 0;

                //B (mem input) passthrough to main bus
                alu_op_out   = 3'b001;

                //Dont write
                we_out       = 0;
            end

            //Inc PC now that IR is loaded
            S_FETCH_2: begin
                //Inc PC
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 1;
                set_ir_out   = 0;

                //PC selected
                addr_mux_out = 0;

                //B (mem input) passthrough to main bus
                alu_op_out   = 3'b001;

                //Dont write
                we_out       = 0;
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

                //PC selected
                addr_mux_out = 0;

                //ALU dont care
                alu_op_out   = 0;

                //Dont write
                we_out       = 0;
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

                //PC selected
                addr_mux_out = 0;

                //B (mem input) passthrough to main bus
                alu_op_out   = 3'b001;

                //Dont write
                we_out       = 0;
            end

            //Latch data to A and inc PC
            S_LDA_IMM_1: begin
                //Latch A + Inc PC
                set_a_out    = 1;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 1;
                set_ir_out   = 0;

                //PC selected
                addr_mux_out = 0;

                //B (mem input) passthrough to main bus
                alu_op_out   = 3'b001;

                //Dont write
                we_out       = 0;
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

                //PC selected
                addr_mux_out = 0;

                //B (mem input) passthrough to main bus
                alu_op_out   = 3'b001;

                //Dont write
                we_out       = 0;
            end

            //Latch data to M
            S_LDA_DIR_1: begin
                //Latch M
                set_a_out    = 0;
                set_m_out    = 1;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;

                //PC selected
                addr_mux_out = 0;

                //B (mem input) passthrough to main bus
                alu_op_out   = 3'b001;

                //Dont write
                we_out       = 0;
            end

            //Set addr out to M
            S_LDA_DIR_2: begin
                //Dont set or inc any registers
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;

                //M selected
                addr_mux_out = 1;

                //B (mem input) passthrough to main bus
                alu_op_out   = 3'b001;

                //Dont write
                we_out       = 0;
            end

            //Latch data to A and inc PC
            S_LDA_DIR_3: begin
                //Latch A + Inc PC
                set_a_out    = 1;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 1;
                set_ir_out   = 0;

                //M selected
                addr_mux_out = 1;

                //B (mem input) passthrough to main bus
                alu_op_out   = 3'b001;

                //Dont write
                we_out       = 0;
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

                //PC selected
                addr_mux_out = 0;

                //ALU->Addition
                alu_op_out   = 3'b010;

                //Dont write
                we_out       = 0;
            end

            //Latch data to A and inc PC
            S_ADD_IMM_1: begin
                //Latch A + Inc PC
                set_a_out    = 1;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 1;
                set_ir_out   = 0;

                //PC selected
                addr_mux_out = 0;

                //ALU->Addition
                alu_op_out   = 3'b010;

                //Dont write
                we_out       = 0;
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

                //PC selected
                addr_mux_out = 0;

                //B (mem input) passthrough to main bus
                alu_op_out   = 3'b001;

                //Dont write
                we_out       = 0;
            end

            //Latch data to M
            S_ADD_DIR_1: begin
                //Latch M
                set_a_out    = 0;
                set_m_out    = 1;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;

                //PC selected
                addr_mux_out = 0;

                //B (mem input) passthrough to main bus
                alu_op_out   = 3'b001;

                //Dont write
                we_out       = 0;
            end

            //Set addr out to M and prep to add incoming data
            S_ADD_DIR_2: begin
                //Dont set or inc any registers
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;

                //M selected
                addr_mux_out = 1;

                //ALU->Addition
                alu_op_out   = 3'b010;

                //Dont write
                we_out       = 0;
            end

            //Latch data to A and inc PC
            S_ADD_DIR_3: begin
                //Latch A + Inc PC
                set_a_out    = 1;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 1;
                set_ir_out   = 0;

                //M selected
                addr_mux_out = 1;

                //ALU->Addition
                alu_op_out   = 3'b010;

                //Dont write
                we_out       = 0;
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

                //PC selected
                addr_mux_out = 0;

                //ALU->Subtraction
                alu_op_out   = 3'b011;

                //Dont write
                we_out       = 0;
            end

            //Latch data to A and inc PC
            S_SUB_IMM_1: begin
                //Latch A + Inc PC
                set_a_out    = 1;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 1;
                set_ir_out   = 0;

                //PC selected
                addr_mux_out = 0;

                //ALU->Subtraction
                alu_op_out   = 3'b011;

                //Dont write
                we_out       = 0;
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

                //PC selected
                addr_mux_out = 0;

                //B (mem input) passthrough to main bus
                alu_op_out   = 3'b001;

                //Dont write
                we_out       = 0;
            end

            //Latch data to M
            S_SUB_DIR_1: begin
                //Latch M
                set_a_out    = 0;
                set_m_out    = 1;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;

                //PC selected
                addr_mux_out = 0;

                //B (mem input) passthrough to main bus
                alu_op_out   = 3'b001;

                //Dont write
                we_out       = 0;
            end

            //Set addr out to M and prep to subtract incoming data
            S_SUB_DIR_2: begin
                //Dont set or inc any registers
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;

                //M selected
                addr_mux_out = 1;

                //ALU->Subtraction
                alu_op_out   = 3'b011;

                //Dont write
                we_out       = 0;
            end

            //Latch data to A and inc PC
            S_SUB_DIR_3: begin
                //Latch A + Inc PC
                set_a_out    = 1;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 1;
                set_ir_out   = 0;

                //M selected
                addr_mux_out = 1;

                //ALU->Subtraction
                alu_op_out   = 3'b011;

                //Dont write
                we_out       = 0;
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

                //PC selected
                addr_mux_out = 0;

                //ALU->Logical AND
                alu_op_out   = 3'b100;

                //Dont write
                we_out       = 0;
            end

            //Latch data to A and inc PC
            S_AND_IMM_1: begin
                //Latch A + Inc PC
                set_a_out    = 1;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 1;
                set_ir_out   = 0;

                //PC selected
                addr_mux_out = 0;

                //ALU->Logical AND
                alu_op_out   = 3'b100;

                //Dont write
                we_out       = 0;
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

                //PC selected
                addr_mux_out = 0;

                //B (mem input) passthrough to main bus
                alu_op_out   = 3'b001;

                //Dont write
                we_out       = 0;
            end

            //Latch data to M
            S_AND_DIR_1: begin
                //Latch M
                set_a_out    = 0;
                set_m_out    = 1;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;

                //PC selected
                addr_mux_out = 0;

                //B (mem input) passthrough to main bus
                alu_op_out   = 3'b001;

                //Dont write
                we_out       = 0;
            end

            //Set addr out to M and prep to AND incoming data
            S_AND_DIR_2: begin
                //Dont set or inc any registers
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;

                //M selected
                addr_mux_out = 1;

                //ALU->Logical AND
                alu_op_out   = 3'b100;

                //Dont write
                we_out       = 0;
            end

            //Latch data to A and inc PC
            S_AND_DIR_3: begin
                //Latch A + Inc PC
                set_a_out    = 1;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 1;
                set_ir_out   = 0;

                //M selected
                addr_mux_out = 1;

                //ALU->Logical AND
                alu_op_out   = 3'b100;

                //Dont write
                we_out       = 0;
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

                //PC selected
                addr_mux_out = 0;

                //ALU->Logical OR
                alu_op_out   = 3'b101;

                //Dont write
                we_out       = 0;
            end

            //Latch data to A and inc PC
            S_OR_IMM_1: begin
                //Latch A + Inc PC
                set_a_out    = 1;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 1;
                set_ir_out   = 0;

                //PC selected
                addr_mux_out = 0;

                //ALU->Logical OR
                alu_op_out   = 3'b101;

                //Dont write
                we_out       = 0;
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

                //PC selected
                addr_mux_out = 0;

                //B (mem input) passthrough to main bus
                alu_op_out   = 3'b001;

                //Dont write
                we_out       = 0;
            end

            //Latch data to M
            S_OR_DIR_1: begin
                //Latch M
                set_a_out    = 0;
                set_m_out    = 1;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;

                //PC selected
                addr_mux_out = 0;

                //B (mem input) passthrough to main bus
                alu_op_out   = 3'b001;

                //Dont write
                we_out       = 0;
            end

            //Set addr out to M and prep to OR incoming data
            S_OR_DIR_2: begin
                //Dont set or inc any registers
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;

                //M selected
                addr_mux_out = 1;

                //ALU->Logical OR
                alu_op_out   = 3'b101;

                //Dont write
                we_out       = 0;
            end

            //Latch data to A and inc PC
            S_OR_DIR_3: begin
                //Latch A + Inc PC
                set_a_out    = 1;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 1;
                set_ir_out   = 0;

                //M selected
                addr_mux_out = 1;

                //ALU->Logical OR
                alu_op_out   = 3'b101;

                //Dont write
                we_out       = 0;
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

                //PC selected
                addr_mux_out = 0;

                //ALU->Logical XOR
                alu_op_out   = 3'b110;

                //Dont write
                we_out       = 0;
            end

            //Latch data to A and inc PC
            S_XOR_IMM_1: begin
                //Latch A + Inc PC
                set_a_out    = 1;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 1;
                set_ir_out   = 0;

                //PC selected
                addr_mux_out = 0;

                //ALU->Logical XOR
                alu_op_out   = 3'b110;

                //Dont write
                we_out       = 0;
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

                //PC selected
                addr_mux_out = 0;

                //B (mem input) passthrough to main bus
                alu_op_out   = 3'b001;

                //Dont write
                we_out       = 0;
            end

            //Latch data to M
            S_XOR_DIR_1: begin
                //Latch M
                set_a_out    = 0;
                set_m_out    = 1;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;

                //PC selected
                addr_mux_out = 0;

                //B (mem input) passthrough to main bus
                alu_op_out   = 3'b001;

                //Dont write
                we_out       = 0;
            end

            //Set addr out to M and prep to XOR incoming data
            S_XOR_DIR_2: begin
                //Dont set or inc any registers
                set_a_out    = 0;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 0;
                set_ir_out   = 0;

                //M selected
                addr_mux_out = 1;

                //ALU->Logical XOR
                alu_op_out   = 3'b110;

                //Dont write
                we_out       = 0;
            end

            //Latch data to A and inc PC
            S_XOR_DIR_3: begin
                //Latch A + Inc PC
                set_a_out    = 1;
                set_m_out    = 0;
                set_pc_out   = 0;
                inc_pc_out   = 1;
                set_ir_out   = 0;

                //M selected
                addr_mux_out = 1;

                //ALU->Logical XOR
                alu_op_out   = 3'b110;

                //Dont write
                we_out       = 0;
            end

        endcase
    end


    //Next state logic
    //--------------------------
    always @ (curr_state, ir_op_buss_in, alu_flag_n_in, alu_flag_z_in) begin
        case(curr_state)
            //Reset sequence
            S_RESET_0: next_state = S_FETCH_0;

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

                endcase
            end

            //LDA_IMM sequence
            S_LDA_IMM_0: next_state = S_LDA_IMM_1;
            S_LDA_IMM_1: next_state = S_FETCH_0;

            //LDA_DIR sequence
            S_LDA_DIR_0: next_state = S_LDA_DIR_1;
            S_LDA_DIR_1: next_state = S_LDA_DIR_2;
            S_LDA_DIR_2: next_state = S_LDA_DIR_3;
            S_LDA_DIR_3: next_state = S_FETCH_0;

            //ADD_IMM sequence
            S_ADD_IMM_0: next_state = S_ADD_IMM_1;
            S_ADD_IMM_1: next_state = S_FETCH_0;

            //ADD_DIR sequence
            S_ADD_DIR_0: next_state = S_ADD_DIR_1;
            S_ADD_DIR_1: next_state = S_ADD_DIR_2;
            S_ADD_DIR_2: next_state = S_ADD_DIR_3;
            S_ADD_DIR_3: next_state = S_FETCH_0;

            //SUB_IMM sequence
            S_SUB_IMM_0: next_state = S_SUB_IMM_1;
            S_SUB_IMM_1: next_state = S_FETCH_0;

            //SUB_DIR sequence
            S_SUB_DIR_0: next_state = S_SUB_DIR_1;
            S_SUB_DIR_1: next_state = S_SUB_DIR_2;
            S_SUB_DIR_2: next_state = S_SUB_DIR_3;
            S_SUB_DIR_3: next_state = S_FETCH_0;

            //AND_IMM sequence
            S_AND_IMM_0: next_state = S_AND_IMM_1;
            S_AND_IMM_1: next_state = S_FETCH_0;

            //AND_DIR sequence
            S_AND_DIR_0: next_state = S_AND_DIR_1;
            S_AND_DIR_1: next_state = S_AND_DIR_2;
            S_AND_DIR_2: next_state = S_AND_DIR_3;
            S_AND_DIR_3: next_state = S_FETCH_0;

            //OR_IMM sequence
            S_OR_IMM_0: next_state = S_OR_IMM_1;
            S_OR_IMM_1: next_state = S_FETCH_0;

            //OR_DIR sequence
            S_OR_DIR_0: next_state = S_OR_DIR_1;
            S_OR_DIR_1: next_state = S_OR_DIR_2;
            S_OR_DIR_2: next_state = S_OR_DIR_3;
            S_OR_DIR_3: next_state = S_FETCH_0;

            //XOR_IMM sequence
            S_XOR_IMM_0: next_state = S_XOR_IMM_1;
            S_XOR_IMM_1: next_state = S_FETCH_0;

            //XOR_DIR sequence
            S_XOR_DIR_0: next_state = S_XOR_DIR_1;
            S_XOR_DIR_1: next_state = S_XOR_DIR_2;
            S_XOR_DIR_2: next_state = S_XOR_DIR_3;
            S_XOR_DIR_3: next_state = S_FETCH_0;

            //Should never get here
            default:
                next_state = S_FETCH_0;
        endcase
    end
endmodule
