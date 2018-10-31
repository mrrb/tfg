/*
 *
 * Test bench for the ULPI module
 * Execute "make gtk" to view the results
 * 
 */

module ULPI_tb ();

    // Registers and wires
    reg clk_int = 1'b0;
    reg clk_ext = 1'b0;
    reg rst = 1'b0;
    reg WD = 1'b0;
    reg RD = 1'b0;
    reg TD = 1'b0;
    reg LP = 1'b0;
    reg [5:0]ADDR = 6'b0;
    reg [7:0]DATA_IN = 8'b0;
    reg DIR = 1'b0;
    reg NXT = 1'b0;
    reg [7:0]ULPI_DATA_r = 8'b0;

    wire [7:0]DATA_OUT;
    wire STP;
    wire [7:0]ULPI_DATA_w;
    wire busy;

    wire [7:0]ULPI_DATA;
    assign ULPI_DATA = (DIR == 1'b1) ? ULPI_DATA_r : ULPI_DATA_w;

    // Module under test Init
    ULPI UP_tb (
                .clk_ext(clk_ext), .clk_int(clk_int), .rst(rst), // System signals
                .WD(WD), .RD(RD), .TD(TD), .LP(LP), .ADDR(ADDR), // ULPI controller signals
                .REG_DATA_IN(DATA_IN), .REG_DATA_OUT(DATA_OUT), .BUSY(busy), // ULPI controller signals
                .DIR(DIR), .STP(STP), .NXT(NXT), .ULPI_DATA(ULPI_DATA) // ULPI pins
               );

    // CLK gen
    always #1 clk_ext <= ~clk_ext;

    // Simulation
    initial begin
        $dumpfile("sim/ULPI_tb.vcd");
        $dumpvars(0, ULPI_tb);

        // REG Write test
        #1 ADDR = 6'h1A; DATA_IN = 8'h3A;

        #1 WD = 1;
        #2 WD = 0;

        #2 NXT = 1;
        #4 NXT = 0;
        #1
        #2
        // REG Read test
        ULPI_DATA_r = 8'h3D;

        #1 RD = 1;
           ADDR = 6'h1B;
        #2 RD = 0;
           ADDR = 0;

        #2 NXT = 1;
        #2 NXT = 0;
           DIR = 1;

        #4 DIR = 0;
        
        #25 $finish;
    end


endmodule