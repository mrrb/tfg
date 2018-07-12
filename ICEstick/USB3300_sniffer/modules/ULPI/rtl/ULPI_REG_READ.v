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

/*
 This module has the instructions set that let read data from the PHY registers

 States:
    1. 

 */

module ULPI_REG_READ ();

    // CMD used to perform a register read 11xxxxxx
    parameter [1:0]REG_READ_CMD = 2'b11;

    /// ULPI_REG_READ Regs and wires
    // Outputs

    // Inputs
    // #NONE

    // Buffers

    // Control registers
    reg [2:0]READ_state_r = 3'b0; // Register to store the current state of the ULPI_REG_READ module

    // Flags
    
    // Assigns

    /// End of ULPI_REG_READ Regs and wires

    /// ULPI_REG_READ States (See module description at the beginning to get more info)
    localparam READ_IDLE = 3'b0;
    localparam READ_IDLE = 3'b0;
    /// End of ULPI_REG_READ States

    /// ULPI_REG_READ controller
    // States and actions
    // #FIGURE_NUMBER READ_state_machine
    always @(posedge clk) begin
        if(rst == 1'b1) begin

        end
        else begin
            case(READ_state_r)
                default: begin
                end
            endcase
        end
    end
    /// End of ULPI_REG_READ controller

endmodule