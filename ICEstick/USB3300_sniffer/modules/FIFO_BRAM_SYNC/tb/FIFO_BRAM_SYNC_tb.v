/*
 *
 * Test bench for the FIFO_BRAM_SYNC module
 * Execute "make gtk" to view the results
 * 
 */

`default_nettype none
`timescale 100ns/10ns

`define ASYNC_RESET

// `include "SB_RAM40_4K.vh"
`include "cells_sim.v"

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
    FIFO_BRAM_SYNC     #(.FWFT_MODE(1))
    FIFO_BRAM_SYNC_mut  (
                         .rst(rst),
                         .clk(clk),
                         .wr_dv(wr_dv),
                         .wr_DATA(DATA_in),
                         .wr_full(wr_full),
                         .wr_almost_full(wr_almost_full),
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
    integer i = 0;
    initial begin
        $dumpfile("./sim/FIFO_BRAM_SYNC_tb.vcd");
        $dumpvars();

        rst = 1;

        #2
        for(i=0; i<512; i=i+1) begin
            #1 DATA_in = i; wr_dv = 1;
        end
        #1 wr_dv = 0;

        #2 rd_en = 1;
        #512 rd_en = 0;

        #4 DATA_in = 0; wr_dv = 1;
        for(i=1; i<25; i=i+1) begin
            #1 DATA_in = i; wr_dv = 1; rd_en = 1;
        end
        #2 wr_dv = 0; rd_en = 0;

        #2
        for(i=0; i<25; i=i+1) begin
            #1 DATA_in = i; wr_dv = 1;
        end
        #1 wr_dv = 0;

        #2 rd_en = 1;
        #1 rst = 0;
        #1 rst = 1;
        #35 rd_en = 0;

        #1 $finish;
    end
    /// End of Simulation

endmodule