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
 *     Initial:        2018/07/16        Mario Rubio
 */

module ULPI_tb ();

    // Registers and wires
    reg clk_int = 1'b0;
    reg clk_ext = 1'b0;
    reg rst = 1'b0;
    reg WD = 1'b0;
    reg RD = 1'b0;
    reg TD = 1'b0;
    reg LP = 1'b0;
    reg [5:0]ADDR = 6'b0;
    reg [7:0]DATA_IN = 8'b0;
    reg DIR = 1'b0;
    reg NXT = 1'b0;
    reg [7:0]ULPI_DATA_r = 8'b0;

    wire [7:0]DATA_OUT;
    wire STP;
    wire [7:0]ULPI_DATA_w;

    wire [7:0]ULPI_DATA;
    assign ULPI_DATA = (DIR == 1'b1) ? ULPI_DATA_r : ULPI_DATA_w;

    // Module Init
    ULPI UP_tb (clk_ext, clk_int, rst, WD, RD, TD, LP, ADDR, DATA_IN, DATA_OUT, DIR, STP, NXT, ULPI_DATA);

    // CLK gen
    always #1 clk_ext <= ~clk_ext;

    // Simulation
    initial begin
        $dumpfile("sim/ULPI_tb.vcd");
        $dumpvars(0, ULPI_tb);

        #2 WD = 1;
        #2 WD = 0;
        
        #100 $finish;
    end


endmodule