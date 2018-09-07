/*
 * MIT License
 *
 * Copyright (c) 2018 Mario Rubio
 *
 MIT License

Copyright (c) 2015-present, Facebook, Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
 
 */

/*
 * Revision History:
 *     Initial:        2018/06/15        Mario Rubio
 */

/*
 * 
 * This is the main file for the USB3300 sniffer
 * 
 */

`default_nettype none

`include "./rtl/ULPI_REG_ADDR.vh" // USB3300 register addresses definitions
`include "./modules/ULPI/rtl/ULPI.v" // ULPI module
`include "./modules/UART/rtl/UART.v" // UART module
`include "./modules/SPI_SLAVE_CTRL/rtl/SPI_SLAVE_CTRL.v" // SPI module

module USB3300_parser (
                       // Clocks
                       input  wire clk_int, // FPGA 12MHz clock
                       input  wire clk_ext, // USB3300 60MHz clock

                       // USB3300/ULPI pins
                       input  wire ULPI_DIR, // ULPI DIR input
                       input  wire ULPI_NXT, // ULPI NXT input
                       output wire ULPI_STP, // ULPI STP output
                       inout  wire [7:0]ULPI_DATA, // ULPI Data inout

                       // SPI pins
                       input  wire SPI_SCK,  // SPI reference clock
                       input  wire SPI_SS,   // SPI Slave Select pin
                       input  wire SPI_MOSI, // SPI input  'Master Out Slave In'
                       output wire SPI_MISO, // SPI output 'Master In  Slave Out'

                       // UART pins
                       input  wire UART_RX, // UART serial data input
                       output wire UART_TX  // UART serial data output
                      );

    /// Main clock generator from PLL
    /*
     * PLL configuration
     *
     * This configuration was generated automatically
     * using the icepll tool from the IceStorm project.
     * Use at your own risk.
     *
     * Given input frequency:        12.000 MHz
     * Requested output frequency:  100.000 MHz
     * Achieved output frequency:   100.500 MHz
     */
    wire clk_ctrl; // Master controller clock signal
    wire locked;   // Locked control signal
    SB_PLL40_CORE #(
		            .FEEDBACK_PATH("SIMPLE"),
		            .DIVR(4'b0000),		    // DIVR =  0
		            .DIVF(7'b1000010),	    // DIVF = 66
		            .DIVQ(3'b011),		    // DIVQ =  3
		            .FILTER_RANGE(3'b001)	// FILTER_RANGE = 1
	               )
               uut (
		            .LOCK(locked),
		            .RESETB(1'b1),
		            .BYPASS(1'b0),
		            .REFERENCECLK(clk_int),
		            .PLLOUTCORE(clk_ctrl)
		           );
    /// End of Main clock generator from PLL


    /// Main controller register bank init
    /// End of Main controller register bank init
    

    /// Main memory init
    /// End of Main memory init


    /// UART module init
    /// End of UART module init


    /// SPI module init
    /// End of SPI module init


    /// ULPI module init
    /// End of ULPI module init

endmodule