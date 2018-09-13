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
 *     Initial:        2018/09/08        Mario Rubio
 */

module shift_register_tb ();


    // Regs and wires
    reg clk = 1'b0;
    reg bit_in = 1'b0;
    reg enable = 1'b0;
    reg par_en = 1'b0;
    reg [7:0]DATA_in = 8'b0;

    wire bit_out;
    wire [7:0]DATA;

    // Module init
    shift_register sr (clk, enable, bit_in, bit_out, DATA, DATA_in, par_en);

    // CLK gen
    always #1 clk <= ~clk;

    // Simulation
    initial begin
      
        $dumpfile("sim/shift_register_tb.vcd");
        $dumpvars(0, shift_register_tb);

        #1 enable = 1;
        #2 bit_in = 1;
        #2 bit_in = 0;
        #2 bit_in = 0;
        #2 bit_in = 1;
        #2 bit_in = 1;
        #2 bit_in = 0;
        #2 bit_in = 1;
        #2 bit_in = 1;

        #2 enable = 0;

        #2 enable = 1;
        #20
        #2 bit_in = 0;
        #20
        #2 enable = 0; DATA_in = 8'b10011100;

        #2 enable = 1; par_en = 1;
        #2 enable = 0; par_en = 0;

        #4
        
        #6 $finish;
    end

endmodule