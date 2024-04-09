/*
 * Copyright (c) 2024 Zachary Frazee
 * SPDX-License-Identifier: Apache-2.0
 */


//CPU IR opcodes
//--------------------------
parameter _NOP     = 8'h00;
parameter _LDA_IMM = 8'h01;
parameter _LDA_DIR = 8'h02;
parameter _STA_IMM = 8'h03;
parameter _STA_DIR = 8'h04;
parameter _ADD_IMM = 8'h05;
parameter _ADD_DIR = 8'h06;
parameter _SUB_IMM = 8'h07;
parameter _SUB_DIR = 8'h08;
parameter _AND_IMM = 8'h09;
parameter _AND_DIR = 8'h0A;
parameter _OR_IMM  = 8'h0B;
parameter _OR_DIR  = 8'h0C;
parameter _XOR_IMM = 8'h0D;
parameter _XOR_DIR = 8'h0E;
parameter _LSL_IMM = 8'h0F;
parameter _LSL_DIR = 8'h10;
parameter _LSR_IMM = 8'h11;
parameter _LSR_DIR = 8'h12;
parameter _ASL_IMM = 8'h13;
parameter _ASL_DIR = 8'h14;
parameter _ASR_IMM = 8'h15;
parameter _ASR_DIR = 8'h16;
parameter _RSL_IMM = 8'h17;
parameter _RSL_DIR = 8'h18;
parameter _RSR_IMM = 8'h19;
parameter _RSR_DIR = 8'h1A;
parameter _JMP_IMM = 8'h1B;
parameter _JMP_DIR = 8'h1C;
parameter _BNE_IMM = 8'h1D;
parameter _BNE_DIR = 8'h1E;
parameter _BEQ_IMM = 8'h1F;
parameter _BEQ_DIR = 8'h20;
parameter _BPL_IMM = 8'h21;
parameter _BPL_DIR = 8'h22;
parameter _BMI_IMM = 8'h23;
parameter _BMI_DIR = 8'h24;

//--------------------------
//Demo ROM Program
//--------------------------
module demo_rom_32B(
    //Input Addr
    input wire [4:0] address,

    //Output Data
    output reg [7:0] data_out
);
    always @(address)
        case(address)
            5'h00:   data_out = _NOP;        //First istr is a NOP
            5'h01:   data_out = _LDA_IMM;    //Make sure A is zero
            5'h02:   data_out = 0;
            5'h03:   data_out = _NOP;        //NOP is the START of the LOOP0
            5'h04:   data_out = _ADD_IMM;    //ADD 1 to A
            5'h05:   data_out = 1;
            5'h06:   data_out = _STA_IMM;    //Write this value to 0x40
            5'h07:   data_out = 8'h40;
            5'h08:   data_out = _BNE_IMM;    //Keep branching to LOOP0 until we roll over to 0
            5'h09:   data_out = 8'h03;
            5'h0A:   data_out = _LDA_IMM;    //Load a 1 into A
            5'h0B:   data_out = 1;
            5'h0C:   data_out = _STA_IMM;    //Write this value to 0x40
            5'h0D:   data_out = 8'h40;
            5'h0E:   data_out = _NOP;        //NOP is the START of the LOOP1
            5'h0F:   data_out = _LSL_IMM;    //Shift A left by 1
            5'h10:   data_out = 1;
            5'h11:   data_out = _STA_IMM;    //Write this value to 0x40
            5'h12:   data_out = 8'h40;
            5'h13:   data_out = _BPL_IMM;    //Keep branching to LOOP1 until we hit 0b10000000
            5'h14:   data_out = 8'h0E;
            5'h15:   data_out = _JMP_IMM;    //Start the whole fun over again!
            5'h16:   data_out = 8'h00;

            default: data_out = 0;           //Unused space
        endcase
endmodule
