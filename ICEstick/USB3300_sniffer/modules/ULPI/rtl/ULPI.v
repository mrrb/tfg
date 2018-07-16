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
 *  - ULPI detect
 *  - 
 *
 */

`default_nettype none

`include "ULPI_REG_READ.v"
`include "ULPI_REG_WRITE.v"
`include "../../mux/rtl/mux.v"

module ULPI (
             // System signals
             input  wire clk_ext, // 60Mhz Clock input signal from the PHY
             input  wire clk_int, // 12Mhz Clock input signal from the FPGA itself 
             input  wire rst,     // Master reset signal
             // ULPI controller signals
             input  wire WD,                // Input to write DATA in a register given an Address (ADDR)
             input  wire RD,                // Input to read DATA from a register given an Address (ADDR)
             input  wire [5:0]ADDR,         // Address wher ewe have to read/write
             input  wire [7:0]REG_DATA_IN,  // Data to write in register
             output wire [7:0]REG_DATA_OUT, // Data readed from a register
             // ULPI pins
             input  wire NXT,
             input  wire DIR,
             output wire STP,
             inout  wire [7:0]ULPI_DATA
            );

    /// ULPI DATA output tristate controller
    
    /// End of ULPI DATA output tristate controller

    /// ULPI DATA inout multiplexer
    localparam mux_bits = 3;
    genvar i;
    generate
        for(i=0; i<8; i=i+1) begin
           mux #(.n_bits(mux_bits)) ULPImux ({1'b0,
                                              ULPI_DATA_READ[i],
                                              ULPI_DATA_READ[i],
                                              4'b0,
                                              ULPI_DATA[i]
                                             },
                                             muxSel_w, ULPI_MUX_OUT); 
        end
    endgenerate
    /// End of ULPI DATA inout multiplexer 

    /// ULPI submodules load
    ULPI_REG_READ  UR (clk_ext, rst, RD_w, ADDR, REG_DATA_OUT, busy_read,  DIR, STP_R, NXT, ULPI_DATA_READ);
    ULPI_REG_WRITE UW (clk_ext, rst, WD_w, ADDR, REG_DATA_IN,  busy_write, DIR, STP_W, NXT, ULPI_DATA_WRITE);
    /// End of ULPI submodules load

    /// ULPI Regs and wires
    // Outputs

    // Inputs

    // Buffers

    // Control registers
    reg [2:0]ULPI_state_r = 3'b0;
    reg clk_sel_r         = 1'b0;
    reg WD_r = 1'b0; wire WD_w;
    reg RD_r = 1'b0; wire RD_w;
    reg TD_r = 1'b0; wire TD_w;
    reg [mux_bits-1:0]muxSel_r; wire muxSel_w;

    // Flags
    wire ULPI_CTRL_s_IDLE;
    wire ULPI_CTRL_s_REG_READ;
    wire ULPI_CTRL_s_REG_WRITE;
    wire ULPI_CTRL_s_RECV_PCK;
    wire ULPI_CTRL_s_TRANS_PCK;
    wire ULPI_CTRL_s_ENTER_LP;
    wire ULPI_CTRL_s_EXIT_LP;
    wire busy_read;
    wire busy_write;
    wire [7:0]ULPI_DATA_READ;
    wire [7:0]ULPI_DATA_WRITE;

    // Assigns
    assign clk     = (clk_sel_r == 1'b0) ? clk_ext : clk_int; // #CTRL
    assign WD_w    = WD_r;    // #CTRL
    assign RD_w    = RD_r;    // #CTRL
    assign TD_w    = TD_r;    // #CTRL
    assign muxCh_w = muxCh_r; // #CTRL
    assign ULPI_CTRL_s_IDLE      = (ULPI_state_r == ULPI_CTRL_IDLE)      ? 1'b1 : 1'b0; // #FLAG
    assign ULPI_CTRL_s_REG_READ  = (ULPI_state_r == ULPI_CTRL_REG_READ)  ? 1'b1 : 1'b0; // #FLAG
    assign ULPI_CTRL_s_REG_WRITE = (ULPI_state_r == ULPI_CTRL_REG_WRITE) ? 1'b1 : 1'b0; // #FLAG
    assign ULPI_CTRL_s_RECV_PCK  = (ULPI_state_r == ULPI_CTRL_RECV_PCK)  ? 1'b1 : 1'b0; // #FLAG
    assign ULPI_CTRL_s_TRANS_PCK = (ULPI_state_r == ULPI_CTRL_TRANS_PCK) ? 1'b1 : 1'b0; // #FLAG
    assign ULPI_CTRL_s_ENTER_LP  = (ULPI_state_r == ULPI_CTRL_ENTER_LP)  ? 1'b1 : 1'b0; // #FLAG
    assign ULPI_CTRL_s_EXIT_LP   = (ULPI_state_r == ULPI_CTRL_EXIT_LP)   ? 1'b1 : 1'b0; // #FLAG
    assign ULPI_DATA             = (DIR == 1'b1) ? {8{1'bz}} : ULPI_MUX_OUT; // #INOUT
    assign ULPI_DATA_READ        = (DIR == 1'b1) ? ULPI_DATA : {8{1'bz}}; // #INOUT

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
                    else if(WD == 1'b1 and DIR == 1'b0) begin
                        // Register WRITE request
                        ULPI_state_r <= ULPI_CTRL_REG_WRITE;
                    end
                    else if(RD == 1'b1 and DIR == 1'b0) begin
                        // Register READ request
                        ULPI_state_r <= ULPI_CTRL_REG_READ;
                    end
                    else if(TD == 1'b1 and DIR == 1'b0) begin
                        // Package transmission request
                        ULPI_state_r <= ULPI_CTRL_TRANS_PCK;
                    end
                    else if(LP == 1'b1 and DIR == 1'b0) begin
                        // Request to enter in Low Power Mode
                        ULPI_state_r <= ULPI_CTRL_ENTER_LP;
                    end
                    else begin
                        ULPI_state_r <= ULPI_CTRL_IDLE;
                    end
                end
                ULPI_CTRL_REG_READ: begin
                    if() begin
                    end
                    else ULPI_state_r <= ULPI_CTRL_REG_READ;
                end
                ULPI_CTRL_REG_WRITE: begin
                    if() begin
                    end
                    else ULPI_state_r <= ULPI_CTRL_REG_WRITE;
                end
                ULPI_CTRL_RECV_PCK: begin
                    if() begin
                    end
                    else ULPI_state_r <= ULPI_CTRL_RECV_PCK;
                end
                ULPI_CTRL_TRANS_PCK: begin
                    if() begin
                    end
                    else ULPI_state_r <= ULPI_CTRL_TRANS_PCK;
                end
                ULPI_CTRL_ENTER_LP: begin
                    if() begin
                    end
                    else ULPI_state_r <= ULPI_CTRL_ENTER_LP;
                end
                ULPI_CTRL_EXIT_LP: begin
                    if() begin
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