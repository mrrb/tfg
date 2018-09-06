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
 *     Initial:        2018/09/05        Mario Rubio
 */

module REG_BANK #(parameter ADDR_BITS = 4, // Width of the addresses of the register bank
                  parameter DATA_BITS = 3  // Width of the data of the register bank
                 )
                 (
                  input  wire clk, // Master clock
                  input  wire WD,  // "Write Data" control input. When high, the data in DATA_in will be saved in the bank.
                  input  wire [(2**ADDR_BITS - 1):0] ADDR,     // Address where the data have to be save/read
                  input  wire [(2**DATA_BITS - 1):0] DATA_in,  // Data to be save in the bank
                  output wire [(2**DATA_BITS - 1):0] DATA_out  // Data read from the bank
                 );


    // Main register
    reg [(2**DATA_BITS - 1):0] bank_r [(2**ADDR_BITS - 1):0];

    // Output Data
    assign DATA_out = bank_r[ADDR];

    // Controller
    always @(posedge clk) begin
        if(WD) begin
            bank_r[ADDR] <= DATA_in;
        end
    end


endmodule