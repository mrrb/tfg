/*
 *
 * Test bench for the FIFO_MERGE module
 * Execute "make gtk" to view the results
 * 
 */

`default_nettype none
`timescale 100ns/10ns

`define ASYNC_RESET
`include "cells_sim.v"

module FIFO_MERGE_tb();

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

    localparam FF_cnt = 5;
    /// End of Regs and wires

    /// Module under test init
    FIFO_MERGE     #(.FIFO_COUNT(FF_cnt), .ALMOST_FULL(0.9), .ALMOST_EMPTY(0.1)) 
    FIFO_MERGE_mut  (
                     .rst(rst),
                     .clk(clk12),
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
    reg clk12 = 1'b0;
    always #0.5 clk12 = ~clk12;
    reg clk60 = 1'b0;
    always #0.1 clk60 = ~clk60;
    /// End of Clock gen

    /// Simulation
    integer i;
    integer j;
    initial begin
        $dumpfile("./sim/FIFO_MERGE_tb.vcd");
        $dumpvars();

        #1 rst = 1;

        #20

        // FIFO Push test
        #4 DATA_in = 0;
        j = 0;
        for(i=0; i<(512*FF_cnt); i=i+1) begin
            // #1 DATA_in = i; wr_dv = 1;
            #1 DATA_in = j; wr_dv = 1;
            if((i%512 == 0) && i!=0) j=j+1;
        end
        #1 wr_dv = 0;

        #20

        // FIFO Pull test
        for(i=0; i<(512*FF_cnt); i=i+1) begin
            #1 rd_en = 1;
        end
        #1 rd_en = 0;

        #20

        // FIFO Push&Pull test [1]
        #4 DATA_in = 0; wr_dv = 1;
        for(i=1; i<(512*FF_cnt-1); i=i+1) begin
            #1 DATA_in = i; wr_dv = 1; rd_en = 1;
        end
        #2 wr_dv = 0;
        #2 rd_en = 0;

        #20 $finish;
    end
    /// End of Simulation

endmodule