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
    //Wires
    //---------------------------------
    wire drive_enable_sig;
    wire nc_addr_bus_bit_7;

    //---------------------------------
    //Minibyte CPU
    //---------------------------------
    minibyte_cpu cpu(
        //Basic Inputs
        .clk_in(clk), .rst_in(rst_n),

        //Memory and IO Inputs
        .data_in(uio_in),

        //DFT Inputs
        .tm_control(ui_in),

        //Memory and IO Outputs
        .addr_out   ({nc_addr_bus_bit_7,uo_out[6:0]}),  //Only 7 bits get connected as we need to save one output for WE below:(
        .data_out   (uio_out),
        .we_out     (uo_out[7]),                        //Dedicated output bit 7 gets used for WE
        .drive_out  (drive_enable_sig)
    );

    //---------------------------------
    //Output enable control
    //---------------------------------
    drive_enable_fanout oe_driver(
        //Drive enable input signal
        .drive_en(drive_enable_sig),

        //Output drive signals
        .drive(uio_oe)
    );

endmodule
