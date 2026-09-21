`timescale 1ns / 1ps
module pe (
    input wire clk,
    input wire rst_n,
    input wire clr,
    input wire en,                      // NEW: Freeze accumulator if 0
    input wire signed [7:0] activation, 
    input wire signed [7:0] weight,     
    output reg signed [31:0] psum       
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            psum <= 32'd0;
        end else if (clr) begin
            psum <= 32'd0;
        end else if (en) begin
            psum <= psum + (activation * weight);
        end
    end

endmodule