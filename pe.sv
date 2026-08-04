`timescale 1ns / 1ps

module pe (
    input  logic               clk,
    input  logic               reset,
    input  logic               en,        // Enables accumulation
    input  logic signed [7:0]  weight,    // 8-bit INT8 weight
    input  logic signed [7:0]  pixel_in,  // 8-bit INT8 pixel/activation
    output logic signed [31:0] psum       // 32-bit partial sum to prevent overflow
);

    // Using always_ff enforces that this block creates flip-flops (registers)
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            psum <= 32'd0;
        end 
        else if (en) begin
            // Multiply the 8-bit numbers and add to the 32-bit accumulator
            psum <= psum + (weight * pixel_in);
        end
    end

endmodule