`timescale 1ns / 1ps
`include "controller.sv"
`include "systolic_array.sv"

module accelerator_top (
    input  logic               clk,
    input  logic               reset,
    input  logic               start,
    output logic               done,
    output logic signed [31:0] final_psum
);

    // 1. Internal Wires (connecting the modules together)
    logic       pe_en;
    logic [6:0] mem_addr;
    
    // Arrays to hold the 8 items being fetched from memory
    logic signed [7:0] current_weights [0:7];
    logic signed [7:0] current_pixels  [0:7];

    // 2. On-Chip Memory (Block RAM / ROM)
    // We store the full 784 elements here
    logic signed [7:0] image_rom  [0:783]; 
    logic signed [7:0] weight_rom [0:783]; // 784 weights for 1 neuron

    // Initialize the ROM with the Python hex files
    initial begin
        $readmemh("hex_files/sample_image.hex", image_rom);
        $readmemh("hex_files/fc1_weight.hex", weight_rom); 
    end

    // Combinational logic to fetch 8 pixels/weights based on the controller's address
    always_comb begin
        for (int i = 0; i < 8; i++) begin
            // mem_addr goes 0 to 97. We multiply by 8 and add the offset (0-7)
            current_pixels[i]  = image_rom[(mem_addr * 8) + i];
            current_weights[i] = weight_rom[(mem_addr * 8) + i];
        end
    end

    // 3. Instantiate the Brain (Controller)
    controller u_ctrl (
        .clk(clk),
        .reset(reset),
        .start(start),
        .pe_en(pe_en),
        .mem_addr(mem_addr),
        .done(done)
    );

    // 4. Instantiate the Muscle (Systolic Array)
    systolic_array u_array (
        .clk(clk),
        .reset(reset),
        .en(pe_en),
        .weights(current_weights),
        .pixels_in(current_pixels),
        .total_psum(final_psum)
    );

endmodule