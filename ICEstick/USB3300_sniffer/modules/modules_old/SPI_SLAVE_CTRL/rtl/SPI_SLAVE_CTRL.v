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
 *  1. SPI_IDLE
 *  2. SPI_PCK1
 *  3. SPI_PCK2
 *  4. SPI_WAIT
 *
 */

// SPI MODE 0 => CPOL = 0; CPHA = 0;

module SPI_SLAVE_CTRL (
                       // System
                       input  wire clk,           // FPGA reference clock
                       input  wire rst,           // Reset signal
                       input  wire [7:0]STA,      // Status signal that will be send to the SPI master
                       input  wire [7:0]DATA_in,  // Data that will be send to the SPI master [MISO]
                       output wire [7:0]DATA_out, // Data received from the SPI master [MOSI]
                       output wire [7:0]CMD,      // Command sent by the SPI master

                       // SPI pins   
                       input  wire SCK,  // SPI clock
                       input  wire SS,   // Slave Select SPI pin 
                       input  wire MOSI, // Master-OUT Slave-IN  SPI pin
                       output wire MISO  // Master-IN  Slave-OUT SPI pin
                      );

    /// SPI_SLAVE_CTRL Regs and wires
    // Outputs
    reg [7:0]DATA_out_r = 8'b0;

    // Inputs

    // Buffers
    reg [7:0]DATA_MOSI_buff = 8'b0;
    reg [7:0]DATA_MISO_buff = 8'b0;

    // Control registers
    reg [3:0]SPI_ctrl_r  = 4'b0; // Register where is stored the next bit number to be read in the serial interface
    reg [1:0]SPI_state_r = 2'b0; // Register to store the current state of the SPI_SLAVE_CTRL module

    // Flags
    wire SPI_s_IDLE; // 1 if SPI_state_r == SPI_IDLE, else 0
    wire SPI_s_PCK1; // 1 if SPI_state_r == SPI_PCK1, else 0
    wire SPI_s_PCK2; // 1 if SPI_state_r == SPI_PCK2, else 0
    wire SPI_s_WAIT; // 1 if SPI_state_r == SPI_WAIT, else 0

    // Assigns
    assign SPI_s_IDLE = (SPI_state_r == SPI_IDLE) ? 1'b1 : 1'b0; // #FLAG
    assign SPI_s_PCK1 = (SPI_state_r == SPI_PCK1) ? 1'b1 : 1'b0; // #FLAG
    assign SPI_s_PCK2 = (SPI_state_r == SPI_PCK2) ? 1'b1 : 1'b0; // #FLAG
    assign SPI_s_WAIT = (SPI_state_r == SPI_WAIT) ? 1'b1 : 1'b0; // #FLAG
    assign DATA_out   = DATA_out_r; // #OUTPUT
    
    /// End of SPI_SLAVE_CTRL Regs and wires

    /// SPI_SLAVE_CTRL States (See module description at the beginning to get more info)
    localparam SPI_IDLE = 2'b00;
    localparam SPI_PCK1 = 2'b01;
    localparam SPI_PCK2 = 2'b10;
    localparam SPI_WAIT = 2'b11;
    /// End of SPI_SLAVE_CTRL States


    /// SPI_SLAVE_CTRL controller
    // States and actions
    // #FIGURE_NUMBER SPI_CTRL_state_machine
    always @(posedge clk) begin
        if(rst) begin
            // The current state and the control registers are re-initialized
            SPI_state_r <= SPI_IDLE;
            SPI_ctrl_r <= 4'b0;
        end
        else begin
            case(SPI_state_r)
                SPI_IDLE: begin
                    if(!SS) begin
                        SPI_state_r <= SPI_PCK1;
                    end
                    else begin
                        SPI_state_r <= SPI_IDLE;
                    end
                end
                SPI_PCK1: begin
                    if(SPI_ctrl_r == 4'b1000) begin
                        SPI_state_r <= SPI_PCK2;
                        // Actions
                        SPI_ctrl_r <= 4'b0; // This register is used in the next state, so It has to be to purged at the end of this state
                    end
                    else begin
                        SPI_state_r <= SPI_PCK1;

                         SPI_ctrl_r <= SPI_ctrl_r + 1'b1;
                    end
                end
                SPI_PCK2: begin
                    if(SPI_ctrl_r == 4'b1000) begin
                        SPI_state_r <= SPI_WAIT;

                        // Actions
                        SPI_ctrl_r <= 4'b0; // The controller register is purged
                    end
                    else begin
                        SPI_state_r <= SPI_PCK2;

                        // Actions
                        SPI_ctrl_r <= SPI_ctrl_r + 1'b1;
                    end
                end
                SPI_WAIT: begin
                    // We wait for the SS signal to go back to its original state (HIGH)
                    if(SS) SPI_state_r <= SPI_IDLE;
                    else   SPI_state_r <= SPI_WAIT;
                end
                default: begin
                    SPI_state_r <= SPI_IDLE;
                    
                    SPI_ctrl_r <= 4'b0; // The controller register is purged
                end
            endcase
        end
    end
    /// End of SPI_SLAVE_CTRL controller

endmodule