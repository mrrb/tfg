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
 *     Initial: 2018/04/22      Mario Rubio
 */

// Transmisión de datos por el puerto serie del integrado FTDI
// Partes
// 1. Generador del reloj de baudios
// 2. 

module serial_write #(parameter BAUD_DIVIDER = 9)       // Divider used to generate the baud serial clock
                     (input  wire clk,                  // Reference clock
                      input  wire [N_BITS-1:0]tx_data,  // Data to send
                      input  wire send_data,            // Send the current data in tx_data IF there isn't any trasmission in progress
                      output wire  TiP,                 // Trasmission in Progress flag
                      output wire  ctrl,
                      output wire  ctrl2,
                      output wire  tx);                 // TX pin output

    localparam CTRL_LEN = $ceil((N_BITS+1)/2);

    // Baud clock gen
    reg  [BAUD_DIVIDER-1:0]baud_r = {BAUD_DIVIDER{1'b_0}};
    wire clk_baud;
    assign clk_baud = baud_r[BAUD_DIVIDER-1];

    // Data buffer
    reg [N_BITS+END_BITS+1-1:0]buffer = {(N_BITS+END_BITS+1){1'b_1}};

    // Serial controller
    reg TiP_r = 1'b_0;
    reg [CTRL_LEN-1:0]counter_ctrl = {CTRL_LEN{1'b_0}};

    // Serial data flow
    always @(posedge clk_baud) begin
      if (TiP_r == 1'b_1) begin
        buffer <= {1'b_1, buffer>>1};
        counter_ctrl <= {counter_comp<<1, 1'b_1};
      end
      else if(counter_ctrl[CTRL_LEN-1]) begin
        // counter_ctrl <= {(CTRL_LEN){1'b_0}};
        // buffer <= {(N_BITS+END_BITS+1){1'b_1}};
        // TiP_r <= 1'b_0;
        // baud_r <= {BAUD_DIVIDER{1'b_0}};
      end
    end

    // Data load
    always @(posedge clk) begin
      if(send_data&(!TiP_r) == 1'b_1) begin
        buffer <= {1'b_0, tx_data[0:N_BITS-1], {END_BITS{1'b_0}}};
        test <= !test;
        TiP_r  <= 1'b_1;
        counter_ctrl <= {(CTRL_LEN){1'b_0}};        
        baud_r <= {BAUD_DIVIDER{1'b_0}};
      end
      else if(TiP_r == 1'b1) begin
        baud_r <= baud_r + 1;
      end
    end

    // tx output and TiP
    assign tx  = (TiP_r == 1'b_1) ? buffer[0] : 1'b_1;
    assign TiP = TiP_r;

    reg test = 1'b0;
    assign ctrl  = clk_baud;
    assign ctrl2 = buffer[7];

endmodule