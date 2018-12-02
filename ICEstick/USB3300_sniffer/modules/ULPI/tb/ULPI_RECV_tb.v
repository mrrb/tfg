/*
 *
 * Test bench for the ULPI_RECV module
 * Execute "make gtk M_NAME=ULPI_RECV" to view the results
 * 
 */

`default_nettype none
`timescale 100ns/10ns

`define ASYNC_RESET

`include "cells_sim.v"

module ULPI_RECV_tb ();

    /// Regs and wires
    wire [7:0]DATA;
    wire [7:0]DATA_O;
    wire busy;
    wire STP;
    wire U_RST;
    wire NrD;

    wire [7:0]USB_DATA;
    wire [15:0]USB_INFO_DATA;
    wire DATA_buff_full;
    wire DATA_buff_empty;
    wire INFO_buff_full;
    wire INFO_buff_empty;

    wire [7:0]RxCMD;
    wire [1:0]RxLineState;
    wire [1:0]RxVbusState;
    wire RxActive;
    wire RxError;
    wire RxHostDisconnect;
    wire RxID;


    reg rst = 0;
    reg DIR = 0;
    reg NXT = 0;
    reg [7:0]DATA_I = 0;
    reg ReadAllow = 0;
    reg DATA_re = 0;
    reg INFO_re = 0;
    /// End of Regs and wires

    /// Module under test init
    assign DATA = (DIR) ? DATA_I : DATA_O;
    ULPI_RECV ULPI_RECV_mut (
                             .rst(rst), .clk_ULPI(clk60), // System signals
                             
                             .ReadAllow(ReadAllow), .busy(busy), // Control signals

                             .RxCMD(RxCMD), .RxLineState(RxLineState), .RxVbusState(RxVbusState), // Rx states
                             .RxActive(RxActive), .RxError(RxError), // Rx states
                             .RxHostDisconnect(RxHostDisconnect), .RxID(RxID), // Rx states

                             .DATA_re(DATA_re), .INFO_re(INFO_re),
                             .USB_DATA(USB_DATA), .USB_INFO_DATA(USB_INFO_DATA), // Buffer control
                             .DATA_buff_full(DATA_buff_full), .DATA_buff_empty(DATA_buff_empty), // Buffer control
                             .INFO_buff_full(INFO_buff_full), .INFO_buff_empty(INFO_buff_empty), // Buffer control

                             .DIR(DIR), .NXT(NXT), .DATA_I(DATA_I), // ULPI signals                 
                             .DATA_O(DATA_O), .STP(STP) // ULPI signals
                            );
    /// End of Module under test init

    /// Clock gen
    reg clk12 = 1'b0;
    always #0.5 clk12 = ~clk12;
    reg clk60 = 1'b0;
    always #0.1 clk60 = ~clk60;
    /// End of Clock gen

    /// Simulation
    reg [15:0]sim_INFO = 0; 
    reg  [7:0]sim_DATA = 0;
    integer i = 0;
    initial begin
        $dumpfile("./sim/ULPI_RECV_tb.vcd");
        $dumpvars();

        #0.5 rst = 1;

        // Test 1
        ReadAllow = 1;
        #0.2 DATA_I = 8'b11111111; DIR = 1; NXT = 1;
        #0.2 DATA_I = 8'b10110111; NXT = 0; ReadAllow = 0;
        #0.2 DATA_I = 8'hA4; NXT = 1;
        #0.2 DATA_I = 8'h3F;
        #0.2 DATA_I = 8'h03;
        #0.2 DATA_I = 8'b10010110; NXT = 0;
        #0.2 DATA_I = 8'hAB; NXT = 1;
        #0.2 NXT = 0; DIR = 0;

        #1.1

        #0.2 INFO_re = 1;
        #0.2 INFO_re = 0; sim_INFO = USB_INFO_DATA;
             DATA_re = 1; $display("USB_INFO_DATA = %b; RxCMD = %b; LEN = %b", sim_INFO, sim_INFO[15:10], sim_INFO[9:0]);
        for(i=0; i<sim_INFO[9:0]; i=i+1) begin
            #0.2 sim_DATA <= USB_DATA;
        end
        DATA_re = 0;

        #1.1

        // Test 2
        ReadAllow = 1;
        #0.2 DATA_I = 8'b11111111; DIR = 1; NXT = 1;
        #0.2 DATA_I = 8'b10110111; NXT = 0; ReadAllow = 0;
        #0.2 DATA_I = 8'hA4; NXT = 1;
        #0.2 DATA_I = 8'h3F;
        #0.2 DATA_I = 8'h03; #0.2 DATA_I = 8'h7E;
        #0.2 DATA_I = 8'hA3; #0.2 DATA_I = 8'h22;
        #0.2 DATA_I = 8'h5A; #0.2 DATA_I = 8'h90;
        #0.2 DATA_I = 8'hAE; #0.2 DATA_I = 8'hF5;
        #0.2 DATA_I = 8'h01; #0.2 DATA_I = 8'hA9;
        #0.2 DATA_I = 8'h02; #0.2 DATA_I = 8'hAD;
        #0.2 DATA_I = 8'b10010110; NXT = 0;
        #0.2 DATA_I = 8'hAB; NXT = 1;
        #0.2 NXT = 0; DIR = 0;

        #1.1

        #0.2 INFO_re = 1;
        #0.2 INFO_re = 0; sim_INFO = USB_INFO_DATA;
             DATA_re = 1; $display("USB_INFO_DATA = %b; RxCMD = %b; LEN = %b", sim_INFO, sim_INFO[15:10], sim_INFO[9:0]);
        for(i=0; i<sim_INFO[9:0]; i=i+1) begin
            #0.2 sim_DATA <= USB_DATA;
        end
        DATA_re = 0;

        #1 $finish;
    end
    /// End of Simulation

endmodule