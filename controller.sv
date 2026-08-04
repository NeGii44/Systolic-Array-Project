`timescale 1ns / 1ps

module controller (
    input  logic        clk,
    input  logic        reset,
    input  logic        start,       // Signal from master to begin calculation
    output logic        pe_en,       // Enables the PEs to accumulate
    output logic [6:0]  mem_addr,    // 7-bit address (0 to 97) to fetch memory
    output logic        done         // Pulses high when computation is finished
);

    // 1. Define FSM States using enum
    typedef enum logic [1:0] {
        IDLE    = 2'b00,
        COMPUTE = 2'b01,
        DONE    = 2'b10
    } state_t;

    state_t current_state, next_state;
    
    // Counter to track the 98 clock cycles
    logic [6:0] cycle_count;

    // 2. Sequential Logic (Clock-driven)
    // Updates the current state and increments the cycle counter
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;
            cycle_count   <= 7'd0;
        end else begin
            current_state <= next_state;
            
            // Only count up when we are actively computing
            if (current_state == COMPUTE) begin
                cycle_count <= cycle_count + 1;
            end else begin
                cycle_count <= 7'd0; // Reset counter when not computing
            end
        end
    end

    // 3. Combinational Logic (State Transitions & Outputs)
    always_comb begin
        // Default values to prevent accidental latches
        next_state = current_state;
        pe_en      = 0;
        done       = 0;
        mem_addr   = cycle_count;

        case (current_state)
            IDLE: begin
                // Wait for the start signal to begin processing
                if (start) begin
                    next_state = COMPUTE;
                end
            end
            
            COMPUTE: begin
                // Turn on the Systolic Array PEs
                pe_en = 1;
                
                // Once we hit the 98th cycle (0 to 97), move to DONE
                if (cycle_count == 7'd97) begin
                    next_state = DONE;
                end
            end
            
            DONE: begin
                // Fire the done flag for one clock cycle, then reset to IDLE
                done = 1;
                next_state = IDLE;
            end
            
            default: next_state = IDLE;
        endcase
    end

endmodule