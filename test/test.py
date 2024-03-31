# SPDX-FileCopyrightText: © 2023 Uri Shaked <uri@tinytapeout.com>
# SPDX-License-Identifier: MIT

#Includes
#-------------------------
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

import random

#DFT Testmodes
#-------------------------
TM_OFF                = 0x00

TM_DEBUG_OUT_A        = 0x01
TM_DEBUG_OUT_A_UPPER  = 0x02
TM_DEBUG_OUT_M        = 0x03
TM_DEBUG_OUT_PC       = 0x04
TM_DEBUG_OUT_IR       = 0x05
TM_DEBUG_OUT_CCR      = 0x06
TM_DEBUG_OUT_CU_STATE = 0x07

#IR Opcodes
#-------------------------
IR_NOP     = 0x00

IR_LDA_IMM = 0x01
IR_LDA_DIR = 0x02
IR_STA_IMM = 0x03
IR_STA_DIR = 0x04

IR_ADD_IMM = 0x05
IR_ADD_DIR = 0x06
IR_SUB_IMM = 0x07
IR_SUB_DIR = 0x08
IR_AND_IMM = 0x09
IR_AND_DIR = 0x0A
IR_OR_IMM  = 0x0B
IR_OR_DIR  = 0x0C
IR_XOR_IMM = 0x0D
IR_XOR_DIR = 0x0E
IR_LSL_IMM = 0x0F
IR_LSL_DIR = 0x10
IR_LSR_IMM = 0x11
IR_LSR_DIR = 0x12
IR_ASL_IMM = 0x13
IR_ASL_DIR = 0x14
IR_ASR_IMM = 0x15
IR_ASR_DIR = 0x16


#IR Cycle Counts
#-------------------------
CYCLES_NOP     = 4 # S_FETCH_0->S_FETCH_1->S_FETCH_2->S_DECODE_0
CYCLES_LDA_IMM = 7 # S_FETCH_0->S_FETCH_1->S_FETCH_2->S_DECODE_0->S_LDA_IMM_0->S_LDA_IMM_1->S_PC_INC_0
CYCLES_LDA_DIR = 9 # S_FETCH_0->S_FETCH_1->S_FETCH_2->S_DECODE_0->S_LDA_DIR_0->S_LDA_DIR_1->S_LDA_DIR_2->S_LDA_DIR_3->S_PC_INC_0
CYCLES_STA_IMM = 9 # S_FETCH_0->S_FETCH_1->S_FETCH_2->S_DECODE_0->S_STA_IMM_0->S_STA_IMM_1->S_STA_IMM_2->S_STA_IMM_3->S_PC_INC_0

CYCLES_ALU_IMM = 7 # S_FETCH_0->S_FETCH_1->S_FETCH_2->S_DECODE_0->S_<ALU>_IMM_0->S_<ALU>_IMM_1->S_PC_INC_0


#Test TM_DEBUG_OUT_A
#-------------------------
@cocotb.test()
async def test_tm_debug_out_a(dut):
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
        #Set data input buss to a LDA_IMM
        dut._log.info("IR_LDA_IMM")
        dut.uio_in.value = IR_LDA_IMM

        #Clock in the first half of the instruction
        #S_FETCH_0->S_FETCH_1->S_FETCH_2->S_DECODE_0->S_LDA_IMM_0(current)
        await ClockCycles(dut.clk, CYCLES_NOP)

        #Set the data buss to the test_value to be loaded
        dut.uio_in.value = test_value

        #Set debug out
        dut.ui_in.value = TM_DEBUG_OUT_A

        #Clock in the remaining cycles -1
        #S_LDA_IMM_0->S_LDA_IMM_1->S_PC_INC_0(current)
        await ClockCycles(dut.clk, (CYCLES_LDA_IMM - CYCLES_NOP) - 1)

        #Verify that A (lower 7) has the expected value
        assert dut.uo_out.value == (test_value & 0x7f)

        #Set debug out
        dut.ui_in.value = TM_DEBUG_OUT_A_UPPER

        #Clock last cycle
        #S_PC_INC_0->S_FETCH_0(current)
        await ClockCycles(dut.clk, 1)

        #Verify that A (upper bit) has the expected value
        assert dut.uo_out.value == ((test_value & 0x80) >> 7)

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

        #Load data to A via immediate data
        #---------

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

        #STA_IMM the data back out
        #---------

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

        #Load data to A via test_address
        #---------

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

        #STA_IMM the data back out
        #---------

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


