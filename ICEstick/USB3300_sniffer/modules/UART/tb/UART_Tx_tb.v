/*
 *
 * Test bench for the UART_Tx module
 * Execute "make gtk M_NAME=UART_Tx" to view the results
 * 
 */

`default_nettype none
`timescale 100ns/10ns

`define ASYNC_RESET

`include "./modules_simulation/SB_RAM40_4K.vh"

module UART_Tx_tb ();

    /// Regs and wires
    wire clk_Tx;
    wire Tx;
    wire TiP;
    wire FULL;

    reg rst = 1'b1;
    reg [7:0]DATA_in = 8'b0;
    reg send_data = 1'b0;
    /// End of Regs and wires

    /// Module under test init
    UART_Tx     #(.BAUDS(104))
    UART_Tx_mut  (
                  .rst(rst),
                  .clk(clk),
                  .clk_Tx(clk_Tx),
                  .Tx(Tx),
                  .I_DATA(DATA_in),
                  .send_data(send_data),
                  .TiP(TiP),
                  .Tx_FULL(FULL)
                 );
    /// End of Module under test init

    /// Clock gen
    reg clk = 1'b0;
    always #0.5 clk = ~clk;
    /// End of Clock gen

    /// Simulation
    initial begin
        $dumpfile("./sim/UART_Tx_tb.vcd");
        $dumpvars();

        #1 send_data = 1;
        #1 send_data = 0;
        #1100

        #1 send_data = 1; DATA_in = 8'hAA;
        #1 send_data = 0;
        #1100

        #1 send_data = 1; DATA_in = 8'hF3;
        #1 DATA_in = 8'h0D;
        #1 send_data = 0;
        #2200

        #1 send_data = 1; DATA_in = 8'hAA;
        #1 send_data = 0;
        #550
        rst = 0;
        #550
        rst = 1;

        #1 $finish;
    end
    /// End of Simulation

endmodule