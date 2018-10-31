/*
 *
 * SPI_COMM module
 * This module controls the SPI communication with a SPI Master. It handles the OSI level 2 (frame).
 * 
 * 
 */

`default_nettype none

 module SPI_COMM(
                 // System signals
                 input  wire clk, // Master clock signal
                 input  wire rst, // Reset signal

                 // SPI interface signals
                 input  wire SCLK, // SPI Clock signal
                 input  wire SS,   // Slave Select
                 input  wire MOSI, // Master-Out Slave-In
                 output wire MISO, // Master-IN  Slave-Out

                 // Data signals
                 input  wire  [7:0]STA,      // Status code to send to the Master
                 input  wire  [7:0]DATA_in,  // Data to send to the Master
                 output wire  [7:0]CMD,      // Command received from the Master
                 output wire [15:0]ADDR,     // Address where the DATA must be read/write
                 output wire  [7:0]DATA_out, // Data received from the Master
                 output wire  [7:0]RAW_out,  // Raw data from the Master

                 // Control signals
                 input  wire err_in,  // Error in the SPI transaction (catched by the SPI main controller)
                 output wire err_out, // Error in the last SPI transaction (catched by SPI_COMM)
                 output wire EoB,     // End of Byte control signal
                 output wire busy     // When there is a transfer in progress this signal will be High
                );

endmodule