#Test <ALU>_IMM instruction
#-------------------------
@cocotb.test()
async def test_alu_imm(dut):
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

    #Test 500 Random Values
    test_vals = [(random.randint(0, 255), random.randint(0, 255)) for _ in range(1000)] #1000 vals using large RHS
    test_vals = [(random.randint(0, 255), random.randint(0, 7))   for _ in range(100)] #100 vals using small RHS (usefull for testing shifts and such)

    #8-bit twos comp functions
    def _2s_comp_to_pyint(x):
        if x > 127:
            return -((x ^ 0xff) + 1)
        else:
            return x

    def pyint_to_2scomp(x):
        if x < 0:
            return (-x ^ 0xff) + 1
        else:
            return x

    #Test suite
    test_suite =[
        (
            "ADD_IMM",
            "+",
            IR_ADD_IMM,
            CYCLES_ALU_IMM,
            lambda lhs, rhs : (lhs + rhs) & 0xff
        ),
        (
            "SUB_IMM",
            "-",
            IR_SUB_IMM,
            CYCLES_ALU_IMM,
            lambda lhs, rhs : (lhs - rhs) & 0xff
        ),
        (
            "AND_IMM",
            "&",
            IR_AND_IMM,
            CYCLES_ALU_IMM,
            lambda lhs, rhs : (lhs & rhs) & 0xff
        ),
        (
            "OR_IMM",
            "|",
            IR_OR_IMM,
            CYCLES_ALU_IMM,
            lambda lhs, rhs : (lhs | rhs) & 0xff
        ),
        (
            "XOR_IMM",
            "^",
            IR_XOR_IMM,
            CYCLES_ALU_IMM,
            lambda lhs, rhs : (lhs ^ rhs) & 0xff
        ),
        (
            "LSL_IMM",
            "<<",
            IR_LSL_IMM,
            CYCLES_ALU_IMM,
            lambda lhs, rhs : (lhs << rhs) & 0xff
        ),
        (
            "LSR_IMM",
            ">>",
            IR_LSR_IMM,
            CYCLES_ALU_IMM,
            lambda lhs, rhs : (lhs >> rhs) & 0xff
        ),
        (
            "ASL_IMM",
            "<<<",
            IR_ASL_IMM,
            CYCLES_ALU_IMM,
            lambda lhs, rhs : pyint_to_2scomp(_2s_comp_to_pyint(lhs) << rhs) & 0xff
        ),
        (
            "ASR_IMM",
            ">>>",
            IR_ASR_IMM,
            CYCLES_ALU_IMM,
            lambda lhs, rhs : pyint_to_2scomp(_2s_comp_to_pyint(lhs) >> rhs) & 0xff
        ),
    ]

    for alu_ir_name, alu_symbol, alu_ir, alu_cycles, alu_test_func in test_suite:
        for (lhs_test_val, rhs_test_val) in test_vals:
            #Load the LHS value to A
            #---------

            #Set data input buss to a LDA_IMM
            dut._log.info("IR_LDA_IMM")
            dut.uio_in.value = IR_LDA_IMM

            #Clock in the first half of the instruction
            #S_FETCH_0->S_FETCH_1->S_FETCH_2->S_DECODE_0->S_LDA_IMM_0(current)
            await ClockCycles(dut.clk, CYCLES_NOP)

            #Set the data buss to the test_value to be loaded
            dut.uio_in.value = lhs_test_val

            #Clock in the remaining cycles
            #S_LDA_IMM_0->S_LDA_IMM_1->S_PC_INC_0->S_FETCH_0(current)
            await ClockCycles(dut.clk, CYCLES_LDA_IMM - CYCLES_NOP)

            #Add the RHS value to A
            #---------

            #Set data input buss to a LDA_IMM
            dut._log.info(f"ALU_IR_OP: {alu_ir_name}")
            dut.uio_in.value = alu_ir

            #Clock in the first half of the instruction
            #S_FETCH_0->S_FETCH_1->S_FETCH_2->S_DECODE_0->S_<ALU>_DIR_0(current)
            await ClockCycles(dut.clk, CYCLES_NOP)

            #Set the data buss to the test_value to be loaded
            dut.uio_in.value = rhs_test_val

            #Clock in the remaining cycles -2
            #S_<ALU>_DIR_0->S_<ALU>_DIR_1->S_<ALU>_DIR_2->S_<ALU>_DIR_3->S_PC_INC_0(current)
            await ClockCycles(dut.clk, (alu_cycles - CYCLES_NOP ) - 2)

            #Set debug out
            dut.ui_in.value = TM_DEBUG_OUT_A

            #Clock the second to last cycle
            #S_PC_INC_0->S_FETCH_0(current)
            await ClockCycles(dut.clk, 1)

            #Set debug out (upper bit)
            dut.ui_in.value = TM_DEBUG_OUT_A_UPPER

            #Save lower 7 a bits
            a_data = dut.uo_out.value & 0x7f

            #Clock the last cycle
            #S_PC_INC_0->S_FETCH_0(current)
            await ClockCycles(dut.clk, 1)

            #Save the upper a bit
            a_data |= (dut.uo_out.value & 0x1) << 7

            #Log info
            dut._log.info(f"Desired: {lhs_test_val} {alu_symbol} {rhs_test_val} = {alu_test_func(lhs_test_val, rhs_test_val)}")
            dut._log.info(f"Actual : {lhs_test_val} {alu_symbol} {rhs_test_val} = {a_data}")

            #Check the result
            assert a_data == alu_test_func(lhs_test_val, rhs_test_val)

            #Disable debug out
            dut.ui_in.value = TM_OFF