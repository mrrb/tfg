/*
 *
 * ULPI module
 * This module lets the FPGA communicate with a ULPI compliant device (in this case, the USB3300 ic).
 *
 * In this module are instantiated all the required submodules:
 *  - 
 *
 */

`default_nettype none

`ifdef ASYNC_RESET
    `define ULPI_ASYNC_RESET or negedge rst
`else
    `define ULPI_ASYNC_RESET
`endif

`include "./modules/ULPI_RW.vh"

 module ULPI (
              // System signals
              input  wire rst,       // Reset signal
              input  wire clk_ice,   // 12MHz ICEstick reference clock
              input  wire clk_ULPI,  // 60MHz ULPI clock

              // Control signals
              input  wire PrW,

              // Register signals
              input  wire [5:0]ADDR,
              input  wire [7:0]REG_VAL_W,
              output wire [7:0]REG_VAL_R,

              // ULPI signals
              input  wire DIR,       // ULPI DIR (DIRection) signal
              input  wire NXT,       // ULPI NXT (NeXT) signal
              inout  wire [7:0]DATA, // ULPI inout DATA signals
              output wire STP,       // ULPI STP (SToP) signal
              output wire U_RST      // ULPI RST (ReSeT) signal
             );

    /// ULPI reset
    assign U_RST = !rst;
    /// End of ULPI reset

    /// DATA inout selector
    wire [7:0]DATA_out; // Data generated in the FPGA (link)
    assign DATA = (DIR) ? 8'bz : DATA_out; // When the PHY has the ownership of the bus, the FPGA must have the inputs in a HIGH impedance mode
                                            // so there will not have any conflicts.
    /// End of DATA inout selector

    /// Metastability solver
    // Check the reference doc FPGA_ICE40/wp-01082-quartus-ii-metastability.pdf for more info
    // (Or https://www.intel.com/content/dam/www/programmable/us/en/pdfs/literature/wp/wp-01082-quartus-ii-metastability.pdf)
    reg [7:0]DATA_A, DATA_B;
    wire [7:0]DATA_in;
    assign DATA_in = DATA_B;

    always @(posedge clk_ULPI `ULPI_ASYNC_RESET) begin
        if(!rst) begin
            DATA_A <= 0;
            DATA_B <= 0;
        end
        else if(DIR) begin
            DATA_A <= DATA;
            DATA_B <= DATA_A;
        end
    end
    /// End of Metastability solver

    /// Reg_Write submodule init
    wire RW_busy;
    ULPI_REG_WRITE ULPI_RW (
                            // System signals
                            .rst(rst),           // [Input]
                            .clk_ULPI(clk_ULPI), // [Input]

                            // Control signals
                            .PrW(PrW),           // [Input]
                            .busy(RW_busy),      // [Output]

                            // Register values
                            .ADDR(ADDR),         // [Input]
                            .REG_VAL(REG_VAL_R), // [Input]

                            // ULPI signals
                            .DIR(DIR),           // [Input]
                            .NXT(NXT),           // [Input]
                            .DATA_I(DATA_in),    // [Input]
                            .DATA_O(DATA_out),   // [Output]
                            .STP(STP)            // [Output]
                           );
    /// End of Reg_Write submodule init

    /// Reg_Read submodule init
    /// End of Reg_Read submodule init

 endmodule
