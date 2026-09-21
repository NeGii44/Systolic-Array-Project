`timescale 1ns / 1ps

module tb_top;

    // System signals
    reg sys_clk;
    reg rst_n;

    // SPI signals (simulating the ESP32)
    reg spi_cs;
    reg spi_clk;
    reg spi_mosi;

    // Dummy Weights for testing
    reg signed [7:0] weight_n0, weight_n1, weight_n2, weight_n3;
    reg signed [7:0] weight_n4, weight_n5, weight_n6, weight_n7;

    // Outputs from the accelerator
    wire batch_done;
    wire signed [31:0] out_neuron0, out_neuron1, out_neuron2, out_neuron3;
    wire signed [31:0] out_neuron4, out_neuron5, out_neuron6, out_neuron7;

    // Instantiate Top Module
    accelerator_top uut (
        .sys_clk(sys_clk),
        .rst_n(rst_n),
        .spi_cs(spi_cs),
        .spi_clk(spi_clk),
        .spi_mosi(spi_mosi),
        .weight_n0(weight_n0), .weight_n1(weight_n1), .weight_n2(weight_n2), .weight_n3(weight_n3),
        .weight_n4(weight_n4), .weight_n5(weight_n5), .weight_n6(weight_n6), .weight_n7(weight_n7),
        .batch_done(batch_done),
        .out_neuron0(out_neuron0), .out_neuron1(out_neuron1), .out_neuron2(out_neuron2), .out_neuron3(out_neuron3),
        .out_neuron4(out_neuron4), .out_neuron5(out_neuron5), .out_neuron6(out_neuron6), .out_neuron7(out_neuron7)
    );

    // Tang Nano 20K System Clock (27 MHz = ~37ns period)
    always #18.5 sys_clk = ~sys_clk;

    // Task to simulate ESP32 sending 1 byte over SPI (1 MHz SPI clock)
    task send_spi_byte;
        input [7:0] data;
        integer i;
        begin
            spi_cs = 0; // Active low
            #500;
            for (i = 7; i >= 0; i = i - 1) begin
                spi_mosi = data[i]; // Send MSB first
                #500;
                spi_clk = 1; // Rising edge (FPGA samples here)
                #500;
                spi_clk = 0; // Falling edge
            end
            #500;
            spi_cs = 1; // Deselect
            #1000;      // Small delay between bytes just like real hardware
        end
    endtask

    integer j;

    initial begin
        $dumpfile("final_chip.vcd");
        $dumpvars(0, tb_top);

        // Initialize
        sys_clk = 0;
        rst_n = 0;
        spi_cs = 1;
        spi_clk = 0;
        spi_mosi = 0;

        // Set dummy weights for the 8 parallel neurons
        weight_n0 = 8'd1; weight_n1 = 8'd2; weight_n2 = 8'd3; weight_n3 = 8'd4;
        weight_n4 = 8'd5; weight_n5 = 8'd6; weight_n6 = 8'd7; weight_n7 = 8'd8;

        // Release Reset
        #100 rst_n = 1;
        #100;

        $display("--- Starting ESP32 SPI Transmission ---");
        
        // Send exactly 784 bytes to trigger the compute engine
        // We send a pixel value of '2' for the first byte, and '1' for the remaining 783 bytes
        send_spi_byte(8'd2);
        for (j = 1; j < 784; j = j + 1) begin
            send_spi_byte(8'd1);
        end

        $display("--- 784 Bytes Received. Waiting for Compute Engine ---");

        // Wait for the math engine to complete its 784-cycle loop
        wait(batch_done == 1'b1);
        
        #100;
        $display("Neuron 0 Final Sum: %d", out_neuron0);
        $display("Neuron 7 Final Sum: %d", out_neuron7);
        
        #100;
        $display("Top-Level Simulation Complete.");
        $finish;
    end

endmodule