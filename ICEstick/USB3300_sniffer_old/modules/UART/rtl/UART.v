/*
 *
 * UART module
 * This module let the FPGA communicate with other devices via Serial interface.
 *
 * 
 */

`default_nettype none
`include "./modules/clk_div_gen.vh"    // Clock divider module
`include "./modules/UART_Tx.vh"    // Clock divider module
// `include "./modules/UART_Rx.vh"    // Clock divider module

 module UART #(
               parameter BAUD_DIVIDER = 7
              )
              (
               // System signals
               input  wire rst,         // Reset signal
               input  wire clk,         // Reference clock input pin
               output wire clk_baud,    // Baudrate clock output
 
               // UART signals
               input  wire Rx,          // Rx input pin
               output wire Tx,          // Tx output pin
 
               // Data signals
               input  wire [7:0]I_DATA, // 8-bits data to send
               output wire [7:0]O_DATA, // 8-bits received data
 
               // Control signals
               input  wire send_data,   // Send the current data in DATA IF there isn't any trasmission in progress
               output wire TiP,         // Trasmission in Progress flag
               output wire NrD          // New received Data flag
              );

    /// Clk Baud Gen
    wire clk_pulse_w;
    clk_div_gen #(.DIVIDER(BAUD_DIVIDER))
       baud_clk  (.clk(clk), .enable(1'b1), .new_clk(clk_baud), .clk_pulse(clk_pulse_w));
    /// End of Clk Baud Gen

    /// Transmitter sub-module
        UART_Tx U_Tx (
                      .rst(rst), .clk(clk),                         // System signals
                      .clk_baud(clk_baud), .clk_pulse(clk_pulse_w), // System signals
                      .Tx(Tx),                                      // UART signals
                      .I_DATA(I_DATA),                              // Data signals
                      .send_data(send_data), .TiP(TiP)              // Control signals
                     );
    /// End of Transmitter sub-module
    
    /// Receiver sub-module
    //    UART_Rx U_Rx (
    //                   .rst(rst), .clk(clk),                         // System signals
    //                   .clk_baud(clk_baud), .clk_pulse(clk_pulse_w), // System signals
    //                   .Rx(Rx),                                      // UART signals
    //                   .O_DATA(O_DATA),                              // Data signals
    //                   .NrD(NrD)                                     // Control signals
    //                  );
    /// End of Receiver sub-module

endmodule