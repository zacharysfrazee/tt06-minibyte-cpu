/*
 * Copyright (c) 2024 Zachary Frazee
 * SPDX-License-Identifier: Apache-2.0
 */

//---------------------------------
//Generic Mux Module
//---------------------------------
module minibyte_genmux(
    //Mux Inputs
    input  wire [7:0] a_in,
    input  wire [7:0] b_in,
    input  wire [7:0] c_in,
    input  wire [7:0] d_in,

    //Mux Select
    input  wire [1:0] sel_in,

    //Mux Output
    output reg  [7:0] mux_out
);

    //Main Procedural Block
    //--------------------------
    always @(*) begin
        //A out if sel is 00
        if(sel_in == 0)
            mux_out = a_in;

        //B out if sel is 01
        else if(sel_in == 1)
            mux_out = b_in;

        //C out if sel is 10
        else if(sel_in == 2)
            mux_out = c_in;

        //D out if sel is 11
        else
            mux_out = d_in;
    end

endmodule
