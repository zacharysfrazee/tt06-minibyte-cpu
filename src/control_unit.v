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

            //Should never get here
            default:
                next_state = S_FETCH_0;
        endcase
    end
endmodule
