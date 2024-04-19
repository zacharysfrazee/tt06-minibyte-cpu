/*
 * Copyright (c) 2024 Zachary Frazee
 * SPDX-License-Identifier: Apache-2.0
 */

//--------------------------
//REGISTER RAM
//--------------------------
module reg_ram_4B(
    //Input Addr
    input wire [1:0] address,

    //Input Data
    input reg [7:0] data_in,

    //Input WE and EN
    input wire we_in,
    input wire en_in,

    //Output Data
    output reg [7:0] data_out
);
    //Data registers
    reg [7:0] reg_data[3:0];

    always @ (address or we_in or data_in) begin
        if (!en_in)
            data_out = 8'hzz;
        else if (we_in)
            reg_data[address] <= data_in;
        else
            data_out = reg_data[address];
    end

endmodule
