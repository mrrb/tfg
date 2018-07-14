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

`include "clk_gen.v"

module UART #(parameter BAUD_DIVIDER = 9)
             (input  wire Rx,          // Rx input pin
              input  wire clk,         // reference clock input pin
              input  wire [7:0]I_DATA, // 8-bits data to send
              input  wire send_data,   // Send the current data in DATA IF there isn't any trasmission in progress
              output wire Tx,          // Tx output pin
              output wire TiP,         // Trasmission in Progress flag
              output wire NrD,         // New received Data flag
              output wire [7:0]O_DATA, // 8-bits data received
              output wire bauds,
              output wire ctrl
              );

    // Baud clock gen
    wire clk_baud;
    clk_gen #(.DIVIDER(9)) baud (clk, clk_baud);

    // Buffers and registers
    reg TiP_r = 1'b0;
    reg NrD_r = 1'b0;
    reg [9:0]buffer_out_r = 10'b0;
    reg [3:0]Tx_counter_r = 3'b0;
    reg [9:0]buffer_in_r  = 10'b0;

    // Serial data sender controller
    always @(posedge clk) begin
        if((send_data == 1'b1) && (TiP == 1'b0)) begin
            buffer_out_r <= {1'b0 , I_DATA, 1'b0};
            TiP_r        <= 1'b1;
            Tx_counter_r <= 3'b0;
            // both         <= ~both;
        end
    end

    always @(posedge clk) begin
        if((TiP == 1'b1) && (clk_baud == 1'b1)) begin
            if(Tx_counter_r == 4'b1001) begin
                TiP_r <= 1'b1;
            end
            buffer_out_r <= buffer_out_r>>1;
            Tx_counter_r <= Tx_counter_r + 1;
        end
    end
    // Tx_counter
    // 0000 -> star bit
    // 0001 -> data_0
    // 0010 -> data_1
    // 0011 -> data_2
    // 0100 -> data_3
    // 0101 -> data_4
    // 0110 -> data_5
    // 0111 -> data_6
    // 1000 -> data_7
    // 1001 -> stop bit

    // Big-Endian
    // [0:3]var
    // x x x x
    // 0 1 2 3
    // Little-endian
    // [3:0]var
    // x x x x
    // 3 2 1 0

    // reg [1:0]both = 2'b10;
    // Assigns
    assign Tx  = (TiP == 1'b1) ? buffer_out_r[0] : 1'b1;
    // assign Tx  = (TiP == 1'b1) ? both[1] : both[0];
    assign TiP = TiP_r;
    assign NrD = NrD_r;
    assign O_DATA = buffer_in_r[8:1];
    assign bauds = clk_baud;

    assign ctrl = buffer_out_r[0];

endmodule