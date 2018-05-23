/*
 * MIT License
 *
 * Copyright (c) 2018 Mario Rubio
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the 'Software'), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

/*
 * Revision History:
 *     Initial: 2018/05/22      Mario Rubio
 */

module fifo_stack_u #(parameter STACK_SIZE = 8)
                     (input  wire clk,       // Reference clock
                      input  wire i_data,    // New input data
                      input  wire save,      // Input to save the current bit in i_data
                      input  wire pop,       // Input to pop the first bit in the stack
                      input  wire reset,     // Input to reset the stack
                      output wire o_data,    // Output bit, always the first bit in the stack
                      output wire fifo_full, // Stack full flag
                      output wire fifo_empty,// Stack empty flag
                      output wire fifo_busy  // Module Busy, no new operation allowed
                      );

    localparam STACK_SIZE_N = $clog2(STACK_SIZE+1)/$clog2(2);

    /// FIFO regs and wires
    // Outputs
    reg o_data_r = 1'b0; assign o_data = o_data_r;

    // Inputs
    reg i_data_r = 1'b0;
    reg save_r   = 1'b0;
    reg pop_r    = 1'b0;
    reg reset_r  = 1'b0;
    always @(posedge clk) begin
        if(fifo_s_IDLE && save == 1'b1) begin
            i_data_r <= i_data;
        end
    end
    always @(posedge clk) begin
        save_r   <= save;
        pop_r    <= pop;
        reset_r  <= reset;
    end

    // Buffers
    reg [STACK_SIZE-1:0]memory = {STACK_SIZE{1'b0}};

    // Control registers
    reg [STACK_SIZE_N-1:0]fifo_position_r = {STACK_SIZE_N{1'b0}};
    reg [1:0]fifo_state_r = 2'b0;

    // Flags
    wire fifo_s_IDLE;
    wire fifo_s_SAVE;
    wire fifo_s_POP;
    wire fifo_s_RST;

    // Assigns
    assign fifo_s_IDLE = (fifo_state_r == FIFO_IDLE) ? 1'b1 : 1'b0;
    assign fifo_s_SAVE = (fifo_state_r == FIFO_SAVE) ? 1'b1 : 1'b0;
    assign fifo_s_POP  = (fifo_state_r == FIFO_POP)  ? 1'b1 : 1'b0;
    assign fifo_full   = (fifo_position_r == (STACK_SIZE+1)) ? 1'b1 : 1'b0;
    assign fifo_empty  = (fifo_position_r == 0) ? 1'b1 : 1'b0;
    assign fifo_busy   = !fifo_s_IDLE;

    /// End of FIFO regs and wires

    /// FIFO states
    localparam FIFO_IDLE = 2'b00; // Default state. Do nothing.
    localparam FIFO_SAVE = 2'b01; // Save a new value into the memory
    localparam FIFO_POP  = 2'b10; // Pop the first value of the memory
    localparam FIFO_WAIT = 2'b11; // Delay to show the new values in the output
    /// End of FIFO states

    /// FIFO controller
    always @(posedge clk) begin
        if(reset_r) begin
            fifo_state_r <= FIFO_IDLE;
            memory <= {STACK_SIZE{1'b0}};
            fifo_position_r <= {STACK_SIZE_N{1'b0}};
        end
        else begin
            case(fifo_state_r)
                FIFO_IDLE: begin
                    if(save_r && !pop_r)
                        fifo_state_r <= FIFO_SAVE;
                    else if(pop_r && !save_r)
                        fifo_state_r <= FIFO_POP;
                    else
                        fifo_state_r <= FIFO_IDLE;
                end
                FIFO_SAVE: begin
                    fifo_state_r <= FIFO_WAIT;
                end
                FIFO_POP: begin
                    fifo_state_r <= FIFO_WAIT;
                end
                FIFO_WAIT: begin
                    fifo_state_r <= FIFO_IDLE;
                end
                default: begin
                    fifo_state_r <= FIFO_IDLE;
                end
            endcase
        end
    end

    always @(posedge clk) begin
        o_data_r <= memory[0];
    end

    // Memory modify
    always @(posedge clk) begin
        if(fifo_s_IDLE == 1'b1) begin
        end
        else if(fifo_s_SAVE == 1'b1) begin
            if(fifo_full == 1'b0) begin
                memory[fifo_position_r] <= i_data_r;
            end
        end
        else if(fifo_s_POP == 1'b1) begin
            if(fifo_empty == 1'b0) begin
                memory <= memory>>1;
            end
        end
    end

    // fifo position change
    always @(posedge clk) begin
        if(fifo_s_IDLE == 1'b1) begin
        end
        else if(fifo_s_SAVE == 1'b1) begin
            if(fifo_full == 1'b0) begin
                fifo_position_r <= fifo_position_r + 1'b1;
            end
        end
        else if(fifo_s_POP == 1'b1) begin
            if(fifo_empty == 1'b0) begin
                fifo_position_r <= fifo_position_r - 1'b1;
            end
        end
    end
    /// End of FIFO controller

endmodule