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
 *     Initial: 2018/05/23      Mario Rubio
 */

module USB3300_receiver 
                         (input  wire clk,       // Master clock signal
                          input  wire DIR,       // Input ULPI DIR
                          input  wire NXT,       // Input ULPI NXT
                          input  wire [7:0]DATA, // Input ULPI data
                          input  wire ME,        // Mode Enable (1->enable; 0->stop) 
                          output wire [7:0]PID,  // PID info
                          output wire [7:0]D2,   // Data packet 2
                          output wire [7:0]D1,   // Data packet 1
                          output wire [7:0]CMD,  // RXD CMD
                          output wire NP,        // New Package flag
                          output wire busy       // Busy flag
                          );

    /// USB3300 receiver regs and wires
    // Outputs
    reg [7:0]PID_r = 8'b0; assign PID = PID_r;
    reg [7:0]D2_r  = 8'b0; assign D2  = D2_r;
    reg [7:0]D1_r  = 8'b0; assign D1  = D1_r;
    reg [7:0]CMD_r = 8'b0; assign CMD = CMD_r;
    reg NP_r       = 1'b0; assign NP  = NP_r;

    // Inputs
    reg [7:0]DATA_r = 8'b0;
    reg DIR_r       = 1'b0;
    reg NXT_r       = 1'b0;
    always @(posedge clk) begin
        DATA_r <= DATA;
        DIR_r  <= DIR;
        NXT_r  <= NXT;
    end

    // Buffers

    // Control registers
    reg [2:0]receiver_state_r = 3'b0;

    // Flags
    wire receiver_s_IDLE;
    wire receiver_s_CMD1;
    wire receiver_s_PID;
    wire receiver_s_D1;
    wire receiver_s_CMD2;
    wire receiver_s_D2;
    wire receiver_s_WAIT;

    // Assigns
    assign receiver_s_IDLE = (receiver_state_r == receiver_IDLE)      ? 1'b1 : 1'b0;
    assign receiver_s_CMD1 = (receiver_state_r == receiver_READ_CMD1) ? 1'b1 : 1'b0;
    assign receiver_s_PID  = (receiver_state_r == receiver_READ_PID)  ? 1'b1 : 1'b0;
    assign receiver_s_D1   = (receiver_state_r == receiver_READ_D1)   ? 1'b1 : 1'b0;
    assign receiver_s_CMD2 = (receiver_state_r == receiver_READ_CMD2) ? 1'b1 : 1'b0;
    assign receiver_s_D2   = (receiver_state_r == receiver_READ_D2)   ? 1'b1 : 1'b0;
    assign receiver_s_WAIT = (receiver_state_r == receiver_WAIT)      ? 1'b1 : 1'b0;
    assign busy            = !receiver_s_IDLE;

    /// End of USB3300 receiver regs and wires

    /// USB3300 receiver states
    localparam receiver_IDLE      = 3'b000;
    localparam receiver_READ_CMD1 = 3'b001;
    localparam receiver_READ_PID  = 3'b010;
    localparam receiver_READ_D1   = 3'b011;
    localparam receiver_READ_CMD2 = 3'b100;
    localparam receiver_READ_D2   = 3'b101;
    localparam receiver_WAIT      = 3'b110;
    /// End of USB3300 receiver states

    /// USB3300 receiver controller
    always @(posedge clk) begin
        if(ME == 1'b0) begin
            receiver_state_r <= receiver_IDLE;
        end
        else begin
            case(receiver_state_r)
                receiver_IDLE: begin
                    if(DIR_r) begin
                        receiver_state_r <= receiver_READ_CMD1;
                    end
                    else begin
                        receiver_state_r <= receiver_IDLE;
                    end
                end
                receiver_READ_CMD1: begin
                    if(DIR_r) begin
                        receiver_state_r <= receiver_READ_PID;
                    end
                    else begin
                        receiver_state_r <= receiver_IDLE;
                    end
                end
                receiver_READ_PID: begin
                    if(DIR_r) begin
                        receiver_state_r <= receiver_READ_D1;
                    end
                    else begin
                        receiver_state_r <= receiver_IDLE;
                    end
                end
                receiver_READ_D1: begin
                    if(DIR_r) begin
                        receiver_state_r <= receiver_READ_CMD2;
                    end
                    else begin
                        receiver_state_r <= receiver_IDLE;
                    end
                end
                receiver_READ_CMD2: begin
                    if(DIR_r) begin
                        receiver_state_r <= receiver_READ_D2;
                    end
                    else begin
                        receiver_state_r <= receiver_IDLE;
                    end
                end
                receiver_READ_D2: begin
                    if(DIR_r) begin
                        receiver_state_r <= receiver_IDLE;
                    end
                    else begin
                        receiver_state_r <= receiver_IDLE;
                    end
                end
                receiver_WAIT: begin
                    receiver_state_r <= receiver_IDLE;
                end
                default: begin
                    receiver_state_r <= receiver_IDLE;
                end
            endcase
        end
    end
    
    // Store USB frame
    always @(posedge clk) begin
        if(ME == 1'b0) begin
            PID_r <= 8'b0;
            D2_r  <= 8'b0;
            D1_r  <= 8'b0;
            CMD_r <= 8'b0;
            NP_r  <= 1'b0;
            // {PID_r, D2_r, D1_r, CMD_r, NP_r} <= 33'b0;
        end
        else if(receiver_s_IDLE) begin
            NP_r  <= 1'b0;
        end
        else if(receiver_s_CMD1) begin
            CMD_r <= DATA_r;
        end
        else if(receiver_s_PID) begin
            PID_r <= DATA_r;
        end
        else if(receiver_s_D1) begin
            D1_r  <= DATA_r;
        end
        else if(receiver_s_CMD2) begin
            CMD_r <= DATA_r;
        end
        else if(receiver_s_D2) begin
            D2_r  <= DATA_r;
            NP_r  <= 1'b1;
        end
        else if(receiver_s_WAIT) begin
        end
    end
    /// End of USB3300 receiver controller

endmodule