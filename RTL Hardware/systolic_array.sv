`timescale 1ns / 1ps

module systolic_array (
    input wire clk,
    input wire rst_n,
    input wire clr,
    input wire en,  // NEW
    
    input wire signed [7:0] pixel_data,
    
    input wire signed [7:0] weight_n0, input wire signed [7:0] weight_n1,
    input wire signed [7:0] weight_n2, input wire signed [7:0] weight_n3,
    input wire signed [7:0] weight_n4, input wire signed [7:0] weight_n5,
    input wire signed [7:0] weight_n6, input wire signed [7:0] weight_n7,
    
    output wire signed [31:0] out_neuron0, output wire signed [31:0] out_neuron1,
    output wire signed [31:0] out_neuron2, output wire signed [31:0] out_neuron3,
    output wire signed [31:0] out_neuron4, output wire signed [31:0] out_neuron5,
    output wire signed [31:0] out_neuron6, output wire signed [31:0] out_neuron7
);

    pe pe0 (.clk(clk), .rst_n(rst_n), .clr(clr), .en(en), .activation(pixel_data), .weight(weight_n0), .psum(out_neuron0));
    pe pe1 (.clk(clk), .rst_n(rst_n), .clr(clr), .en(en), .activation(pixel_data), .weight(weight_n1), .psum(out_neuron1));
    pe pe2 (.clk(clk), .rst_n(rst_n), .clr(clr), .en(en), .activation(pixel_data), .weight(weight_n2), .psum(out_neuron2));
    pe pe3 (.clk(clk), .rst_n(rst_n), .clr(clr), .en(en), .activation(pixel_data), .weight(weight_n3), .psum(out_neuron3));
    pe pe4 (.clk(clk), .rst_n(rst_n), .clr(clr), .en(en), .activation(pixel_data), .weight(weight_n4), .psum(out_neuron4));
    pe pe5 (.clk(clk), .rst_n(rst_n), .clr(clr), .en(en), .activation(pixel_data), .weight(weight_n5), .psum(out_neuron5));
    pe pe6 (.clk(clk), .rst_n(rst_n), .clr(clr), .en(en), .activation(pixel_data), .weight(weight_n6), .psum(out_neuron6));
    pe pe7 (.clk(clk), .rst_n(rst_n), .clr(clr), .en(en), .activation(pixel_data), .weight(weight_n7), .psum(out_neuron7));

endmodule