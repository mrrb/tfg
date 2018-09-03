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
 *     Initial:        2018/06/15        Mario Rubio
 */

/*
 * This module enables the communication between the FPGA and the USB3300 module using the ULPI protocol.
 * 
 * Submodules:
 *  - ULPI_REG_READ
 *  - ULPI_REG_WRITE
 *
 */

`default_nettype none

`include "./modules/ULPI/rtl/ULPI_REG_READ.v"
`include "./modules/ULPI/rtl/ULPI_REG_WRITE.v"
`include "./modules/mux/rtl/mux.v"

module ULPI (
             // System signals
             input  wire clk_ext, // 60Mhz Clock input signal from the PHY
             input  wire clk_int, // 12Mhz Clock input signal from the FPGA itself 
             input  wire rst,     // Master reset signal
             // ULPI controller signals
             input  wire WD,                // Input to write DATA in a register given an Address (ADDR)
             input  wire RD,                // Input to read DATA from a register given an Address (ADDR)
             input  wire TD,                // Input to start a new DATA package transmission
             input  wire LP,                // Input to enter in the Low Power Mode
             input  wire [5:0]ADDR,         // Address wher ewe have to read/write
             input  wire [7:0]REG_DATA_IN,  // Data to write in register
             output wire [7:0]REG_DATA_OUT, // Data readed from a register
             output wire BUSY,              // Singal activated whenever the ULPI controller is not in the IDLE state
             // ULPI pins
             input  wire DIR,
             output wire STP,
             input  wire NXT,
             inout  wire [7:0]ULPI_DATA
            );

    /// ULPI DATA input/output tristate controller
    // Wires for the ULPI_DATA signals
    wire [7:0]ULPI_DATA_REG_READ;  // DATA signal from the ULPI_REG_READ submodule
    wire [7:0]ULPI_DATA_REG_WRITE; // DATA signal from the ULPI_REG_WRITE submodule
    wire [7:0]ULPI_DATA_TRS_PCK;   // DATA signal from the ULPI_TRS_PCK submodule
    wire [7:0]ULPI_DATA_REC_PCK;   // DATA signal from the ULPI_REC_PCK submodule
    wire [1:0]ULPI_DATA_CTRL;      // Signal to control the ULPI_DATA mux
    wire [7:0]ULPI_DATA_w;

    // Assigns for the ULPI_DATA signals
    assign ULPI_DATA = DIR ? {8{1'bz}} : ULPI_DATA_w;
    assign ULPI_DATA_CTRL = ULPI_CTRL_s_REG_READ  ? 2'b01 :
                           (ULPI_CTRL_s_REG_WRITE ? 2'b10 : 
                           (ULPI_CTRL_s_TRANS_PCK ? 2'b11 : 2'b00));
    
    // ULPI_DATA mux
    localparam DATA_WIDTH = 8;
    genvar i;
    generate
        for(i=0; i<DATA_WIDTH; i=i+1) begin
           mux #(.n_bits(2)) ULPI_DATA_MUX ({1'b0,
                                             ULPI_DATA_REG_READ[i],
                                             ULPI_DATA_REG_WRITE[i],
                                             ULPI_DATA_TRS_PCK[i]
                                             },
                                            ULPI_DATA_CTRL,
                                            ULPI_DATA_w[i]);
        end
    endgenerate

    // Wires for the STP signal
    wire STP_READ;      // STP signal from the ULPI_REG_READ submodule
    wire STP_WRITE;     // STP signal from the ULPI_REG_WRITE submodule
    wire STP_TRS_PCK;   // STP signal from the ULPI_TRS_PCK submodule
    wire STP_REC_PCK;   // STP signal from the ULPI_REC_PCK submodule
    wire [1:0]STP_CTRL; // Signal to control the STP mux

    // STP assigns
    assign STP_CTRL = ULPI_CTRL_s_REG_WRITE ? 2'b01 :
                     (ULPI_CTRL_s_TRANS_PCK ? 2'b10 : 2'b00);

    // STP mux
    mux #(.n_bits(2)) STP_MUX ({1'b0, STP_WRITE, STP_TRS_PCK, 1'b0}, STP_CTRL, STP);
    /// End of ULPI DATA input/output tristate controller

    /// ULPI submodules load
    ULPI_REG_READ  UR (clk_ext, rst, RD_w, ADDR, REG_DATA_OUT, busy_read,  DIR, STP_READ,  NXT, ULPI_DATA, ULPI_DATA_REG_READ);
    ULPI_REG_WRITE UW (clk_ext, rst, WD_w, ADDR, REG_DATA_IN,  busy_write, DIR, STP_WRITE, NXT, ULPI_DATA, ULPI_DATA_REG_WRITE);
    /// End of ULPI submodules load

    /// ULPI Regs and wires
    // Outputs

    // Inputs

    // Buffers

    // Control registers
    reg [2:0]ULPI_state_r = 3'b0; // Register to store the current state of the controller
    reg clk_sel_r         = 1'b0; // Clock selector between the external 60MHz clock and the internal 12MHz one

    // Flags
    wire ULPI_CTRL_s_IDLE;      // 1 if ULPI_state_r == ULPI_CTRL_IDLE, else 0
    wire ULPI_CTRL_s_REG_READ;  // 1 if ULPI_state_r == ULPI_CTRL_REG_READ, else 0
    wire ULPI_CTRL_s_REG_WRITE; // 1 if ULPI_state_r == ULPI_CTRL_REG_WRITE, else 0
    wire ULPI_CTRL_s_RECV_PCK;  // 1 if ULPI_state_r == ULPI_CTRL_RECV_PCK, else 0
    wire ULPI_CTRL_s_TRANS_PCK; // 1 if ULPI_state_r == ULPI_CTRL_TRANS_PCK, else 0
    wire ULPI_CTRL_s_ENTER_LP;  // 1 if ULPI_state_r == ULPI_CTRL_ENTER_LP, else 0
    wire ULPI_CTRL_s_EXIT_LP;   // 1 if ULPI_state_r == ULPI_CTRL_EXIT_LP, else 0
    wire busy_read;  // Busy signal from the ULPI_REG_READ  submodule
    wire busy_write; // Busy signal from the ULPI_REG_WRITE submodule
    wire clk;   // Controller clock
    wire WD_w;  // Wire to make a register WRITE operation
    wire RD_w;  // Wire to make a register READ  operation
    wire TD_w;  // Wire to make a package transfer
    wire DCTRL; // Flag activated when there is only 1 or less of the following signals HIGH: WD, RD, TD

    // Assigns
    assign clk  = (clk_sel_r == 1'b0) ? clk_ext : clk_int; // #CTRL
    assign WD_w = (ULPI_CTRL_s_IDLE && !DIR && !DCTRL) ? WD : 1'b0; // #FLAG
    assign RD_w = (ULPI_CTRL_s_IDLE && !DIR && !DCTRL) ? RD : 1'b0; // #FLAG
    assign TD_w = (ULPI_CTRL_s_IDLE && !DIR && !DCTRL) ? TD : 1'b0; // #FLAG
    assign DCTRL = !{^{WD,RD,TD,1'b0}};
    assign ULPI_CTRL_s_IDLE      = (ULPI_state_r == ULPI_CTRL_IDLE)      ? 1'b1 : 1'b0; // #FLAG
    assign ULPI_CTRL_s_REG_READ  = (ULPI_state_r == ULPI_CTRL_REG_READ)  ? 1'b1 : 1'b0; // #FLAG
    assign ULPI_CTRL_s_REG_WRITE = (ULPI_state_r == ULPI_CTRL_REG_WRITE) ? 1'b1 : 1'b0; // #FLAG
    assign ULPI_CTRL_s_RECV_PCK  = (ULPI_state_r == ULPI_CTRL_RECV_PCK)  ? 1'b1 : 1'b0; // #FLAG
    assign ULPI_CTRL_s_TRANS_PCK = (ULPI_state_r == ULPI_CTRL_TRANS_PCK) ? 1'b1 : 1'b0; // #FLAG
    assign ULPI_CTRL_s_ENTER_LP  = (ULPI_state_r == ULPI_CTRL_ENTER_LP)  ? 1'b1 : 1'b0; // #FLAG
    assign ULPI_CTRL_s_EXIT_LP   = (ULPI_state_r == ULPI_CTRL_EXIT_LP)   ? 1'b1 : 1'b0; // #FLAG
    assign BUSY = !ULPI_CTRL_s_IDLE; // #OUTPUT
    /// End of ULPI Regs and wires


    /// ULPI States (See module description at the beginning to get more info)
    localparam ULPI_CTRL_IDLE      = 0;
    localparam ULPI_CTRL_REG_READ  = 1;
    localparam ULPI_CTRL_REG_WRITE = 2;
    localparam ULPI_CTRL_RECV_PCK  = 3;
    localparam ULPI_CTRL_TRANS_PCK = 4;
    localparam ULPI_CTRL_ENTER_LP  = 5;
    localparam ULPI_CTRL_EXIT_LP   = 6;
    /// End of ULPI States


    /// ULPI controller
    // 12Mhz clock switcher

    // States and actions
    // #FIGURE_NUMBER ULPI_state_machine
    always @(posedge clk) begin
        if(rst == 1'b1) begin
            // Master reset actions
        end
        else begin
            case(ULPI_state_r)
                ULPI_CTRL_IDLE: begin
                    if(DIR == 1'b1) begin
                        // Package incoming
                        ULPI_state_r <= ULPI_CTRL_RECV_PCK;
                    end
                    else if(WD_w == 1'b1) begin
                        // Register WRITE request
                        ULPI_state_r <= ULPI_CTRL_REG_WRITE;
                    end
                    else if(RD_w == 1'b1) begin
                        // Register READ request
                        ULPI_state_r <= ULPI_CTRL_REG_READ;
                    end
                    else if(TD_w == 1'b1 && DIR == 1'b0) begin
                        // Package transmission request
                        ULPI_state_r <= ULPI_CTRL_TRANS_PCK;
                    end
                    else if(LP == 1'b1 && DIR == 1'b0) begin
                        // Request to enter in Low Power Mode
                        ULPI_state_r <= ULPI_CTRL_ENTER_LP;
                    end
                    else begin
                        ULPI_state_r <= ULPI_CTRL_IDLE;
                    end
                end
                ULPI_CTRL_REG_READ: begin
                    // Once the read process finished, we go back to the IDLE state
                    if(busy_read == 1'b0) begin
                        ULPI_state_r <= ULPI_CTRL_IDLE;
                    end
                    else ULPI_state_r <= ULPI_CTRL_REG_READ;
                end
                ULPI_CTRL_REG_WRITE: begin
                    // Once the write process finished, we go back to the IDLE state
                    if(busy_write == 1'b0) begin
                        ULPI_state_r <= ULPI_CTRL_IDLE;
                    end
                    else ULPI_state_r <= ULPI_CTRL_REG_WRITE;
                end
                ULPI_CTRL_RECV_PCK: begin
                    if(1'b0) begin
                    end
                    else ULPI_state_r <= ULPI_CTRL_RECV_PCK;
                end
                ULPI_CTRL_TRANS_PCK: begin
                    if(1'b0) begin
                    end
                    else ULPI_state_r <= ULPI_CTRL_TRANS_PCK;
                end
                ULPI_CTRL_ENTER_LP: begin
                    if(1'b0) begin
                    end
                    else ULPI_state_r <= ULPI_CTRL_ENTER_LP;
                end
                ULPI_CTRL_EXIT_LP: begin
                    if(1'b0) begin
                    end
                    else ULPI_state_r <= ULPI_CTRL_REG_READ;
                end
                default: begin
                end
            endcase
        end
    end
    /// End of ULPI controller

endmodule