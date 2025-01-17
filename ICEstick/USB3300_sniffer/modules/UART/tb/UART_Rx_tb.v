/*
 *
 * Test bench for the UART_Rx module
 * Execute "make gtk M_NAME=UART_Rx" to view the results
 * 
 */

`default_nettype none
`timescale 100ns/10ns

`define ASYNC_RESET

// `include "SB_RAM40_4K.vh"
`include "cells_sim.v"

module UART_Rx_tb ();

    /// Regs and wires
    wire clk_Rx;
    wire [7:0]DATA_out;
    wire NrD;
    wire Rx_FULL;
    wire Rx_EMPTY;

    reg Rx  = 1'b1;
    reg rst = 1'b1;
    reg NxT = 1'b0;
    /// End of Regs and wires

    /// Module under test init
    UART_Rx     #(.BAUDS(104))
    UART_Rx_mut  (
                  .rst(rst),
                  .clk(clk),
                  .clk_Rx(clk_Rx),
                  .Rx(Rx),
                  .O_DATA(DATA_out),
                  .NxT(NxT),
                  .NrD(NrD),
                  .Rx_FULL(Rx_FULL),
                  .Rx_EMPTY(Rx_EMPTY)
                 );
    /// End of Module under test init

    /// Clock gen
    reg clk = 1'b0;
    always #0.5 clk = ~clk;
    /// End of Clock gen

    /// Simulation
    integer i = 0;
    initial begin
        $dumpfile("./sim/UART_Rx_tb.vcd");
        $dumpvars();

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

        #104 Rx = 0; // START
        #104 Rx = 1; // Bit 0
        #104 Rx = 1; // Bit 1
        #104 Rx = 1; // Bit 2
        #104 Rx = 1; // Bit 3
        #104 Rx = 0; // Bit 4
        #104 Rx = 1; // Bit 5
        #104 Rx = 0; // Bit 6
        #104 Rx = 1; // Bit 7
        #104 Rx = 1; // STOP
        #104

        #1  NxT = 1;
        #11 NxT = 0;

        #104 Rx = 0; // START
        #104 Rx = 1; // Bit 0
        #104 Rx = 1; // Bit 1
        #104 Rx = 1; // Bit 2
        rst = 0;
        #104 Rx = 1; // Bit 3
        #104 Rx = 1; // Bit 4
        #104 Rx = 1; // Bit 5
        rst = 1;
        #104 Rx = 1; // Bit 6
        #104 Rx = 1; // Bit 7
        #104 Rx = 1; // STOP
        #104

        // Full FIFO size Test
        // for(i=0; i<512; i=i+1) begin
        //     #104 Rx = 0; // START
        //     #104 Rx = i[0]; // Bit 0
        //     #104 Rx = i[1]; // Bit 1
        //     #104 Rx = i[2]; // Bit 2
        //     #104 Rx = i[3]; // Bit 3
        //     #104 Rx = i[4]; // Bit 4
        //     #104 Rx = i[5]; // Bit 5
        //     #104 Rx = i[6]; // Bit 6
        //     #104 Rx = i[7]; // Bit 7
        //     #104 Rx = 1; // STOP
        //     #104;
        // end

        // #2   NxT = 1;
        // #512 NxT = 0;

        #10 $finish;
    end
    /// End of Simulation

endmodule