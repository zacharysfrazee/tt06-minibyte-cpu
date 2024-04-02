/*
 * Copyright (c) 2024 Zachary Frazee
 * SPDX-License-Identifier: Apache-2.0
 */

//---------------------------------------------------------------------------------------------------------
// MINIBYTE ALU
//---------------------------------------------------------------------------------------------------------
// OPERATION | ALU_OP | MEANING
//---------------------------------------------------------------------------------------------------------
// PASSA     | 0b0000  | Passthrough input A
// PASSB     | 0b0001  | Passthrough input B
// ADD       | 0b0010  | Add A and B
// SUB       | 0b0011  | Subtract B from A
// AND       | 0b0100  | Logical and of A, B
// OR        | 0b0101  | Logical or of A, B
// XOR       | 0b0110  | Logical xor of A, B
// LSL       | 0b0111  | Logical shift A left by B
// LSR       | 0b1000  | Logical shift A right by B
// ASL       | 0b1001  | Arithmetic shift A left by B
// ASR       | 0b1010  | Arithmetic shift A right by B
// RSL       | 0b1011  | Rotatary shift A left by B
// RSR       | 0b1100  | Rotatary shift A right by B
//---------------------------------------------------------------------------------------------------------

//--------------------------
//Params
//--------------------------
parameter ALU_PASSA  = 4'b0000;
parameter ALU_PASSB  = 4'b0001;
parameter ALU_ADD    = 4'b0010;
parameter ALU_SUB    = 4'b0011;
parameter ALU_AND    = 4'b0100;
parameter ALU_OR     = 4'b0101;
parameter ALU_XOR    = 4'b0110;
parameter ALU_LSL    = 4'b0111;
parameter ALU_LSR    = 4'b1000;
parameter ALU_ASL    = 4'b1001;
parameter ALU_ASR    = 4'b1010;
parameter ALU_RSL    = 4'b1011;
parameter ALU_RSR    = 4'b1100;

//--------------------------
//ALU Module
//--------------------------
module minibyte_alu (
    //ALU Inputs
    input wire signed [7:0] a_in,
    input wire signed [7:0] b_in,
    input wire        [3:0] alu_op_in,

    //ALU Outputs
    output reg signed [7:0] res_out,
    output reg        [1:0] flags_zn_out
);

    //Main Procedural Block
    //--------------------------
    always @(*) begin

        //Assign ALU result
        //---------------------
        case(alu_op_in)

            //A Passthrough
            //--------------
            ALU_PASSA:
                res_out = a_in;

            //B Passthrough
            //--------------
            ALU_PASSB:
                res_out = b_in;

            //Addition
            //--------------
            ALU_ADD:
                res_out = a_in + b_in;

            //Subtraction
            //--------------
            ALU_SUB:
                res_out = a_in - b_in;

            //Logical AND
            //--------------
            ALU_AND:
                res_out = a_in & b_in;

            //Logical OR
            //--------------
            ALU_OR:
                res_out = a_in | b_in;

            //Logical XOR
            //--------------
            ALU_XOR:
                res_out = a_in ^ b_in;

            //Logical Shift Left
            //--------------
            ALU_LSL:
                res_out = a_in << b_in;

            //Logical Shift Right
            //--------------
            ALU_LSR:
                res_out = a_in >> b_in;

            //Arithmetic Shift Left
            //--------------
            ALU_ASL:
                res_out = a_in <<< b_in;

            //Arithmetic Shift Right
            //--------------
            ALU_ASR:
                res_out = a_in >>> b_in;

            //Rotary Shift Left
            //--------------
            ALU_RSL:
                case(b_in[2:0])
                    //Hardcoded concatenations of all possible inputs
                    3'b000:
                        res_out = a_in;
                    3'b001:
                        res_out = {a_in[6:0], a_in[7]};
                    3'b010:
                        res_out = {a_in[5:0], a_in[7:6]};
                    3'b011:
                        res_out = {a_in[4:0], a_in[7:5]};
                    3'b100:
                        res_out = {a_in[3:0], a_in[7:4]};
                    3'b101:
                        res_out = {a_in[2:0], a_in[7:3]};
                    3'b110:
                        res_out = {a_in[1:0], a_in[7:2]};
                    3'b111:
                        res_out = {a_in[0], a_in[7:1]};
                endcase

            //Rotary Shift Right
            //--------------
            ALU_RSR:
                case(b_in[2:0])
                    //Hardcoded concatenations of all possible inputs
                    3'b000:
                        res_out = a_in;
                    3'b001:
                        res_out = {a_in[0], a_in[7:1]};
                    3'b010:
                        res_out = {a_in[1:0], a_in[7:2]};
                    3'b011:
                        res_out = {a_in[2:0], a_in[7:3]};
                    3'b100:
                        res_out = {a_in[3:0], a_in[7:4]};
                    3'b101:
                        res_out = {a_in[4:0], a_in[7:5]};
                    3'b110:
                        res_out = {a_in[5:0], a_in[7:6]};
                    3'b111:
                        res_out = {a_in[6:0], a_in[7]};
                endcase

            //Default (SHOULD NEVER GET HERE)
            //--------------
            default:
                res_out = 0;

        endcase

        //Assign Zero flag
        //---------------------
        if(res_out == 0)
            flags_zn_out[1] = 1;
        else
            flags_zn_out[1] = 0;

        //Assign Negative flag
        //---------------------
        flags_zn_out[0] = res_out[7];

    end

endmodule
