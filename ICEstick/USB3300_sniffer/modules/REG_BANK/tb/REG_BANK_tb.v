/*
 *
 * Test bench for the REG_BANK module
 * Execute "make gtk" to view the results
 * 
 */

module REG_BANK_tb();

    // Reg and wires
    reg clk = 1'b0;
    reg WD  = 1'b0;
    reg [15:0]ADDR   = 0;
    reg [7:0]DATA_in = 0;

    wire [7:0]DATA_out;

    // Module under test init
    REG_BANK bank (clk, WD, ADDR, DATA_in, DATA_out);

    // Clock
    always #1 clk = ~clk;

    initial begin
        $dumpfile("sim/REG_BANK_tb.vcd");
        $dumpvars(0, REG_BANK_tb);

        #0 DATA_in = 16'h9D; WD = 1;
        #2 WD = 0; ADDR = 1; DATA_in = DATA_in - 5; WD = 1;
        #2 WD = 0;

        #2 ADDR = 0;

        #5 $finish;
    end

endmodule