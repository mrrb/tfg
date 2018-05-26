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

`include "clk_gen.v"

module UART_tb();
   
    // Registers and wires
    reg  [7:0]data = 8'b0;
    reg  clk = 1'b0;
    reg  send_data = 1'b0;
    wire Tx;
    wire Rx;
    wire TiP;
    wire NrD;
    wire [7:0]O_DATA;

    wire ctrl;
    UART #(.BAUD_DIVIDER(1)) U1 (Rx, clk, data, send_data, Tx, TiP, NrD, O_DATA, ctrl);

    // Clock
    always #1 clk = ~clk;

    //
    initial begin
      
        $dumpfile("UART.vcd");
        $dumpvars(0, UART_tb);

        $monitor("data=%8b send_data=%1b Tx=%1b TiP=%1b",data, send_data, Tx, TiP);
        #2
        #2   data = 8'b01010101; send_data =1'b1;
        #2   send_data =1'b0;
        #100 $display("End!"); $finish;
    end

endmodule