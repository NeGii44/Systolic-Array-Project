`timescale 1ns / 1ps
`include "systolic_array.sv"

module tb_systolic_array;

    // 1. Declare signals
    logic               clk;
    logic               reset;
    logic               en;
    logic signed [7:0]  weights [0:7];
    logic signed [7:0]  pixels_in [0:7];
    logic signed [31:0] total_psum;

    // 2. Instantiate the 8-PE Array
    systolic_array uut (
        .clk(clk),
        .reset(reset),
        .en(en),
        .weights(weights),
        .pixels_in(pixels_in),
        .total_psum(total_psum)
    );

    // 3. Memory Arrays for Hex Data
    logic signed [7:0] image_mem  [0:783]; 
    logic signed [7:0] weight_mem [0:50175]; 

    // 4. Clock Generation
    always #5 clk = ~clk;

    // 5. Main Simulation Block
    initial begin
        // Initialize signals
        clk = 0;
        reset = 1;
        en = 0;
        for (int i=0; i<8; i++) begin
            weights[i] = 0;
            pixels_in[i] = 0;
        end

        // Load the Python hex files
        $readmemh("hex_files/sample_image.hex", image_mem);
        $readmemh("hex_files/fc1_weight.hex", weight_mem); 

        #15 reset = 0;
        
        $display("--- Starting 8-PE Array Operations ---");
        en = 1;
        
        // Feed data in chunks of 8
        // We will run 98 clock cycles to see the array in action
        for (int cycle = 0; cycle < 98; cycle++) begin
            @(posedge clk); #1; // Wait for clock edge
            
            // Load 8 pixels and 8 weights simultaneously
            for (int i = 0; i < 8; i++) begin
                pixels_in[i] = image_mem[(cycle * 8) + i];
                weights[i]   = weight_mem[(cycle * 8) + i];
            end
            
            $display("Cycle %0d: Processing 8 MACs... Array PSum = %0d", cycle, total_psum);
        end
        
        @(posedge clk);
        en = 0;
        
        $display("--- Final Total PSum: %0d ---", total_psum);
        #20 $finish;
    end

endmodule