/*
 *
 * Test bench for the ULPI_REG_WRITE module
 * Execute "make gtk M_NAME=ULPI_REG_WRITE" to view the results
 * 
 */

`default_nettype none
`timescale 100ns/10ns

`define ASYNC_RESET

module ULPI_REG_WRITE_tb ();

    /// Regs and wires
    wire [7:0]DATA;
    wire [7:0]DATA_O;
    wire busy;
    wire STP;
    wire U_RST;

    reg rst = 0;
    reg PrW = 0;
    reg [5:0]ADDR = 0;
    reg [7:0]REG_VAL = 0;
    reg DIR = 0;
    reg NXT = 0;
    reg [7:0]DATA_I = 0;
    /// End of Regs and wires

    /// Module under test init
    assign DATA = (DIR) ? DATA_I : DATA_O;
    ULPI_REG_WRITE ULPI_REG_WRITE_mut (
                                       .rst(rst), .clk_ULPI(clk60), // System signals
                                       .PrW(PrW), .busy(busy), // Control signals
                                       .ADDR(ADDR), .REG_VAL(REG_VAL), // Register values
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
    initial begin
        $dumpfile("./sim/ULPI_REG_WRITE_tb.vcd");
        $dumpvars();

        #0.4 rst = 1;

        ADDR = 6'h2F;
        REG_VAL = 8'hB9;

        // Test 1
        #0.2 PrW = 1;
        #0.2 PrW = 0;
        #0.2 NXT = 1;
        #0.2 NXT = 1;
        #0.2 NXT = 0;

        // Test 2
        #0.2 PrW = 1;
        #0.2 PrW = 0;
        #0.2 NXT = 1;
        rst = 0;
        #0.1 rst = 1;
        #0.1 NXT = 1;
        #0.2 NXT = 0;

        ADDR = 6'h2C;
        REG_VAL = 8'hA1;

        // Test 3
        #0.2 PrW = 1;
        #0.2 PrW = 0;
        #0.2 NXT = 1;
        #0.2 NXT = 1;
        #0.2 NXT = 0;
        
        #1 $finish;
    end
    /// End of Simulation

endmodule