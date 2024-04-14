![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg)

# MiniByte CPU

The Minibyte CPU is a simple "toy" 8-bit CPU designed with Verilog and verified using Python+Cocotb

This CPU will be manufactured on actual silicon as part of the TinyTapeout 6 Shuttle (https://tinytapeout.com)

The CPU has some built in DFT (Design For Test) features and a Demo ROM that can be enabled for easy testing

This was created mostly as a learning/reference project to get more familiar with Verilog, and to tick off a bucket list item of actually making my own "real" CPU.

At some point between tapeout and silicon arriving, I intend to write a rudimentary assembler for creating programs that can be burned to EPROM/EEPROMs to be used with the CPU. A link will be added here in the future to another repo if I get around to writing this.

[FULL DOCUMENTATION HERE](docs/info.md)

![Minibyte Block Diagram](docs/block_diagram.png)
