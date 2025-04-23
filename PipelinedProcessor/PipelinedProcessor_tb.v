`timescale 1ns / 1ps

module PipelinedProcessor_tb;

    // Inputs
    reg clk;
    reg reset;

    // Outputs
    wire [31:0] result;
    wire [31:0] instruction;

    // Instantiate the Unit Under Test (UUT)
    PipelinedProcessor uut (
        .clk(clk),
        .reset(reset),
        .result(result),
        .instruction(instruction)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Generate a clock with a 10 ns period
    end

    // Testbench logic
    initial begin
        // Initialize inputs
        reset = 1;

        // Apply reset
        #10 reset = 0;

        // Wait for some cycles to simulate execution
        #100;

        // End simulation
        $stop;
    end

    // Monitor outputs
    initial begin
        $monitor("Time: %d | Instruction: %h | Result: %d", $time, instruction, result);
    end

endmodule
