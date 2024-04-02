/*
 * Copyright (c) 2024 Zachary Frazee
 * SPDX-License-Identifier: Apache-2.0
 */

//--------------------------
//General Register Module
//--------------------------
module minibyte_genreg (
    //Basic Inputs
    input  wire       clk_in, rst_in,

    //Register Inputs
    input  wire [7:0] reg_in,
    input  wire       set_in,

    //Register Outputs
    output reg  [7:0] reg_out
);

    //Main Procedural Block
    //--------------------------
    always @(posedge clk_in or negedge rst_in) begin
        //Reset if rst goes low
        if(!rst_in)
            reg_out <= 0;
        else
            //Set register to input if set signal goes high on a clk
            if(set_in)
                reg_out <= reg_in;
    end
endmodule

//--------------------------
//CCR Register Module
//--------------------------
module minibyte_ccrreg (
    //Basic Inputs
    input  wire       clk_in, rst_in,

    //Register Inputs
    input  wire [1:0] reg_in,
    input  wire       set_in,

    //Register Outputs
    output reg  [1:0] reg_out
);

    //Main Procedural Block
    //--------------------------
    always @(posedge clk_in or negedge rst_in) begin
        //Reset if rst goes low
        if(!rst_in)
            reg_out <= 0;
        else
            //Set register to input if set signal goes high on a clk
            if(set_in)
                reg_out <= reg_in;
    end
endmodule

//---------------------------------
//Program Counter Register Module
//---------------------------------
module minibyte_pcreg (
    //Basic Inputs
    input  wire       clk_in, rst_in,

    //Register Inputs
    input  wire [7:0] reg_in,
    input  wire       set_in,
    input  wire       inc_in,

    //Register Outputs
    output reg  [7:0] reg_out
);

    //Main Procedural Block
    //--------------------------
    always @(posedge clk_in or negedge rst_in) begin
        //Reset if rst goes low
        if(!rst_in)
            reg_out <= 0;
        else
            //Set register to input if set signal goes high
            if(set_in)
                reg_out <= reg_in;

            //Increment register if inc signal goes high on a clk
            else if(inc_in)
                reg_out <= reg_out + 1;
    end
endmodule
