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
 *     Initial:        2018/07/12        Mario Rubio
 */

module ULPI_REG_READ_tb ();

    // Registers and wires
    reg clk = 1'b0;
    reg rst = 1'b0;
    reg RD  = 1'b0;
    reg NXT = 1'b0;
    reg DIR = 1'b0;
    reg [5:0]ADDR = 6'b0;
    reg [7:0]ULPI_DATA_r = 8'b0;

    wire [7:0]DATA;
    wire [7:0]ULPI_DATA_w;
    wire STP;
    wire busy;

    wire [7:0]ULPI_DATA;
    assign ULPI_DATA = (DIR == 1'b1) ? ULPI_DATA_r : ULPI_DATA_w;

    // Module init
    ULPI_REG_READ READ_tb (clk, rst, RD, ADDR, DATA, busy, DIR, STP, NXT, ULPI_DATA_r, ULPI_DATA_w);

    // CLK gen
    always #1 clk <= ~clk;

    // Simulation
    initial begin
      
        $dumpfile("sim/ULPI_REG_READ_tb.vcd");
        $dumpvars(0, ULPI_REG_READ_tb);

        ULPI_DATA_r = 8'h3D;

        #1;

        #1 RD = 1;
           ADDR = 6'h1B;
        #2 RD = 0;
           ADDR = 0;

        #2 NXT = 1;
        #2 NXT = 0;
           DIR = 1;

        #4 DIR = 0;
        
        #100 $finish;
    end

endmodule