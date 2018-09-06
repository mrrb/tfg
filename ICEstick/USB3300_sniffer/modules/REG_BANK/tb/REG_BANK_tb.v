/*
 * MIT License
 *
 * Copyright (c) 2018 Mario Rubio
 *
 MIT License

Copyright (c) 2015-present, Facebook, Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
 
 */

/*
 * Revision History:
 *     Initial:        2018/09/06        Mario Rubio
 */

module REG_BANK_tb();

    // Reg and wires
    reg clk = 1'b0;
    reg WD  = 1'b0;
    reg [15:0]ADDR = 0;
    reg [7:0]DATA_in = 0;

    wire [7:0]DATA_out;

    // Module init
    REG_BANK bank (clk, WD, ADDR, DATA_in, DATA_out);

    // Clock
    always #1 clk = ~clk;

    initial begin
        $dumpfile("sim/REG_BANK_tb.vcd");
        $dumpvars(0, REG_BANK_tb);

        #0 DATA_in = 16'h9D; WD = 1;
        #2 WD = 0; ADDR = 1; DATA_in = DATA_in - 5; WD = 1;
        #2 WD = 0;

        #2 ADDR = 0;

        #5 $finish;
    end

endmodule