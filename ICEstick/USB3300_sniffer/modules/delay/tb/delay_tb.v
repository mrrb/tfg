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
 *     Initial: 2018/05/27      Mario Rubio
 */

module delay_tb();

    reg  d_in = 1'b0;
    reg  clk  = 1'b1;
    wire d_out;
    delay del (clk, d_in, d_out); // Module under test init

    // Clock
    always #1 clk = ~clk;

    initial begin
        $dumpfile("sim/delay_tb.vcd");
        $dumpvars(0, delay_tb);

        #2 d_in = 1;
        #4 d_in = 0;
        #2 d_in = 1;
        #2 d_in = 0;
        #2 d_in = 1;
        #2 d_in = 0;
        #2 d_in = 1;
        #4 d_in = 0;
        #4 d_in = 1;

        #10 $finish;
    end

endmodule