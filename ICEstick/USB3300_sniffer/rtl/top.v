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
 *     Initial:        2018/06/15        Mario Rubio
 */

`include "./rtl/ULPI_REG_ADDR.vh"
`include "./modules/ULPI/rtl/ULPI.v"


module USB3300_parser (
                       input  wire clk_ext,
                       input  wire clk_int,

                       // ULPI pins
                       input  wire DIR,
                       output wire STP,
                       input  wire NXT,
                       inout  wire [7:0]ULPI_DATA
                      );

    wire rst; assign rst = 1'b0;
    wire WD;  assign WD = 1'b0;
    wire RD;  assign RD = 1'b0;
    wire TD;  assign TD = 1'b0;
    wire LP;  assign LP = 1'b0;
    wire [5:0]ADDR;  assign ADDR = 6'b0;
    wire [7:0]REG_DATA_IN;  assign REG_DATA_IN = 8'b0;

    wire [7:0]REG_DATA_OUT;
    wire busy;

    ULPI ULPI_Module (clk_ext, clk_int, rst,
                      WD, RD, TD, LP, ADDR,
                      REG_DATA_IN, REG_DATA_OUT, busy,
                      DIR, STP, NXT, ULPI_DATA);

endmodule