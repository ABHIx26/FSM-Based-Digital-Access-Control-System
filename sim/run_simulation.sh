#!/bin/bash

# Compile Verilog design and testbench
iverilog -o access_control_sim ../src/access_control.v ../tb/access_control_tb.v

# Run simulation
vvp access_control_sim

# Open waveform
gtkwave access_control.vcd
