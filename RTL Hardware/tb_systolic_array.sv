`timescale 1ns / 1ps

module tb_systolic_array;

    reg clk;
    reg rst_n;
    reg clr;
    reg signed [7:0] pixel_data;
    
    reg signed [7:0] weight_n0, weight_n1, weight_n2, weight_n3;
    reg signed [7:0] weight_n4, weight_n5, weight_n6, weight_n7;
    
    wire signed [31:0] out_neuron0, out_neuron1, out_neuron2, out_neuron3;
    wire signed [31:0] out_neuron4, out_neuron5, out_neuron6, out_neuron7;

    systolic_array uut (
        .clk(clk), .rst_n(rst_n), .clr(clr),
        .pixel_data(pixel_data),
        .weight_n0(weight_n0), .weight_n1(weight_n1), .weight_n2(weight_n2), .weight_n3(weight_n3),
        .weight_n4(weight_n4), .weight_n5(weight_n5), .weight_n6(weight_n6), .weight_n7(weight_n7),
        .out_neuron0(out_neuron0), .out_neuron1(out_neuron1), .out_neuron2(out_neuron2), .out_neuron3(out_neuron3),
        .out_neuron4(out_neuron4), .out_neuron5(out_neuron5), .out_neuron6(out_neuron6), .out_neuron7(out_neuron7)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("array_sim.vcd");
        $dumpvars(0, tb_systolic_array);

        clk = 0;
        rst_n = 0;
        clr = 0;
        pixel_data = 0;
        weight_n0 = 0; weight_n1 = 0; weight_n2 = 0; weight_n3 = 0;
        weight_n4 = 0; weight_n5 = 0; weight_n6 = 0; weight_n7 = 0;

        #20 rst_n = 1;

        // Feed Pixel 1
        #10;
        pixel_data = 8'd10;
        // Assign 8 unique weights to represent 8 different neurons
        weight_n0 = 8'd1; weight_n1 = 8'd2; weight_n2 = 8'd3; weight_n3 = 8'd4;
        weight_n4 = 8'd5; weight_n5 = 8'd6; weight_n6 = 8'd7; weight_n7 = 8'd8;
        
        // Feed Pixel 2
        #10;
        pixel_data = 8'd2;
        weight_n0 = 8'd1; weight_n1 = 8'd1; weight_n2 = 8'd1; weight_n3 = 8'd1;
        weight_n4 = 8'd1; weight_n5 = 8'd1; weight_n6 = 8'd1; weight_n7 = 8'd1;

        #20;
        
        $display("Neuron 0 Final Sum: %d", out_neuron0); // Expected: (10*1) + (2*1) = 12
        $display("Neuron 7 Final Sum: %d", out_neuron7); // Expected: (10*8) + (2*1) = 82
        
        $finish;
    end

endmodule