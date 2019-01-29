/*
 *
 * Test bench for the btn_debouncer module
 * Execute "make gtk" to view the results
 * 
 */

`default_nettype none
`timescale 100ns/10ns

`define ASYNC_RESET

`include "./modules/clk_div.vh"

// `include "cells_sim.v"

module btn_debouncer_tb ();

    /// Regs and wires
    reg btn_in = 0;

    wire btn_out;
    wire clk_out;
    wire clk_pulse;
    /// End of Regs and wires

    /// Module under test init
    btn_debouncer btn_debouncer_mut (
                                     .clk(clk), // System signals
                                     .btn_in(btn_in), .btn_out(btn_out) // Button
                                    );
    /// End of Module under test init

    /// Clock gen
    reg clk = 1'b0;
    always #0.5 clk = ~clk;

        clk_div #(.DIVIDER(2)) 
    clk_div_mut  (
                  .clk_in(clk), .clk_out(clk_out), .clk_pulse(clk_pulse), // Clock signals
                  .enable(1'b1) // Control signals
                 );
    /// End of Clock gen

    /// Simulation
    initial begin
        $dumpfile("./sim/btn_debouncer_tb.vcd");
        $dumpvars();

        #4
        #0.1 btn_in = 1; #0.1 btn_in = 0;
        #0.4 btn_in = 1; #0.1 btn_in = 0;
        #0.6 btn_in = 1; #0.1 btn_in = 0;
        #0.2 btn_in = 1; #0.1 btn_in = 0;
        #0.1 btn_in = 1;

        #4
        #0.1 btn_in = 0; #0.1 btn_in = 1;
        #0.4 btn_in = 0; #0.1 btn_in = 1;
        #0.6 btn_in = 0; #0.1 btn_in = 1;
        #0.2 btn_in = 0; #0.1 btn_in = 1;
        #0.1 btn_in = 0;
  
        #4 $finish;
    end
    /// End of Simulation

endmodule