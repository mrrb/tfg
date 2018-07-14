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

module USB3300_parser_tb ();


    reg  clk1 = 1'b0;
    reg  clk2 = 1'b0;
    reg  [7:0]DATA = 8'b0;
    reg  DIR  = 1'b0;
    reg  NXT  = 1'b0;
    reg  Rx   = 1'b0;
    wire Tx;
    wire STP;
    wire [4:0]LEDs;
    wire bauds;
    wire reset;

    USB3300_parser usb (clk1, clk2, DATA, DIR, NXT, Rx, Tx, STP, LEDs, bauds, reset);

    // Clock
    always #1 clk2 = ~clk2;

    initial begin
        $dumpfile("USB3300_parser_tb.vcd");
        $dumpvars(0, USB3300_parser_tb);

        #4

        $display("Data: %8b  DIR: %1b  NXT: %1b", DATA, DIR, NXT);
        #2 DIR = 1; DATA = "A";

        $display("Data: %8b  DIR: %1b  NXT: %1b", DATA, DIR, NXT);
        #2 DIR = 1; DATA = "B";

        $display("Data: %8b  DIR: %1b  NXT: %1b", DATA, DIR, NXT);
        #2 DIR = 1; DATA = "C";

        $display("Data: %8b  DIR: %1b  NXT: %1b", DATA, DIR, NXT);
        #2 DIR = 1; DATA = "D";

        $display("Data: %8b  DIR: %1b  NXT: %1b", DATA, DIR, NXT);
        #2 DIR = 1; DATA = "E";

        $display("Data: %8b  DIR: %1b  NXT: %1b", DATA, DIR, NXT);
        #2 DIR = 1; DATA = "F";

        $display("Data: %8b  DIR: %1b  NXT: %1b", DATA, DIR, NXT);
        #2 DIR = 0; DATA = 0;

        $display("Data: %8b  DIR: %1b  NXT: %1b", DATA, DIR, NXT);
        #2 DIR = 0; DATA = 0;

        $display("Data: %8b  DIR: %1b  NXT: %1b", DATA, DIR, NXT);
        #2 DIR = 0; DATA = 0;

        #60000 $finish;
    end

endmodule