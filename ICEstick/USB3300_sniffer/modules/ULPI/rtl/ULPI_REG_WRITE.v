/*
 *
 * ULPI_REG_WRITE module
 * This module let the FPGA write a register inside a ULPI capable phy device (usb3300 in this case)
 *
 * Parameters:
 *  - 
 *
 * Inputs:
 *  - 
 *
 * Outputs:
 *  - 
 *
 */

`default_nettype none

`ifdef ASYNC_RESET
    `define ULPI_RW_ASYNC_RESET or negedge rst
`else
    `define ULPI_RW_ASYNC_RESET
`endif

module ULPI_REG_WRITE (
                       // System signals
                       input  wire rst,          // Reset signal
                       input  wire clk_ice,      // 12MHz ICEstick reference clock
                       input  wire clk_ULPI,     // 60MHz ULPI clock

                       // Control signals
                       input  wire PrW,          // Perform register Write
                       output wire [1:0]status,  // Module status code

                       // Register values
                       input  wire [5:0]ADDR,    // PHY address where the value will be stored
                       input  wire [7:0]REG_VAL, // Value that is going to be stored in the PHY register

                       // ULPI signals
                       input  wire DIR,          // ULPI DIR (DIRection) signal
                       input  wire NXT,          // ULPI NXT (NeXT) signal
                       inout  wire [7:0]DATA_I,  // ULPI input DATA signals [PHY => LINK]
                       output wire [7:0]DATA_O,  // ULPI output DATA signals [LINK => PHY]
                       output wire STP,          // ULPI STP (SToP) signal
                       output wire U_RST         // ULPI RST (ReSeT) signal
                      );

    localparam CMD_HEADER = 2'b10; // Immediate Register Write Command
                                   // 76543210
                                   // 10xxxxxx [7:6] => CMD; [5:0] => Address

    ///
    ///

endmodule