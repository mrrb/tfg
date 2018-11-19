`default_nettype none
`timescale 100ns/10ns

module SB_RAM40_4K_tb ();

    /// Regs and wires
    wire [15:0]rd_DATA;

    reg WE = 0;
    reg RE = 0;
    reg [15:0]wr_DATA = 0;
    reg [10:0]wr_addr = 0;
    reg [10:0]rd_addr = 0;
    /// End of Regs and wires

    /// Module under test init
    SB_RAM40_4K #(
                  .WRITE_MODE(1), // DATA Width
                  .READ_MODE(1)   // DATA Width
                 )
    BRAM_mut     (
                  // WRITE signals
                  .WDATA(wr_DATA), // [Input]
                  .WADDR(wr_addr), // [Input]
                  .WE(WE),    // [Input]
                  .WCLK(clk),   // [Input]
                  .WCLKE(WE),  // [Input]

                  // READ signals
                  .RDATA(rd_DATA), // [Output]
                  .RADDR(rd_addr), // [Input]
                  .RE(RE),    // [Input]
                  .RCLK(clk),   // [Input]
                  .RCLKE(RE) // [Input]
                 );
    /// End of Module under test init

    /// Clock gen
    reg clk = 1'b0;
    always #0.5 clk = ~clk;
    /// End of Clock gen

    /// Simulation
    initial begin
        $dumpfile("./sim/SB_RAM40_4K_tb.vcd");
        $dumpvars();

        #1 WE = 1;

        #1 wr_DATA = 8'hAF; wr_addr = 9'h1A;

        #1 wr_DATA = 8'h09; wr_addr = 9'hF9;
        
        #1 wr_DATA = 8'h11; wr_addr = 9'hC5;

        #1 WE = 0;

        #2 RE = 1;

        #1 rd_addr = 9'h1A;

        #1 rd_addr = 9'hF9;

        #1 rd_addr = 9'hAB;

        #1 rd_addr = 9'hC5;

        #1 RE = 0;

        #1 rd_addr = 0;

        #1 $finish;
    end
    /// End of Simulation

endmodule