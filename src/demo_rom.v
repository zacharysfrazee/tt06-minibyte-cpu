/*
 * Copyright (c) 2024 Zachary Frazee
 * SPDX-License-Identifier: Apache-2.0
 */


//CPU IR opcodes
//--------------------------
parameter _NOP     = 8'h00;
parameter _LDA_IMM = 8'h01;
parameter _LDA_DIR = 8'h02;
parameter _STA_DIR = 8'h03;
//parameter _STA_IND = 8'h04;
parameter _ADD_IMM = 8'h05;
//parameter _ADD_DIR = 8'h06;
//parameter _SUB_IMM = 8'h07;
//parameter _SUB_DIR = 8'h08;
//parameter _AND_IMM = 8'h09;
//parameter _AND_DIR = 8'h0A;
//parameter _OR_IMM  = 8'h0B;
//parameter _OR_DIR  = 8'h0C;
//parameter _XOR_IMM = 8'h0D;
//parameter _XOR_DIR = 8'h0E;
parameter _LSL_IMM = 8'h0F;
//parameter _LSL_DIR = 8'h10;
//parameter _LSR_IMM = 8'h11;
//parameter _LSR_DIR = 8'h12;
//parameter _ASL_IMM = 8'h13;
//parameter _ASL_DIR = 8'h14;
//parameter _ASR_IMM = 8'h15;
//parameter _ASR_DIR = 8'h16;
//parameter _RSL_IMM = 8'h17;
//parameter _RSL_DIR = 8'h18;
//parameter _RSR_IMM = 8'h19;
//parameter _RSR_DIR = 8'h1A;
parameter _JMP_DIR = 8'h1B;
//parameter _JMP_IND = 8'h1C;
parameter _BNE_DIR = 8'h1D;
//parameter _BNE_IND = 8'h1E;
//parameter _BEQ_DIR = 8'h1F;
//parameter _BEQ_IND = 8'h20;
parameter _BPL_DIR = 8'h21;
//parameter _BPL_IND = 8'h22;
//parameter _BMI_DIR = 8'h23;
//parameter _BMI_IND = 8'h24;

//--------------------------
//Demo ROM Program
//--------------------------
module demo_rom_64B(
    //Input Addr
    input wire [5:0] address,

    //Output Data
    output reg [7:0] data_out
);
    always @(address)
        case(address)
            6'h00:   data_out = _NOP;        //First istr is a NOP
            6'h01:   data_out = _LDA_IMM;    //Make sure A is zero
            6'h02:   data_out = 0;
            6'h03:   data_out = _NOP;        //NOP is the START of the LOOP0
            6'h04:   data_out = _ADD_IMM;    //ADD 1 to A
            6'h05:   data_out = 1;
            6'h06:   data_out = _STA_DIR;    //Write this value to 0x40
            6'h07:   data_out = 8'h40;
            6'h08:   data_out = _BNE_DIR;    //Keep branching to LOOP0 until we roll over to 0
            6'h09:   data_out = 8'h03;

            6'h0A:   data_out = _LDA_IMM;    //Load a 1 into A
            6'h0B:   data_out = 1;
            6'h0C:   data_out = _STA_DIR;    //Write this value to 0x40
            6'h0D:   data_out = 8'h40;
            6'h0E:   data_out = _NOP;        //NOP is the START of the LOOP1
            6'h0F:   data_out = _LSL_IMM;    //Shift A left by 1
            6'h10:   data_out = 1;
            6'h11:   data_out = _STA_DIR;    //Write this value to 0x40
            6'h12:   data_out = 8'h40;
            6'h13:   data_out = _BPL_DIR;    //Keep branching to LOOP1 until we hit 0b10000000
            6'h14:   data_out = 8'h0E;

            6'h15:   data_out = _LDA_IMM;    //Load DEADBEEF into RAM
            6'h16:   data_out = 8'hDE;
            6'h17:   data_out = _STA_DIR;
            6'h18:   data_out = 8'h7C;
            6'h19:   data_out = _LDA_IMM;
            6'h1A:   data_out = 8'hAD;
            6'h1B:   data_out = _STA_DIR;
            6'h1C:   data_out = 8'h7D;
            6'h1D:   data_out = _LDA_IMM;
            6'h1E:   data_out = 8'hBE;
            6'h1F:   data_out = _STA_DIR;
            6'h20:   data_out = 8'h7E;
            6'h21:   data_out = _LDA_IMM;
            6'h22:   data_out = 8'hEF;
            6'h23:   data_out = _STA_DIR;
            6'h24:   data_out = 8'h7F;

            6'h25:   data_out = _LDA_DIR;    //READ out the contents of RAM
            6'h26:   data_out = 8'h7C;
            6'h27:   data_out = _STA_DIR;    //Write this value to 0x40
            6'h28:   data_out = 8'h40;
            6'h29:   data_out = _LDA_DIR;    //READ out the contents of RAM
            6'h2A:   data_out = 8'h7D;
            6'h2B:   data_out = _STA_DIR;    //Write this value to 0x40
            6'h2C:   data_out = 8'h40;
            6'h2D:   data_out = _LDA_DIR;    //READ out the contents of RAM
            6'h2E:   data_out = 8'h7E;
            6'h2F:   data_out = _STA_DIR;    //Write this value to 0x40
            6'h30:   data_out = 8'h40;
            6'h31:   data_out = _LDA_DIR;    //READ out the contents of RAM
            6'h32:   data_out = 8'h7F;
            6'h33:   data_out = _STA_DIR;    //Write this value to 0x40
            6'h34:   data_out = 8'h40;

            6'h35:   data_out = _JMP_DIR;    //Start the whole thing over!
            6'h36:   data_out = 8'h00;

            default: data_out = 0;           //Unused space
        endcase
endmodule
