# SPDX-FileCopyrightText: © 2023 Uri Shaked <uri@tinytapeout.com>
# SPDX-License-Identifier: MIT

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

#DFT Testmodes
#-------------------------
TM_OFF                = 0x00

TM_DEBUG_OUT_A        = 0x01
TM_DEBUG_OUT_M        = 0x02
TM_DEBUG_OUT_PC       = 0x03
TM_DEBUG_OUT_IR       = 0x04
TM_DEBUG_OUT_ALU_OP   = 0x05
TM_DEBUG_OUT_CCR      = 0x06
TM_DEBUG_OUT_CU_STATE = 0x07

#IR Opcodes
#-------------------------
IR_NOP     = 0
IR_LDA_IMM = 1
IR_LDA_DIR = 2
IR_STA_IMM = 3

#IR Cycle Counts
#-------------------------
CYCLES_NOP     = 4 # S_FETCH_0->S_FETCH_1->S_FETCH_2->S_DECODE_0
CYCLES_LDA_IMM = 7 # S_FETCH_0->S_FETCH_1->S_FETCH_2->S_DECODE_0->S_LDA_IMM_0->S_LDA_IMM_1->S_PC_INC_0
CYCLES_LDA_DIR = 9 # S_FETCH_0->S_FETCH_1->S_FETCH_2->S_DECODE_0->S_LDA_DIR_0->S_LDA_DIR_1->S_LDA_DIR_2->S_LDA_DIR_3->S_PC_INC_0
CYCLES_STA_IMM = 9 # S_FETCH_0->S_FETCH_1->S_FETCH_2->S_DECODE_0->S_STA_IMM_0->S_STA_IMM_1->S_STA_IMM_2->S_STA_IMM_3->S_PC_INC_0

#Test NOP instruction
#-------------------------
@cocotb.test()
async def test_nop(dut):
    #Start
    dut._log.info("Start")

    #Setup Clock
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    #Reset
    dut._log.info("Reset")
    dut.ena.value    = 1
    dut.ui_in.value  = TM_OFF
    dut.uio_in.value = 0
    dut.rst_n.value  = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value  = 1

    #Clock through the reset state S_RESET_0->S_FETCH_0(current)
    await ClockCycles(dut.clk, 2)

    #Set data input buss to a NOP
    dut._log.info("NOP")
    dut.uio_in.value = IR_NOP

    #Clock in 7 NOPs
    #Each NOP should take 4 cycles to execute
    #S_FETCH_0->S_FETCH_1->S_FETCH_2->S_DECODE_0 (DONE)
    await ClockCycles(dut.clk, CYCLES_NOP * 7)

    #Verify that PC has incremented to 7
    assert dut.uo_out.value == 0x07

#Test LDA_IMM/STA_IMM instruction
#-------------------------
@cocotb.test()
async def test_lda_imm_sta_imm(dut):
    #Start
    dut._log.info("Start")

    #Setup Clock
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    #Reset
    dut._log.info("Reset")
    dut.ena.value    = 1
    dut.ui_in.value  = TM_OFF
    dut.uio_in.value = 0
    dut.rst_n.value  = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value  = 1

    #Clock through the reset state S_RESET_0->S_FETCH_0(current)
    await ClockCycles(dut.clk, 2)

    #Test Values
    TEST_VALUES = [0x77, 0xaa, 0x00, 0xff]

    #Main test loop
    for test_value in TEST_VALUES:
        #7-bit Address to write to later
        test_address = (test_value ^ 0xaa) & 0x7f

        #Set data input buss to a LDA_IMM
        dut._log.info("IR_LDA_IMM")
        dut.uio_in.value = IR_LDA_IMM

        #Clock in the first half of the instruction
        #S_FETCH_0->S_FETCH_1->S_FETCH_2->S_DECODE_0->S_LDA_IMM_0(current)
        await ClockCycles(dut.clk, CYCLES_NOP)

        #Set the data buss to the test_value to be loaded
        dut.uio_in.value = test_value

        #Clock in the remaining cycles
        #S_LDA_IMM_0->S_LDA_IMM_1->S_PC_INC_0->S_FETCH_0(current)
        await ClockCycles(dut.clk, CYCLES_LDA_IMM - CYCLES_NOP)

        #Set data input buss to a STA_IMM
        dut._log.info("IR_STA_IMM")
        dut.uio_in.value = IR_STA_IMM

        #Clock in the first half of the instruction
        #S_FETCH_0->S_FETCH_1->S_FETCH_2->S_DECODE_0->S_STA_IMM_0(current)
        await ClockCycles(dut.clk, CYCLES_NOP)

        #Set the data buss to a test 7-bit address
        dut.uio_in.value = test_address

        #Clock till we get to the drive out state
        #S_STA_IMM_0->S_STA_IMM_1->S_STA_IMM_2->S_STA_IMM_3(current)
        await ClockCycles(dut.clk, (CYCLES_STA_IMM - CYCLES_NOP) - 2)

        #Verify that we are driving
        assert dut.uio_oe == 0xff

        #Verify that test data is back out on the buss
        assert dut.uio_out.value == test_value

        #Verify that the address is pointing to the test addr
        assert (dut.uo_out.value & 0x7f) == test_address

        #Verify that WE is set
        assert (dut.uo_out.value & 0x80)

        #Finish the STA_IMM instruction
        #S_STA_IMM_3->S_PC_INC_0(current)
        await ClockCycles(dut.clk,1)

        #Verify that WE is no longer set
        assert (dut.uo_out.value & 0x80) == 0

        #Verify that we are no longer driving
        assert dut.uio_oe == 0x00

        #Allow PC to increment
        #S_PC_INC_0->S_FETCH_0(current)
        await ClockCycles(dut.clk,1)


