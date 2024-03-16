/*
 * Copyright (c) 2024 Zachary Frazee
 * SPDX-License-Identifier: Apache-2.0
 */

`define default_netname none

//---------------------------------
//Top Level Project Module
//---------------------------------
module tt_um_minibyte (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    //---------------------------------
    //Minibyte CPU
    //---------------------------------
    minibyte_cpu cpu(
        //Basic Inputs
        .clk_in(clk_in), .rst_in(rst_in),

        //Memory and IO Inputs
        .data_in(uio_in),

        //Memory and IO Outputs
        .addr_out(uo_out),
        .data_out(uio_out),
        .we_out  (uio_oe[0])
    );

    assign uio_oe[7:1] = 0;

    // All output pins must be assigned. If not used, assign to 0.
    //assign uo_out  = ui_in + uio_in;  // Example: ou_out is the sum of ui_in and uio_in
    //assign uio_out = 0;
    //assign uio_oe  = 0;

endmodule
