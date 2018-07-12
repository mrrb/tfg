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
 *     Initial: 2018/04/21      Mario Rubio
 */


// 
module serial_write #(parameter BAUD_DIVIDER = 234,
                      parameter DATA_BITS    = 8)
                     (input clk,
                      input tx,
                      input [DATA_BITS-1:0]data,
                      input save_data,
                      output TiP);

    localparam CTRL_LEN = $clog2(DATA_BITS+2)/$clog2(2);

    // Baud clk generator
    reg [BAUD_DIVIDER-1:0]clk_baud;
    
    // Data buffer
    reg [DATA_BITS-1+2:0]buffer = {(DATA_BITS+2){1'b0}};

    // Tx register
    reg tx_r = 1'b1;

    // Transmission in progress and counter registers
    reg TiP_r = 1'b0;
    reg [CTRL_LEN-1:0]tx_ctrl_r = {CTRL_LEN{1'b0}};

    always @(posedge clk) begin
        if((write_enable == 1'b1) && !TiP_r) begin
            TiP_r  <= 1'b1;
            buffer <= {1'b1, data, 1'b0};
        end 
    end

    always @(posedge clk_baud[BAUD_DIVIDER-1]) begin
        if((TiP_r == 1'b1) && (tx_ctrl_r != CTRL_LEN-1)) begin
            tx_ctrl_r <= tx_ctrl_r + 1'd1;
            tx_r <= buffer[0];
            buffer <= buffer>>1;
        end
        else if(tx_ctrl_r == CTRL_LEN-1) begin
            tx_ctrl_r <= 0;
            TiP_r <= 1'b0;
        end
        else begin
            TiP_r <= 1'b0;
            tx <= 1'b1;
        end
    end

    assign tx  = tx_r;
    assign TiP = TiP_r;

endmodule