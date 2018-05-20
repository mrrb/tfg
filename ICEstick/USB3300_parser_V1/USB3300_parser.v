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

module USB3300_parser #(parameter test = 1)
                       (input  wire clk_int,    // Internal clock input (12MHz)
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

    // UART module init
    wire [7:0]Tx_data_w;
    wire [7:0]Rx_data_w;
    wire send_data_w;
    wire TiP_w;
    wire NrD_w;
    wire [1:0]ctrl;
    UART UART_m(Rx, clk_int, Tx_data_w,
                send_data_w, Tx, TiP_w,
                NrD_w, Rx_data_w, bauds, ctrl);

    /// TESTS
    reg  [26:0]ctrl_r = {27{1'b_0}};
    wire clk_ctrl;
    assign clk_ctrl = ctrl_r[26]&ctrl_r[25]&ctrl_r[24]&ctrl_r[23]&ctrl_r[22]&ctrl_r[21]&ctrl_r[20]&ctrl_r[19]&ctrl_r[18]&ctrl_r[17];
    always @(posedge clk_ext) begin
        ctrl_r <= ctrl_r + 1;
    end

    reg [7:0]a = "a";
    // reg [7:0]a = 8'b0;
    assign Tx_data_w = a;
    assign send_data_w = (TiP_w == 1'b1) ? 1'b0 : clk_ctrl;
    assign LEDs[0] = send_data_w;
    assign LEDs[1] = TiP_w;
    assign LEDs[2] = clk_ctrl;
    assign LEDs[3] = ctrl[0];
    assign LEDs[4] = ctrl[1];
    /// END OF TESTS

endmodule