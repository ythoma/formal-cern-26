Formal Verification : axis_upscaler
===================================

This folder contains an example of formal verification of an AXIs upscaler.
To run the example with SBY, go into the
scripts folder. Then run the following command:

sby --yosys "yosys -m ghdl" -f axis_upscaler.sby

or

sby --yosys "yosys -m ghdl" -f axis_upscaler.sby bmc

or

sby --yosys "yosys -m ghdl" -f axis_upscaler.sby cover


The script will compile the sequences, the assertions, and
formally verify that the properties hold (using bmc, or just checking coverage).

Actually, prove does not work very well on the current PSL assertions, so we only kept bmc does.