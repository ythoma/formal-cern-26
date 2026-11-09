Timer Example
=============

This folder contains an example of formal verification of a sequence detector (1100).
To run the example with SBY, go into the
scripts folder. Then run the following command:

sby --yosys "yosys -m ghdl" -f seq_detector.sby prove

or

sby --yosys "yosys -m ghdl" -f seq_detector.sby bmc

or

sby --yosys "yosys -m ghdl" -f seq_detector.sby cover


The script will compile the DUV, the assertions, and
formally verify that the properties hold (using prove, bmc, or just checking coverage).

The structure of the folder is the following:

.
├── README.md
├── scripts
│   └── seq_detector.sby
├── src_vhdl
│   └── seq_detector.vhd
└── src_tb
    └── seq_detector.psl


Interesting fact: with BMC, it goes up to the detph defined in the .sby file. For this case,
prove seems more efficient. For prove it uses two engines, and we can observe the difference in
speed for both (for that specific example)