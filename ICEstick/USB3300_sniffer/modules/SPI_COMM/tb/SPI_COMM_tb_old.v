/*
 *
 * Test bench for the SPI_COMM module
 * Execute "make gtk" to view the results
 * 
 */

module SPI_COMM_tb ();

    // Registers and wires
    reg clk_fast = 1'b0;    
    reg clk_slow = 1'b0;
    reg SS_r = 1'b1;
    reg MOSI_r = 1'b0;
    reg [7:0]DATA_in_r = 8'b0;
    reg [7:0]STA_r = 8'b0;
    reg err_in_r = 1'b0;

    wire [7:0]DATA_out_w;
    wire [7:0]RAW_w;
    wire [7:0]CMD_w;
    wire [15:0]ADDR_w;
    wire MISO_w;
    wire EoB_w;
    wire busy;
    wire err_w;


    // Module under test Init
    SPI_COMM spi (
                  .clk(clk_fast), .rst(1'b0), // System signals
                  .SCLK(clk_slow), .SS(SS_r), .MOSI(MOSI_r), .MISO(MISO_w), // SPI interface signals
                  .STA(STA_r), .DATA_in(DATA_in_r), .CMD(CMD_w), .ADDR(ADDR_w), .DATA_out(DATA_out_w), .RAW_out(RAW_w), // Data signals
                  .err_in(err_in_r), .err_out(err_w), .EoB(EoB_w), .busy(busy) // Control signals
                 );

    // CLK gen
    always #3  clk_fast <= ~clk_fast;
    always #10 clk_slow <= ~clk_slow;

    // Simulation
    initial begin
        $dumpfile("sim/SPI_COMM_tb.vcd");
        $dumpvars(0, SPI_COMM_tb);

        #5

        $display("Test 1 - Mode 1");

        SS_r = 0;
        STA_r = 8'hAA;

        // First byte [10110000]
            #0  MOSI_r = 0; // Mode
            #20 MOSI_r = 0; // Mode
            #20 MOSI_r = 0; // CONT
            #20 MOSI_r = 0; // WRITE
            #20 MOSI_r = 1;
            #20 MOSI_r = 1;
            #20 MOSI_r = 0;
            #20 MOSI_r = 1; 
        // End of First byte

        #20 SS_r = 1;
        STA_r = 8'b0;
        #60      

        $display("Test 2 - Mode 2 READ");

        SS_r = 0;
        STA_r = 8'hAA;

        // First byte [10110001]
            #0  MOSI_r = 1; // Mode
            #20 MOSI_r = 0; // Mode
            #20 MOSI_r = 0; // CONT
            #20 MOSI_r = 0; // WRITE
            #20 MOSI_r = 1;
            #20 MOSI_r = 1;
            #20 MOSI_r = 0;
            #20 MOSI_r = 1; 
        // End of First byte

        // Second byte [10100101]
            #20 MOSI_r = 1;
            #20 MOSI_r = 0;
            #20 MOSI_r = 1;
            #20 MOSI_r = 0;
            #20 MOSI_r = 0;
            #20 MOSI_r = 1;
            #20 MOSI_r = 0;
            #20 MOSI_r = 1; 
        // End of Second byte

        #20 SS_r = 1;
        STA_r = 8'b0;
        DATA_in_r = 8'b0;
        #60        

        $display("Test 3 - Mode 2 WRITE");

        SS_r = 0;
        STA_r = 8'hAA;
        DATA_in_r = 8'hA5;

        // First byte [10111001]
            #0  MOSI_r = 1; // Mode
            #20 MOSI_r = 0; // Mode
            #20 MOSI_r = 0; // CONT
            #20 MOSI_r = 1; // WRITE
            #20 MOSI_r = 1;
            #20 MOSI_r = 1;
            #20 MOSI_r = 0;
            #20 MOSI_r = 1; 
        // End of First byte

        // Second byte [10100101]
            #20 MOSI_r = 1;
            #20 MOSI_r = 0;
            #20 MOSI_r = 1;
            #20 MOSI_r = 0;
            #20 MOSI_r = 0;
            #20 MOSI_r = 1;
            #20 MOSI_r = 0;
            #20 MOSI_r = 1; 
        // End of Second byte

        #20 SS_r = 1;
        STA_r = 8'b0;
        DATA_in_r = 8'b0;
        #60

        $display("Test 4 - Mode 3 READ");

        SS_r = 0;
        STA_r = 8'hAA;
        DATA_in_r = 8'hA5;

        // First byte [10110010]
            #0  MOSI_r = 0; // Mode
            #20 MOSI_r = 1; // Mode
            #20 MOSI_r = 0; // CONT
            #20 MOSI_r = 0; // WRITE
            #20 MOSI_r = 1;
            #20 MOSI_r = 1;
            #20 MOSI_r = 0;
            #20 MOSI_r = 1; 
        // End of First byte

        // Second byte [10100101]
            #20 MOSI_r = 1;
            #20 MOSI_r = 0;
            #20 MOSI_r = 1;
            #20 MOSI_r = 0;
            #20 MOSI_r = 0;
            #20 MOSI_r = 1;
            #20 MOSI_r = 0;
            #20 MOSI_r = 1; 
        // End of Second byte

        // Third byte [01011010]
            #20 MOSI_r = 0;
            #20 MOSI_r = 1;
            #20 MOSI_r = 0;
            #20 MOSI_r = 1;
            #20 MOSI_r = 1;
            #20 MOSI_r = 0;
            #20 MOSI_r = 1;
            #20 MOSI_r = 0; 
        // End of Third byte

        #20 SS_r = 1;
        STA_r = 8'b0;
        DATA_in_r = 8'b0;
        #60

        $display("Test 5 - Mode 3 WRITE");

        SS_r = 0;
        STA_r = 8'hAA;
        DATA_in_r = 8'hA5;

        // First byte [10110010]
            #0  MOSI_r = 0; // Mode
            #20 MOSI_r = 1; // Mode
            #20 MOSI_r = 0; // CONT
            #20 MOSI_r = 1; // WRITE
            #20 MOSI_r = 1;
            #20 MOSI_r = 1;
            #20 MOSI_r = 0;
            #20 MOSI_r = 1; 
        // End of First byte

        // Second byte [10100101]
            #20 MOSI_r = 1;
            #20 MOSI_r = 0;
            #20 MOSI_r = 1;
            #20 MOSI_r = 0;
            #20 MOSI_r = 0;
            #20 MOSI_r = 1;
            #20 MOSI_r = 0;
            #20 MOSI_r = 1; 
        // End of Second byte

        // Third byte [01011010]
            #20 MOSI_r = 0;
            #20 MOSI_r = 1;
            #20 MOSI_r = 0;
            #20 MOSI_r = 1;
            #20 MOSI_r = 1;
            #20 MOSI_r = 0;
            #20 MOSI_r = 1;
            #20 MOSI_r = 0; 
        // End of Third byte

        #20 SS_r = 1;
        STA_r = 8'b0;
        DATA_in_r = 8'b0;
        #60

        $display("Test 6 - Mode 4 READ");

        SS_r = 0;
        STA_r = 8'hAA;
        DATA_in_r = 8'hA5;

        // First byte [10110011]
            #0  MOSI_r = 1; // Mode
            #20 MOSI_r = 1; // Mode
            #20 MOSI_r = 0; // CONT
            #20 MOSI_r = 0; // WRITE
            #20 MOSI_r = 1;
            #20 MOSI_r = 1;
            #20 MOSI_r = 0;
            #20 MOSI_r = 1; 
        // End of First byte

        // Second byte [10100101]
            #20 MOSI_r = 1;
            #20 MOSI_r = 0;
            #20 MOSI_r = 1;
            #20 MOSI_r = 0;
            #20 MOSI_r = 0;
            #20 MOSI_r = 1;
            #20 MOSI_r = 0;
            #20 MOSI_r = 1; 
        // End of Second byte

        // Third byte [01011010]
            #20 MOSI_r = 0;
            #20 MOSI_r = 1;
            #20 MOSI_r = 0;
            #20 MOSI_r = 1;
            #20 MOSI_r = 1;
            #20 MOSI_r = 0;
            #20 MOSI_r = 1;
            #20 MOSI_r = 0; 
        // End of Third byte

        // Fourth byte [10100101]
            #20 MOSI_r = 1;
            #20 MOSI_r = 0;
            #20 MOSI_r = 1;
            #20 MOSI_r = 0;
            #20 MOSI_r = 0;
            #20 MOSI_r = 1;
            #20 MOSI_r = 0;
            #20 MOSI_r = 1;
        // End of Fourth byte

        #20 SS_r = 1;
        STA_r = 8'b0;
        DATA_in_r = 8'b0;
        #60

        $display("Test 7 - Mode 4 WRITE");

        SS_r = 0;
        STA_r = 8'hAA;
        DATA_in_r = 8'hA5;

        // First byte [10110011]
            #0  MOSI_r = 1; // Mode
            #20 MOSI_r = 1; // Mode
            #20 MOSI_r = 0; // CONT
            #20 MOSI_r = 1; // WRITE
            #20 MOSI_r = 1;
            #20 MOSI_r = 1;
            #20 MOSI_r = 0;
            #20 MOSI_r = 1; 
        // End of First byte

        // Second byte [10100101]
            #20 MOSI_r = 1;
            #20 MOSI_r = 0;
            #20 MOSI_r = 1;
            #20 MOSI_r = 0;
            #20 MOSI_r = 0;
            #20 MOSI_r = 1;
            #20 MOSI_r = 0;
            #20 MOSI_r = 1; 
        // End of Second byte

        // Third byte [01011010]
            #20 MOSI_r = 0;
            #20 MOSI_r = 1;
            #20 MOSI_r = 0;
            #20 MOSI_r = 1;
            #20 MOSI_r = 1;
            #20 MOSI_r = 0;
            #20 MOSI_r = 1;
            #20 MOSI_r = 0; 
        // End of Third byte

        // Fourth byte [10100101]
            #20 MOSI_r = 1;
            #20 MOSI_r = 0;
            #20 MOSI_r = 1;
            #20 MOSI_r = 0;
            #20 MOSI_r = 0;
            #20 MOSI_r = 1;
            #20 MOSI_r = 0;
            #20 MOSI_r = 1;
        // End of Fourth byte

        #20 SS_r = 1;
        STA_r = 8'b0;
        DATA_in_r = 8'b0;
        #60

        #100 $finish;
    end


endmodule
