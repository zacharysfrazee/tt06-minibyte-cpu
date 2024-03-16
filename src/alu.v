/*
 * Copyright (c) 2024 Zachary Frazee
 * SPDX-License-Identifier: Apache-2.0
 */

//---------------------------------------------------------------------------------------------------------
//MINIBYTE ALU
//---------------------------------------------------------------------------------------------------------
// OPERATION | ALU_OP | MEANING
//---------------------------------------------------------------------------------------------------------
// PASSA     | 0b000  | Passthrough input A
// PASSB     | 0b001  | Passthrough input B
// PASSB     | 0b010  | Add A and B
// PASSB     | 0b011  | Subtract B from A
// PASSB     | 0b100  | Logical and of A, B
// PASSB     | 0b101  | Logical or of A, B
// PASSB     | 0b110  | Logical xor of A, B
// PASSB     | 0b111  | Rotate 1 bit based on sign of B (left if B is positive, right if B is negative)
//---------------------------------------------------------------------------------------------------------

//--------------------------
//ALU Module
//--------------------------
module minibyte_alu (
    input  wire [7:0] a_in,
    input  wire [7:0] b_in,
    input  wire [2:0] alu_op_in,
    output reg  [7:0] res_out,
    output reg        flag_z_out,
    output reg        flag_n_out
);

    //Main Procedural block
    //--------------------------
    always @(*) begin

        //Assign ALU result
        //---------------------
        case(alu_op_in)

            //A Passthrough
            //--------------
            3'b000:
                res_out = a_in;

            //B Passthrough
            //--------------
            3'b001:
                res_out = b_in;

            //Addition
            //--------------
            3'b010:
                res_out = a_in + b_in;

            //Subtraction
            //--------------
            3'b011:
                res_out = a_in - b_in;

            //Logical AND
            //--------------
            3'b100:
                res_out = a_in & b_in;

            //Logical OR
            //--------------
            3'b101:
                res_out = a_in | b_in;

            //Logical XOR
            //--------------
            3'b110:
                res_out = a_in ^ b_in;

            //Rotate left by 1 bit based on sign of B
            //--------------
            3'b111:
                //Rotate right if B is negative
                if(b_in[7] == 1)
                    res_out = (a_in << 1) | (a_in >> 7);
                //Rotate left otherwise
                else
                    res_out = (a_in >> 1) | (a_in << 7);

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