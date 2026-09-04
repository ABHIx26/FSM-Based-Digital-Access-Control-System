`timescale 1ns / 1ps

module access_control_tb;

    // Testbench signals
    reg clk;
    reg reset;
    reg [1:0] key;

    wire unlock;
    wire lockout;
    wire [1:0] failed_attempts;
    wire [2:0] current_state;

    // Instantiate the Design Under Test (DUT)
    access_control dut (
        .clk(clk),
        .reset(reset),
        .key(key),
        .unlock(unlock),
        .lockout(lockout),
        .failed_attempts(failed_attempts),
        .current_state(current_state)
    );

    // Clock generation: 10 ns period
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin

        // Generate waveform file
        $dumpfile("access_control.vcd");
        $dumpvars(0, access_control_tb);

        $display("========================================");
        $display("Starting Access Control System Test");
        $display("========================================");

        // -----------------------------------
        // TEST 1: Reset
        // -----------------------------------
        reset = 1;
        key = 2'b00;
        #10;

        reset = 0;
        #10;

        // -----------------------------------
        // TEST 2: Correct sequence A-B-C-A
        // -----------------------------------
        $display("TEST 2: Correct sequence");

        key = 2'b00; #10;  // A
        key = 2'b01; #10;  // B
        key = 2'b10; #10;  // C
        key = 2'b00; #10;  // A

        // -----------------------------------
        // TEST 3: Incorrect attempt 1
        // -----------------------------------
        $display("TEST 3: Incorrect attempt 1");

        key = 2'b00; #10;  // A
        key = 2'b10; #10;  // Wrong key

        // -----------------------------------
        // TEST 4: Incorrect attempt 2
        // -----------------------------------
        $display("TEST 4: Incorrect attempt 2");

        key = 2'b00; #10;  // A
        key = 2'b10; #10;  // Wrong key

        // -----------------------------------
        // TEST 5: Incorrect attempt 3
        // -----------------------------------
        $display("TEST 5: Incorrect attempt 3 - Lockout expected");

        key = 2'b00; #10;  // A
        key = 2'b10; #10;  // Wrong key

        #10;

        // -----------------------------------
        // TEST 6: Reset after lockout
        // -----------------------------------
        $display("TEST 6: Resetting system");

        reset = 1;
        #10;

        reset = 0;
        #10;

        // -----------------------------------
        // TEST 7: Correct sequence after reset
        // -----------------------------------
        $display("TEST 7: Correct sequence after reset");

        key = 2'b00; #10;
        key = 2'b01; #10;
        key = 2'b10; #10;
        key = 2'b00; #10;

        #20;

        $display("========================================");
        $display("Simulation completed");
        $display("========================================");

        $finish;
    end

endmodule
