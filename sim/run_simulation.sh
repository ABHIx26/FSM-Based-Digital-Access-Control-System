#!/bin/bash

# Compile the Verilog design and testbench
iverilog -o access_control_sim \
    ../src/access_control.v \
    ../tb/access_control_tb.v

# Run the simulation
vvp access_control_sim

# Open the generated waveform
gtkwave access_control.vcd
