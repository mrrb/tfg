/*
 *
 * FIFO_BRAM_SYNC module
 * This module genereates a SYNCHRONOUS FIFO memory based on a BRAM.
 *
 * Parameters:
 *  - DATA_WIDTH.
 *  - ALMOST_FULL_VAL.
 *  - ALMOST_EMPTY_VAL.
 *
 * Inputs:
 *  - rst. Reset signal, active LOW
 *  - clk. Reference clock.
 *  - wr_dv. Write Data Valid, if HIGH and posedge of clk_wr, a write process occurs.
 *  - wr_DATA. Data that is going to be stored in the FIFO memory.
 *  - rd_en. Read enable, if HIGH and posedge of clk_rd, a read process occurs.
 *
 * Outputs:
 *  - wr_full. The FIFO memory is full and any future write operations will be ignored.
 *  - wr_almost_full. There are ALMOST_FULL_VAL or more slots already occupied.
 *  - rd_DATA. Data read from the FIFO memory.
 *  - rd_empty. The FIFO memory is empty and any future read operations will be ignored.
 *  - rd_almost_empty. There are ALMOST_EMPTY_VAL or less slots already occupied.
 *
 */

`default_nettype none

`define FIFO_BRAM_16 16
`define FIFO_BRAM_8  8
`define FIFO_BRAM_4  4
`define FIFO_BRAM_2  2


module FIFO_BRAM_SYNC #(
                        parameter DATA_WIDTH = `FIFO_BRAM_8,
                        parameter ALMOST_FULL_VAL  = $ceil((2**DATA_WIDTH)*0.9),
                        parameter ALMOST_EMPTY_VAL = $ceil((2**DATA_WIDTH)*0.1)
                       )
                       (
                        // System signals
                        input  wire rst, // Master reset signal, active LOW
                        input  wire clk, // Reference clock

                        // Write control signals
                        input  wire wr_dv,  // Write Data Valid

                        // Write data signals
                        input  wire [(DATA_WIDTH-1):0]wr_DATA, // Input DATA
                        
                        // Write flags
                        output wire wr_full,        // The FIFO memory is full
                        output wire wr_almost_full, // The FIFO memory is almost full

                        // Read control signals            
                        input  wire rd_en,  // Read enable

                        // Read data signals            
                        output wire [(DATA_WIDTH-1):0]rd_DATA, // Output DATA
                        
                        // Read flags
                        output wire rd_empty,       // The FIFO memory is empty
                        output wire rd_almost_empty // The FIFO memory is almost empty
                       );

    localparam BRAM_MODE = 4-$clog2(DATA_WIDTH);
    localparam BRAM_SIZE = 256*(2**BRAM_MODE);
    localparam ADDR_SIZE = $clog2(BRAM_SIZE);

    /// BRAM init
    wire BRAM_WE, BRAM_RE;
    SB_RAM40_4K #(
                  .WRITE_MODE(BRAM_MODE), // DATA Width
                  .READ_MODE(BRAM_MODE)   // DATA Width
                 )
    FIFO_BRAM    (
                  // WRITE signals
                  .WDATA(wr_DATA), // [Input]
                  .WADDR(wr_addr), // [Input]
                  .WE(BRAM_WE),    // [Input]
                  .WCLK(clk),   // [Input]
                  .WCLKE(BRAM_WE), // [Input]

                  // READ signals
                  .RDATA(rd_DATA), // [Output]
                  .RADDR(rd_addr), // [Input]
                  .RE(BRAM_RE),    // [Input]
                  .RCLK(clk),   // [Input]
                  .RCLKE(BRAM_RE)  // [Input]
                 );
    /// End of BRAM init

    /// Regs and wires
    reg [(ADDR_SIZE-1):0]wr_addr  = 0; // Address where the DATA is going to be add
    reg [(ADDR_SIZE-1):0]rd_addr  = 0; // Address where the DATA is going to be read

    reg [ADDR_SIZE:0]FIFO_size    = 0; // Current slots stored in the FIFO
    /// End of Regs and wires

    /// Assigns
    assign wr_full  = (FIFO_size == BRAM_SIZE) ? 1'b1 : 1'b0;
    assign rd_empty = (FIFO_size == 0)         ? 1'b1 : 1'b0;

    assign wr_almost_full  = (FIFO_size >= ALMOST_FULL_VAL)  ? 1'b1 : 1'b0;
    assign rd_almost_empty = (FIFO_size <= ALMOST_EMPTY_VAL) ? 1'b1 : 1'b0;
    /// End of Assigns

    /// Controller
    // FIFO_size counter controller
    always @(posedge clk or negedge rst) begin
        if(!rst) FIFO_size <= 0;
        else if(wr_dv && !wr_full)  FIFO_size <= FIFO_size + 1'b1;
        else if(rd_en && !rd_empty) FIFO_size <= FIFO_size - 1'b1;
    end

    // Address controller
    always @(posedge clk or negedge rst) begin
        if(!rst) wr_addr <= 0;
        else if(wr_dv && !wr_full) wr_addr <= wr_addr + 1'b1;
        else if(rd_en && !rd_empty) rd_addr <= rd_addr + 1'b1;
    end
 
    // FIFO controller
    assign BRAM_WE = (wr_dv && !wr_full)  ? 1'b1 : 1'b0;
    assign BRAM_RE = (rd_en && !rd_empty) ? 1'b1 : 1'b0;
    /// End of Controller
endmodule