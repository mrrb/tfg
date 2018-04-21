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
 *     Initial: 2018/04/19      Mario Rubio
 */

// n*log(2)=log(8) -> n = log(8) / log(2) -> 

module FIFO_STACK #(parameter N_STACK_SIZE = 8)
                   (input wire data_in,
                    input wire clk,
                    input wire in_ctrl,
                    input wire out_ctrl,
                    output wire data_out,
                    output wire no_data,
                    output wire overflow);

    // Register that stored the current position of the FIFO stack
    localparam N_CTRL_BITS = ($clog2(N_STACK_SIZE) / $clog2(2));
    reg [N_CTRL_BITS-1:0]stack_ctrl = 0;

    // Register that stored the full stack
    reg [N_STACK_SIZE-1:0]stack;

    // Registers that stored the overflow and no data values
    reg overflow_r = 1'b0;
    reg no_data_r  = 1'b0;

    // Main FIFO controller
    always @ (posedge clk) begin
        if((in_ctrl & (!out_ctrl)) == 1'b_1) begin
            // Input mode
            //{N_CTRL_BITS{1'}} N_CTRL_BITS'd_{N_STACK_SIZE}
            if(stack_ctrl == N_STACK_SIZE) begin
                overflow_r <= 1'b1;
            end
            else begin
                stack[stack_ctrl+1] <= data_in;
                stack_ctrl <= stack_ctrl+1;
                overflow_r <= 1'b0;
            end
        end
        else if((out_ctrl & (!in_ctrl)) == 1'b_1) begin
            // Output mode
            stack_ctrl <= stack_ctrl-1;
            stack = stack>>1;
        end
        else begin
        end

        if(stack_ctrl == 0) begin
            no_data_r = 1'b1;
        end
        else begin
            no_data_r = 1'b0;
        end
    end

    assign data_out = stack[0];
    assign overflow = overflow_r;
    assign no_data  = no_data_rs;

endmodule