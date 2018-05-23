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
 *     Initial: 2018/05/22      Mario Rubio
 */

module fifo_stack_tb();

    reg clk = 1'b0;
    reg [7:0]I_DATA = 1'b0;
    reg save = 1'b0;
    reg pop = 1'b0;
    wire reset; assign reset = 1'b0;
    wire [7:0]O_DATA;
    wire full;
    wire empty;
    wire busy;
    fifo_stack FIFO(clk, I_DATA, save, pop, reset, 
                        O_DATA, full, empty, busy);

    // Clock
    always #1 clk = ~clk;

    initial begin
        $dumpfile("fifo_stack.vcd");
        $dumpvars(0, fifo_stack_tb);

        // $monitor("Input: %1b  Output: %1b  Save: %1b  Pop: %1b  Full: %1b  Empty: %1b", I_DATA, O_DATA, save, pop, full, empty);
        
        $display("     IN      SAVE       OUT     EMPT");
        #2 
        #2 save <= 0; pop <= 0;

           $display("Save 1 [%b]", "A");
           $display("I: %b. S: %b. O: %b. E: %b. [%b]", I_DATA, save, O_DATA, empty, busy);
        #2 I_DATA <= "A";

           $display("I: %b. S: %b. O: %b. E: %b. [%b]", I_DATA, save, O_DATA, empty, busy);
        #2 save <= 1;

        #2 $display("I: %b. S: %b. O: %b. E: %b. [%b]", I_DATA, save, O_DATA, empty, busy);
           save <= 0; I_DATA <= 0;

        #2 $display("I: %b. S: %b. O: %b. E: %b. [%b]", I_DATA, save, O_DATA, empty, busy);
        #2 $display("I: %b. S: %b. O: %b. E: %b. [%b]", I_DATA, save, O_DATA, empty, busy);
        #2 $display("I: %b. S: %b. O: %b. E: %b. [%b]", I_DATA, save, O_DATA, empty, busy);
        
           $display("Save 2 [%b]", "[");
        #2 I_DATA <= "["; save <= 1;
        
           $display("I: %b. S: %b. O: %b. E: %b. [%b]", I_DATA, save, O_DATA, empty, busy);
        #2 I_DATA <= 0; save <= 0;
           $display("I: %b. S: %b. O: %b. E: %b. [%b]", I_DATA, save, O_DATA, empty, busy);

        #2 $display("I: %b. S: %b. O: %b. E: %b. [%b]", I_DATA, save, O_DATA, empty, busy);
        #2 $display("I: %b. S: %b. O: %b. E: %b. [%b]", I_DATA, save, O_DATA, empty, busy);
        #2 $display("I: %b. S: %b. O: %b. E: %b. [%b]", I_DATA, save, O_DATA, empty, busy);
        
           $display("Save 3 [%b]", "c");
        #2 I_DATA <= "c"; save <= 1;
        
           $display("I: %b. S: %b. O: %b. E: %b. [%b]", I_DATA, save, O_DATA, empty, busy);
        #2 I_DATA <= 0; save <= 0;
           $display("I: %b. S: %b. O: %b. E: %b. [%b]", I_DATA, save, O_DATA, empty, busy);

        #2 $display("I: %b. S: %b. O: %b. E: %b. [%b]", I_DATA, save, O_DATA, empty, busy);
        #2 $display("I: %b. S: %b. O: %b. E: %b. [%b]", I_DATA, save, O_DATA, empty, busy);
        #2 $display("I: %b. S: %b. O: %b. E: %b. [%b]", I_DATA, save, O_DATA, empty, busy);

           $display("Pop 1");
        #2 pop <=1;
        
           $display("I: %b. S: %b. O: %b. E: %b. [%b]", I_DATA, save, O_DATA, empty, busy);
        #2 pop <= 0;

        #2 $display("I: %b. S: %b. O: %b. E: %b. [%b]", I_DATA, save, O_DATA, empty, busy);
        #2 $display("I: %b. S: %b. O: %b. E: %b. [%b]", I_DATA, save, O_DATA, empty, busy);
        #2 $display("I: %b. S: %b. O: %b. E: %b. [%b]", I_DATA, save, O_DATA, empty, busy);
        
           $display("Pop 2");
        #2 pop <=1;
        
           $display("I: %b. S: %b. O: %b. E: %b. [%b]", I_DATA, save, O_DATA, empty, busy);
        #2 pop <= 0;

        #2 $display("I: %b. S: %b. O: %b. E: %b. [%b]", I_DATA, save, O_DATA, empty, busy);
        #2 $display("I: %b. S: %b. O: %b. E: %b. [%b]", I_DATA, save, O_DATA, empty, busy);
        #2 $display("I: %b. S: %b. O: %b. E: %b. [%b]", I_DATA, save, O_DATA, empty, busy);
        
           $display("Pop 3");
        #2 pop <=1;
        
           $display("I: %b. S: %b. O: %b. E: %b. [%b]", I_DATA, save, O_DATA, empty, busy);
        #2 pop <= 0;

        #2 $display("I: %b. S: %b. O: %b. E: %b. [%b]", I_DATA, save, O_DATA, empty, busy);
        #2 $display("I: %b. S: %b. O: %b. E: %b. [%b]", I_DATA, save, O_DATA, empty, busy);
        #2 $display("I: %b. S: %b. O: %b. E: %b. [%b]", I_DATA, save, O_DATA, empty, busy);

        #1 $display("Test Done!");
        #64 $finish;
    end

endmodule