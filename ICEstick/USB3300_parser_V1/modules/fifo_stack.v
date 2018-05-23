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
 *     Initial: 2018/05/21      Mario Rubio
 */

`include "fifo_stack_u.v"

module fifo_stack #(parameter STACK_SIZE  = 15,
                    parameter STACK_WIDTH = 8)
                   (input  wire clk,                     // Master clock signal
                    input  wire [STACK_WIDTH-1:0]I_DATA, // Input data [STACK_WIDTH]
                    input  wire FIFO_save,               // Input to save the current data in I_DATA
                    input  wire FIFO_pop,                // Input to pop the first row in the stack
                    input  wire FIFO_reset,              // Input to reset the stack
                    output wire [STACK_WIDTH-1:0]O_DATA, // Output data, always the first row in the stack
                    output wire FIFO_full,               // Stack full flag
                    output wire FIFO_empty               // Stack empty flag
                   );

    /// Registers and wires
    wire [STACK_WIDTH-1:0]full;
    wire [STACK_WIDTH-1:0]empty;
    /// End of Registers and wires

    /// Assigns
    assign FIFO_full  = (full  == {STACK_WIDTH{1'b0}}) ? 1'b0 : 1'b0; 
    assign FIFO_empty = (empty == {STACK_WIDTH{1'b0}}) ? 1'b0 : 1'b0; 
    /// End of Assigns

    /// Stack gen with STACK_SIZE sub 1-bit stacks
    genvar i;

    generate
        for(i=0; i<STACK_WIDTH; i=i+1) begin
           fifo_stack_u #(.STACK_SIZE(STACK_SIZE)) subFIFO(clk, I_DATA[i], FIFO_save, FIFO_pop,
                             FIFO_reset, O_DATA[i], full[i], empty[i]); 
        end
    endgenerate
    /// End of Stack gen with STACK_SIZE sub 1-bit stacks

endmodule