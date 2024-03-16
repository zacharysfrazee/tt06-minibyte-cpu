/*
 * Copyright (c) 2024 Zachary Frazee
 * SPDX-License-Identifier: Apache-2.0
 */

//---------------------------------
//Top Level CPU Module
//---------------------------------
module minibyte_cpu (
    //Basic Inputs
    input  wire       clk_in, rst_in,

    //Memory and IO Inputs
    input  wire [7:0] data_in,

    //Memory and IO Outputs
    output wire [7:0] addr_out,
    output wire [7:0] data_out,
    output wire       we_out
);

    //Main Data Buss
    //--------------------------------
    wire [7:0] main_buss;

    //ALU A-Side Input Data Buss
    //--------------------------------
    wire [7:0] alu_a_buss;


    //Address Busses
    //--------------------------------
    wire [7:0] m_addr_buss;
    wire [7:0] pc_addr_buss;

    //Control Signals
    //--------------------------------

    //Set register signals
    wire ctrl_set_a;
    wire ctrl_set_m;
    wire ctrl_set_pc;

    //Inc register signals
    wire ctrl_inc_oc;

    //A Register
    //--------------------------------
    minibyte_genreg reg_a(
        //Basic Inputs
        .clk_in(clk_in), .rst_in(rst_in),

        //Register Inputs
        .reg_in(main_buss),
        .set_in(ctrl_set_a),

        //Register Outputs
        .reg_out(alu_a_buss)
    );

    //M Register
    //--------------------------------
    minibyte_genreg reg_m(
        //Basic Inputs
        .clk_in(clk_in), .rst_in(rst_in),

        //Register Inputs
        .reg_in(main_buss),
        .set_in(ctrl_set_m),

        //Register Outputs
        .reg_out(m_addr_buss)
    );

    //PC Register
    //--------------------------------
    minibyte_pcreg reg_pc(
        //Basic Inputs
        .clk_in(clk_in), .rst_in(rst_in),

        //Register Inputs
        .reg_in(main_buss),
        .set_in(ctrl_set_pc),
        .inc_in(ctrl_inc_oc),

        //Register Outputs
        .reg_out(pc_addr_buss)
    );

endmodule