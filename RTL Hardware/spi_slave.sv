`timescale 1ns / 1ps
module spi_slave (
    input wire sys_clk,      
    input wire rst_n,        
    
    // SPI Pins
    input wire spi_cs,       
    input wire spi_clk,      
    input wire spi_mosi,     
    
    // Output Interface
    output reg [7:0] rx_data,  
    output reg rx_valid        
);

    // Clock Domain Crossing Synchronizers
    reg [2:0] spi_clk_sync;
    reg [2:0] spi_cs_sync;
    reg [1:0] spi_mosi_sync;

    always @(posedge sys_clk or negedge rst_n) begin
        if (!rst_n) begin
            spi_clk_sync  <= 3'b000;
            spi_cs_sync   <= 3'b111;
            spi_mosi_sync <= 2'b00;
        end else begin
            spi_clk_sync  <= {spi_clk_sync[1:0], spi_clk};
            spi_cs_sync   <= {spi_cs_sync[1:0], spi_cs};
            spi_mosi_sync <= {spi_mosi_sync[0], spi_mosi};
        end
    end

    wire spi_clk_rising = (spi_clk_sync[2:1] == 2'b01);
    wire cs_active = ~spi_cs_sync[1];

    reg [2:0] bit_counter;
    reg [7:0] shift_reg;

    always @(posedge sys_clk or negedge rst_n) begin
        if (!rst_n) begin
            bit_counter <= 3'd0;
            shift_reg   <= 8'd0;
            rx_data     <= 8'd0;
            rx_valid    <= 1'b0;
        end else begin
            rx_valid <= 1'b0; 

            if (cs_active) begin
                if (spi_clk_rising) begin
                    shift_reg <= {shift_reg[6:0], spi_mosi_sync[1]};
                    bit_counter <= bit_counter + 1'b1;

                    if (bit_counter == 3'd7) begin
                        rx_data  <= {shift_reg[6:0], spi_mosi_sync[1]};
                        rx_valid <= 1'b1;
                    end
                end
            end else begin
                bit_counter <= 3'd0;
            end
        end
    end

endmodule