`timescale 1ns / 1ps
`include "accelerator_top.sv"

module tb_top;

    logic clk;
    logic reset;
    logic start;
    logic done;
    logic signed [31:0] final_psum;

    // Instantiate the complete chip
    accelerator_top uut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .done(done),
        .final_psum(final_psum)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_top);
        // Initialize
        clk = 0;
        reset = 1;
        start = 0;

        // Hold reset for a moment, then release
        #15 reset = 0;
        
        // "Press" the start button for one clock cycle
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        $display("--- Chip Started. Waiting for calculation to finish... ---");

        // Wait until the controller fires the 'done' signal
        wait(done == 1'b1);
        
        $display("--- DONE! ---");
        $display("Final Neuron Value: %0d", final_psum);

        #20 $finish;
    end
endmodule