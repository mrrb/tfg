/*
 *
 * Test bench for the ULPI module
 * Execute "make gtk" to view the results
 * 
 */

`default_nettype none
`timescale 100ns/10ns

`define ASYNC_RESET

module ULPI_tb ();

    /// Regs and wires
    reg rst = 0;
    reg PrW = 0;
    reg PrR = 0;
    reg [5:0]ADDR = 0;
    reg [7:0]REG_VAL_W = 0;
    reg DIR = 0;
    reg NXT = 0;
    reg [7:0]DATA_I = 0;

    wire NrD;
    wire [2:0]status;
    wire [7:0]REG_VAL_R;
    wire STP;
    wire U_RST;
    wire [7:0]DATA_O;
    wire [7:0]DATA;
    /// End of Regs and wires

    /// Module under test init
    assign DATA = (DIR) ? DATA_I : DATA_O;
    ULPI ULPI_mut (
                   .rst(rst), .clk_ice(clk12), .clk_ULPI(clk60),
                   .PrW(PrW), .PrR(PrR), .NrD(NrD), .status(status),
                   .ADDR(ADDR), .REG_VAL_W(REG_VAL_W), .REG_VAL_R(REG_VAL_R),
                   .DIR(DIR), .NXT(NXT), .DATA(DATA),
                   .STP(STP), .U_RST(U_RST)
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
        $dumpfile("./sim/ULPI_tb.vcd");
        $dumpvars();

        #0.4 rst = 1;
        
        ADDR = 6'h16;
        REG_VAL_W = 8'hAF;

        // Test 1 - Write (AN 19.17)
        #0.2 PrW = 1;
        #0.2 PrW = 0;
        #0.1 NXT = 1;
        #0.4 NXT = 0;

        #0.5

        // Test 2 - Read (AN 19.17)
        PrR = 1; ADDR = 6'h16;
        #0.2 PrR = 0;
        #0.1 NXT = 1;
        #0.2 NXT = 0; DIR = 1;
        #0.2 DATA_I = 8'hBA;
        #0.2 DIR = 0;

        #1 $finish;
    end
    /// End of Simulation

endmodule