/*
 *
 * UART module
 * This module let the FPGA communicate with other devices via Serial interface (Config: 8N1).
 *
 *
 */

`default_nettype none

`include "./rtl/bauds.vh" // File that contains definitions of common baudrates with theirs optimal counter values

`include "./modules/UART_Tx.vh"
`include "./modules/UART_Rx.vh"

module UART #(
              parameter BAUDS = `B115200
             )
             (
              // System signals
              input  wire rst,         // Reset signal
              input  wire clk,         // Reference clock input

              // UART signals
              input  wire Rx,          // Serial Data input
              output wire Tx,          // Serial Data output
              output wire clk_Rx,
              output wire clk_Tx,

              // Data signals
              input  wire [7:0]I_DATA, // 8-bits data to send
              output wire [7:0]O_DATA, // 8-bits received data

              // Control signals
              input  wire send_data,   // Send the current data in DATA IF there isn't any trasmission in progress
              output wire TiP,         // Trasmission in Progress flag
              output wire NrD          // New received Data flag
             );

    // /// Transmission submodule init
    // UART_Tx #(.BAUDS(BAUDS))
    // UART_Tx  (
    //           // System signals
    //           .rst(rst),             // [Input]
    //           .clk(clk),             // [Input]
    //           .clk_Tx(clk_Tx),       // [Output]

    //           // Data signals
    //           .I_DATA(I_DATA),       // [Input]

    //           // UART signals
    //           .Tx(Tx),               // [Output]

    //           // Control signals
    //           .send_data(send_data), // [Input]
    //           .TiP(TiP)              // [Output]
    //          );
    // /// End of Transmission submodule init


    // /// Reception submodule init
    // UART_Rx #(.BAUDS(BAUDS))
    // UART_Rx  (
    //           // System signals
    //           .rst(rst),             // [Input]
    //           .clk(clk),             // [Input]
    //           .clk_Rx(clk_Rx),       // [Output]

    //           // Data signals
    //           .O_DATA(O_DATA),       // [Output]

    //           // UART signals
    //           .Rx(Rx),               // [Input]

    //           // Control signals
    //           .NrD(NrD)              // [Output]
    //          );
    // /// End of Reception submodule init


endmodule