/*
 *
 * shift_register module
 * This module generates a pulse with a frequency proporcional to COUNTER_VAL and a pulse width equal to a clk_in cycle
 *
 * Parameters:
 *  - BITS. Size (in bits) of the shift register. There are in total BITS + 1 (output bit) 
 *
 * Inputs:
 *  - clk. Control clock. All operations are performed in its rising edge.
 *  - rst. Reset signal, active LOW.
 *  - bit_in. Bit that is going to be shifted into the register (modes 01 and 10).
 *  - DATA_IN. Data that is going to be stored into the register (mode 11).
 *  - mode. Operation mode selector (2 bits).
 *     > 00. Do nothing (Wait).
 *     > 01. Shift Left.
 *     > 10. Shift Right.
 *     > 11. Parallel input.
 *
 * Outputs:
 *  - bit_out. Bit that was shifted out from the register (modes 01 and 10).
 *  - DATA. Parallel Data stored in the register.
 *
 */

`default_nettype none

`ifdef ASYNC_RESET
    `define SHIFT_REGISTER_ASYNC_RESET or negedge rst
`else
    `define SHIFT_REGISTER_ASYNC_RESET
`endif

module shift_register #(
                        parameter BITS = 8 // Size of the shift register
                       )
                       (
                        // System signals
                        input  wire clk, // Reference clock
                        input  wire rst, // Reset signal, active LOW

                        // Serial data
                        input  wire bit_in,  // Bit shifted into the register in modes 01 and 10
                        output wire bit_out, // Bit shifted out of the register in modes 01 and 10

                        // Parallel data
                        input  wire [BITS-1:0]DATA_IN, // Parallel Data to be stored in mode 11
                        output wire [BITS-1:0]DATA,    // Data stored in the shift register

                        // Control signals
                        input  wire [1:0]mode // Operation mode
                       );


    /// Registers
    reg [BITS-1:0]DATA_r = {BITS{1'b0}}; // Main register
    reg bit_out_r        = 1'b0;         // Bit shifted-out in modes 01 and 10
    /// End of Registers

    /// Assigns
    assign DATA    = DATA_r;
    assign bit_out = bit_out_r;
    /// End of Assigns

    /// Modes
    localparam SR_MODE_WAIT        = 0;
    localparam SR_MODE_SHIFT_LEFT  = 1;
    localparam SR_MODE_SHIFT_RIGHT = 2;
    localparam SR_MODE_PARALLEL    = 3;
    /// End of Modes

    /// Controller
    always @(posedge clk `SHIFT_REGISTER_ASYNC_RESET) begin
        if(!rst) begin
            DATA_r <= {BITS{1'b0}};
            bit_out_r <= 1'b0;
        end
        else begin
            case(mode)
                SR_MODE_WAIT: begin
                    DATA_r <= 0;
                end
                SR_MODE_SHIFT_LEFT: begin
                    DATA_r <= {DATA_r[BITS-2:0], bit_in};
                    bit_out_r <= DATA_r[BITS-1];
                end
                SR_MODE_SHIFT_RIGHT: begin
                    DATA_r <= {bit_in, DATA_r[BITS-1:1]};
                    bit_out_r <= DATA_r[0];
                end
                SR_MODE_PARALLEL: begin
                    DATA_r <= DATA_IN;
                end
                default: begin
                    DATA_r <= 0;
                end
            endcase
        end
    end
    /// End of Controller

endmodule