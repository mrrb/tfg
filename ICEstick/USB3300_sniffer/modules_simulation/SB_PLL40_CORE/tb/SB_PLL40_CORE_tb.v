`default_nettype none
`timescale 100ns/10ns

module SB_PLL40_CORE_tb ();

    /// Regs and wires
    reg RESETB = 0;
    reg BYPASS = 0;

    wire clk_pll;
    wire lock;
    /// End of Regs and wires

    /// Module under test init
    SB_PLL40_CORE PLL_mut (
                           .RESETB(RESETB),     // [Input]
                           .BYPASS(BYPASS),     // [Input]
                           .REFERENCECLK(clk),  // [Input]
                           .LOCK(lock),         // [Output]
                           .PLLOUTCORE(clk_pll) // [Output]
                          );
    /// End of Module under test init

    /// Clock gen
    reg clk = 1'b0;
    always #0.5 clk = ~clk;
    /// End of Clock gen

    /// Simulation
    initial begin
        $dumpfile("./sim/SB_PLL40_CORE_tb.vcd");
        $dumpvars();

        #1 RESETB = 1;
        
        #1000 $finish;
    end
    /// End of Simulation

endmodule