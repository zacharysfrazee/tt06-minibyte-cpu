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

    //Mux Select
    input  wire       sel_in,

    //Mux Output
    output reg  [7:0] mux_out
);

    //Main Procedural Block
    //--------------------------
    always @(*) begin
        //A out if sel is low
        if(!sel_in)
            mux_out = a_in;

        //B out if sel is high
        else
            mux_out = b_in;
    end

endmodule