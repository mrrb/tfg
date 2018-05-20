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
 *     Initial: 2018/04/24      Mario Rubio
 */


`include "serial_write.v"
`include "fifo_stack.v"
`include "USB3300_read.v"

module USB3300_receive_tb();

    wire tx;

    // Tests
    reg [7:0]letter = 8'h_4B;
    reg send_data   = 1'b_0;
    wire TiP;
    serial_write S_write(.clk(clk), .tx_data(letter), .send_data(send_data), .TiP(TiP), .tx(tx));
    // End of tests

    always 
        #1 clk <= ~clk;

    initial begin
        $dumpfile("USB3300_receive_tb.vcd");
        $dumpvars(0, USB3300_receive);

        #10 send_data = 0; 
        #10 send_data = 1;

        $finish;
    end

endmodule