#Test LDA_DIR instruction
#-------------------------
@cocotb.test()
async def test_lda_dir(dut):
    #Start
    dut._log.info("Start")

    #Setup Clock
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    #Reset
    dut._log.info("Reset")
    dut.ena.value    = 1
    dut.ui_in.value  = TM_OFF
    dut.uio_in.value = 0
    dut.rst_n.value  = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value  = 1

    #Clock through the reset state S_RESET_0->S_FETCH_0(current)
    await ClockCycles(dut.clk, 2)

    #Test Values
    TEST_VALUES = [0xde, 0xad, 0xbe, 0xef]

    #Main test loop
    for test_value in TEST_VALUES:
        #7-bit Address to write to later
        test_address = (test_value ^ 0xaa) & 0x7f

        #Set data input buss to a LDA_DIR
        dut._log.info("IR_LDA_DIR")
        dut.uio_in.value = IR_LDA_DIR

        #Clock in the first half of the instruction
        #S_FETCH_0->S_FETCH_1->S_FETCH_2->S_DECODE_0->S_LDA_DIR_0(current)
        await ClockCycles(dut.clk, CYCLES_NOP)

        #Set the data buss to the test address to be loaded
        dut.uio_in.value = test_address

        #Clock in till we get to the M output
        #S_LDA_DIR_0->S_LDA_DIR_1->S_LDA_DIR_2(current)
        await ClockCycles(dut.clk, (CYCLES_LDA_DIR - CYCLES_NOP) - 3)

        #Make sure our test address is being output
        assert (dut.uo_out.value & 0x7f) == test_address

        #Set the data to the test data
        dut.uio_in.value = test_value

        #Finish clocking LDA_DIR
        #S_LDA_DIR_2->S_LDA_DIR_3->S_PC_INC_0->S_FETCH_0(current)
        await ClockCycles(dut.clk, 3)

        #Set data input buss to a STA_IMM
        dut._log.info("IR_STA_IMM")
        dut.uio_in.value = IR_STA_IMM

        #Clock in the first half of the instruction
        #S_FETCH_0->S_FETCH_1->S_FETCH_2->S_DECODE_0->S_STA_IMM_0(current)
        await ClockCycles(dut.clk, CYCLES_NOP)

        #Set the data buss to a test 7-bit address
        dut.uio_in.value = test_address

        #Clock till we get to the drive out state
        #S_STA_IMM_0->S_STA_IMM_1->S_STA_IMM_2->S_STA_IMM_3(current)
        await ClockCycles(dut.clk, (CYCLES_STA_IMM - CYCLES_NOP) - 2)

        #Verify that we are driving
        assert dut.uio_oe == 0xff

        #Verify that test data is back out on the buss
        assert dut.uio_out.value == test_value

        #Verify that the address is pointing to the test addr
        assert (dut.uo_out.value & 0x7f) == test_address

        #Verify that WE is set
        assert (dut.uo_out.value & 0x80)

        #Finish the STA_IMM instruction
        #S_STA_IMM_3->S_PC_INC_0(current)
        await ClockCycles(dut.clk,1)

        #Verify that WE is no longer set
        assert (dut.uo_out.value & 0x80) == 0

        #Verify that we are no longer driving
        assert dut.uio_oe == 0x00

        #Allow PC to increment
        #S_PC_INC_0->S_FETCH_0(current)
        await ClockCycles(dut.clk,1)