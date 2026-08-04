`timescale 1ns / 1ps
`include "pe.sv"

module tb_pe;

    // 1. Declare signals to connect to the PE
    logic               clk;
    logic               reset;
    logic               en;
    logic signed [7:0]  weight;
    logic signed [7:0]  pixel_in;
    logic signed [31:0] psum;

    // 2. Instantiate the Processing Element
    pe uut (
        .clk(clk),
        .reset(reset),
        .en(en),
        .weight(weight),
        .pixel_in(pixel_in),
        .psum(psum)
    );

    // 3. Create Memory Arrays to hold the Hex data
    logic signed [7:0] image_mem  [0:783]; 
    logic signed [7:0] weight_mem [0:50175]; // Holds the entire 64x784 weight matrix

    // 4. Generate a 10ns Clock
    always #5 clk = ~clk;

    // 5. Main Simulation Block
    initial begin
        // Initialize signals
        clk = 0;
        reset = 1;
        en = 0;
        weight = 0;
        pixel_in = 0;

        // Load the Python hex files into SystemVerilog memory arrays
        $readmemh("hex_files/sample_image.hex", image_mem);
        $readmemh("hex_files/fc1_weight.hex", weight_mem); 

        #15 reset = 0; // Release reset
        
        $display("--- Starting MAC Operations ---");
        
        // Feed the first 8 pixels and weights into the PE
        en = 1;
        for (int i = 0; i < 8; i++) begin
            @(posedge clk); #1; // Wait for clock edge, add 1ns delay for stability
            pixel_in = image_mem[i];
            weight   = weight_mem[i];
            $display("Cycle %0d: Pixel=%0d, Weight=%0d, PSum=%0d", i, pixel_in, weight, psum);
        end
        
        @(posedge clk);
        en = 0; // Stop accumulation
        
        $display("--- Final Partial Sum: %0d ---", psum);
        
        #20 $finish; // End simulation
    end

    // Optional: Dump waveforms for GTKWave
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_pe);
    end

endmodule