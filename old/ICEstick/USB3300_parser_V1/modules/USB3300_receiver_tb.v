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
 *     Initial: 2018/05/24      Mario Rubio
 */

module USB3300_receiver_tb ();

    reg  clk = 1'b0;
    reg  DIR = 1'b0;
    reg  NXT = 1'b0;
    reg  [7:0]DATA = 8'b0;
    reg  ME  = 8'b1;
    wire [7:0]PID;
    wire [7:0]D2;
    wire [7:0]D1;
    wire [7:0]CMD;
    wire NP;
    wire busy;
    USB3300_receiver receiver (clk, DIR, NXT, DATA, ME, PID,
                               D2, D1, CMD, NP, busy);

    // Clock
    always #1 clk = ~clk;

    initial begin
        $dumpfile("USB3300_receiver.vcd");
        $dumpvars(0, USB3300_receiver_tb);

        #2

        $display("Initial>DATA: %8b  DIR: %1b  NXT: %1b", DATA, DIR, NXT);
        $display("PID: %8b  D1: %8b  D2: %8b  CMD: %8b  [%1b %1b]\n",
                  PID, D1, D2, CMD, NP, busy);
        #2 DATA = "A"; DIR = 1; NXT = 0;

        $display("Turn Around>DATA: %8b  DIR: %1b  NXT: %1b", DATA, DIR, NXT);
        $display("PID: %8b  D1: %8b  D2: %8b  CMD: %8b  [%1b %1b]\n",
                  PID, D1, D2, CMD, NP, busy);
        #2 DATA = "B"; DIR = 1; NXT = 0;

        $display("Rxd CMD>DATA: %8b  DIR: %1b  NXT: %1b", DATA, DIR, NXT);
        $display("PID: %8b  D1: %8b  D2: %8b  CMD: %8b  [%1b %1b]\n",
                  PID, D1, D2, CMD, NP, busy);
        #2 DATA = "C"; DIR = 1; NXT = 0;
        
        $display("PID>DATA: %8b  DIR: %1b  NXT: %1b", DATA, DIR, NXT);
        $display("PID: %8b  D1: %8b  D2: %8b  CMD: %8b  [%1b %1b]\n",
                  PID, D1, D2, CMD, NP, busy);
        #2 DATA = "D"; DIR = 1; NXT = 0;
        
        $display("D1>DATA: %8b  DIR: %1b  NXT: %1b", DATA, DIR, NXT);
        $display("PID: %8b  D1: %8b  D2: %8b  CMD: %8b  [%1b %1b]\n",
                  PID, D1, D2, CMD, NP, busy);
        #2 DATA = "B"; DIR = 1; NXT = 0;
        
        $display("Rxd CMD>DATA: %8b  DIR: %1b  NXT: %1b", DATA, DIR, NXT);
        $display("PID: %8b  D1: %8b  D2: %8b  CMD: %8b  [%1b %1b]\n",
                  PID, D1, D2, CMD, NP, busy);
        #2 DATA = "E"; DIR = 1; NXT = 0;
        
        $display("D2>DATA: %8b  DIR: %1b  NXT: %1b", DATA, DIR, NXT);
        $display("PID: %8b  D1: %8b  D2: %8b  CMD: %8b  [%1b %1b]\n",
                  PID, D1, D2, CMD, NP, busy);
        #2 DATA = 0; DIR = 0; NXT = 0;
        
        $display(">DATA: %8b  DIR: %1b  NXT: %1b", DATA, DIR, NXT);
        $display("PID: %8b  D1: %8b  D2: %8b  CMD: %8b  [%1b %1b]\n",
                  PID, D1, D2, CMD, NP, busy);

        $display(">DATA: %8b  DIR: %1b  NXT: %1b", DATA, DIR, NXT);
        $display("PID: %8b  D1: %8b  D2: %8b  CMD: %8b  [%1b %1b]\n",
                  PID, D1, D2, CMD, NP, busy);
        #2
        $display(">DATA: %8b  DIR: %1b  NXT: %1b", DATA, DIR, NXT);
        $display("PID: %8b  D1: %8b  D2: %8b  CMD: %8b  [%1b %1b]\n",
                  PID, D1, D2, CMD, NP, busy);
        #2
        $display(">DATA: %8b  DIR: %1b  NXT: %1b", DATA, DIR, NXT);
        $display("PID: %8b  D1: %8b  D2: %8b  CMD: %8b  [%1b %1b]\n",
                  PID, D1, D2, CMD, NP, busy);
        #2

        $display("Should be: PID: %8b. D1: %8b. D2: %8b. CMD: %8b", PID, D1, D2, CMD);

        #2

        #10 $finish;
    end

endmodule