/*
 *
 * Test bench for the main project
 * Execute "make gtk" to view the results
 * 
 */

`default_nettype none
`timescale 100ns/10ns

// `include "SB_PLL40_CORE/rtl/SB_PLL40_CORE.v"
// `include "SB_RAM40_4K/rtl/SB_RAM40_4K.v"
`include "cells_sim.v"


module top_tb ();

    /// Regs and wires
    wire [7:0]DATA;
    wire STP;
    wire RST;
    wire Tx;
    wire [4:0]IO_LEDs;
    wire [2:0]IO_test;

    reg Rx = 1;
    reg DIR = 0;
    reg NXT = 0;
    reg [7:0]DATA_r = 0;

    reg [1:0]IO_BTNs = 2'b11;

    reg [31:0]test_counter = 0;

    assign DATA = DIR ? DATA_r : 8'bz;
    /// End of Regs and wires

    /// Module under test init
        USB3300_sniffer #(
                          .DIV_TIMERS(3),
                          .DIV_DEBOUNCE(0),
                          .COUNTER_BAUDRATE(2)
                         )
    USB3300_sniffer_mut  (
                          // System signals
                          .clk_ice(clk1),    // [input]
                          .clk_ULPI(clk2),   // [input]

                          // ULPI signals
                          .ULPI_DIR(DIR),    // [input]
                          .ULPI_NXT(NXT),    // [input]
                          .ULPI_DATA(DATA),  // [inout]
                          .ULPI_STP(STP),    // [output]
                          .ULPI_RST(RST),    // [output]

                          // UART signals
                          .UART_Rx(Rx),      // [input]
                          .UART_Tx(Tx),      // [output]

                          // I/O
                          .IO_BTNs(IO_BTNs), // [input]
                          .IO_LEDs(IO_LEDs), // [output]
                          .IO_test(IO_test)  // [output]
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
        #3

        // Test 1. Reset test.
        test_counter = 1;
        IO_BTNs[0] = 0;
        #3 IO_BTNs[0] = 1;
        #3

        // Test 2. 2nd btn test.
        test_counter = 2;
        IO_BTNs[1] = 0;
        #3 IO_BTNs[1] = 1;
        #10

        // Test 3. Register Read.
        test_counter = 3;
        // Byte 1
        #0.4 Rx = 0; /* START */ #0.4 Rx = 1; /* Bit 0 */ #0.4 Rx = 1; /* Bit 1 */ #0.4 Rx = 0; /* Bit 2 */ #0.4 Rx = 0; /* Bit 3 */
        #0.4 Rx = 0; /* Bit 4 */ #0.4 Rx = 1; /* Bit 5 */ #0.4 Rx = 1; /* Bit 6 */ #0.4 Rx = 1; /* Bit 7 */ #0.4 Rx = 1; /* STOP */
        #1
        // Byte 2
        #0.4 Rx = 0; /* START */ #0.4 Rx = 1; /* Bit 0 */ #0.4 Rx = 0; /* Bit 1 */ #0.4 Rx = 0; /* Bit 2 */ #0.4 Rx = 1; /* Bit 3 */
        #0.4 Rx = 0; /* Bit 4 */ #0.4 Rx = 0; /* Bit 5 */ #0.4 Rx = 1; /* Bit 6 */ #0.4 Rx = 1; /* Bit 7 */ #0.4 Rx = 1; /* STOP */
        #2
        #0.2 NXT = 1;
        #0.2 NXT = 0; DIR = 1;
        #0.2 DATA_r = 8'h34;
        #0.2 DIR = 0; DATA_r = 8'h00;
        #1

        // Test 4. Register Send.
        test_counter = 4;
        // Byte 1
        #0.4 Rx = 0; /* START */ #0.4 Rx = 0; /* Bit 0 */ #0.4 Rx = 0; /* Bit 1 */ #0.4 Rx = 0; /* Bit 2 */ #0.4 Rx = 0; /* Bit 3 */
        #0.4 Rx = 0; /* Bit 4 */ #0.4 Rx = 0; /* Bit 5 */ #0.4 Rx = 1; /* Bit 6 */ #0.4 Rx = 0; /* Bit 7 */ #0.4 Rx = 1; /* STOP */
        #1
        // Byte 2
        #0.4 Rx = 0; /* START */ #0.4 Rx = 1; /* Bit 0 */ #0.4 Rx = 0; /* Bit 1 */ #0.4 Rx = 0; /* Bit 2 */ #0.4 Rx = 1; /* Bit 3 */
        #0.4 Rx = 0; /* Bit 4 */ #0.4 Rx = 0; /* Bit 5 */ #0.4 Rx = 1; /* Bit 6 */ #0.4 Rx = 1; /* Bit 7 */ #0.4 Rx = 1; /* STOP */
        #8

        // Test 5. Register Write.
        test_counter = 5;
        // Byte 1
        #0.4 Rx = 0; /* START */ #0.4 Rx = 0; /* Bit 0 */ #0.4 Rx = 0; /* Bit 1 */ #0.4 Rx = 0; /* Bit 2 */ #0.4 Rx = 0; /* Bit 3 */
        #0.4 Rx = 0; /* Bit 4 */ #0.4 Rx = 0; /* Bit 5 */ #0.4 Rx = 0; /* Bit 6 */ #0.4 Rx = 1; /* Bit 7 */ #0.4 Rx = 1; /* STOP */
        #1
        // Byte 2
        #0.4 Rx = 0; /* START */ #0.4 Rx = 1; /* Bit 0 */ #0.4 Rx = 0; /* Bit 1 */ #0.4 Rx = 0; /* Bit 2 */ #0.4 Rx = 1; /* Bit 3 */
        #0.4 Rx = 0; /* Bit 4 */ #0.4 Rx = 1; /* Bit 5 */ #0.4 Rx = 1; /* Bit 6 */ #0.4 Rx = 1; /* Bit 7 */ #0.4 Rx = 1; /* STOP */
        #2.4 NXT = 1;
        #0.4 NXT = 0;
        #2

        // Test 6. Receive 4 ULPI bytes.
        test_counter = 6;
        #0.2 DATA_r = 8'b11111111; DIR = 1; NXT = 1;
        #0.2 DATA_r = 8'b10110111; NXT = 0;
        #0.2 DATA_r = 8'hA4; NXT = 1;
        #0.2 DATA_r = 8'h3F;
        #0.2 DATA_r = 8'h03;
        #0.2 DATA_r = 8'b10010110; NXT = 0;
        #0.2 DATA_r = 8'hAB; NXT = 1;
        #0.2 NXT = 0; DIR = 0;
        #2

        // Test 7. Send 4 Bytes of ULPI data.
        test_counter = 7;
        #0.4 Rx = 0; /* START */ #0.4 Rx = 0; /* Bit 0 */ #0.4 Rx = 0; /* Bit 1 */ #0.4 Rx = 0; /* Bit 2 */ #0.4 Rx = 0; /* Bit 3 */
        #0.4 Rx = 0; /* Bit 4 */ #0.4 Rx = 0; /* Bit 5 */ #0.4 Rx = 0; /* Bit 6 */ #0.4 Rx = 0; /* Bit 7 */ #0.4 Rx = 1; /* STOP */
        #1
        // Byte 2
        #0.4 Rx = 0; /* START */ #0.4 Rx = 0; /* Bit 0 */ #0.4 Rx = 0; /* Bit 1 */ #0.4 Rx = 0; /* Bit 2 */ #0.4 Rx = 0; /* Bit 3 */
        #0.4 Rx = 0; /* Bit 4 */ #0.4 Rx = 0; /* Bit 5 */ #0.4 Rx = 0; /* Bit 6 */ #0.4 Rx = 0; /* Bit 7 */ #0.4 Rx = 1; /* STOP */
        #40

        $finish;
    end
    /// End of Simulation

endmodule