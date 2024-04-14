/*
 * Copyright (c) 2024 Zachary Frazee
 * SPDX-License-Identifier: Apache-2.0
 */

//---------------------------------
//Top Level CPU Module
//---------------------------------
module minibyte_cpu (
    //Basic Inputs
    input  wire       clk_in, ena_in, rst_in,

    //Memory and IO Inputs
    input  wire [7:0] data_in,

    //DFT Testmode Inputs
    input  wire [7:0] tm_control,

    //Memory and IO Outputs
    output wire [7:0] addr_out,
    output wire [7:0] data_out,
    output wire       we_out,
    output wire       drive_out
);

    //Main Data Buss
    //--------------------------------
    wire [7:0] main_buss;

    //Data out comes from the main buss
    assign data_out = main_buss;


    //ALU A-Side Input Data Buss
    //--------------------------------
    wire [7:0] alu_a_buss;


    //Address Busses
    //--------------------------------
    wire [7:0] m_addr_buss;
    wire [7:0] pc_addr_buss;
    wire [7:0] ir_op_buss;
    wire [7:0] normal_addr_out;

    //DFT Wires
    //--------------------------------
    wire [7:0] dft_cu_state;

    //Control Signals
    //--------------------------------

    //Set register signals
    wire ctrl_set_a;
    wire ctrl_set_m;
    wire ctrl_set_pc;
    wire ctrl_set_ir;
    wire ctrl_set_ccr;

    //Inc register signals
    wire ctrl_inc_pc;

    //Addr mux signals
    wire       ctrl_addr_mux;

    //Alu control signals
    wire [3:0] ctrl_alu_op;

    //Data direction control
    wire   ctrl_we_out;
    wire   ctrl_drive_out;
    assign we_out=ctrl_we_out;
    assign drive_out=ctrl_drive_out;


    //Branch Signals
    //--------------------------------
    wire [1:0] flags_zn_buss;
    wire [1:0] ccr_zn_buss;


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
        .inc_in(ctrl_inc_pc),

        //Register Outputs
        .reg_out(pc_addr_buss)
    );


    //IR Register
    //--------------------------------
    minibyte_genreg reg_ir(
        //Basic Inputs
        .clk_in(clk_in), .rst_in(rst_in),

        //Register Inputs
        .reg_in(main_buss),
        .set_in(ctrl_set_ir),

        //Register Outputs
        .reg_out(ir_op_buss)
    );


    //CCR Register
    //--------------------------------
    minibyte_ccrreg reg_ccr(
        //Basic Inputs
        .clk_in(clk_in), .rst_in(rst_in),

        //Register Inputs
        .reg_in(flags_zn_buss),
        .set_in(ctrl_set_ccr),

        //Register Outputs
        .reg_out(ccr_zn_buss)
    );


    //Addr Out Mux
    //--------------------------------
    minibyte_genmux_2x addr_mux(
        //Mux Inputs
        .a_in(pc_addr_buss),
        .b_in(m_addr_buss),

        //Mux Select
        .sel_in(ctrl_addr_mux),

        //Mux Output
        .mux_out(normal_addr_out)
    );


    //Debug Out Mux
    //--------------------------------
    minibyte_genmux_8x tm_debug_out_mux(
        //Mux Inputs
        .a_in(normal_addr_out),        //0 -> Normal        output
        .b_in(alu_a_buss),             //1 -> A             output
        .c_in({7'h0, alu_a_buss[7]}),  //2 -> A (UPPER BIT) output
        .d_in(m_addr_buss),            //3 -> M             output
        .e_in(pc_addr_buss),           //4 -> PC            output
        .f_in(ir_op_buss),             //5 -> IR            output
        .g_in({6'h0,ccr_zn_buss}),     //6 -> CCR           output
        .h_in(dft_cu_state),           //7 -> CU STATE      output

        //Mux Select
        .sel_in(tm_control[2:0]),

        //Mux Output
        .mux_out(addr_out)
    );


    //ALU
    //--------------------------------
    minibyte_alu alu(
        //ALU Inputs
        .a_in(alu_a_buss),
        .b_in(data_in),
        .alu_op_in(ctrl_alu_op),

        .res_out(main_buss),
        .flags_zn_out(flags_zn_buss)
    );


    //Control Unit
    //--------------------------------
    minibyte_cu cu(
        //Basic Inputs
        .clk_in(clk_in), .rst_in(rst_in),

        //IR Input
        .ir_op_buss_in(ir_op_buss),

        //ALU Flags Input
        .ccr_flag_zn_in(ccr_zn_buss),

        //Control signal outputs
        .set_a_out(ctrl_set_a),
        .set_m_out(ctrl_set_m),
        .set_pc_out(ctrl_set_pc),
        .set_ir_out(ctrl_set_ir),
        .set_ccr_out(ctrl_set_ccr),
        .inc_pc_out(ctrl_inc_pc),

        //Addr select signals
        .addr_mux_out(ctrl_addr_mux),

        //Alu control signals
        .alu_op_out(ctrl_alu_op),

        //Write to memory
        .we_out(ctrl_we_out),

        //Drive enable on data bus
        .drive_out(ctrl_drive_out),

        //DFT Output
        .dft_curr_state(dft_cu_state)
    );

endmodule
