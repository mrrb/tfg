/*
 *
 * Test bench for the ULPI_op_stack module
 * Execute "make gtk" to view the results
 * 
 */

`default_nettype none
`timescale 100ns/10ns

`define ASYNC_RESET

// `include "cells_sim.v"

module ULPI_op_stack_tb ();

    /// Regs and wires
    reg rst = 0;
    reg UART_Rx_EMPTY = 0;
    reg [7:0]UART_DATA = 0;
    reg op_stack_pull = 0;

    wire UART_NxT;
    wire [15:0]op_stack_msg;
    wire op_stack_full;
    wire op_stack_empty;
    /// End of Regs and wires

    /// Module under test init
    ULPI_op_stack ULPI_op_stack_mut (
                                     .rst(rst), .clk(clk), // System signals
                                     .UART_DATA(UART_DATA), .UART_Rx_EMPTY(UART_Rx_EMPTY), .UART_NxT(UART_NxT), // UART Rx Buffer signals
                                     .op_stack_pull(op_stack_pull), .op_stack_msg(op_stack_msg), // Stack control signals
                                     .op_stack_full(op_stack_full), .op_stack_empty(op_stack_empty) // Stack control signals
                                    );
    /// End of Module under test init

    /// Clock gen
    reg clk = 1'b0;
    always #0.5 clk = ~clk;
    /// End of Clock gen

    /// Simulation
    initial begin
        $dumpfile("./sim/ULPI_op_stack_tb.vcd");
        $dumpvars();

        UART_Rx_EMPTY = 1;
        #1 rst = 1;

        // First UART save
        #1 UART_Rx_EMPTY <= 0; UART_DATA = 8'h1A;
        #1.5 UART_Rx_EMPTY <= 1;
        
        #1.5 UART_Rx_EMPTY <= 0; UART_DATA = 8'h1B;
        #1.5 UART_Rx_EMPTY <= 1;
        #1

        // Second UART save
        #1 UART_Rx_EMPTY <= 0; UART_DATA = 8'h2A;
        #1.5 UART_Rx_EMPTY <= 1;
        
        #1.5 UART_Rx_EMPTY <= 0; UART_DATA = 8'h2B;
        #1.5 UART_Rx_EMPTY <= 1;
        #1

        // First pull
        #1 op_stack_pull = 1;
        #1 op_stack_pull = 0;

        // Second pull
        #1 op_stack_pull = 1;
        #1 op_stack_pull = 0;

        #1 $finish;
    end
    /// End of Simulation

endmodule