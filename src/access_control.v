`timescale 1ns / 1ps

module access_control(
    input clk,
    input reset,
    input [1:0] key,
    output reg unlock,
    output reg lockout,
    output reg [1:0] failed_attempts,
    output reg [2:0] current_state
);

    // FSM States
    parameter S0      = 3'd0,
              S1      = 3'd1,
              S2      = 3'd2,
              S3      = 3'd3,
              UNLOCK  = 3'd4,
              LOCKOUT = 3'd5;

    reg [2:0] next_state;
    reg [1:0] next_failed_attempts;

    // Sequential block: Update state and failed attempts
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= S0;
            failed_attempts <= 2'd0;
        end
        else begin
            current_state <= next_state;
            failed_attempts <= next_failed_attempts;
        end
    end

    // Combinational block: FSM logic
    always @(*) begin

        // Default values
        next_state = current_state;
        next_failed_attempts = failed_attempts;
        unlock = 1'b0;
        lockout = 1'b0;

        case (current_state)

            // Waiting for first key: A = 00
            S0: begin
                if (key == 2'b00)
                    next_state = S1;
            end

            // A received, waiting for B = 01
            S1: begin
                if (key == 2'b01)
                    next_state = S2;
                else begin
                    next_state = S0;

                    if (failed_attempts == 2'd2) begin
                        next_failed_attempts = 2'd3;
                        next_state = LOCKOUT;
                    end
                    else
                        next_failed_attempts = failed_attempts + 1'b1;
                end
            end

            // AB received, waiting for C = 10
            S2: begin
                if (key == 2'b10)
                    next_state = S3;
                else begin
                    next_state = S0;

                    if (failed_attempts == 2'd2) begin
                        next_failed_attempts = 2'd3;
                        next_state = LOCKOUT;
                    end
                    else
                        next_failed_attempts = failed_attempts + 1'b1;
                end
            end

            // ABC received, waiting for A = 00
            S3: begin
                if (key == 2'b00) begin
                    next_state = UNLOCK;
                    next_failed_attempts = 2'd0;
                end
                else begin
                    next_state = S0;

                    if (failed_attempts == 2'd2) begin
                        next_failed_attempts = 2'd3;
                        next_state = LOCKOUT;
                    end
                    else
                        next_failed_attempts = failed_attempts + 1'b1;
                end
            end

            // Access granted
            UNLOCK: begin
                unlock = 1'b1;
                next_state = S0;
            end

            // System locked after three failed attempts
            LOCKOUT: begin
                lockout = 1'b1;
                next_state = LOCKOUT;
            end

            default: begin
                next_state = S0;
                next_failed_attempts = 2'd0;
            end

        endcase
    end

endmodule
