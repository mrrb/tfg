/*
 *
 * FIFO_BRAM_SYNC module
 * This module genereates a SYNCHRONOUS FIFO memory based on a BRAM.
 *
 * Parameters:
 *  - DATA_WIDTH. Size of each cell. [Default: FIFO_BRAM_8 bits]
 *  - ALMOST_FULL. Ratio that makes wr_almost_full HIGH (ALMOST_FULL to 1). [Default: 0.9]
 *  - ALMOST_EMPTY. Ratio that makes rd_almost_empty LOW (0 to ALMOST_EMPTY). [Default: 0.1]
 *  - FWFT_MODE. First Word Fall Through (1 > enable, 0 > disable). [ToDo]
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

`ifdef ASYNC_RESET
    `define FIFO_BRAM_SYNC_ASYNC_RESET or negedge rst
`else
    `define FIFO_BRAM_SYNC_ASYNC_RESET
`endif

`define FIFO_BRAM_16 16
`define FIFO_BRAM_8  8
`define FIFO_BRAM_4  4
`define FIFO_BRAM_2  2

module FIFO_BRAM_SYNC #(
                        parameter DATA_WIDTH   = `FIFO_BRAM_8,
                        parameter ALMOST_FULL  = 0.9,
                        parameter ALMOST_EMPTY = 0.1,
                        parameter FWFT_MODE    = 1 // ToDo
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

    localparam BRAM_MODE = 4-$clog2(DATA_WIDTH); // BRAM mode
    localparam BRAM_SIZE = 256*(2**BRAM_MODE);   // Maximum number of bytes that can be stored in the FIFO
    localparam ADDR_SIZE = $clog2(BRAM_SIZE);    // Bits of the address

    localparam ALMOST_FULL_VAL  = $ceil(BRAM_SIZE*ALMOST_FULL);  // Minimum value that makes wr_almost_full HIGH.
    localparam ALMOST_EMPTY_VAL = $ceil(BRAM_SIZE*ALMOST_EMPTY); // Maximum value that makes rd_almost_empty HIGH.

    /// Error control
    // wire wr_error, rd_error;
    // assign wr_error = wr_dv && wr_full;
    // assign rd_error = rd_en && rd_empty;
    /// End of Error control

    /// BRAM init
    wire [(DATA_WIDTH-1):0]BRAM_DATA_wr;
    wire [15:0]BRAM_DATA_rd;
    wire  [(ADDR_SIZE-1):0]BRAM_ADDR_wr, BRAM_ADDR_rd;
    wire BRAM_WE, BRAM_RE;
    SB_RAM40_4K #(
                  .WRITE_MODE(BRAM_MODE), // DATA Width
                  .READ_MODE(BRAM_MODE)   // DATA Width
                 )
    FIFO_BRAM    (
                  // WRITE signals
                  .WDATA({8'b0,BRAM_DATA_wr}), // [Input]
                  .WADDR({2'b0,BRAM_ADDR_wr}), // [Input]
                  .WE(BRAM_WE),                // [Input]
                  .WCLK(clk),                  // [Input]
                  .WCLKE(BRAM_WE),             // [Input]

                  // READ signals
                  .RDATA(BRAM_DATA_rd),        // [Output]
                  .RADDR({2'b0,BRAM_ADDR_rd}), // [Input]
                  .RE(BRAM_RE),                // [Input]
                  .RCLK(!clk),                 // [Input]
                  .RCLKE(BRAM_RE)              // [Input]
                 );
    /// End of BRAM init

    /// Regs and wires
    reg [ADDR_SIZE:0]FIFO_size = 0;

    reg [(ADDR_SIZE-1):0]ADDR_wr = 0; // Address where the DATA is going to be add
    reg [(ADDR_SIZE-1):0]ADDR_rd = 0; // Address where the DATA is going to be read

    wire wr_ctrl, rd_ctrl;
    /// End of Regs and wires

    /// Assigns
    assign BRAM_DATA_wr = wr_DATA;
    assign rd_DATA = BRAM_DATA_rd[7:0];

    assign BRAM_ADDR_wr = ADDR_wr;
    assign BRAM_ADDR_rd = ADDR_rd;

    assign wr_ctrl = wr_dv && !wr_full;
    assign rd_ctrl = rd_en && !rd_empty;

    assign wr_full  = (FIFO_size == BRAM_SIZE) ? 1'b1 : 1'b0;
    assign rd_empty = (FIFO_size == 0)         ? 1'b1 : 1'b0;

    assign wr_almost_full  = (FIFO_size >= ALMOST_FULL_VAL) ? 1'b1 : 1'b0;
    assign rd_almost_empty = (FIFO_size <= ALMOST_EMPTY_VAL)  ? 1'b1 : 1'b0;
    /// End of Assigns

    /// Controller
    // FIFO_size counter controller
    always @(posedge clk `FIFO_BRAM_SYNC_ASYNC_RESET) begin
        if(!rst) FIFO_size <= 0;
        else if( wr_ctrl && !rd_ctrl) FIFO_size <= FIFO_size + 1'b1; // FIFO push
        else if(!wr_ctrl &&  rd_ctrl) FIFO_size <= FIFO_size - 1'b1; // FIFO pull
                                                                     // Otherwise, both push & pull OR no change
    end

    // Address controller
    always @(posedge clk `FIFO_BRAM_SYNC_ASYNC_RESET) begin
        if(!rst) ADDR_wr <= 0;
        else if(wr_ctrl) ADDR_wr <= ADDR_wr + 1'b1; // FIFO push
    end

    always @(posedge clk `FIFO_BRAM_SYNC_ASYNC_RESET) begin
        if(!rst) ADDR_rd <= 0;
        else if(rd_ctrl) ADDR_rd <= ADDR_rd + 1'b1; // FIFO pull
    end

    // FIFO controller
    assign BRAM_WE = (wr_ctrl)   ? 1'b1 : 1'b0;
    assign BRAM_RE = (!rd_empty) ? 1'b1 : 1'b0;
    /// End of Controller

endmodule