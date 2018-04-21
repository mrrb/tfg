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
 *     Initial: 2018/04/15      Mario Rubio
 */

// Partes a realizar
// 1. Entrada/salida de señales del módulo USB3300 - Listo
// 2. Configuración del sistema según los pulsos del reloj externo de 60MHz - Listo
// 3. Configurar acción cuando DIR está a nivel alto - Listo
// 4. Almacenar los 8 bits de datos en un registro
// 5. Pasar dicho registro al módulo de transmisión serie. Modulo que tiene que almacenar como mínimo N (5 creo) bloques de 8bits para no perder información
// 6. Configurar un registro de desplazamiento que envia toda eas información por el puerto serie

`include "FIFO_STACK.v" 

module USB3300_parser(input wire clk_ext,
                      input wire clk_int,
                      input wire [7:0]DATA,
                      input wire DIR,
                      input wire NXT,
                      output wire STP);

    // Storage settings
    localparam BUFF_SIZE = 16;

    // Data FIFO buffers and control registers
    reg in_ctrl  = 1'b0;
    reg out_ctrl = 1'b0;
    reg [7:0]stored_data;
    reg [7:0]overflow;
    reg [7:0]no_data;
    FIFO_STACK #(.N_STACK_SIZE(BUFF_SIZE)) D0(.data_in(DATA[0]), .clk(!clk_ext), .in_ctrl(in_ctrl), .out_ctrl(out_ctrl), .data_out(stored_data[0]), .no_data(no_data[0]), .overflow(overflow[0]));
    FIFO_STACK #(.N_STACK_SIZE(BUFF_SIZE)) D1(.data_in(DATA[1]), .clk(!clk_ext), .in_ctrl(in_ctrl), .out_ctrl(out_ctrl), .data_out(stored_data[1]), .no_data(no_data[1]), .overflow(overflow[1]));
    FIFO_STACK #(.N_STACK_SIZE(BUFF_SIZE)) D2(.data_in(DATA[2]), .clk(!clk_ext), .in_ctrl(in_ctrl), .out_ctrl(out_ctrl), .data_out(stored_data[2]), .no_data(no_data[2]), .overflow(overflow[2]));
    FIFO_STACK #(.N_STACK_SIZE(BUFF_SIZE)) D3(.data_in(DATA[3]), .clk(!clk_ext), .in_ctrl(in_ctrl), .out_ctrl(out_ctrl), .data_out(stored_data[3]), .no_data(no_data[3]), .overflow(overflow[3]));
    FIFO_STACK #(.N_STACK_SIZE(BUFF_SIZE)) D4(.data_in(DATA[4]), .clk(!clk_ext), .in_ctrl(in_ctrl), .out_ctrl(out_ctrl), .data_out(stored_data[4]), .no_data(no_data[4]), .overflow(overflow[4]));
    FIFO_STACK #(.N_STACK_SIZE(BUFF_SIZE)) D5(.data_in(DATA[5]), .clk(!clk_ext), .in_ctrl(in_ctrl), .out_ctrl(out_ctrl), .data_out(stored_data[5]), .no_data(no_data[5]), .overflow(overflow[5]));
    FIFO_STACK #(.N_STACK_SIZE(BUFF_SIZE)) D6(.data_in(DATA[6]), .clk(!clk_ext), .in_ctrl(in_ctrl), .out_ctrl(out_ctrl), .data_out(stored_data[6]), .no_data(no_data[6]), .overflow(overflow[6]));
    FIFO_STACK #(.N_STACK_SIZE(BUFF_SIZE)) D7(.data_in(DATA[7]), .clk(!clk_ext), .in_ctrl(in_ctrl), .out_ctrl(out_ctrl), .data_out(stored_data[7]), .no_data(no_data[7]), .overflow(overflow[7]));


    always @(posedge clk_ext) begin
        if(DIR == 1'b_1) begin
            in_ctrl  <= 1'b1;
            out_ctrl <= 1'b0;
        end
        else begin
            in_ctrl  <= 1'b0;
            out_ctrl <= 1'b0;
        end
    end

endmodule