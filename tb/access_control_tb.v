`timescale 1ns / 1ps

module access_control_tb;

    reg clk;
    reg reset;
    reg [1:0] key;

    wire unlock;
    wire lockout;
    wire [1:0] failed_attempts;
    wire [2:0] current_state;

    integer errors;

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

    // Apply a key for one clock cycle
    task press_key;
        input [1:0] key_value;
        begin
            key = key_value;
            #10;
            key = 2'b11;
            #1;
        end
    endtask

    initial begin

        $dumpfile("access_control.vcd");
        $dumpvars(0, access_control_tb);

        errors = 0;
        key = 2'b11;

        $display("========================================");
        $display("ACCESS CONTROL SYSTEM VERIFICATION");
        $display("========================================");

        // TEST 1: Reset
        reset = 1;
        #10;
        reset = 0;
        #10;

        if (current_state == 3'd0 && failed_attempts == 2'd0 &&
            unlock == 1'b0 && lockout == 1'b0)
            $display("TEST 1: PASS - System reset successfully");
        else begin
            $display("TEST 1: FAIL - Reset operation incorrect");
            errors = errors + 1;
        end

        // TEST 2: Correct sequence A-B-C-A
        press_key(2'b00);
        press_key(2'b01);
        press_key(2'b10);
        press_key(2'b00);

        #1;

        if (unlock == 1'b1 && failed_attempts == 2'd0)
            $display("TEST 2: PASS - Correct sequence unlocked system");
        else begin
            $display("TEST 2: FAIL - Correct sequence did not unlock");
            errors = errors + 1;
        end

        #9;

        // TEST 3: Incorrect attempt 1
        press_key(2'b00);
        press_key(2'b10);

        if (failed_attempts == 2'd1 && lockout == 1'b0)
            $display("TEST 3: PASS - Failed attempt count = 1");
        else begin
            $display("TEST 3: FAIL - Incorrect first attempt handling");
            errors = errors + 1;
        end

        // TEST 4: Incorrect attempt 2
        press_key(2'b00);
        press_key(2'b10);

        if (failed_attempts == 2'd2 && lockout == 1'b0)
            $display("TEST 4: PASS - Failed attempt count = 2");
        else begin
            $display("TEST 4: FAIL - Incorrect second attempt handling");
            errors = errors + 1;
        end

        // TEST 5: Incorrect attempt 3
        press_key(2'b00);
        press_key(2'b10);

        if (failed_attempts == 2'd3 && lockout == 1'b1 &&
            current_state == 3'd5)
            $display("TEST 5: PASS - System entered LOCKOUT after 3 failed attempts");
        else begin
            $display("TEST 5: FAIL - Lockout operation incorrect");
            errors = errors + 1;
        end

        // TEST 6: Reset after lockout
        reset = 1;
        #10;
        reset = 0;
        key = 2'b11;
        #10;

        if (current_state == 3'd0 && failed_attempts == 2'd0 &&
            lockout == 1'b0)
            $display("TEST 6: PASS - System recovered after reset");
        else begin
            $display("TEST 6: FAIL - Reset recovery incorrect");
            errors = errors + 1;
        end

        // TEST 7: Correct sequence after reset
        press_key(2'b00);
        press_key(2'b01);
        press_key(2'b10);
        press_key(2'b00);

        #1;

        if (unlock == 1'b1 && failed_attempts == 2'd0)
            $display("TEST 7: PASS - Correct sequence works after reset");
        else begin
            $display("TEST 7: FAIL - Correct sequence failed after reset");
            errors = errors + 1;
        end

        #9;

        $display("========================================");

        if (errors == 0)
            $display("ALL TESTS PASSED");
        else
            $display("SIMULATION FAILED - %0d TEST(S) FAILED", errors);

        $display("========================================");

        $finish;
    end

endmodule
