locker Example
=============

This folder contains an example of formal verification of a locker.
To run the example with SBY, go into the
scripts folder. Then run the following command:


sby --yosys "yosys -m ghdl" -f locker.sby

or

sby --yosys "yosys -m ghdl" -f locker.sby proveX

or

sby --yosys "yosys -m ghdl" -f locker.sby bmcX

or

sby --yosys "yosys -m ghdl" -f locker.sby cover


When running the proveX or bmcX, replace the X by a numerical value between 0 and 7. For 0
the tests are expected to succeed, and for 1 to 7 they should fail, as the design will have internal
errors.

The script will compile the DUV, the assertions, and
formally verify that the properties hold (using prove, bmc, or just checking coverage).

The structure of the folder is the following:

.
├── README.md
├── scripts
│   └── locker.sby
├── src_vhdl
│   └── locker.vhd
└── src_tb
    └── locker.psl


