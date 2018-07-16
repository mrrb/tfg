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
 *     Initial:        2018/07/15        Mario Rubio
 */

module impedance_tb ();


    reg I_r    = 1'b0; wire I;    assign I    = I_r;
    reg IO_r   = 1'b0; wire IO;   assign IO   = (ctrl == 1'b1) ? IO_r : 1'bz;
    reg ctrl_r = 1'b0; wire ctrl; assign ctrl = ctrl_r;
    wire O;

    impedance IM_tb (IO, I, ctrl, O);
    initial begin
    
        $dumpfile("sim/impedance_tb.vcd");
        $dumpvars(0, impedance_tb);
        
        #1 I_r = 1;        
        #1 I_r = 0;        
        #1 I_r = 1;        
        #2 I_r = 0;

        #1 ctrl_r = 1;        
        #1 I_r = 1; IO_r = 1;     
        #1 I_r = 0; IO_r = 0;     
        #1 I_r = 1; IO_r = 1; 
        #2 I_r = 0; IO_r = 0;

        #1 ctrl_r = 0;
        #1 I_r = 1; 

        #20 $finish;

    end


endmodule