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

module fifo_stack #(parameter STACK_SIZE  = 10,
                    parameter STACK_WIDTH = 8)
                   (input  wire clk,
                    input  wire [STACK_WIDTH-1:0]I_DATA,
                    input  wire save_row,
                    input  wire pop_row,
                    output wire [STACK_WIDTH-1:0]O_DATA,
                    output wire full,
                    output wire empty
                   );

    localparam STACK_SIZE_n = $clog2(STACK_SIZE+1)/$clog2(2);
    /// FIFO regs and wires
    // Outputs
    reg [STACK_WIDTH-1:0]O_DATA_r = {STACK_WIDTH{1'b0}};

    // Inputs
    reg [STACK_WIDTH-1:0]I_DATA_r = {STACK_WIDTH{1'b0}};
    reg save_row_r = 1'b0;
    reg pop_row_r = 1'b0;
    always @(posedge clk) begin
        save_row_r <= save_row;
        pop_row_r  <= pop_row;
        I_DATA_r   <= I_DATA;
    end

    // Buffers
    reg [STACK_WIDTH-1:0]memory[STACK_SIZE-1:0];

    // Control registers
    reg [1:0]state_r = 2'b0;
    reg [STACK_SIZE_n-1:0]position = {STACK_SIZE_n{1'b0}};

    // Flags
    wire FIFO_s_IDLE;
    wire FIFO_s_SAVE;
    wire FIFO_s_POP;

    // Assigns
    assign O_DATA = O_DATA_r;
    assign FIFO_s_IDLE = (state_r == FIFO_IDLE) ? 1'b1 : 1'b0;
    assign FIFO_s_SAVE = (state_r == FIFO_SAVE) ? 1'b1 : 1'b0;
    assign FIFO_s_POP  = (state_r == FIFO_POP)  ? 1'b1 : 1'b0;
    assign empty = (position == 0) ? 1'b1 : 1'b0;
    assign full  = (position == (STACK_SIZE+1)) ? 1'b1 : 1'b0;

    /// End of FIFO regs and wires

    /// FIFO states
    localparam FIFO_IDLE = 2'b00; 
    localparam FIFO_SAVE = 2'b01; 
    localparam FIFO_POP  = 2'b10; 
    /// End of FIFO states

    /// FIFO controller
    always @(posedge clk) begin
        case(state_r)
            FIFO_IDLE: begin
                if(save_row_r) begin
                    state_r <= FIFO_SAVE;
                end
                else if(pop_row_r) begin
                    state_r <= FIFO_POP;
                end
                else begin
                    state_r <= FIFO_IDLE;
                end
            end
            FIFO_SAVE: begin
                state_r <= FIFO_IDLE;
            end
            FIFO_POP: begin
                state_r <= FIFO_IDLE;
            end
            default: begin
                state_r <= FIFO_IDLE;
            end
        endcase
    end

    // Memory modification
    reg i = 1'b0;
    always @(posedge clk) begin
        if(FIFO_s_SAVE == 1'b1) begin
            if(!full) begin
                for(i=0; i<STACK_WIDTH; i=i+1) begin
                    memory[i][position] <= I_DATA_r[i];
                end
                position <= position + 1;
            end
        end
        else if(FIFO_s_POP == 1'b1) begin
            if(!empty) begin
                for(i=0; i<STACK_WIDTH; i=i+1) begin
                    memory[i] <= memory[i]>>1;
                end
                position <= position - 1;
            end
        end
        else begin
        end
    end

    // Output register modification
    always @(posedge clk) begin
        if(FIFO_s_SAVE == 1'b1) begin
        end
        else if(FIFO_s_POP == 1'b1) begin
        end
        else begin
        end
    end

    /// End of FIFO controller

    /// FIFO assigns
    /// End of FIFO assigns

endmodule