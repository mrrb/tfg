/*
 *
 * Test bench for the UART_Rx module
 * Execute "make gtk M_NAME=UART_Rx" to view the results
 * 
 */

`default_nettype none
`timescale 100ns/10ns

`define ASYNC_RESET

`include "./modules_simulation/SB_RAM40_4K.vh"

module UART_Rx_tb ();

    /// Regs and wires
    wire clk_Rx;
    wire [7:0]DATA_out;
    wire NrD;
    wire Rx_FULL;
    wire Rx_EMPTY;

    reg Rx  = 1'b1;
    reg rst = 1'b1;
    /// End of Regs and wires

    /// Module under test init
    UART_Rx     #(.BAUDS(104))
    UART_Rx_mut  (
                  .rst(rst),
                  .clk(clk),
                  .clk_Rx(clk_Rx),
                  .Rx(Rx),
                  .O_DATA(DATA_out),
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
        rst = 0;
        #104 Rx = 1; // Bit 3
        #104 Rx = 1; // Bit 4
        #104 Rx = 1; // Bit 5
        rst = 1;
        #104 Rx = 1; // Bit 6
        #104 Rx = 1; // Bit 7
        #104 Rx = 1; // STOP
        #104

        #1 $finish;
    end
    /// End of Simulation

endmodule