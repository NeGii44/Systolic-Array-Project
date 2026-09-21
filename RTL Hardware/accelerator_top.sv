`timescale 1ns / 1ps
module accelerator_top (
    input wire sys_clk,
    input wire rst_n,

    input wire spi_cs,
    input wire spi_clk,
    input wire spi_mosi,

    input wire signed [7:0] weight_n0, input wire signed [7:0] weight_n1,
    input wire signed [7:0] weight_n2, input wire signed [7:0] weight_n3,
    input wire signed [7:0] weight_n4, input wire signed [7:0] weight_n5,
    input wire signed [7:0] weight_n6, input wire signed [7:0] weight_n7,

    output wire batch_done,
    output wire signed [31:0] out_neuron0, output wire signed [31:0] out_neuron1,
    output wire signed [31:0] out_neuron2, output wire signed [31:0] out_neuron3,
    output wire signed [31:0] out_neuron4, output wire signed [31:0] out_neuron5,
    output wire signed [31:0] out_neuron6, output wire signed [31:0] out_neuron7
);

    wire [7:0] rx_data;
    wire rx_valid;
    reg [9:0] write_ptr;
    
    wire [9:0] pixel_read_addr;
    wire signed [7:0] pixel_read_data;
    
    wire pe_clr;
    wire pe_en; // NEW
    wire [9:0] weight_addr; 
    
    reg compute_start;

    always @(posedge sys_clk or negedge rst_n) begin
        if (!rst_n) begin
            write_ptr <= 10'd0;
            compute_start <= 1'b0;
        end else begin
            compute_start <= 1'b0; 
            if (rx_valid) begin
                write_ptr <= write_ptr + 1'b1;
                if (write_ptr == 10'd783) begin
                    compute_start <= 1'b1;
                    write_ptr <= 10'd0; 
                end
            end
        end
    end

    spi_slave u_spi (
        .sys_clk(sys_clk), .rst_n(rst_n), .spi_cs(spi_cs),
        .spi_clk(spi_clk), .spi_mosi(spi_mosi), .rx_data(rx_data), .rx_valid(rx_valid)
    );

    pixel_bram u_bram (
        .clk(sys_clk), .we(rx_valid), .write_addr(write_ptr), .write_data(rx_data),
        .read_addr(pixel_read_addr), .read_data(pixel_read_data)
    );

    controller u_ctrl (
        .clk(sys_clk), .rst_n(rst_n), .start(compute_start),
        .pixel_addr(pixel_read_addr), .weight_addr(weight_addr),
        .pe_clr(pe_clr), .pe_en(pe_en), .batch_done(batch_done) // Updated
    );

    systolic_array u_array (
        .clk(sys_clk), .rst_n(rst_n), .clr(pe_clr), .en(pe_en), // Updated
        .pixel_data(pixel_read_data),
        .weight_n0(weight_n0), .weight_n1(weight_n1), .weight_n2(weight_n2), .weight_n3(weight_n3),
        .weight_n4(weight_n4), .weight_n5(weight_n5), .weight_n6(weight_n6), .weight_n7(weight_n7),
        .out_neuron0(out_neuron0), .out_neuron1(out_neuron1), .out_neuron2(out_neuron2), .out_neuron3(out_neuron3),
        .out_neuron4(out_neuron4), .out_neuron5(out_neuron5), .out_neuron6(out_neuron6), .out_neuron7(out_neuron7)
    );

endmodule