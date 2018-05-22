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

    /// FIFO module
    wire FIFO_full;
    wire FIFO_empty;
    wire [7:0]FIFO_out;
    reg  [7:0]FIFO_in_r  = {8{1'b0}};
    reg  FIFO_save_r   = 1'b0;
    reg  FIFO_pop_r    = 1'b0;
    fifo_stack FIFO(clk_ext, FIFO_in_r, FIFO_save_r, FIFO_pop_r,
                    1'b0, FIFO_out, FIFO_full, FIFO_empty);
    /// End of FIFO module

    /// TESTS
    wire clk_ctrl;
    wire clk_ctrl_pulse;
    clk_gen #(26) pulse (clk_ext, 1'b1, clk_ctrl, clk_ctrl_pulse);

    reg [7:0]a = "D";
    // reg [7:0]a = 8'b0;
    assign Tx_data_w = a;
    assign send_data_w = (TiP_w == 1'b1) ? 1'b0 : clk_ctrl_pulse;
    assign LEDs[0] = send_data_w;
    assign LEDs[1] = TiP_w;
    assign LEDs[2] = clk_ctrl;
    assign LEDs[3] = 1'b0;
    assign LEDs[4] = 1'b0;

    // Init FIFO
    reg [2:0]init_state = 3'b0;
    wire stt1; assign stt1 = (init_state == 3'b000) ? 1'b1: 1'b0;
    wire stt2; assign stt2 = (init_state == 3'b001) ? 1'b1: 1'b0;
    wire stt3; assign stt3 = (init_state == 3'b010) ? 1'b1: 1'b0;
    wire stt4; assign stt4 = (init_state == 3'b011) ? 1'b1: 1'b0;
    wire stt5; assign stt5 = (init_state == 3'b100) ? 1'b1: 1'b0;
    always @(posedge clk_ext) begin
        case(init_state)
            3'b000: begin
                init_state <= 3'b001;
            end
            3'b001: begin
                init_state <= 3'b010;
            end
            3'b010: begin
                init_state <= 3'b011;
            end
            3'b011: begin
                init_state <= 3'b100;
            end
            3'b100: begin
                init_state <= 3'b100;
            end
            default:
                init_state <= 3'b000;
        endcase
    end
    always @(posedge clk_ext) begin
        if(stt1 == 1'b1) begin
            FIFO_in_r <= "H";
            FIFO_save_r <= 1'b1; 
        end
        if(stt2 == 1'b1) begin
            FIFO_in_r <= "o";
            FIFO_save_r <= 1'b1; 
        end
        if(stt3 == 1'b1) begin
            FIFO_in_r <= "l";
            FIFO_save_r <= 1'b1; 
        end
        if(stt4 == 1'b1) begin
            FIFO_in_r <= "a";
            FIFO_save_r <= 1'b1; 
        end
    end
    /// End of TESTS

endmodule