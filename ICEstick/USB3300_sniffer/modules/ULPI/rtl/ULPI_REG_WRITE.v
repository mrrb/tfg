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
 *     Initial:        2018/07/04        Mario Rubio
 */

/*
 * This module has the instructions set that let write data into the PHY registers

 States:
    1. WRITE_IDLE. The module is doing nothing until the WRITE_DATA input is activated.
    2. WRITE_TXCMD. Once the write signal is asserted, the LINK has the ownership of the bus and send the TXCMD 8bit data ('10'cmd+{6bit Address}).
                    The PHY will respond activating the NXT signal indicating that TXCMD has been successfully latched.
    3. WRITE_SEND_DATA. Link drives the DATA to be stored in the register.
                        The PHY drives NXT high indicating that the data has been latched.
    4. WRITE_STP. Finally, the LINK drives HIGH STP, ending the writing of the register.

 */

module ULPI_REG_WRITE #()
                       (
                        // System signals
                        input  wire clk, // Clock input signal
                        input  wire rst, // Master reset signal
                        // ULPI controller signals
                        input  wire WRITE_DATA, // Signal to initiate a register write
                        input  wire [7:0]DATA,  // Input that transmit the 8 bit DATA to be written in the ULPI register
                        input  wire [5:0]ADDR,  // Input that transmit the 6 bit address where we want to write the DATA
                        output wire BUSY,       // Output signal activated whenever is a Write operationn in progress
                        // ULPI pins
                        input  wire NXT,
                        output wire STP,
                        output wire [7:0]ULPI_DATA,
                        );

    // CMD used to perform a register write 10xxxxxx
    parameter [1:0]REG_WRITE_CMD = 2'b10;

    /// ULPI_REG_WRITE Regs and wires
    // Outputs
    reg STP_r = 1'b0; assign STP = STP_r;

    // Inputs
    // #NONE

    // Buffers
    reg [7:0]DATA_buf_r = 8'b0;      // Buffer for the ULPI controller DATA input
    reg [7:0]ULPI_DATA_buf_r = 8'b0; // Buffer for the ULPI pins DATA output
    assign ULPI_DATA = ULPI_DATA_buf_r;

    // Control registers
    reg [1:0]WRITE_state_r = 2'b00;  // Register to store the current state of the ULPI_REG_WRITE module

    // Flags
    wire WRITE_s_IDLE;
    wire WRITE_s_TXCMD;
    wire WRITE_s_SEND_DATA;
    wire WRITE_s_STP;
    
    // Assigns
    assign WRITE_s_IDLE      = (WRITE_state_r == WRITE_IDLE)      ? 1'b1 : 1'b0;
    assign WRITE_s_TXCMD     = (WRITE_state_r == WRITE_TXCMD)     ? 1'b1 : 1'b0;
    assign WRITE_s_SEND_DATA = (WRITE_state_r == WRITE_SEND_DATA) ? 1'b1 : 1'b0;
    assign WRITE_s_STP       = (WRITE_state_r == WRITE_STP)       ? 1'b1 : 1'b0;
    assign BUSY              = !WRITE_s_IDLE;
    /// End of ULPI_REG_WRITE Regs and wires

    /// ULPI_REG_WRITE States (See module description at the beginning to get more info)
    localparam WRITE_IDLE      = 2'b00;
    localparam WRITE_TXCMD     = 2'b01;
    localparam WRITE_SEND_DATA = 2'b10;
    localparam WRITE_STP       = 2'b11;
    /// End of ULPI_REG_WRITE States

    /// ULPI_REG_WRITE controller
    // States
    // #FIGURE_NUMBER WRITE_state_machine
    always @(posedge clk) begin
        if(rst == 1'b1) begin
            WRITE_state_r <= WIRTE_IDLE;
        end
        else begin
            case(WRITE_state_r)
                WRITE_IDLE: begin
                    // The state change once the Write signal (WRITE_DATA) is activated, elsewise, we do nothing
                    if(WRITE_DATA == 1'b1) WRITE_state_r <= WRITE_TXCMD;
                    else WRITE_state_r <= WRITE_IDLE;
                end
                WRITE_TXCMD: begin                   // We wait until the PHY assert the NXT signal
                    if(NXT == 1'b1) WRITE_state_r <= WRITE_SEND_DATA;
                    else WRITE_state_r <= WRITE_TXCMD;
                end
                WRITE_SEND_DATA: begin
                    // We wait again for an activated NXT signal
                    if(NXT == 1'b1) WRITE_state_r <= WRITE_STP;
                    else WRITE_state_r <= WRITE_SEND_DATA;
                end
                WRITE_STP: begin
                    // The WRITE routine is done, so we go back to the IDLE state
                    WRITE_state_r <= WRITE_IDLE;
                end
                default: begin
                    // Just in case a not possible state value occurs, we go back to the inital state
                    WRITE_state_r <= WRITE_IDLE;
                end
            endcase
        end
    end

    // Transition actions
    always @(posedge clk) begin
        if(rst == 1'b1) begin
            STP_r <= 1'b0;
            ULPI_DATA_buf_r <= 8'b0;
        end
        else begin
            case(WRITE_state_r)
                WRITE_IDLE: begin
                    STP_r <= 1'b0;
                    if(WRITE_DATA == 1'b1) begin
                        // The value of the DATA input may vary during the write process, so we store its initial value.
                        DATA_buf_r      <= DATA;
                        ULPI_DATA_buf_r <= {REG_WRITE_CMD, ADDR};
                    end
                end
                WRITE_TXCMD: begin
                    STP_r <= 1'b0;
                    if(NXT == 1'b1) begin
                        ULPI_DATA_buf_r <= DATA_buf_r;
                    end
                end
                WRITE_SEND_DATA: begin
                    STP_r <= 1'b0;
                    if(NXT == 1'b1) begin
                        STP_r <= 1'b1;
                    end
                end
                WRITE_STP: begin
                    STP_r <= 1'b0;
                    ULPI_DATA_buf_r <= 8'b0;
                end
                default: begin
                    STP_r <= 1'b0;
                end
            endcase
        end
    end
    /// End of ULPI_REG_WRITE controller

endmodule