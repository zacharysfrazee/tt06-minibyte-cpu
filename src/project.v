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
    //Top Level Singal Notes
    //---------------------------------
    //ui_in          => Test and Configuration bits
    //uo_out         => WE and 7-bit Address Buss
    //uio_in/uio_out => 8-bit Bidirectional Data Buss
    //uio_oe         => Output Enable for Data Buss
    //---------------------------------
    //ui_in (Test)
    //      bit[7:4] => UNUSED
    //      bit[3]   => ENABLE DEMO ROM
    //      bit[2:0] => DEBUG OUTPUT SIGNAL CONTROL
    //                  0 -> Normal        output
    //                  1 -> A             output
    //                  2 -> A (UPPER BIT) output
    //                  3 -> M             output
    //                  4 -> PC            output
    //                  5 -> IR            output
    //                  6 -> CCR           output
    //                  7 -> CU STATE      output
    //---------------------------------
    //uio_in/uio_out
    //      bit[7]   => WE (Write Enable)
    //      bit[6:0] => Address Buss
    //---------------------------------

    //---------------------------------
    //Wires
    //---------------------------------
    wire [6:0] address_buss;
    wire       we_signal;

    wire [7:0] tm_control_bits;

    wire [7:0] data_buss_in;
    wire [7:0] data_buss_out;
    wire [7:0] data_buss_oe;

    wire [7:0] data_buss_rom;

    wire [7:0] data_buss_muxed_in;

    wire drive_enable_sig;
    wire nc_addr_buss_bit_7;

    //---------------------------------
    //Assignments
    //---------------------------------
    assign uo_out[6:0]     = address_buss;
    assign uo_out[7]       = we_signal;

    assign tm_control_bits = ui_in;

    assign data_buss_in    = uio_in;
    assign uio_out         = data_buss_out;
    assign uio_oe          = data_buss_oe;


    //---------------------------------
    //Minibyte CPU
    //---------------------------------
    minibyte_cpu cpu(
        //Basic Inputs
        .clk_in(clk), .ena_in(ena), .rst_in(rst_n),

        //Memory and IO Inputs
        .data_in(data_buss_muxed_in),

        //DFT Inputs
        .tm_control(tm_control_bits),

        //Memory and IO Outputs
        .addr_out   ({nc_addr_buss_bit_7,address_buss}),  //Only 7 bits get connected as we need to save one output for WE below:(
        .data_out   (data_buss_out),
        .we_out     (we_signal),                          //Dedicated output bit 7 gets used for WE
        .drive_out  (drive_enable_sig)
    );

    //---------------------------------
    //Input Device MUX
    //---------------------------------
    minibyte_genmux_4x input_mux(
        //Mux Inputs
        .a_in(data_buss_in),
        .b_in(data_buss_rom),
        .c_in(8'h00),
        .d_in(8'h00),

        //Mux Select
        .sel_in({1'b0,tm_control_bits[3]}),

        //Mux Output
        .mux_out(data_buss_muxed_in)
    );

    //---------------------------------
    //Demo ROM
    //---------------------------------
    demo_rom_32B rom(
        //Input Addr and Enable
        .address(address_buss[4:0]), //Lower 5 addr buss bits

        //Output Data
        .data_out(data_buss_rom)
    );

    //---------------------------------
    //Output enable control
    //---------------------------------
    drive_enable_fanout oe_driver(
        //Drive enable input signal
        .drive_en(drive_enable_sig),

        //Output drive signals
        .drive(data_buss_oe)
    );

endmodule
