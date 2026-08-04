`timescale 1ns / 1ps
`include "pe.sv"
module systolic_array (
    input  logic               clk,
    input  logic               reset,
    input  logic               en,
    // SystemVerilog allows passing arrays directly through ports!
    input  logic signed [7:0]  weights [0:7],
    input  logic signed [7:0]  pixels_in [0:7],
    output logic signed [31:0] total_psum
);

    // Array to hold the individual partial sums from each PE
    logic signed [31:0] pe_psums [0:7];

    // Generate block to automatically instantiate 8 PEs
    genvar i;
    generate
        for (i = 0; i < 8; i++) begin : pe_array
            pe u_pe (
                .clk(clk),
                .reset(reset),
                .en(en),
                .weight(weights[i]),
                .pixel_in(pixels_in[i]),
                .psum(pe_psums[i])
            );
        end
    endgenerate

    // Combinational logic to sum the outputs of all 8 PEs instantly
    always_comb begin
        total_psum = pe_psums[0] + pe_psums[1] + pe_psums[2] + pe_psums[3] + 
                     pe_psums[4] + pe_psums[5] + pe_psums[6] + pe_psums[7];
    end

endmodule