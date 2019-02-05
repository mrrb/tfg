/*
 *
 * Test bench for the signal_trigger module
 * Execute "make gtk" to view the results
 * 
 */

`default_nettype none
`timescale 100ns/10ns

`define ASYNC_RESET

// `include "cells_sim.v"

module signal_trigger_tb ();

    /// Regs and wires
    wire output_signal;

    reg input_signal = 0;
    /// End of Regs and wires

    /// Module under test init
    signal_trigger signal_trigger_mut (.clk(clk), .input_signal(input_signal), .output_signal(output_signal));
    /// End of Module under test init

    /// Clock gen
    reg clk = 1'b0;
    always #0.5 clk = ~clk;
    /// End of Clock gen

    /// Simulation
    initial begin
        $dumpfile("./sim/signal_trigger_tb.vcd");
        $dumpvars();

        #1 input_signal = 1;
        #10 input_signal = 0;

        #1 input_signal = 1;
        #1 input_signal = 0;

        #1 input_signal = 1;
        #0.5 input_signal = 0;
        #0.5

        #1 input_signal = 1;
        #2 input_signal = 0;

        #5 $finish;
    end
    /// End of Simulation

endmodule