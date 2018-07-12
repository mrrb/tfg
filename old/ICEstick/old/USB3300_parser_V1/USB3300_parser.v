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
`include "modules/fifo_stack_u.v"
`include "modules/USB3300_receiver.v"
`include "modules/delay.v"

module USB3300_parser  (input  wire clk_int,    // Internal clock input (12MHz)
                        input  wire clk_ext,    // External clock input (60MHz)
                        input  wire [7:0]DATA,  // USB3300 8-bit DATA input
                        input  wire DIR,        // USB3300 DIR input
                        input  wire NXT,        // USB3300 NXT input
                        input  wire Rx,         // UART Rx data input
                        output wire Tx,         // UART Tx data output
                        output wire STP,        // USB3300 STP output
                        output wire [4:0]LEDs,  // Status LEDs
                        output wire bauds,      // Baud clock
                        output wire reset       // 
                        );


    reg test_state_r = 1'b0;
    reg stp_r = 1'b0;

    assign STP = stp_r;

    always @(posedge clk) begin
        case(test_state_r) 
            1'b0: begin
                test_state_r <= 1'b1;
                if(!DIR)
                    stp_r <= 1'b1;
            end
            1'b1: begin
                test_state_r <= 1'b1;
                stp_r <= 1'b0;
            end
        endcase
    end

    /// Config
    // UART divider 9->115200 bauds; 8->256000 bauds
    parameter UD = 9;
    /// End of Config

    /// Master clock
    wire clk;
    assign clk = clk_ext;
    /// End of Master clock

    /// Regs and wires
    wire MASTER_RST; assign MASTER_RST = 1'b0;
    /// End of Regs and wires

    /// UART module
    reg  [7:0]Tx_data_w_r = 8'b0;
    reg  send_data_r = 1'b0;
    wire [7:0]Rx_data_w;
    wire TiP_w;
    wire NrD_w;
    UART #(.BAUD_DIVIDER(UD)) UART_m(Rx, clk, Tx_data_w_r,
                                     send_data_r, Tx, TiP_w,
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
    fifo_stack FIFO_CMD(clk, CMD, FIFO_all_save_r, FIFO_all_pop_r,
                        MASTER_RST, FIFO_CMD_out,
                        FIFO_CMD_full, FIFO_CMD_empty, FIFO_CMD_busy);
                        
    // FIFO for the PID data
    wire FIFO_PID_full;
    wire FIFO_PID_empty;
    wire FIFO_PID_busy;
    wire [7:0]FIFO_PID_out;
    fifo_stack FIFO_PID(clk, PID, FIFO_all_save_r, FIFO_all_pop_r,
                        MASTER_RST, FIFO_PID_out,
                        FIFO_PID_full, FIFO_PID_empty, FIFO_PID_busy);
                        
    // FIFO for the D1 data
    wire FIFO_D1_full;
    wire FIFO_D1_empty;
    wire FIFO_D1_busy;
    wire [7:0]FIFO_D1_out;
    fifo_stack FIFO_D1(clk, D1, FIFO_all_save_r, FIFO_all_pop_r,
                        MASTER_RST, FIFO_D1_out,
                        FIFO_D1_full, FIFO_D1_empty, FIFO_D1_busy);
                        
    // FIFO for the D2 data
    wire FIFO_D2_full;
    wire FIFO_D2_empty;
    wire FIFO_D2_busy;
    wire [7:0]FIFO_D2_out;
    fifo_stack FIFO_D2(clk, D2, FIFO_all_save_r, FIFO_all_pop_r,
                        MASTER_RST, FIFO_D2_out,
                        FIFO_D2_full, FIFO_D2_empty, FIFO_D2_busy);

    // FIFO glags
    wire FIFO_all_empty; 
    wire FIFO_all_full;
    wire FIFO_all_busy;
    wire FIFO_all_ctrl;

    // Assigns
    assign FIFO_all_empty = FIFO_CMD_empty & FIFO_PID_empty &
                            FIFO_D1_empty  & FIFO_D2_empty;
    assign FIFO_all_busy  = FIFO_CMD_busy & FIFO_PID_busy &
                            FIFO_D1_busy  & FIFO_D2_busy;
    assign FIFO_all_full  = FIFO_CMD_full & FIFO_PID_full &
                            FIFO_D1_full  & FIFO_D2_full;
    assign FIFO_all_ctrl  = !FIFO_all_busy & !FIFO_all_empty;
    /// End of FIFO modules

    /// USB3300 receiver module
    wire [7:0]PID;
    wire [7:0]D2;
    wire [7:0]D1;
    wire [7:0]CMD;
    wire receiver_NP;
    wire receiver_busy;
    USB3300_receiver receiver(clk, DIR, NXT, DATA, !MASTER_RST, PID,
                              D2, D1, CMD, receiver_NP, receiver_busy);
    /// End of USB3300 receiver module

    /// Subcontroller 1 [S1]
    // Save in the FIFO modules the new incoming data
    // Regs and wires
    reg  S1_state_r = 1'b0;
    wire S1_s_IDLE;
    wire S1_s_SAVE;

    // Flags
    assign S1_s_IDLE = (S1_state_r == S1_IDLE) ? 1'b1 : 1'b0;
    assign S1_s_SAVE = (S1_state_r == S1_SAVE) ? 1'b1 : 1'b0;

    // S1 states
    localparam S1_IDLE = 1'b0;
    localparam S1_SAVE = 1'b1;

    // S1 subcontroller
    always @(posedge clk) begin
        if(MASTER_RST == 1'b1) begin
        end
        else begin
            case(S1_state_r)
                S1_IDLE: begin
                    if(receiver_NP == 1'b1)
                        S1_state_r <= S1_SAVE;
                    else
                        S1_state_r <= S1_IDLE;
                end
                S1_SAVE: begin
                    S1_state_r <= S1_IDLE;
                end
                default: begin
                    S1_state_r <= S1_IDLE;
                end
            endcase
        end
    end

    // FIFOs actions
    always @(posedge clk) begin
        if(MASTER_RST == 1'b1) begin
        end
        else if(S1_s_IDLE) begin
            FIFO_all_save_r <= 0;
        end
        else if(S1_s_SAVE) begin
            FIFO_all_save_r <= 1;
        end
    end
    /// End of Subcontroller 1 [S1]

    /// Subcontroller 2 [S2]
    // Send (and pop) each packet of 8-bit Data
    // Regs and wires
    reg  [3:0]S2_state_r = 4'b0;
    reg  tr_ctrl = 1'b0;
    wire S2_s_IDLE;
    wire S2_s_TR_CMD_L;
    wire S2_s_TR_CMD;
    wire S2_s_TR_PID_L;
    wire S2_s_TR_PID;
    wire S2_s_TR_D1_L;
    wire S2_s_TR_D1;
    wire S2_s_TR_D2_L;
    wire S2_s_TR_D2;
    wire S2_s_POP;

    // Flags
    assign S2_s_IDLE     = (S2_state_r == S2_IDLE)     ? 1'b1 : 1'b0; 
    assign S2_s_TR_CMD_L = (S2_state_r == S2_TR_CMD_L) ? 1'b1 : 1'b0; 
    assign S2_s_TR_CMD   = (S2_state_r == S2_TR_CMD)   ? 1'b1 : 1'b0; 
    assign S2_s_TR_PID_L = (S2_state_r == S2_TR_PID_L) ? 1'b1 : 1'b0; 
    assign S2_s_TR_PID   = (S2_state_r == S2_TR_PID)   ? 1'b1 : 1'b0; 
    assign S2_s_TR_D1_L  = (S2_state_r == S2_TR_D1_L)  ? 1'b1 : 1'b0; 
    assign S2_s_TR_D1    = (S2_state_r == S2_TR_D1)    ? 1'b1 : 1'b0; 
    assign S2_s_TR_D2_L  = (S2_state_r == S2_TR_D2_L)  ? 1'b1 : 1'b0; 
    assign S2_s_TR_D2    = (S2_state_r == S2_TR_D2)    ? 1'b1 : 1'b0; 
    assign S2_s_POP      = (S2_state_r == S2_POP)      ? 1'b1 : 1'b0; 

    // S2 states
    localparam S2_IDLE     = 1;
    localparam S2_TR_CMD_L = 2;
    localparam S2_TR_CMD   = 3;
    localparam S2_TR_PID_L = 4;
    localparam S2_TR_PID   = 5;
    localparam S2_TR_D1_L  = 6;
    localparam S2_TR_D1    = 7;
    localparam S2_TR_D2_L  = 8;
    localparam S2_TR_D2    = 9;
    localparam S2_POP      = 10;
    
    // TiP 2clk delay
    wire TiP_d2;
    delay del2(clk, TiP_w, TiP_d2);

    // S2 subcontroller
    always @(posedge clk) begin
        if(MASTER_RST == 1'b1) begin
        end
        else begin
            case(S2_state_r)
                S2_IDLE: begin
                    if(FIFO_all_ctrl)
                        S2_state_r <= S2_TR_CMD_L;
                    else
                        S2_state_r <= S2_IDLE;
                end
                S2_TR_CMD_L: begin
                    S2_state_r <= S2_TR_CMD;
                end
                S2_TR_CMD: begin
                    if(!TiP_d2)
                        S2_state_r <= S2_TR_PID_L;
                    else
                        S2_state_r <= S2_TR_CMD;
                end
                S2_TR_PID_L: begin
                    S2_state_r <= S2_TR_PID;
                end
                S2_TR_PID: begin
                    if(!TiP_d2)
                        S2_state_r <= S2_TR_D1_L;
                    else
                        S2_state_r <= S2_TR_PID;
                end
                S2_TR_D1_L: begin
                    S2_state_r <= S2_TR_D1;
                end
                S2_TR_D1: begin
                    if(!TiP_d2)
                        S2_state_r <= S2_TR_D2_L;
                    else
                        S2_state_r <= S2_TR_D1;
                end
                S2_TR_D2_L: begin
                    S2_state_r <= S2_TR_D2;
                end
                S2_TR_D2: begin
                    if(!TiP_d2)
                        S2_state_r <= S2_POP;
                    else
                        S2_state_r <= S2_TR_D2;
                end
                S2_POP: begin
                    S2_state_r <= S2_IDLE;
                end
                default: begin
                    S2_state_r <= S2_IDLE;
                end
            endcase
        end
    end

    // UART transmission and FIFO POP
    always @(posedge clk) begin
        if(MASTER_RST == 1'b1) begin
            FIFO_all_pop_r <= 0;
            send_data_r    <= 1'b0;
            Tx_data_w_r    <= 8'b0;
        end
        else if(S2_s_IDLE) begin
            FIFO_all_pop_r <= 0;
            send_data_r <= 1'b0;
        end
        else if(S2_s_TR_CMD_L) begin
            Tx_data_w_r <= FIFO_CMD_out;
            // Tx_data_w_r <= "A";
            send_data_r <= 1'b1;
        end
        else if(S2_s_TR_CMD) begin
            send_data_r <= 1'b0;
        end
        else if(S2_s_TR_PID_L) begin
            Tx_data_w_r <= FIFO_PID_out;
            send_data_r <= 1'b1;
        end
        else if(S2_s_TR_PID) begin
            send_data_r <= 1'b0;
        end
        else if(S2_s_TR_D1_L) begin
            Tx_data_w_r <= FIFO_D1_out;
            send_data_r <= 1'b1;
        end
        else if(S2_s_TR_D1) begin
            send_data_r <= 1'b0;
        end
        else if(S2_s_TR_D2_L) begin
            Tx_data_w_r <= FIFO_D2_out;
            send_data_r <= 1'b1;
        end
        else if(S2_s_TR_D2) begin
            send_data_r <= 1'b0;
        end
        else if(S2_s_POP) begin
            FIFO_all_pop_r <= 1;
            Tx_data_w_r    <= 8'b0;
        end
    end
    /// End of Subcontroller 2 [S2]

    /// Indicator LEDs
    assign LEDs[0] = FIFO_all_empty;
    assign LEDs[1] = TiP_w;
    assign LEDs[2] = receiver_busy;
    assign LEDs[3] = STP;
    assign LEDs[4] = DIR;
    // assign LEDs[4] = !S2_s_IDLE;
    /// End of Indicator LEDs

    /// Other stuff
    // assign STP   = 1'b0;
    assign reset = 1'b0;
    /// End of Other stuff

endmodule