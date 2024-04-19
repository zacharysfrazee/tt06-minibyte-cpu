/*
 * Copyright (c) 2024 Zachary Frazee
 * SPDX-License-Identifier: Apache-2.0
 */

//--------------------------
//REGISTER RAM
//--------------------------
module reg_ram_4B(
    //Input CLK and RST
    input wire clk_in,
    input wire rst_in,

    //Input Addr
    input wire [1:0] address,

    //Input Data
    input wire [7:0] data_in,

    //Input WE and EN
    input wire we_in,
    input wire en_in,

    //Output Data
    output reg [7:0] data_out
);
    //Data busses
    //------------------------------------
    reg  [3:0] r_we;

    reg  [7:0] r0_out_data;
    reg  [7:0] r1_out_data;
    reg  [7:0] r2_out_data;
    reg  [7:0] r3_out_data;

    //Data registers
    //------------------------------------
    minibyte_genreg r0(
        //Basic Inputs
        .clk_in(clk_in), .rst_in(rst_in),

        //Register Inputs
        .reg_in(data_in),
        .set_in(r_we[0]),

        //Register Outputs
        .reg_out(r0_out_data)
    );

    minibyte_genreg r1(
        //Basic Inputs
        .clk_in(clk_in), .rst_in(rst_in),

        //Register Inputs
        .reg_in(data_in),
        .set_in(r_we[1]),

        //Register Outputs
        .reg_out(r1_out_data)
    );

    minibyte_genreg r2(
        //Basic Inputs
        .clk_in(clk_in), .rst_in(rst_in),

        //Register Inputs
        .reg_in(data_in),
        .set_in(r_we[2]),

        //Register Outputs
        .reg_out(r2_out_data)
    );

    minibyte_genreg r3(
        //Basic Inputs
        .clk_in(clk_in), .rst_in(rst_in),

        //Register Inputs
        .reg_in(data_in),
        .set_in(r_we[3]),

        //Register Outputs
        .reg_out(r3_out_data)
    );

    //Register control logic
    //------------------------------------
    always @ (*) begin
        if (!en_in) begin
            data_out = 8'hzz;
            r_we     = 4'h0;
        end

        else if (we_in) begin
            case(address)
                2'b00:
                    r_we = 4'b0001;
                2'b01:
                    r_we = 4'b0010;
                2'b10:
                    r_we = 4'b0100;
                2'b11:
                    r_we = 4'b1000;
                default:
                    r_we = 4'b0000;
            endcase

            data_out = 8'hzz;
        end

        else begin
            case(address)
                2'b00:
                    data_out = r0_out_data;
                2'b01:
                    data_out = r1_out_data;
                2'b10:
                    data_out = r2_out_data;
                2'b11:
                    data_out = r3_out_data;
            endcase

            r_we = 4'h0;
        end
    end

endmodule
