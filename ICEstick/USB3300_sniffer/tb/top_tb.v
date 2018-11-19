/*
 *
 * Test bench for the main project
 * Execute "make gtk" to view the results
 * 
 */

`default_nettype none
`timescale 100ns/10ns

`include "SB_PLL40_CORE/rtl/SB_PLL40_CORE.v"
`include "SB_RAM40_4K/rtl/SB_RAM40_4K.v"

module top_tb ();

    /// Regs and wires
    wire [7:0]DATA;
    wire STP;
    wire RST;
    wire Tx;
    wire [7:0]IO_bank0;
    wire [1:0]IO_bank2;
    wire [4:0]IO_LEDs;

    reg Rx = 0;
    reg DIR = 0;
    reg NXT = 0;
    reg [7:0]DATA_r = 0;

    assign DATA = DIR ? DATA_r : 8'bz;
    /// End of Regs and wires

    /// Module under test init
    USB3300_sniffer USB3300_sniffer (
                                     // System signals
                                     .clk_ice(clk1),  // [input]
                                     .clk_ULPI(clk2), // [input]

                                     // ULPI signals
                                     .ULPI_DIR(DIR),   // [input]
                                     .ULPI_NXT(NXT),   // [input]
                                     .ULPI_DATA(DATA), // [inout]
                                     .ULPI_STP(STP),   // [output]
                                     .ULPI_RST(RST),   // [output]

                                     // UART signals
                                     .UART_Rx(Rx),
                                     .UART_Tx(Tx),

                                     // I/O
                                     .IO_bank0(IO_bank0),
                                     .IO_bank2(IO_bank2),
                                     .IO_LEDs(IO_LEDs)
    );
    /// End of Module under test init

    /// Clock gen
    reg clk1 = 1'b0;
    always #0.5 clk1 = ~clk1;

    reg clk2 = 1'b0;
    always #0.1 clk2 = ~clk2;
    /// End of Clock gen

    /// Simulation
    initial begin
        $dumpfile("./sim/top_tb.vcd");
        $dumpvars();

        #1000 $finish;
    end
    /// End of Simulation

endmodule