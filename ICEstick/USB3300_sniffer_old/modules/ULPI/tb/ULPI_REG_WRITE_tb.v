/*
 *
 * Test bench for the ULPI_REG_WRITE module
 * Execute "make gtk_sub S_MOD=REG_WRITE" to view the results
 * 
 */

module ULPI_REG_WRITE_tb ();

    // Registers and wires
    reg clk = 1'b0;
    reg rst = 1'b0;
    reg WD  = 1'b0;
    reg NXT = 1'b0;
    reg [7:0]DATA = 8'b0;
    reg [5:0]ADDR = 6'b0;

    wire [7:0]ULPI_DATA;
    wire STP;
    wire busy;
    wire DIR;

    // Module under test init
    ULPI_REG_WRITE WRITE_tb (.clk(clk), .rst(rst), // System signals
                             .WRITE_DATA(WD), .ADDR(ADDR), .DATA(DATA), .BUSY(busy), // ULPI controller signals
                             .DIR(DIR), .STP(STP), .NXT(NXT), .ULPI_DATA_IN(8'b0), .ULPI_DATA_OUT(ULPI_DATA) // ULPI pins
                            );

    // CLK gen
    always #1 clk <= ~clk;

    // Simulation
    initial begin
        $dumpfile("sim/ULPI_REG_WRITE_tb.vcd");
        $dumpvars(0, ULPI_REG_WRITE_tb);

        #1 ADDR = 6'h1A; DATA = 8'h3A;

        #1 WD = 1;
        #2 WD = 0;

        #2 NXT = 1;
        #4 NXT = 0;
        
        #100 $finish;
    end

endmodule
        