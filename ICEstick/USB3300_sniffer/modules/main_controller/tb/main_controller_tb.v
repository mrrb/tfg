/*
 *
 * Test bench for the main_controller module
 * Execute "make gtk" to view the results
 * 
 */

`default_nettype none
`timescale 100ns/10ns

`define ASYNC_RESET

// `include "cells_sim.v"

module main_controller_tb ();

    /// Regs and wires
    wire op_stack_pull;

    wire ULPI_DATA_re;
    wire ULPI_INFO_re;

    wire [7:0]ULPI_REG_VAL_W;
    wire [5:0]ULPI_ADDR;
    wire ULPI_PrW;
    wire ULPI_PrR;

    wire [7:0]UART_Tx_DATA;
    wire UART_send;


    reg rst = 0;
    reg force_send = 0;

    reg [15:0]op_stack_msg = 0;
    reg op_stack_empty = 1;

    reg [7:0]ULPI_USB_DATA = 0;
    reg [15:0]ULPI_USB_INFO_DATA = 0;
    reg ULPI_DATA_buff_empty = 1;
    reg ULPI_INFO_buff_empty = 1;

    reg ULPI_busy = 0;
    reg [7:0]ULPI_REG_VAL_R = 0;

    reg UART_Tx_FULL = 0;


    reg [32:0]test_num = 0;
    /// End of Regs and wires

    /// Module under test init
    main_controller main_controller_mut (                        
                                         .rst(rst), .clk(clk), .force_send(force_send), // System signals
                                        
                                         .op_stack_msg(op_stack_msg), .op_stack_empty(op_stack_empty), .op_stack_pull(op_stack_pull), // Op stack

                                         .ULPI_USB_DATA(ULPI_USB_DATA), .ULPI_USB_INFO_DATA(ULPI_USB_INFO_DATA), // DATA ULPI signals
                                         .ULPI_DATA_buff_empty(ULPI_DATA_buff_empty), .ULPI_INFO_buff_empty(ULPI_INFO_buff_empty), // DATA ULPI signals
                                         .ULPI_DATA_re(ULPI_DATA_re), .ULPI_INFO_re(ULPI_INFO_re), // DATA ULPI signals

                                         .ULPI_busy(ULPI_busy), // General ULPI signals
                                        
                                         .ULPI_REG_VAL_R(ULPI_REG_VAL_R), .ULPI_REG_VAL_W(ULPI_REG_VAL_W), // Register ULPI signals
                                         .ULPI_ADDR(ULPI_ADDR), .ULPI_PrW(ULPI_PrW), .ULPI_PrR(ULPI_PrR), // Register ULPI signals

                                         .UART_Tx_FULL(UART_Tx_FULL), .UART_Tx_DATA(UART_Tx_DATA), .UART_send(UART_send) // UART
                                        );
    /// End of Module under test init

    /// Clock gen
    reg clk = 1'b0;
    always #0.5 clk = ~clk;
    /// End of Clock gen

    /// Simulation
    initial begin
        $dumpfile("./sim/main_controller_tb.vcd");
        $dumpvars();

        #1 rst = 1;

        // Test 1. Register Read.
        test_num = 1;
        op_stack_msg = 16'b11100001_10010110;
        op_stack_empty = 0;
        #1.5 op_stack_empty = 1;
        #1 ULPI_REG_VAL_R = 8'b11001010;
        #1.5

        // Test 2. Register Write.
        test_num = 2;
        op_stack_msg = 16'b10100010_10010110;
        op_stack_empty = 0;
        #1.5 op_stack_empty = 1;
        #2.5

        // Test 3. UART send last register.
        test_num = 3;
        op_stack_msg = 16'b01100011_10010110;
        op_stack_empty = 0;
        #1.5 op_stack_empty = 1;
        #2.5
        
        // Test 4. Register Read with ULPI_busy.
        test_num = 4;
        ULPI_busy = 1;
        op_stack_msg = 16'b11100001_10010110;
        op_stack_empty = 0;
        #1.5 op_stack_empty = 1;
        #4 ULPI_busy = 0;
        ULPI_REG_VAL_R = 8'b11001110;
        #1.5
        
        // Test 5. UART send last register with UART_Tx_FULL.
        test_num = 5;
        UART_Tx_FULL = 1;
        op_stack_msg = 16'b01100011_10010110;
        op_stack_empty = 0;
        #1.5 op_stack_empty = 1;
        #4 UART_Tx_FULL = 0;
        #2.5

        // Test 6. UART forced send last register.
        test_num = 6;
        force_send = 1;
        ULPI_REG_VAL_R = 8'b01101000;
        #1.5 force_send = 0;
        #3.5

        // Test 7. RECV send test.
        test_num = 7;
        ULPI_USB_DATA = 8'hAC; ULPI_DATA_buff_empty = 0;
        ULPI_USB_INFO_DATA = 16'b11000100_00000001; ULPI_INFO_buff_empty = 0;
        op_stack_msg = 16'b00100001_10010110;
        op_stack_empty = 0;
        #1.5 op_stack_empty = 1; ULPI_INFO_buff_empty = 1;
        #4 ULPI_DATA_buff_empty = 1; ULPI_USB_DATA = 8'h00;
        #2.5

        // Test 8. RECV (more than 1byte) send test.
        test_num = 8;
        ULPI_USB_DATA = 8'hAC; ULPI_DATA_buff_empty = 0;
        ULPI_USB_INFO_DATA = 16'b11000100_00000011; ULPI_INFO_buff_empty = 0;
        op_stack_msg = 16'b00100001_10010110;
        op_stack_empty = 0;
        #1.5 op_stack_empty = 1; ULPI_INFO_buff_empty = 1;
        #4 ULPI_USB_DATA = 8'hBC;
        #1 ULPI_USB_DATA = 8'hCC;
        #1 ULPI_DATA_buff_empty = 1; ULPI_USB_DATA = 8'h00;
        #2.5

        // Test 9. RECV send empty.!!
        test_num = 9;
        ULPI_USB_INFO_DATA = 16'b11000100_00000000; ULPI_INFO_buff_empty = 0;
        op_stack_msg = 16'b00100001_10010110;
        op_stack_empty = 0;
        #1.5 op_stack_empty = 1; ULPI_INFO_buff_empty = 1;
        #4.5

        // Test 10. RECV send test with TxFull in MAIN_RECV_SEND1.
        test_num = 10;
        UART_Tx_FULL = 1;
        ULPI_USB_DATA = 8'hAC; ULPI_DATA_buff_empty = 0;
        ULPI_USB_INFO_DATA = 16'b11000100_00000001; ULPI_INFO_buff_empty = 0;
        op_stack_msg = 16'b00100001_10010110;
        op_stack_empty = 0;
        #1.5 op_stack_empty = 1; ULPI_INFO_buff_empty = 1;
        #2 UART_Tx_FULL = 0;
        #4 ULPI_DATA_buff_empty = 1; ULPI_USB_DATA = 8'h00;
        #2.5

        // Test 11. RECV send test with TxFull in MAIN_RECV_SEND2.
        test_num = 11;
        ULPI_USB_DATA = 8'hAC; ULPI_DATA_buff_empty = 0;
        ULPI_USB_INFO_DATA = 16'b11000100_00000001; ULPI_INFO_buff_empty = 0;
        op_stack_msg = 16'b00100001_10010110;
        op_stack_empty = 0;
        #1.5 op_stack_empty = 1; ULPI_INFO_buff_empty = 1;
        #3 UART_Tx_FULL = 1;
        #3 UART_Tx_FULL = 0;
        #1 ULPI_DATA_buff_empty = 1; ULPI_USB_DATA = 8'h00;
        #2.5

        // Test 12. RECV send (more than 1byte) test with TxFull in MAIN_RECV_SEND2.!!
        test_num = 12;
        ULPI_USB_DATA = 8'hAC; ULPI_DATA_buff_empty = 0;
        ULPI_USB_INFO_DATA = 16'b11000100_00000011; ULPI_INFO_buff_empty = 0;
        op_stack_msg = 16'b00100001_10010110;
        op_stack_empty = 0;
        #1.5 op_stack_empty = 1; ULPI_INFO_buff_empty = 1;
        #3 UART_Tx_FULL = 1;
        #3 UART_Tx_FULL = 0;
        #1 ULPI_USB_DATA = 8'hBC;
        #1 ULPI_USB_DATA = 8'hCC;
        #1 ULPI_DATA_buff_empty = 1; ULPI_USB_DATA = 8'h00;
        #2.5

        // Test 13. RECV send test with TxFull in MAIN_RECV_WAIT.
        test_num = 13;
        ULPI_USB_DATA = 8'hAC; ULPI_DATA_buff_empty = 0;
        ULPI_USB_INFO_DATA = 16'b11000100_00000001; ULPI_INFO_buff_empty = 0;
        op_stack_msg = 16'b00100001_10010110;
        op_stack_empty = 0;
        #1.5 op_stack_empty = 1; ULPI_INFO_buff_empty = 1;
        #2.5 UART_Tx_FULL = 1;
        #1.5 UART_Tx_FULL = 0;
        #2 ULPI_DATA_buff_empty = 1; ULPI_USB_DATA = 8'h00;
        #2.5

        // Test 14. RECV send test with reset.
        test_num = 14;
        ULPI_USB_DATA = 8'hAC; ULPI_DATA_buff_empty = 0;
        ULPI_USB_INFO_DATA = 16'b11000100_00000001; ULPI_INFO_buff_empty = 0;
        op_stack_msg = 16'b00100001_10010110;
        op_stack_empty = 0;
        #1 rst = 0;
        op_stack_empty = 1; ULPI_INFO_buff_empty = 1;
        ULPI_DATA_buff_empty = 1; ULPI_USB_DATA = 8'h00;
        #1 rst = 1;
        #2.5

        $finish;
    end
    /// End of Simulation

endmodule