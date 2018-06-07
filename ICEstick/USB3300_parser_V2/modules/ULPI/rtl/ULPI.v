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

`inclue "ULPI_REG_ADDR.vh"

module ULPI #()
             (input  wire clk,
              input  wire DIR,
              input  wire NXT,
              inout  wire [7:0]DATA,
              output wire STP);

    /// ULPI registers values
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
    /// End of ULPI registers values

    /// ULPI states
    localparam ULPI_REG_READ    = 3'b000;
    localparam ULPI_REG_WRITE   = 3'b001;
    localparam ULPI_TRANS_PACK  = 3'b010;
    localparam ULPI_REC_PACK    = 3'b011;
    localparam ULPI_REC_RXCMD   = 3'b100;
    localparam ULPI_LOWPW_ENTER = 3'b101;
    localparam ULPI_LOWPW_EXIT  = 3'b110;
    localparam ULPI_IDLE        = 3'b111;
    /// End of ULPI states

    /// ULPI register READ
    reg [7:0]READ_ADDR = 8'b0;
    reg READ_EXECUTE = 1'b0;
    /// End of ULPI register READ

    /// ULPI register WRITE
    reg [7:0]TX_CMD = 8'b0;
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