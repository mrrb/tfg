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
 *     Initial: 2018/05/30      Mario Rubio
 */

module ULPI #()
             (
              input  [4:0]reg_addr,
              // Registers write/read
              input  reg_write,
              input  reg_read,
              input  [7:0]reg_write_data,
              output [7:0]reg_read_data,
              // Physical pins
              input  wire clk,
              input  wire DIR,
              input  wire NXT,
              inout  wire [7:0]DATA,
              output wire STP);


    /// Input data storage
    reg [4:0]reg_addr_r       = 5'b0;
    // Write/read registers
    reg reg_write_r           = 1'b0;
    reg reg_read_r            = 1'b0;
    reg [7:0]reg_write_data_r = 8'b0;

    always @(posedge clk) begin
        reg_write_r      <= reg_write;
        reg_read_r       <= reg_read;
        reg_addr_r       <= reg_addr;
        reg_write_data_r <= reg_write_data;
    end
    /// End of Input data storage

    /// Bidirectional DATA controller
    // https://www.altera.com/support/support-resources/design-examples/design-software/verilog/ver_bidirec.html
    reg DATA_buff_r = 8'b0;
    assign DATA = (DIR == 1'b1) ? {8{1'bz}} : DATA_buff_r;
    /// Edn of Bidirectional DATA controller
    

    /// Send TXCMD task

    /// End of Send TXCMD task


    /// Output buffers
    reg [7:0]ULPI_TXCMD_buf_r = 8'b0;
    reg [7:0]ULPI_D0_buf_r = 8'b0;
    /// End of Output buffers


    /// ULPI USB3300 registers
    reg [7:0]vendor_id_low_r      = 8'b0;
    reg [7:0]vendor_id_high_r     = 8'b0;
    reg [7:0]product_id_low_r     = 8'b0;
    reg [7:0]product_id_high_r    = 8'b0;
    reg [7:0]function_control_r   = 8'b0;
    reg [7:0]interface_control_r  = 8'b0;
    reg [7:0]OTG_control_r        = 8'b0;
    reg [7:0]USB_int_en_rising_r  = 8'b0;
    reg [7:0]USB_int_en_falling_r = 8'b0;
    reg [7:0]USB_int_status_r     = 8'b0;
    reg [7:0]USB_int_latch_r      = 8'b0;
    reg [7:0]debug_r              = 8'b0;
    reg [7:0]scratch_r            = 8'b0;
    /// End of ULPI USB3300 registers


    /// ULPI registers
    reg [3:0]ULPI_state_r = 4'b0;
    reg ULPI_start_done   = 1'b0;
    /// End of ULPI registers


    /// ULPI states
    localparam ULPI_REG_READ    = 4'b0000; 
    localparam ULPI_REG_WRITE   = 4'b0001;
    localparam ULPI_TRANS_PACK  = 4'b0010;
    localparam ULPI_TRANS_TXCMD = 4'b0011;
    localparam ULPI_REC_PACK    = 4'b0100;
    localparam ULPI_REC_RXCMD   = 4'b0101;
    localparam ULPI_LOWPW_ENTER = 4'b0110;
    localparam ULPI_LOWPW_EXIT  = 4'b0111;
    localparam ULPI_LOWPW       = 4'b1000;
    localparam ULPI_IDLE        = 4'b1001;
    localparam ULPI_START       = 4'b1010;
    /// End of ULPI states


    /// ULPI flags
    wire ULPI_S_REG_READ;    assign ULPI_S_REG_READ    = (ULPI_state_r == ULPI_REG_READ)    ? 1'b1 : 1'b0;
    wire ULPI_S_REG_WRITE;   assign ULPI_S_REG_WRITE   = (ULPI_state_r == ULPI_REG_WRITE)   ? 1'b1 : 1'b0;
    wire ULPI_S_TRANS_PACK;  assign ULPI_S_TRANS_PACK  = (ULPI_state_r == ULPI_TRANS_PACK)  ? 1'b1 : 1'b0;
    wire ULPI_S_REC_PACK;    assign ULPI_S_REC_PACK    = (ULPI_state_r == ULPI_REC_PACK)    ? 1'b1 : 1'b0;
    wire ULPI_S_REC_RXCMD;   assign ULPI_S_REC_RXCMD   = (ULPI_state_r == ULPI_REC_RXCMD)   ? 1'b1 : 1'b0;
    wire ULPI_S_LOWPW_ENTER; assign ULPI_S_LOWPW_ENTER = (ULPI_state_r == ULPI_LOWPW_ENTER) ? 1'b1 : 1'b0;
    wire ULPI_S_LOWPW_EXIT;  assign ULPI_S_LOWPW_EXIT  = (ULPI_state_r == ULPI_LOWPW_EXIT)  ? 1'b1 : 1'b0;
    wire ULPI_S_LOWPW;       assign ULPI_S_LOWPW       = (ULPI_state_r == ULPI_LOWPW)       ? 1'b1 : 1'b0;
    wire ULPI_S_IDLE;        assign ULPI_S_IDLE        = (ULPI_state_r == ULPI_IDLE)        ? 1'b1 : 1'b0;
    wire ULPI_S_START;       assign ULPI_S_START       = (ULPI_state_r == ULPI_START)       ? 1'b1 : 1'b0;
    /// End of ULPI flags


    /// ULPI controller
    always @(posedge clk) begin
        if() begin
            // RST
        end
        else begin
            case(ULPI_state_r)
                ULPI_START: begin
                    if(ULPI_start_done == 1'b1) ULPI_state_r <= ULPI_IDLE;
                    else ULPI_state_r <= ULPI_START;
                end
                ULPI_IDLE: begin
                    if()
                    else ULPI_state_r <= ULPI_IDLE;
                end
                ULPI_REG_READ: begin
                end
                ULPI_REG_WRITE: begin
                end
                ULPI_TRANS_PACK: begin
                end
                ULPI_REC_PACK: begin
                end
                ULPI_REC_RXCMD: begin
                end
                ULPI_LOWPW_ENTER: begin
                end
                ULPI_LOWPW_EXIT: begin
                end
                ULPI_LOWPW: begin
                end
                default: begin
                    ULPI_state_r <= ULPI_IDLE;
                end
            endcase
        end
    end
    /// End of ULPI controller


    /// ULPI register READ
    // Reg read registers
    reg ULPI_read_state_r = 3'b0;
    reg ULPI_read_start_r = 1'b0;

    // Reg read states
    localparam ULPI_READ_IDLE  = 3'b000; // Default state. Doing nothing.
    localparam ULPI_READ_LOAD  = 3'b001; // Detect if PHY has control over the bus. If not, load the ADDRESS and TXCMD registers.
    localparam ULPI_READ_TXCMD = 3'b010; // Send TXCMD and wait until NXT assert
    localparam ULPI_READ_SYNC  = 3'b011; // Turn around 1 clk pulse wait
    localparam ULPI_READ_SAVE  = 3'b100; // Data save

    // Reg read flags
    wire ULPI_S_READ_IDLE;
    wire ULPI_S_READ_LOAD;
    wire ULPI_S_READ_TXCMD;
    wire ULPI_S_READ_SYNC;
    wire ULPI_S_READ_SAVE;

    // Reg read assigns
    assign ULPI_S_READ_IDLE  = (ULPI_read_state_r == ULPI_READ_IDLE)  ? 1'b1 : 1'b0;
    assign ULPI_S_READ_LOAD  = (ULPI_read_state_r == ULPI_READ_LOAD)  ? 1'b1 : 1'b0;
    assign ULPI_S_READ_TXCMD = (ULPI_read_state_r == ULPI_READ_TXCMD) ? 1'b1 : 1'b0;
    assign ULPI_S_READ_SYNC  = (ULPI_read_state_r == ULPI_READ_SYNC)  ? 1'b1 : 1'b0;
    assign ULPI_S_READ_SAVE  = (ULPI_read_state_r == ULPI_READ_SAVE)  ? 1'b1 : 1'b0;

    // Reg read controller
    always @(posedge clk) begin
        if() begin
            // RST
        end
        else
            case(ULPI_read_state_r)
                ULPI_READ_IDLE: begin
                    if(ULPI_read_start_r == 1'b1) ULPI_read_state_r <= ULPI_READ_LOAD;
                    else ULPI_read_state_r <= ULPI_READ_IDLE;
                end
                ULPI_READ_LOAD: begin
                    ULPI_read_state_r <= ULPI_READ_TXCMD;
                end
                ULPI_READ_TXCMD: begin

                end
                ULPI_READ_SYNC: begin
                end
                ULPI_READ_SAVE: begin

                end
                default: begin
                    ULPI_read_state_r <= ULPI_READ_IDLE;
                end
        end
    end

    always @(posedge clk) begin
        if() begin
            // RST
        end
        else if(ULPI_S_READ_IDLE  == 1'b1) begin
        end
        else if(ULPI_S_READ_LOAD  == 1'b1) begin
        end
        else if(ULPI_S_READ_TXCMD == 1'b1) begin
        end
        else if(ULPI_S_READ_SYNC  == 1'b1) begin
        end
        else if(ULPI_S_READ_SAVE  == 1'b1) begin
        end
        else begin
        end
    end
    /// End of ULPI register READ


    /// ULPI register WRITE
    /// End of ULPI register WRITE


    /// ULPI transmit Packet
    /// End of ULPI transmit Packet
    

    /// ULPI receive Packet
    /// End of ULPI receive Packet
    

    /// ULPI receive RXCMD
    /// End of ULPI receive RXCMD


    /// ULPI enter LOW POWER MODE
    /// End of ULPI enter LOW POWER MODE


    /// ULPI resuming from LOW POWER MODE
    /// End of ULPI resuming from LOW POWER MODE


endmodule