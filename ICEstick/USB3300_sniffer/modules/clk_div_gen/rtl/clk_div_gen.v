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
 *     Initial: 2018/05/17      Mario Rubio
 */

module clk_div_gen #(
                     parameter DIVIDER = 9
                    )
                    (
                     input  wire clk,
                     input  wire enable,
                     output wire new_clk,
                     output wire clk_pulse
                    );

    // Main clock gen
    reg  [DIVIDER-1:0]new_clk_r = {DIVIDER{1'b0}};
    assign new_clk = (enable == 1'b1) ? new_clk_r[DIVIDER-1] : 1'b0;
    always @(posedge clk) begin
        if(enable) begin
            new_clk_r <= new_clk_r + 1;
        end
        else begin
            new_clk_r <= {DIVIDER{1'b1}};
        end
    end

    // Pulse gen
    reg baud_last_r    = 1'b0;
    reg baud_posedge_r = 1'b0;
    always @(posedge clk) begin
        baud_posedge_r  <= !baud_last_r & new_clk;
    end
    always @(posedge clk) begin
        if(enable)
            baud_last_r <= new_clk;
    end
    assign clk_pulse = baud_posedge_r;

endmodule