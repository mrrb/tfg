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

// SPI MODE 0 => CPOL = 0; CPHA = 0;

module SPI_SLAVE (
                  // SPI pins   
                  input  wire SCK,  // SPI clock
                  input  wire SS,   // Slave Select SPI pin 
                  input  wire MOSI, // Master-OUT Slave-IN  SPI pin
                  output wire MISO  // Master-IN  Slave-OUT SPI pin
                 );

    /// SPI_SLAVE Regs and wires
    // Outputs
    reg STP_r = 1'b0;

    // Inputs
    // #NONE

    // Buffers
    reg [7:0]DATA_buf_r = 8'b0;      // Buffer for the ULPI controller DATA input
    reg [7:0]ULPI_DATA_buf_r = 8'b0; // Buffer for the ULPI pins DATA output

    // Control registers
    reg [1:0]WRITE_state_r = 2'b0;   // Register to store the current state of the SPI_SLAVE module

    // Flags
    wire WRITE_s_IDLE;      // 1 if WRITE_state_r == WRITE_IDLE, else 0
    wire WRITE_s_TXCMD;     // 1 if WRITE_state_r == WRITE_TXCMD, else 0
    wire WRITE_s_SEND_DATA; // 1 if WRITE_state_r == WRITE_SEND_DATA, else 0
    wire WRITE_s_STP;       // 1 if WRITE_state_r == WRITE_STP, else 0
    
    // Assigns
    assign WRITE_s_IDLE      = (WRITE_state_r == WRITE_IDLE)      ? 1'b1 : 1'b0; // #FLAG
    assign WRITE_s_TXCMD     = (WRITE_state_r == WRITE_TXCMD)     ? 1'b1 : 1'b0; // #FLAG
    assign WRITE_s_SEND_DATA = (WRITE_state_r == WRITE_SEND_DATA) ? 1'b1 : 1'b0; // #FLAG
    assign WRITE_s_STP       = (WRITE_state_r == WRITE_STP)       ? 1'b1 : 1'b0; // #FLAG
    assign BUSY              = !WRITE_s_IDLE;   // #OUTPUT
    assign ULPI_DATA_OUT     = ULPI_DATA_buf_r; // #OUTPUT
    assign STP               = STP_r;           // #OUTPUT
    /// End of SPI_SLAVE Regs and wires


    /// SPI_SLAVE States (See module description at the beginning to get more info)
    localparam WRITE_IDLE      = 2'b00;
    localparam WRITE_TXCMD     = 2'b01;
    localparam WRITE_SEND_DATA = 2'b10;
    localparam WRITE_STP       = 2'b11;
    /// End of SPI_SLAVE States


    /// SPI_SLAVE controller
    // States and actions
    // #FIGURE_NUMBER WRITE_state_machine
    always @(posedge clk) begin
        if(rst == 1'b1) begin
            // When a reset occurs, the default state is loaded, and the registers are purged
        end
        else begin
            case()
                default: begin
                end
            endcase
        end
    end
    /// End of SPI_SLAVE controller

endmodule