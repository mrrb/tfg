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

// Lectura de trama a partir del modulo USB3300
// Partes
// 1. Módulo de transmisión serie FPGA->PC
// 2. Almacenamiento FIFO (un bloque de memoria por bits de datos)
// 3. Lectura de datos provenientes del módulo USB3300 (Cuando DIR está en nivel alto, en el flanco de subida del reloj externo de 60MHz)

// Funcionamiento
// 1. La señal de reloj del módulo USB3300 controla todo els sitema.
// 2. Cuando se de

// Pruebas
// 1. Prueba de funcionamiento de transmisión del puerto serie
// 2. 

`default_nettype none

`include "serial_write.v"
`include "fifo_stack.v"
`include "USB3300_read.v"

module USB3300_receive(input  wire clk_int,   // Internal clock, 60MHz
                       input  wire clk_ext,   //  clock, 12MHz
                       input  wire [7:0]DATA, // USB3300 DATA pins
                       input  wire DIR,       // USB3300 DIR pin
                       input  wire NXT,       // USB3300 NXT pin
                       output wire STP,       // USB3300 STP pin
                       output wire tx,        // Serial TX output
                       output wire [3:0]LEDs);

    // Tests
    reg [20:0]send_r = 21'b_0;
    wire send_data;
    assign send_data = send_r[20];

    always @ (posedge clk_int) begin
        send_r <= send_r + 1;
    end

    reg [7:0]letter = 8'h_4B;
    wire TiP;
    wire ctrl;
    wire ctrl2;
    serial_write S_write(.clk(clk_ext), .tx_data(letter), .send_data(send_data), .TiP(TiP), .tx(tx), .ctrl(ctrl), .ctrl2(ctrl2));

    assign LEDs[0] = TiP;
    assign LEDs[1] = send_data;
    assign LEDs[2] = ctrl;
    assign LEDs[3] = ctrl2;
    // End of tests

endmodule