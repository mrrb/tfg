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
 *     Initial:        2018/07/20        Mario Rubio
 */

/*
 * This module enables the FPGA to act as a SPI slave to communicate with the main controller (computer in this case).
 * 
 * States:
 *  1. 
 *
 */

// SPI MODE 0 => CPOL = 0; CPHA = 0;

module SPI_SLAVE_CTRL (
                       // System
                       input  wire clk,   // FPGA clock
                       input  wire STA_F, // FPGA+USB3300 status code
                       output wire STA_C, // Controller status code (code given by the computer)
                       // SPI pins   
                       input  wire SCK,  // SPI clock
                       input  wire SS,   // Slave Select SPI pin 
                       input  wire MOSI, // Master-OUT Slave-IN  SPI pin
                       output wire MISO  // Master-IN  Slave-OUT SPI pin
                      );

    /// SPI_SLAVE_CTRL Regs and wires
    // Outputs

    // Inputs

    // Buffers

    // Control registers

    // Flags

    // Assigns
    
    /// End of SPI_SLAVE_CTRL Regs and wires

    /// SPI_SLAVE_CTRL States (See module description at the beginning to get more info)
    
    /// End of SPI_SLAVE_CTRL States


    /// SPI_SLAVE_CTRL controller
    // States and actions
    // #FIGURE_NUMBER SPI_CTRL_state_machine
    always @(posedge clk) begin
        if(rst == 1'b1) begin
        end
        else begin
            case()
                default: begin
                end
            endcase
        end
    end
    /// End of SPI_SLAVE_CTRL controller

endmodule