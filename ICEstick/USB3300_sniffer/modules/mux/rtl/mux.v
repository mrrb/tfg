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

module mux #(
             parameter n_bits = 2 // Bits of the multiplexer
            )
            (
             input  wire [2**n_bits-1:0]ch,  // Input channels (2^n_bits)
             input  wire [n_bits-1:0]sel, // Selecction input (n_bits)
             output wire out      // Mux output
            );

    assign out = ch[sel];

endmodule