/*
 * Copyright (c) 2024 Zachary Frazee
 * SPDX-License-Identifier: Apache-2.0
 */

//--------------------------
//REGISTER RAM
//--------------------------
module reg_ram_8B(
    //Input CLK and RST
    input wire clk_in,
    input wire rst_in,

    //Input Addr
    input wire [2:0] address,

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
    reg  [7:0] r_we;

    reg  [7:0] r0_out_data;
    reg  [7:0] r1_out_data;
    reg  [7:0] r2_out_data;
    reg  [7:0] r3_out_data;
    reg  [7:0] r4_out_data;
    reg  [7:0] r5_out_data;
    reg  [7:0] r6_out_data;
    reg  [7:0] r7_out_data;

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

    minibyte_genreg r4(
        //Basic Inputs
        .clk_in(clk_in), .rst_in(rst_in),

        //Register Inputs
        .reg_in(data_in),
        .set_in(r_we[4]),

        //Register Outputs
        .reg_out(r4_out_data)
    );

    minibyte_genreg r5(
        //Basic Inputs
        .clk_in(clk_in), .rst_in(rst_in),

        //Register Inputs
        .reg_in(data_in),
        .set_in(r_we[5]),

        //Register Outputs
        .reg_out(r5_out_data)
    );

    minibyte_genreg r6(
        //Basic Inputs
        .clk_in(clk_in), .rst_in(rst_in),

        //Register Inputs
        .reg_in(data_in),
        .set_in(r_we[6]),

        //Register Outputs
        .reg_out(r6_out_data)
    );

    minibyte_genreg r7(
        //Basic Inputs
        .clk_in(clk_in), .rst_in(rst_in),

        //Register Inputs
        .reg_in(data_in),
        .set_in(r_we[7]),

        //Register Outputs
        .reg_out(r7_out_data)
    );

    //Register control logic
    //------------------------------------
    always @ (*) begin
        if (!en_in) begin
            data_out = 8'h00;
            r_we     = 8'h00;
        end

        else if (we_in) begin
            case(address)
                3'b000:
                    r_we = 8'b00000001;
                3'b001:
                    r_we = 8'b00000010;
                3'b010:
                    r_we = 8'b00000100;
                3'b011:
                    r_we = 8'b00001000;
                3'b100:
                    r_we = 8'b00010000;
                3'b101:
                    r_we = 8'b00100000;
                3'b110:
                    r_we = 8'b01000000;
                3'b111:
                    r_we = 8'b10000000;
                default:
                    r_we = 8'b00000000;
            endcase

            data_out = 8'h00;
        end

        else begin
            case(address)
                3'b000:
                    data_out = r0_out_data;
                3'b001:
                    data_out = r1_out_data;
                3'b010:
                    data_out = r2_out_data;
                3'b011:
                    data_out = r3_out_data;
                3'b100:
                    data_out = r4_out_data;
                3'b101:
                    data_out = r5_out_data;
                3'b110:
                    data_out = r6_out_data;
                3'b111:
                    data_out = r7_out_data;
            endcase

            r_we = 8'h00;
        end
    end

endmodule
