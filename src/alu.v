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
// ASR       | 0b1002  | Arithmetic shift A right by B
//---------------------------------------------------------------------------------------------------------

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
    output reg              flag_z_out,
    output reg              flag_n_out
);

    //Main Procedural Block
    //--------------------------
    always @(*) begin

        //Assign ALU result
        //---------------------
        case(alu_op_in)

            //A Passthrough
            //--------------
            4'b0000:
                res_out = a_in;

            //B Passthrough
            //--------------
            4'b0001:
                res_out = b_in;

            //Addition
            //--------------
            4'b0010:
                res_out = a_in + b_in;

            //Subtraction
            //--------------
            4'b0011:
                res_out = a_in - b_in;

            //Logical AND
            //--------------
            4'b0100:
                res_out = a_in & b_in;

            //Logical OR
            //--------------
            4'b0101:
                res_out = a_in | b_in;

            //Logical XOR
            //--------------
            4'b0110:
                res_out = a_in ^ b_in;

            //Logical Shift Left
            //--------------
            4'b0111:
                res_out = a_in << b_in;

            //Logical Shift Right
            //--------------
            4'b1000:
                res_out = a_in >> b_in;

            //Arithmetic Shift Left
            //--------------
            4'b1001:
                res_out = a_in <<< b_in;

            //Arithmetic Shift Right
            //--------------
            4'b1010:
                res_out = a_in >>> b_in;


            //Default (SHOULD NEVER GET HERE)
            //--------------
            default:
                res_out = 0;

        endcase

        //Assign Zero flag
        //---------------------
        if(res_out == 0)
            flag_z_out = 1;
        else
            flag_z_out = 0;

        //Assign Negative flag
        //---------------------
        flag_n_out = res_out[7];

    end

endmodule
