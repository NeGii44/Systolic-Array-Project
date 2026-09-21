`timescale 1ns / 1ps

module tb_pe;

    reg clk;
    reg rst_n;
    reg clr;
    reg signed [7:0] activation;
    reg signed [7:0] weight;
    wire signed [31:0] psum;

    pe uut (
        .clk(clk),
        .rst_n(rst_n),
        .clr(clr),
        .activation(activation),
        .weight(weight),
        .psum(psum)
    );

    // Clock generation (10ns period)
    always #5 clk = ~clk;

    initial begin
        $dumpfile("pe_sim.vcd");
        $dumpvars(0, tb_pe);

        // Initialize Inputs
        clk = 0;
        rst_n = 0;
        clr = 0;
        activation = 0;
        weight = 0;

        // Apply Global Reset
        #20 rst_n = 1;

        // Test MAC Operation (Cycle 1)
        #10;
        activation = 8'd10;
        weight = 8'd2; // Expected psum: 20

        // Test MAC Operation (Cycle 2)
        #10;
        activation = 8'd5;
        weight = 8'd3; // Expected psum: 20 + 15 = 35
        
        #10;
        
        // Test the new CLR signal (Simulating the end of a 784-cycle batch)
        clr = 1;
        #10;
        clr = 0;
        
        // Ensure MAC starts from 0 again
        activation = 8'd4;
        weight = 8'd4; // Expected psum: 16 (not 35 + 16)

        #20;
        $display("PE Simulation Complete.");
        $finish;
    end

endmodule