`timescale 1ns / 1ps
module pixel_bram (
    input wire clk,
    
    // Write Port (Fed by the SPI Slave)
    input wire we,                       // Write Enable (connected to spi_slave rx_valid)
    input wire [9:0] write_addr,         // Memory index to write to (0 to 783)
    input wire signed [7:0] write_data,  // 8-bit pixel from ESP32
    
    // Read Port (Read by the Compute Engine)
    input wire [9:0] read_addr,          // Memory index requested by controller
    output reg signed [7:0] read_data    // 8-bit pixel sent to PEs
);

    // 784 bytes to hold exactly one 28x28 flattened MNIST image
    reg signed [7:0] ram [0:783];

    always @(posedge clk) begin
        // Write logic
        if (we) begin
            ram[write_addr] <= write_data;
        end
        
        // Synchronous read logic (Required for FPGA Block RAM inference)
        read_data <= ram[read_addr];
    end

endmodule