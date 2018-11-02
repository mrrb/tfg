/*
 *
 * Test bench for the FIFO_BRAM module
 * Execute "make gtk" to view the results
 * 
 */

`default_nettype none
`timescale 100ns/10ns

module FIFO_REG_tb ();

    /// Regs and wires
    wire wr_full;
    wire wr_almost_full;
    wire [3:0]DATA_out;
    wire rd_empty;
    wire rd_almost_empty;

    reg rst = 1'b0;
    reg wr_dv = 1'b0;
    reg [3:0]DATA_in = 4'b0;
    reg rd_en = 1'b0;
    /// End of Regs and wires

    /// Module under test init
    FIFO_REG     #(.DATA_WIDTH(4), .DATA_DEPTH(8), .ALMOST_FULL_VAL(6), .ALMOST_EMPTY_VAL(2))
    FIFO_REG_mut  (
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
    initial begin
        $dumpfile("./sim/FIFO_REG_tb.vcd");
        $dumpvars();

        rst = 1;

        #2 DATA_in = 4'h8; wr_dv = 1;
        #1 DATA_in = 4'h9;
        #1 DATA_in = 4'hA;
        #1 DATA_in = 4'hB;
        #1 DATA_in = 4'hC;
        #1 DATA_in = 4'hD;
        #1 DATA_in = 4'hE;
        #1 DATA_in = 4'hF;
        #1 wr_dv = 0;

        #2 rd_en = 1;
        #8 rd_en = 0;

        #1.5 DATA_in = 4'h8; wr_dv = 1;
        #0.5 wr_dv = 0;
        #0.5 rd_en = 1;


        #1 $finish;
    end
    /// End of Simulation

endmodule