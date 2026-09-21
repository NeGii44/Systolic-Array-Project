`timescale 1ns / 1ps

module controller (
    input wire clk,
    input wire rst_n,
    input wire start,
    
    output wire [9:0] pixel_addr,
    output wire [9:0] weight_addr,
    output reg pe_clr,
    output reg pe_en,     // NEW
    output reg batch_done
);

    typedef enum logic [1:0] {IDLE, COMPUTE, DONE} state_t;
    state_t state, next_state;
    reg [9:0] cycle_count;

    // BRAM Read Latency Synchronizer (1-cycle delay)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) pe_en <= 1'b0;
        else pe_en <= (state == COMPUTE);
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            cycle_count <= 10'd0;
        end else begin
            state <= next_state;
            if (state == COMPUTE) cycle_count <= cycle_count + 1'b1;
            else if (state == IDLE) cycle_count <= 10'd0;
        end
    end

    always @(*) begin
        next_state = state;
        batch_done = 1'b0;
        pe_clr = 1'b0;

        case (state)
            IDLE: begin
                if (start) begin
                    pe_clr = 1'b1; 
                    next_state = COMPUTE;
                end
            end
            COMPUTE: begin
                if (cycle_count == 10'd783) next_state = DONE;
            end
            DONE: begin
                batch_done = 1'b1; 
                next_state = IDLE; 
            end
        endcase
    end

    assign pixel_addr = cycle_count;
    assign weight_addr = cycle_count;

endmodule