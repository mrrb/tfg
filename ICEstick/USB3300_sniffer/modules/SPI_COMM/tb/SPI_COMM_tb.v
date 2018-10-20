/*
 *
 * Test bench for the SPI_COMM module
 * Execute "make gtk" to view the results
 * 
 */

`default_nettype none

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

    // Simulation control
    reg [2:0]Read_pos_r = 3'b0;
    reg [7:0]MISO_raw_r = 8'b0;
    always @(posedge SCLK) begin
        MISO_raw_r[Read_pos_r] <= MISO_w;
        Read_pos_r <= Read_pos_r + 1'b1;
    end

    // Module under test Init
    SPI_COMM spi (
                  .clk(clk_fast), .rst(1'b1), // System signals
                  .SCLK(SCLK), .SS(SS_r), .MOSI(MOSI_r), .MISO(MISO_w), // SPI interface signals
                  .STA(STA_r), .DATA_in(DATA_in_r), .CMD(CMD_w), .ADDR(ADDR_w), .DATA_out(DATA_out_w), .RAW_out(RAW_w), // Data signals
                  .err_in(err_in_r), .err_out(err_w), .EoB(EoB_w), .busy(busy) // Control signals
                 );

    // CLK gen
    wire SCLK;
    always #3  clk_fast <= ~clk_fast;
    always #10 clk_slow <= ~clk_slow;
    assign SCLK = SS_r ? 1'b0 : clk_slow;

    // Simulation
    initial begin
        $dumpfile("sim/SPI_COMM_tb.vcd");
        $dumpvars(0, SPI_COMM_tb);

        $display("Test 1 - Mode 1");

        STA_r <= 8'b10100101;
        DATA_in_r <= 8'hF1;
        #5 SS_r <= 0;

        // First byte [10110000]
            #0  MOSI_r <= 0; // Mode
            #20 MOSI_r <= 0; // Mode
            #20 MOSI_r <= 0; // CONT
            #20 MOSI_r <= 0; // WRITE
            #20 MOSI_r <= 1;
            #20 MOSI_r <= 1;
            #20 MOSI_r <= 0;
            #20 MOSI_r <= 1; 
        // End of First byte

        #20 SS_r <= 1;
        #60 $display(" Byte 1");
            $display("  MOSI [%b => %b]. Result: %s", 8'b10110000, RAW_w, (RAW_w == 8'b10110000) ? "Pass!" : "Fail!");
            $display("  MISO [%b => %b]. Result: %s", STA_r, MISO_raw_r, (MISO_raw_r == STA_r) ? "Pass!" : "Fail!");
            $display(" [%b %b %b]", CMD_w, ADDR_w, DATA_out_w);
            STA_r <= 8'b0;

        $display();

        $display("Test 2 - Mode 2 READ");

        SS_r <= 0;
        STA_r <= 8'hAA;

        // First byte [10110001]
            #0  MOSI_r <= 1; // Mode
            #20 MOSI_r <= 0; // Mode
            #20 MOSI_r <= 0; // CONT
            #20 MOSI_r <= 0; // WRITE
            #20 MOSI_r <= 1;
            #20 MOSI_r <= 1;
            #20 MOSI_r <= 0;
            #20 MOSI_r <= 1; 
        // End of First byte

        #20 $display(" Byte 1");
            $display("  MOSI [%b => %b]. Result: %s", 8'b10110001, RAW_w, (RAW_w == 8'b10110001) ? "Pass!" : "Fail!");
            $display("  MISO [%b => %b]. Result: %s", STA_r, MISO_raw_r, (MISO_raw_r == STA_r) ? "Pass!" : "Fail!");
        
        // Second byte [10100101]
            #0  MOSI_r <= 1;
            #20 MOSI_r <= 0;
            #20 MOSI_r <= 1;
            #20 MOSI_r <= 0;
            #20 MOSI_r <= 0;
            #20 MOSI_r <= 1;
            #20 MOSI_r <= 0;
            #20 MOSI_r <= 1; 
        // End of Second byte

        #20 SS_r <= 1;
        #60 $display(" Byte 2");
            $display("  MOSI [%b => %b]. Result: %s", 8'b10100101, RAW_w, (RAW_w == 8'b10100101) ? "Pass!" : "Fail!");
            $display("  MISO [%b => %b]. Result: %s", DATA_in_r, MISO_raw_r, (MISO_raw_r == DATA_in_r) ? "Pass!" : "Fail!");
            $display(" [%b %b %b]", CMD_w, ADDR_w, DATA_out_w);
            STA_r <= 8'b0; DATA_in_r <= 8'b0;

        $display();  

        $display("Test 3 - Mode 2 WRITE");

        SS_r <= 0;
        STA_r <= 8'hAA;
        DATA_in_r <= 8'hA5;

        // First byte [10111001]
            #0  MOSI_r <= 1; // Mode
            #20 MOSI_r <= 0; // Mode
            #20 MOSI_r <= 0; // CONT
            #20 MOSI_r <= 1; // WRITE
            #20 MOSI_r <= 1;
            #20 MOSI_r <= 1;
            #20 MOSI_r <= 0;
            #20 MOSI_r <= 1; 
        // End of First byte

        #20 $display(" Byte 1");
            $display("  MOSI [%b => %b]. Result: %s", 8'b10111001, RAW_w, (RAW_w == 8'b10111001) ? "Pass!" : "Fail!");
            $display("  MISO [%b => %b]. Result: %s", STA_r, MISO_raw_r, (MISO_raw_r == STA_r) ? "Pass!" : "Fail!");

        // Second byte [10100101]
            #0  MOSI_r <= 1;
            #20 MOSI_r <= 0;
            #20 MOSI_r <= 1;
            #20 MOSI_r <= 0;
            #20 MOSI_r <= 0;
            #20 MOSI_r <= 1;
            #20 MOSI_r <= 0;
            #20 MOSI_r <= 1; 
        // End of Second byte

        #20 SS_r <= 1;
        #60 $display(" Byte 2");
            $display("  MOSI [%b => %b]. Result: %s", 8'b10100101, RAW_w, (RAW_w == 8'b10100101) ? "Pass!" : "Fail!");
            $display("  MISO [%b => %b]. Result: %s", DATA_in_r, MISO_raw_r, (MISO_raw_r == DATA_in_r) ? "Pass!" : "Fail!");
            $display(" [%b %b %b]", CMD_w, ADDR_w, DATA_out_w);
            STA_r <= 8'b0; DATA_in_r <= 8'b0;

        $display();

        $display("Test 4 - Mode 3 READ");

        SS_r <= 0;
        STA_r <= 8'hAA;
        DATA_in_r <= 8'hA5;

        // First byte [10110010]
            #0  MOSI_r <= 0; // Mode
            #20 MOSI_r <= 1; // Mode
            #20 MOSI_r <= 0; // CONT
            #20 MOSI_r <= 0; // WRITE
            #20 MOSI_r <= 1;
            #20 MOSI_r <= 1;
            #20 MOSI_r <= 0;
            #20 MOSI_r <= 1; 
        // End of First byte

        #20 $display(" Byte 1");
            $display("  MOSI [%b => %b]. Result: %s", 8'b10110010, RAW_w, (RAW_w == 8'b10110010) ? "Pass!" : "Fail!");
            $display("  MISO [%b => %b]. Result: %s", STA_r, MISO_raw_r, (MISO_raw_r == STA_r) ? "Pass!" : "Fail!");


        // Second byte [10100101]
            #0  MOSI_r <= 1;
            #20 MOSI_r <= 0;
            #20 MOSI_r <= 1;
            #20 MOSI_r <= 0;
            #20 MOSI_r <= 0;
            #20 MOSI_r <= 1;
            #20 MOSI_r <= 0;
            #20 MOSI_r <= 1; 
        // End of Second byte

        #20 $display(" Byte 2");
            $display("  MOSI [%b => %b]. Result: %s", 8'b10100101, RAW_w, (RAW_w == 8'b10100101) ? "Pass!" : "Fail!");
            $display("  MISO [Don't Care].");

        // Third byte [01011010]
            #0  MOSI_r <= 0;
            #20 MOSI_r <= 1;
            #20 MOSI_r <= 0;
            #20 MOSI_r <= 1;
            #20 MOSI_r <= 1;
            #20 MOSI_r <= 0;
            #20 MOSI_r <= 1;
            #20 MOSI_r <= 0; 
        // End of Third byte

        #20 SS_r <= 1;
        #60 $display(" Byte 3");
            $display("  MOSI [%b => %b]. Result: %s", 8'b01011010, RAW_w, (RAW_w == 8'b01011010) ? "Pass!" : "Fail!");
            $display("  MISO [Don't Care].");
            $display(" [%b %b %b]", CMD_w, ADDR_w, DATA_out_w);
            STA_r <= 8'b0; DATA_in_r <= 8'b0;

        $display();

        $display("Test 5 - Mode 3 WRITE");

        SS_r <= 0;
        STA_r <= 8'hAA;
        DATA_in_r <= 8'hA5;

        // First byte [10111010]
            #0  MOSI_r <= 0; // Mode
            #20 MOSI_r <= 1; // Mode
            #20 MOSI_r <= 0; // CONT
            #20 MOSI_r <= 1; // WRITE
            #20 MOSI_r <= 1;
            #20 MOSI_r <= 1;
            #20 MOSI_r <= 0;
            #20 MOSI_r <= 1; 
        // End of First byte

        #20 $display(" Byte 1");
            $display("  [%b %b %b %b]", CMD_w, ADDR_w, DATA_out_w, RAW_w);
            $display("  MOSI [%b => %b]. Result: %s", 8'b10111010, RAW_w, (RAW_w == 8'b10111010) ? "Pass!" : "Fail!");
            $display("  MISO [%b => %b]. Result: %s", STA_r, MISO_raw_r, (MISO_raw_r == STA_r) ? "Pass!" : "Fail!");

        // Second byte [10100101]
            #0  MOSI_r <= 1;
            #20 MOSI_r <= 0;
            #20 MOSI_r <= 1;
            #20 MOSI_r <= 0;
            #20 MOSI_r <= 0;
            #20 MOSI_r <= 1;
            #20 MOSI_r <= 0;
            #20 MOSI_r <= 1; 
        // End of Second byte

        #20 $display(" Byte 2");
            $display("  [%b %b %b %b]", CMD_w, ADDR_w, DATA_out_w, RAW_w);
            $display("  MOSI [%b => %b]. Result: %s", 8'b10100101, RAW_w, (RAW_w == 8'b10100101) ? "Pass!" : "Fail!");
            $display("  MISO [Don't Care].");

        // Third byte [01011010]
            #0  MOSI_r <= 0;
            #20 MOSI_r <= 1;
            #20 MOSI_r <= 0;
            #20 MOSI_r <= 1;
            #20 MOSI_r <= 1;
            #20 MOSI_r <= 0;
            #20 MOSI_r <= 1;
            #20 MOSI_r <= 0; 
        // End of Third byte

        #20 SS_r <= 1;
        #60 $display(" Byte 3");
            $display("  [%b %b %b %b]", CMD_w, ADDR_w, DATA_out_w, RAW_w);
            $display("  MOSI [%b => %b]. Result: %s", 8'b01011010, RAW_w, (RAW_w == 8'b01011010) ? "Pass!" : "Fail!");
            $display("  MISO [Don't Care].");
            STA_r <= 8'b0; DATA_in_r <= 8'b0;
        
        $display();

        $display("Test 6 - Mode 4 READ");

        SS_r <= 0;
        STA_r <= 8'hAA;
        DATA_in_r <= 8'hA5;

        // First byte [10110011]
            #0  MOSI_r <= 1; // Mode
            #20 MOSI_r <= 1; // Mode
            #20 MOSI_r <= 0; // CONT
            #20 MOSI_r <= 0; // WRITE
            #20 MOSI_r <= 1;
            #20 MOSI_r <= 1;
            #20 MOSI_r <= 0;
            #20 MOSI_r <= 1; 
        // End of First byte

        #20 $display(" Byte 1");
            $display("  [%b %b %b %b]", CMD_w, ADDR_w, DATA_out_w, RAW_w);
            $display("  MOSI [%b => %b]. Result: %s", 8'b10110011, RAW_w, (RAW_w == 8'b10110011) ? "Pass!" : "Fail!");
            $display("  MISO [%b => %b]. Result: %s", STA_r, MISO_raw_r, (MISO_raw_r == STA_r) ? "Pass!" : "Fail!");

        // Second byte [10100101]
            #0  MOSI_r <= 1;
            #20 MOSI_r <= 0;
            #20 MOSI_r <= 1;
            #20 MOSI_r <= 0;
            #20 MOSI_r <= 0;
            #20 MOSI_r <= 1;
            #20 MOSI_r <= 0;
            #20 MOSI_r <= 1; 
        // End of Second byte

        #20 $display(" Byte 2");
            $display("  [%b %b %b %b]", CMD_w, ADDR_w, DATA_out_w, RAW_w);
            $display("  MOSI [%b => %b]. Result: %s", 8'b10100101, RAW_w, (RAW_w == 8'b10100101) ? "Pass!" : "Fail!");
            $display("  MISO [Don't Care].");

        // Third byte [01011010]
            #0  MOSI_r <= 0;
            #20 MOSI_r <= 1;
            #20 MOSI_r <= 0;
            #20 MOSI_r <= 1;
            #20 MOSI_r <= 1;
            #20 MOSI_r <= 0;
            #20 MOSI_r <= 1;
            #20 MOSI_r <= 0; 
        // End of Third byte

        #20 $display(" Byte 3");
            $display("  [%b %b %b %b]", CMD_w, ADDR_w, DATA_out_w, RAW_w);
            $display("  MOSI [%b => %b]. Result: %s", 8'b01011010, RAW_w, (RAW_w == 8'b01011010) ? "Pass!" : "Fail!");
            $display("  MISO [Don't Care].");

        // Fourth byte [10100101]
            #0  MOSI_r <= 1;
            #20 MOSI_r <= 0;
            #20 MOSI_r <= 1;
            #20 MOSI_r <= 0;
            #20 MOSI_r <= 0;
            #20 MOSI_r <= 1;
            #20 MOSI_r <= 0;
            #20 MOSI_r <= 1;
        // End of Fourth byte

        #20 SS_r <= 1;
        #60 $display(" Byte 4");
            $display("  [%b %b %b %b]", CMD_w, ADDR_w, DATA_out_w, RAW_w);
            $display("  MOSI [%b => %b]. Result: %s", 8'b10100101, RAW_w, (RAW_w == 8'b10100101) ? "Pass!" : "Fail!");
            $display("  MISO [%b => %b]. Result: %s", DATA_in_r, MISO_raw_r, (MISO_raw_r == DATA_in_r) ? "Pass!" : "Fail!");
            STA_r <= 8'b0; DATA_in_r <= 8'b0;
            
        $display();

        $display("Test 7 - Mode 4 WRITE");

        SS_r <= 0;
        STA_r <= 8'hAA;
        DATA_in_r <= 8'hA5;

        // First byte [10111011]
            #0  MOSI_r <= 1; // Mode
            #20 MOSI_r <= 1; // Mode
            #20 MOSI_r <= 0; // CONT
            #20 MOSI_r <= 1; // WRITE
            #20 MOSI_r <= 1;
            #20 MOSI_r <= 1;
            #20 MOSI_r <= 0;
            #20 MOSI_r <= 1; 
        // End of First byte

        #20 $display(" Byte 1");
            $display("  [%b %b %b %b]", CMD_w, ADDR_w, DATA_out_w, RAW_w);
            $display("  MOSI [%b => %b]. Result: %s", 8'b10111011, RAW_w, (RAW_w == 8'b10111011) ? "Pass!" : "Fail!");
            $display("  MISO [%b => %b]. Result: %s", STA_r, MISO_raw_r, (MISO_raw_r == STA_r) ? "Pass!" : "Fail!");

        // Second byte [11000001]
            #0  MOSI_r <= 1;
            #20 MOSI_r <= 0;
            #20 MOSI_r <= 0;
            #20 MOSI_r <= 0;
            #20 MOSI_r <= 0;
            #20 MOSI_r <= 0;
            #20 MOSI_r <= 1;
            #20 MOSI_r <= 1; 
        // End of Second byte

        #20 $display(" Byte 2");
            $display("  [%b %b %b %b]", CMD_w, ADDR_w, DATA_out_w, RAW_w);
            $display("  MOSI [%b => %b]. Result: %s", 8'b11000001, RAW_w, (RAW_w == 8'b11000001) ? "Pass!" : "Fail!");
            $display("  MISO [Don't Care].");

        // Third byte [10011101]
            #0  MOSI_r <= 1;
            #20 MOSI_r <= 0;
            #20 MOSI_r <= 1;
            #20 MOSI_r <= 1;
            #20 MOSI_r <= 1;
            #20 MOSI_r <= 0;
            #20 MOSI_r <= 0;
            #20 MOSI_r <= 1; 
        // End of Third byte

        #20 $display(" Byte 2");
            $display("  [%b %b %b %b]", CMD_w, ADDR_w, DATA_out_w, RAW_w);
            $display("  MOSI [%b => %b]. Result: %s", 8'b10011101, RAW_w, (RAW_w == 8'b10011101) ? "Pass!" : "Fail!");
            $display("  MISO [Don't Care].");

        // Fourth byte [10100101]
            #0  MOSI_r <= 1;
            #20 MOSI_r <= 0;
            #20 MOSI_r <= 1;
            #20 MOSI_r <= 0;
            #20 MOSI_r <= 0;
            #20 MOSI_r <= 1;
            #20 MOSI_r <= 0;
            #20 MOSI_r <= 1;
        // End of Fourth byte

        #20 SS_r <= 1;
        #60 $display(" Byte 4");
            $display("  [%b %b %b %b]", CMD_w, ADDR_w, DATA_out_w, RAW_w);
            $display("  MOSI [%b => %b]. Result: %s", 8'b10100101, RAW_w, (RAW_w == 8'b10100101) ? "Pass!" : "Fail!");
            $display("  MISO [%b => %b]. Result: %s", DATA_in_r, MISO_raw_r, (MISO_raw_r == DATA_in_r) ? "Pass!" : "Fail!");
            STA_r <= 8'b0; DATA_in_r <= 8'b0;

        $display();

        #100 $finish;
    end


endmodule
