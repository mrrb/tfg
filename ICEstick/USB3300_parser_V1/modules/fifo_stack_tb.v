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
    reg [7:0]I_DATA = 8'b0;
    reg save = 1'b0;
    reg pop = 1'b0;
    wire reset; assign reset = 1'b0;
    wire [7:0]O_DATA;
    wire full;
    wire empty;
    fifo_stack FIFO(clk, I_DATA, save, pop, reset, 
                O_DATA, full, empty);

    reg [2:0]init_state = 3'b0;
    wire stt1; assign stt1 = (init_state == 3'b000) ? 1'b1: 1'b0;
    wire stt2; assign stt2 = (init_state == 3'b001) ? 1'b1: 1'b0;
    wire stt3; assign stt3 = (init_state == 3'b010) ? 1'b1: 1'b0;
    wire stt4; assign stt4 = (init_state == 3'b011) ? 1'b1: 1'b0;
    wire stt5; assign stt5 = (init_state == 3'b100) ? 1'b1: 1'b0;
    always @(posedge clk) begin
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
                init_state <= 3'b000;
            end
            default:
                init_state <= 3'b000;
        endcase
    end
    always @(posedge clk) begin
        if(stt1 == 1'b1) begin
            I_DATA <= "H";
            save <= 1'b1; 
        end
        if(stt2 == 1'b1) begin
            I_DATA <= "o";
            save <= 1'b1; 
        end
        if(stt3 == 1'b1) begin
            I_DATA <= "l";
            save <= 1'b1; 
        end
        if(stt4 == 1'b1) begin
            I_DATA <= "a";
            save <= 1'b1; 
        end
    end

    // Clock
    always #1 clk = ~clk;

    initial begin
        $dumpfile("fifo_stack.vcd");
        $dumpvars(0, fifo_stack_tb);

        $monitor("Input: %8b  Output: %8b  Save: %1b  Full: %1b  Empty: %1b", I_DATA, O_DATA, save, full, empty);

        #64 $finish;
    end

endmodule