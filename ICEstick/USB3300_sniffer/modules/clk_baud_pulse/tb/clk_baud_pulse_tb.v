/*
 *
 * Test bench for the clk_baud_pulse module
 * Execute "make gtk" to view the results
 * 
 */

`default_nettype none
`timescale 100ns/10ns

module clk_baud_pulse_tb ();

    /// Regs and wires
    wire clk_pulse1, clk_pulse2;

    reg  enable = 1'b0;
    /// End of Regs and wires

    /// Module under test init
    clk_baud_pulse #(.COUNTER_VAL(104), .PULSE_DELAY(0))
     clk_baud_mut1  (
                     .clk_in(clk),
                     .clk_pulse(clk_pulse1),
                     .enable(enable)
                    );
                    
    clk_baud_pulse #(.COUNTER_VAL(104), .PULSE_DELAY(104/2))
     clk_baud_mut2  (
                     .clk_in(clk),
                     .clk_pulse(clk_pulse2),
                     .enable(enable)
                    );
    /// End of Module under test init

    /// Clock gen
    reg clk = 1'b0;
    always #0.5 clk = ~clk;
    /// End of Clock gen

    /// Simulation
    initial begin
        $dumpfile("./sim/clk_baud_pulse_tb.vcd");
        $dumpvars();

        #2 enable = 1;

        #500 enable = 0;

        #20 enable = 1;

        #500 $finish;
    end
    /// End of Simulation

endmodule