/*
 *
 * Test bench for the FIFO_BRAM_SYNC module
 * Execute "make gtk" to view the results
 * 
 */

`default_nettype none
`timescale 100ns/10ns

`include "SB_RAM40_4K.vh"

module FIFO_BRAM_SYNC_tb ();

    /// Regs and wires
    wire wr_full;
    wire wr_almost_full;
    wire [7:0]DATA_out;
    wire rd_empty;
    wire rd_almost_empty;

    reg rst = 1'b0;
    reg wr_dv = 1'b0;
    reg [7:0]DATA_in = 8'b0;
    reg rd_en = 1'b0;
    /// End of Regs and wires

    /// Module under test init
    FIFO_BRAM_SYNC     #(.ALMOST_FULL_VAL(8), .ALMOST_EMPTY_VAL(2))
    FIFO_BRAM_SYNC_mut  (
                         .rst(rst),
                         .clk_wr(clk),
                         .wr_dv(wr_dv),
                         .wr_DATA(DATA_in),
                         .wr_full(wr_full),
                         .wr_almost_full(wr_almost_full),
                         .clk_rd(clk),
                         .rd_en(rd_en),
                         .rd_DATA(DATA_out),
                         .rd_empty(rd_empty),
                         .rd_almost_empty(rd_almost_empty)
                        );
    /// End of Module under test init

    /// Clock gen
    reg clk = 1'b0;
    always #0.5 clk = ~clk;
    /// End of Clock gen

    /// Simulation
    initial begin
        $dumpfile("./sim/FIFO_BRAM_SYNC_tb.vcd");
        $dumpvars();

        rst = 1;

        #2 DATA_in = 8'h18; wr_dv = 1;
        #1 DATA_in = 8'h29;
        #1 DATA_in = 8'h3A;
        #1 DATA_in = 8'h4B;
        #1 DATA_in = 8'h5C;
        #1 DATA_in = 8'h6D;
        #1 DATA_in = 8'h7E;
        #1 DATA_in = 8'hBF;
        #1 wr_dv = 0;

        #2 rd_en = 1;
        #8 rd_en = 0;

        #1.5 DATA_in = 8'h58; wr_dv = 1;
        #0.5 wr_dv = 0;
        #0.5 rd_en = 1;

        #1 $finish;
    end
    /// End of Simulation

endmodule