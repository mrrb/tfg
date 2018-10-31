/*
 *
 * Test bench for the ULPI_REG_READ module
 * Execute "make gtk_sub S_MOD=REG_READ" to view the results
 * 
 */

module ULPI_REG_READ_tb ();

    // Registers and wires
    reg clk = 1'b0;
    reg rst = 1'b0;
    reg RD  = 1'b0;
    reg NXT = 1'b0;
    reg DIR = 1'b0;
    reg [5:0]ADDR = 6'b0;
    reg [7:0]ULPI_DATA_r = 8'b0;

    wire [7:0]DATA;
    wire [7:0]ULPI_DATA_w;
    wire STP;
    wire busy;

    wire [7:0]ULPI_DATA;
    assign ULPI_DATA = (DIR == 1'b1) ? ULPI_DATA_r : ULPI_DATA_w;

    // Module under test init
    ULPI_REG_READ READ_tb (.clk(clk), .rst(rst), // System signals
                           .READ_DATA(RD), .ADDR(ADDR), .DATA(DATA), .BUSY(busy), // ULPI controller signals
                           .DIR(DIR), .STP(STP), .NXT(NXT), .ULPI_DATA_IN(ULPI_DATA_r), .ULPI_DATA_OUT(ULPI_DATA_w) // ULPI pins
                          );

    // CLK gen
    always #1 clk <= ~clk;

    // Simulation
    initial begin
        $dumpfile("sim/ULPI_REG_READ_tb.vcd");
        $dumpvars(0, ULPI_REG_READ_tb);

        ULPI_DATA_r = 8'h3D;

        #1;

        #1 RD = 1;
           ADDR = 6'h1B;
        #2 RD = 0;
           ADDR = 0;

        #2 NXT = 1;
        #2 NXT = 0;
           DIR = 1;

        #4 DIR = 0;
        
        #100 $finish;
    end

endmodule