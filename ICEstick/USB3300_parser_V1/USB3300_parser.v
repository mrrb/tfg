/*
 * MIT License
 *
 * Copyright (c) 2018 Mario Rubio
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the 'Software'), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

/*
 * Revision History:
 *     Initial: 2018/05/01      Mario Rubio
 */

`default_nettype none

`include "modules/UART.v"
`include "modules/clk_gen.v"
`include "modules/fifo_stack.v"
`include "modules/USB3300_receiver.v"

module USB3300_parser  (input  wire clk_int,    // Internal clock input (12MHz)
                        input  wire clk_ext,    // External clock input (60MHz)
                        input  wire [7:0]DATA,  // USB3300 8-bit DATA input
                        input  wire DIR,        // USB3300 DIR input
                        input  wire NXT,        // USB3300 NXT input
                        input  wire Rx,         // UART Rx data input
                        output wire Tx,         // UART Tx data output
                        output wire STP,        // USB3300 STP output
                        output wire [4:0]LEDs,  // Status LEDs
                        output wire bauds       // Baud clock
                        );

    /// Master clock
    wire clk;
    assign clk = clk_ext;
    /// End of Master clock

    /// Regs and wires
    wire MASTER_RST; assign MASTER_RST = 1'b0;
    /// End of Regs and wires

    /// UART module
    wire [7:0]Tx_data_w;
    wire [7:0]Rx_data_w;
    wire send_data_w;
    wire TiP_w;
    wire NrD_w;
    UART UART_m(Rx, clk_ext, Tx_data_w,
                send_data_w, Tx, TiP_w,
                NrD_w, Rx_data_w, bauds);
    /// End of UART module

    /// FIFO modules
    // Common control pins to all 4 FIFO stacks
    reg  FIFO_all_save_r = 1'b0;
    reg  FIFO_all_pop_r  = 1'b0;

    // FIFO for the CMD data
    wire FIFO_CMD_full;
    wire FIFO_CMD_empty;
    wire FIFO_CMD_busy;
    wire [7:0]FIFO_CMD_out;
    fifo_stack FIFO_CMD(clk_ext, CMD, FIFO_all_save_r, FIFO_all_pop_r,
                        MASTER_RST, FIFO_CMD_out,
                        FIFO_CMD_full, FIFO_CMD_empty, FIFO_CMD_busy);
                        
    // FIFO for the PID data
    wire FIFO_PID_full;
    wire FIFO_PID_empty;
    wire FIFO_PID_busy;
    wire [7:0]FIFO_PID_out;
    fifo_stack FIFO_PID(clk_ext, PID, FIFO_all_save_r, FIFO_all_pop_r,
                        MASTER_RST, FIFO_PID_out,
                        FIFO_PID_full, FIFO_PID_empty, FIFO_PID_busy);
                        
    // FIFO for the D1 data
    wire FIFO_D1_full;
    wire FIFO_D1_empty;
    wire FIFO_D1_busy;
    wire [7:0]FIFO_D1_out;
    fifo_stack FIFO_D1(clk_ext, D1, FIFO_all_save_r, FIFO_all_pop_r,
                        MASTER_RST, FIFO_D1_out,
                        FIFO_D1_full, FIFO_D1_empty, FIFO_D1_busy);
                        
    // FIFO for the D2 data
    wire FIFO_D2_full;
    wire FIFO_D2_empty;
    wire FIFO_D2_busy;
    wire [7:0]FIFO_D2_out;
    fifo_stack FIFO_D2(clk_ext, D2, FIFO_all_save_r, FIFO_all_pop_r,
                        MASTER_RST, FIFO_D2_out,
                        FIFO_D2_full, FIFO_D2_empty, FIFO_D2_busy);
    /// End of FIFO module

    /// USB3300 receiver module
    wire [7:0]PID;
    wire [7:0]D2;
    wire [7:0]D1;
    wire [7:0]CMD;
    wire receiver_NP;
    wire receiver_busy;
    USB3300_receiver receiver(clk_ext, DIR, NXT, DATA, !MASTER_RST, PID,
                              D2, D1, CMD, receiver_NP, receiver_busy);
    /// End of USB3300 receiver module

    /// Subcontroller 1 [S1]
    // Save in the FIFO module the new incoming data
    // Regs and wires
    reg  [2:0]S1_state_r = 3'b0;
    wire S1_s_IDLE;
    wire S1_s_SAVE_CMD;
    wire S1_s_SAVE_PID;
    wire S1_s_SAVE_D1;
    wire S1_s_SAVE_D2;

    // Flags
    assign S1_s_IDLE     = (S1_state_r == S1_IDLE)     ? 1'b1 : 1'b0;
    assign S1_s_SAVE_CMD = (S1_state_r == S1_SAVE_CMD) ? 1'b1 : 1'b0;
    assign S1_s_SAVE_PID = (S1_state_r == S1_SAVE_PID) ? 1'b1 : 1'b0;
    assign S1_s_SAVE_D1  = (S1_state_r == S1_SAVE_D1)  ? 1'b1 : 1'b0;
    assign S1_s_SAVE_D2  = (S1_state_r == S1_SAVE_D2)  ? 1'b1 : 1'b0;

    // S1 states
    localparam S1_IDLE     = 3'b000;
    localparam S1_SAVE_CMD = 3'b001;
    localparam S1_SAVE_PID = 3'b010;
    localparam S1_SAVE_D1  = 3'b011;
    localparam S1_SAVE_D2  = 3'b100;

    // S1 subcontroller
    always @(posedge clk) begin
        if(MASTER_RST == 1'b1) begin
        end
        else begin
            case(S1_state)
                S1_IDLE: begin
                    if(receiver_NP == 1'b1)
                        S1_state_r <= S1_SAVE_CMD;
                    else
                        S1_state_r <= S1_IDLE;
                end
                S1_SAVE_CMD: begin
                end
                S1_SAVE_PID: begin
                end
                S1_SAVE_D1: begin
                end
                S1_SAVE_D2: begin
                end
                default: begin
                end
            endcase
        end
    end
    /// End of Subcontroller 1 [S1]

endmodule