/*
 *
 * Test bench for the ULPI_REG_READ module
 * Execute "make gtk M_NAME=ULPI_REG_READ" to view the results
 * 
 */

`default_nettype none
`timescale 100ns/10ns

`define ASYNC_RESET

module ULPI_REG_READ_tb ();

    /// Regs and wires
    wire [7:0]DATA;
    wire [7:0]DATA_O;
    wire [7:0]REG_VAL;
    wire busy;
    wire STP;
    wire U_RST;

    reg rst = 0;
    reg PrR = 0;
    reg [5:0]ADDR = 0;
    reg DIR = 0;
    reg NXT = 0;
    reg [7:0]DATA_I = 0;
    /// End of Regs and wires

    /// Module under test init
    assign DATA = (DIR) ? DATA_I : DATA_O;
    ULPI_REG_READ ULPI_REG_READ_mut (
                                      .rst(rst), .clk_ULPI(clk60), // System signals
                                      .PrR(PrR), .busy(busy), // Control signals
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
        $dumpfile("./sim/ULPI_REG_READ_tb.vcd");
        $dumpvars();

        #0.4 rst = 1;
        
        // Test 0 (AN 19.17)
        PrR = 1; ADDR = 6'h16;
        #0.2 PrR = 0;
        #0.1 NXT = 1;
        #0.2 NXT = 0; DIR = 1;
        #0.2 DATA_I = 8'hBA;
        #0.2 DIR = 0;

        #0.4
        
        // Test 1
        PrR = 1; ADDR = 6'h1F;
        #0.2 PrR = 0;
        #0.1 NXT = 1;
        #0.2 NXT = 0; DIR = 1;
        #0.2 DATA_I = 8'hAC;
        #0.2 DIR = 0;

        #0.4

        // Test 2
        PrR = 1; ADDR = 6'h1F;
        #0.2 PrR = 0;
        #0.1 NXT = 1;
        #0.2 NXT = 0; DIR = 1; rst = 0;
        #0.2 DATA_I = 8'hAC; rst = 1;
        #0.2 DIR = 0;

        #0.4

        // Test 3
        PrR = 1; ADDR = 6'h1B;
        #0.2 PrR = 0;
        #0.1 NXT = 1;
        #0.2 NXT = 0; DIR = 1;
        #0.2 DATA_I = 8'hAC;
        #0.2 DIR = 0;

        #1 $finish;
    end
    /// End of Simulation

endmodule