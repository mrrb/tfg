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

/*
 *
 * This modules creates a Shift Register with parallel data input capabilities.
 * 
 * To use the parallel input, the signals 'enable' and 'PARALLEL_EN' must be HIGH.
 * To use the module like a normal Shift Register, 'enable' must be HIGH and 'PARALLEL_EN' LOW.
 * All the operations occour in the rising edge of the clock.
 *
 */

module shift_register #(
                        parameter bits = 8 
                       )
                       (
                        // System signals
                        input  wire clk, // Master clock signal

                        // Shift register signals
                        input  wire enable,  // The shift register only works when this signal is HIGH
                        input  wire bit_in,  // New bit to store in the register
                        output wire bit_out, // Overflow bit
                        output wire [(bits - 1):0]DATA_out, // Data stored in the register

                        // Parallel input
                        input  wire [(bits - 1):0]DATA_in,
                        input  wire PARALLEL_EN // Parallel enable signal. When this signal is HIGH, the data in DATA_in is stored in the register.
                       );

    // Main register
    reg [(bits - 1):0]DATA = {bits{1'b0}};
    assign DATA_out = DATA;

    // Overflow bit
    reg bit_out_r = 1'b0;
    assign bit_out = bit_out_r;

    // Main controller
    always @(posedge clk) begin
        if(enable) begin
            if(PARALLEL_EN) begin
                DATA <= DATA_in;
            end
            else begin
                bit_out_r <= DATA[0];
                DATA <= {bit_in, DATA[(bits - 1):1]};
            end
        end
    end

endmodule