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

module fifo_stack_u_tb();

    reg clk = 1'b0;
    reg I_DATA = 1'b0;
    reg save = 1'b0;
    reg pop = 1'b0;
    wire reset; assign reset = 1'b0;
    wire O_DATA;
    wire full;
    wire empty;
    wire busy;
    fifo_stack_u FIFO_u(clk, I_DATA, save, pop, reset, 
                O_DATA, full, empty, busy);

    // reg [2:0]init_state = 3'b0;
    // wire stt1; assign stt1 = (init_state == 3'b000) ? 1'b1: 1'b0;
    // wire stt2; assign stt2 = (init_state == 3'b001) ? 1'b1: 1'b0;
    // wire stt3; assign stt3 = (init_state == 3'b010) ? 1'b1: 1'b0;
    // wire stt4; assign stt4 = (init_state == 3'b011) ? 1'b1: 1'b0;
    // wire stt5; assign stt5 = (init_state == 3'b100) ? 1'b1: 1'b0;
    // wire stt6; assign stt6 = (init_state == 3'b101) ? 1'b1: 1'b0;
    // wire stt7; assign stt7 = (init_state == 3'b110) ? 1'b1: 1'b0;
    // wire stt8; assign stt8 = (init_state == 3'b111) ? 1'b1: 1'b0;
    // always @(posedge clk) begin
    //     case(init_state)
    //         3'b000: begin
    //             if(!busy)
    //                 init_state <= 3'b001;
    //             else
    //                 init_state <= 3'b000;
    //         end
    //         3'b001: begin
    //             if(!busy)
    //                 init_state <= 3'b010;
    //             else
    //                 init_state <= 3'b001;
    //         end
    //         3'b010: begin
    //             if(!busy)
    //                 init_state <= 3'b011;
    //             else
    //                 init_state <= 3'b010;
    //         end
    //         3'b011: begin
    //             if(!busy)
    //                 init_state <= 3'b100;
    //             else
    //                 init_state <= 3'b011;
    //         end
    //         3'b100: begin
    //             if(!busy)
    //                 init_state <= 3'b101;
    //             else
    //                 init_state <= 3'b100;
    //         end
    //         3'b101: begin
    //             if(!busy)
    //                 init_state <= 3'b110;
    //             else
    //                 init_state <= 3'b101;
    //         end
    //         3'b110: begin
    //             if(!busy)
    //                 init_state <= 3'b111;
    //             else
    //                 init_state <= 3'b110;
    //         end
    //         3'b111: begin
    //             if(!busy)
    //                 init_state <= 3'b000;
    //             else
    //                 init_state <= 3'b111;
    //         end
    //         default:
    //             init_state <= 3'b000;
    //     endcase
    // end
    // always @(posedge clk) begin
    //     if(stt1 == 1'b1 && !busy) begin
    //         I_DATA <= 1'b1;
    //         save <= 1'b1; 
    //         pop <= 1'b0;
    //     end
    //     if(stt2 == 1'b1 && !busy) begin
    //         I_DATA <= 1'b0;
    //         save <= 1'b1; 
    //         pop <= 1'b0;
    //     end
    //     if(stt3 == 1'b1 && !busy) begin
    //         I_DATA <= 1'b0;
    //         save <= 1'b1; 
    //         pop <= 1'b0;
    //     end
    //     if(stt4 == 1'b1 && !busy) begin
    //         I_DATA <= 1'b1;
    //         save <= 1'b1; 
    //         pop <= 1'b0;
    //     end
    //     if(stt5 == 1'b1 && !busy) begin
    //         pop <= 1'b1;
    //         save <= 1'b0; 
    //     end
    //     if(stt6 == 1'b1 && !busy) begin
    //         pop <= 1'b1;
    //         save <= 1'b0; 
    //     end
    //     if(stt7 == 1'b1 && !busy) begin
    //         pop <= 1'b1; 
    //         save <= 1'b0; 
    //     end
    //     if(stt8 == 1'b1 && !busy) begin
    //         pop <= 1'b1; 
    //         save <= 1'b0; 
    //     end
    // end

    // Clock
    always #1 clk = ~clk;

    initial begin
        $dumpfile("fifo_stack_u.vcd");
        $dumpvars(0, fifo_stack_u_tb);

        // $monitor("Input: %1b  Output: %1b  Save: %1b  Pop: %1b  Full: %1b  Empty: %1b", I_DATA, O_DATA, save, pop, full, empty);
        
        $display(" IN   SAVE   OUT  EMPT ");
        $display("Save 1 [1]");
        #2 
        #2 save <= 0; pop <= 0;

           $display("I: %b. S: %b. O: %b. E: %b. [%b]", I_DATA, save, O_DATA, empty, busy);
        #2 I_DATA <= 1;

           $display("I: %b. S: %b. O: %b. E: %b. [%b]", I_DATA, save, O_DATA, empty, busy);
        #2 save <= 1;

        #2 $display("I: %b. S: %b. O: %b. E: %b. [%b]", I_DATA, save, O_DATA, empty, busy);
           save <= 0; I_DATA <= 0;

        #2 $display("I: %b. S: %b. O: %b. E: %b. [%b]", I_DATA, save, O_DATA, empty, busy);
        #2 $display("I: %b. S: %b. O: %b. E: %b. [%b]", I_DATA, save, O_DATA, empty, busy);
        #2 $display("I: %b. S: %b. O: %b. E: %b. [%b]", I_DATA, save, O_DATA, empty, busy);
        
           $display("Save 2 [0]");
        #2 I_DATA <= 0; save <= 1;
        
           $display("I: %b. S: %b. O: %b. E: %b. [%b]", I_DATA, save, O_DATA, empty, busy);
        #2 I_DATA <= 0; save <= 0;
           $display("I: %b. S: %b. O: %b. E: %b. [%b]", I_DATA, save, O_DATA, empty, busy);

        #2 $display("I: %b. S: %b. O: %b. E: %b. [%b]", I_DATA, save, O_DATA, empty, busy);
        #2 $display("I: %b. S: %b. O: %b. E: %b. [%b]", I_DATA, save, O_DATA, empty, busy);
        #2 $display("I: %b. S: %b. O: %b. E: %b. [%b]", I_DATA, save, O_DATA, empty, busy);
        
           $display("Save 3 [1]");
        #2 I_DATA <= 1; save <= 1;
        
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

        #64 $finish;
    end

endmodule