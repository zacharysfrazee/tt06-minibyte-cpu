/*
 * Copyright (c) 2024 Zachary Frazee
 * SPDX-License-Identifier: Apache-2.0
 */

//---------------------------------
//Drive enable device
//---------------------------------
module drive_enable_fanout(
    //Drive enable input signal
    input  wire      drive_en,

    //Output drive signals
    output reg [7:0] drive
);

    //Main Procedural Block
    //--------------------------
    always @(*) begin
        if(drive_en == 0)
            drive = 0;
        else
            drive = 8'hff;
    end

endmodule
