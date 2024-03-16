/*
 * Copyright (c) 2024 Zachary Frazee
 * SPDX-License-Identifier: Apache-2.0
 */

`define default_netname none

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

  //Temp dummy wire up ALU
  minibyte_alu alu(
    .a_in(ui_in),
    .b_in(uio_in),
    .alu_op_in(uio_in[2:0]),
    .res_out(uo_out),
    .flag_z_out(uio_out[0]),
    .flag_n_out(uio_out[1])
  );

  assign uio_out[7:2] = 0;
  assign uio_oe       = 'hff;

  // All output pins must be assigned. If not used, assign to 0.
  //assign uo_out  = ui_in + uio_in;  // Example: ou_out is the sum of ui_in and uio_in
  //assign uio_out = 0;
  //assign uio_oe  = 0;

endmodule
