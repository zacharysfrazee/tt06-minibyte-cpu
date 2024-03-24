/*
 * Copyright (c) 2024 Zachary Frazee
 * SPDX-License-Identifier: Apache-2.0
 */

//---------------------------------
//Generic 2->1 Mux Module
//---------------------------------
module minibyte_genmux_2x(
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
        //A out if sel is 0
        if(sel_in == 0)
            mux_out = a_in;
        //B out if sel is 1
        else
            mux_out = b_in;
    end

endmodule


//---------------------------------
//Generic 8->1 Mux Module
//---------------------------------
module minibyte_genmux_8x(
    //Mux Inputs
    input  wire [7:0] a_in,
    input  wire [7:0] b_in,
    input  wire [7:0] c_in,
    input  wire [7:0] d_in,
    input  wire [7:0] e_in,
    input  wire [7:0] f_in,
    input  wire [7:0] g_in,
    input  wire [7:0] h_in,

    //Mux Select
    input  wire [2:0] sel_in,

    //Mux Output
    output reg  [7:0] mux_out
);

    //Main Procedural Block
    //--------------------------
    always @(*) begin
        //A out if sel is 000
        if(sel_in == 3'b000)
            mux_out = a_in;

        //B out if sel is 001
        else if(sel_in == 3'b001)
            mux_out = b_in;

        //C out if sel is 010
        else if(sel_in == 3'b010)
            mux_out = c_in;

        //D out if sel is 011
        else if(sel_in == 3'b011)
            mux_out = d_in;

        //E out if sel is 100
        else if(sel_in == 3'b100)
            mux_out = e_in;

        //F out if sel is 101
        else if(sel_in == 3'b101)
            mux_out = f_in;

        //G out if sel is 110
        else if(sel_in == 3'b110)
            mux_out = g_in;

        //H out if sel is 111
        else
            mux_out = h_in;
    end

endmodule

