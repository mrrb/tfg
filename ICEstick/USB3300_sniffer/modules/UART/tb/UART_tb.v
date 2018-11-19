/*
 *
 * Test bench for the UART module
 * Execute "make gtk" to view the results
 * 
 */

`default_nettype none
`timescale 100ns/10ns

`define ASYNC_RESET

// `include "SB_RAM40_4K.vh"
`include "cells_sim.v"

module UART_tb ();

    /// Regs and wires
    wire clk_Tx;
    wire Tx;
    wire TiP;
    wire NrD;
    wire send_data;
    wire [7:0]DATA_out;
    wire [7:0]DATA_in;
    wire Tx_FULL, Rx_FULL, Rx_EMPTY;

    reg ctrl = 1'b0;
    reg rst = 1'b1;
    reg Rx  = 1'b0;
    reg [7:0]DATA_in_r = 8'b0;
    reg send_data_r = 1'b0;

    assign send_data = (ctrl) ? NrD : send_data_r;
    assign DATA_in   = (ctrl) ? DATA_out : DATA_in_r;
    /// End of Regs and wires

    /// Module under test init
    UART     #(.BAUDS(104))
    UART_mut  (
               .rst(rst),
               .clk(clk),
               .Rx(Rx),
               .Tx(Tx),
               .I_DATA(DATA_in),
               .O_DATA(DATA_out),
               .send_data(send_data),
               .TiP(TiP),
               .NrD(NrD),
               .Tx_FULL(Tx_FULL),
               .Rx_FULL(Rx_FULL),
               .Rx_EMPTY(Rx_EMPTY)
              );
    /// End of Module under test init

    /// Clock gen
    reg clk = 1'b0;
    always #0.5 clk = ~clk;
    /// End of Clock gen

    /// Simulation
    initial begin
        $dumpfile("./sim/UART_tb.vcd");
        $dumpvars();
        Rx  = 1'b1;

        #1 send_data_r = 1;
        #1 send_data_r = 0;
        #104 Rx = 0; // START
        #104 Rx = 1; // Bit 0
        #104 Rx = 1; // Bit 1
        #104 Rx = 1; // Bit 2
        #104 Rx = 1; // Bit 3
        #104 Rx = 1; // Bit 4
        #104 Rx = 1; // Bit 5
        #104 Rx = 1; // Bit 6
        #104 Rx = 1; // Bit 7
        #104 Rx = 1; // STOP
        #104

        #1 send_data_r = 1; DATA_in_r = 8'hAA;
        #1 send_data_r = 0;
        #104 Rx = 0; // START
        #104 Rx = 1; // Bit 0
        #104 Rx = 0; // Bit 1
        #104 Rx = 0; // Bit 2
        #104 Rx = 1; // Bit 3
        #104 Rx = 0; // Bit 4
        #104 Rx = 1; // Bit 5
        #104 Rx = 1; // Bit 6
        #104 Rx = 0; // Bit 7
        #104 Rx = 1; // STOP
        #104

        #1 send_data_r = 1; DATA_in_r = 8'hAA;
        #1 send_data_r = 0;
        #104 Rx = 0; // START
        #104 Rx = 1; // Bit 0
        #104 Rx = 0; // Bit 1
        #104 Rx = 0; // Bit 2
        #104 Rx = 1; // Bit 3
        rst = 0;
        #104 Rx = 0; // Bit 4
        #104 Rx = 1; // Bit 5
        #104 Rx = 1; // Bit 6
        #104 Rx = 0; // Bit 7
        #104 Rx = 1; // STOP
        #104
        rst = 1;

        #1 ctrl = 1;

        #104 Rx = 0; // START
        #104 Rx = 1; // Bit 0
        #104 Rx = 0; // Bit 1
        #104 Rx = 0; // Bit 2
        #104 Rx = 1; // Bit 3
        #104 Rx = 0; // Bit 4
        #104 Rx = 1; // Bit 5
        #104 Rx = 1; // Bit 6
        #104 Rx = 0; // Bit 7
        #104 Rx = 1; // STOP
        #104
        #1100

        #1 ctrl = 0; DATA_in_r = 8'h69;

        #1 send_data_r = 1;
        #1 send_data_r = 0;
        #1100

        #200

        #1 $finish;
    end
    /// End of Simulation

endmodule