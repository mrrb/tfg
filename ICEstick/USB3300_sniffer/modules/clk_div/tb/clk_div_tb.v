/*
 *
 * Test bench for the clk_div module
 * Execute "make gtk" to view the results
 * 
 */

`default_nettype none
`timescale 100ns/10ns

module clk_div_tb ();

    /// Regs and wires
    wire clk_out1;
    wire clk_pulse1;

    wire clk_out2;
    wire clk_pulse2;

    wire clk_out3;
    wire clk_pulse3;

    reg enable = 1'b0;
    /// End of Regs and wires

    /// Module under test init
         clk_div #(.DIVIDER(0)) 
    clk_div_mut1  (
                   .clk_in(clk), .clk_out(clk_out1), .clk_pulse(clk_pulse1), // Clock signals
                   .enable(enable) // Control signals
                  );

         clk_div #(.DIVIDER(1)) 
    clk_div_mut2  (
                   .clk_in(clk), .clk_out(clk_out2), .clk_pulse(clk_pulse2), // Clock signals
                   .enable(enable) // Control signals
                  );

         clk_div #(.DIVIDER(5)) 
    clk_div_mut3  (
                   .clk_in(clk), .clk_out(clk_out3), .clk_pulse(clk_pulse3), // Clock signals
                   .enable(enable) // Control signals
                  );
    /// End of Module under test init

    /// Clock gen
    reg clk = 1'b0;
    always #0.5 clk = ~clk;
    /// End of Clock gen

    /// Simulation
    initial begin
        $dumpfile("./sim/clk_div_tb.vcd");
        $dumpvars();

        enable = 1;

        #100 enable = 0;
        #50  enable = 1;

        #100 $finish;
    end
    /// End of Simulation

endmodule