/*
 *
 * FIFO_BRAM_SYNC_CUSTOM module
 * This module genereates a SYNCHRONOUS FIFO memory based on a BRAM (with a custom number of BRAMs).
 *
 * Parameters:
 *  - ALMOST_FULL. Ratio* that makes wr_almost_full HIGH (ALMOST_FULL to 1). [Default: 0.9]
 *  - ALMOST_EMPTY. Ratio* that makes rd_almost_empty LOW (0 to ALMOST_EMPTY). [Default: 0.1]
 *  - DATA_WIDTH. Size of each cell. [Default: 8-bits]
 *  - FIFO_SIZE_ML. FIFO size multiplier, number of BRAMs used. [Default: 1]
 *  - FWFT_MODE. First Word Fall Through (1 > enable, 0 > disable). [ToDo]
 *  *Value = RATIO*BRAM_SIZE
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
    `define FIFO_BRAM_SYNC_C_ASYNC_RESET or negedge rst
`else
    `define FIFO_BRAM_SYNC_C_ASYNC_RESET
`endif

`ifndef FIFO_BRAM_S
    `define FIFO_BRAM_16 16
    `define FIFO_BRAM_8  8
    `define FIFO_BRAM_4  4
    `define FIFO_BRAM_2  2
    `define FIFO_BRAM_S
`endif

module FIFO_BRAM_SYNC_CUSTOM #(
                               parameter DATA_WIDTH   = `FIFO_BRAM_8,
                               parameter FIFO_SIZE_ML = 1,
                               parameter ALMOST_FULL  = 0.9,
                               parameter ALMOST_EMPTY = 0.1,
                               parameter FWFT_MODE    = 1 // ToDo
                              )
                              (
                               // System signals
                               input  wire rst, // Master reset signal, active LOW
                               input  wire clk, // Reference clock

                               // Write control signals
                               input  wire wr_dv, // Write Data Valid control signal (active HIGH)

                               // Write data signals
                               input  wire [(DATA_WIDTH-1):0]wr_DATA, // Input DATA

                               // Write flags
                               output wire wr_full,        // The FIFO memory is full flag
                               output wire wr_almost_full, // The FIFO memory is almost full flag

                               // Read control signals            
                               input  wire rd_en, // Read enable control signal (active HIGH)

                               // Read data signals            
                               output wire [(DATA_WIDTH-1):0]rd_DATA, // Output DATA

                               // Read flags
                               output wire rd_empty,       // The FIFO memory is empty flag
                               output wire rd_almost_empty // The FIFO memory is almost empty flag
                              );

    localparam BRAM_MODE  = 4-$clog2(DATA_WIDTH);            // ICE40 BRAM mode
    localparam BRAM_SIZE  = 256*(2**BRAM_MODE)*FIFO_SIZE_ML; // Maximum number of bytes that can be stored in the FIFO
    localparam ADDR_SIZE  = $clog2(BRAM_SIZE);               // Bits of the address

    localparam ALMOST_FULL_VAL  = $ceil(BRAM_SIZE*ALMOST_FULL);  // Minimum value that makes wr_almost_full HIGH.
    localparam ALMOST_EMPTY_VAL = $ceil(BRAM_SIZE*ALMOST_EMPTY); // Maximum value that makes rd_almost_empty HIGH.

    /// Error control
    // wire wr_error, rd_error;
    // assign wr_error = wr_dv && wr_full;
    // assign rd_error = rd_en && rd_empty;
    /// End of Error control

    /// BRAM init
    wire [(DATA_WIDTH-1):0]BRAM_DATA_wr; // RAM data IN
    reg  [(DATA_WIDTH-1):0]BRAM_DATA_rd; // RAM register OUT
    wire  [(ADDR_SIZE-1):0]BRAM_ADDR_wr, BRAM_ADDR_rd; // RAM adresses
    wire BRAM_WE, BRAM_RE; // RAM WRITE/READ enable

    reg [(DATA_WIDTH-1):0]RAM_mem[0:(BRAM_SIZE-1)]; // Main memory

    always @(posedge clk) begin
        if(BRAM_WE) RAM_mem[ADDR_wr] <= BRAM_DATA_wr;
    end
    always @(negedge clk) begin
        if(!rst)    BRAM_DATA_rd <= 0;
        if(BRAM_RE) BRAM_DATA_rd <= RAM_mem[ADDR_rd];
    end
    /// End of BRAM init

    /// Regs and wires
    reg [ADDR_SIZE:0]FIFO_size = 0;   // Number of bytes stored in the FIFO

    reg [(ADDR_SIZE-1):0]ADDR_wr = 0; // Address where the DATA is going to be add
    reg [(ADDR_SIZE-1):0]ADDR_rd = 0; // Address where the DATA is going to be read

    wire wr_ctrl, rd_ctrl; // Control signals that go HIGH whenever a WRITE/READ action can occur
    /// End of Regs and wires

    /// Assigns
    assign BRAM_DATA_wr = wr_DATA; // Input assign
    assign rd_DATA = BRAM_DATA_rd; // Output assign

    assign BRAM_ADDR_wr = ADDR_wr; // BRAM WRITE address
    assign BRAM_ADDR_rd = ADDR_rd; // BRAM READ address

    assign wr_ctrl = wr_dv && !wr_full;  // The FIFO ONLY can be WRITE when It isn't full AND wr_dv is HIGH
    assign rd_ctrl = rd_en && !rd_empty; // The FIFO ONLY can be READ when It isn't empty AND rd_en is HIGH

    assign wr_full  = (FIFO_size == BRAM_SIZE) ? 1'b1 : 1'b0; // Full flag
    assign rd_empty = (FIFO_size == 0)         ? 1'b1 : 1'b0; // Empty flag

    assign wr_almost_full  = (FIFO_size >= ALMOST_FULL_VAL)  ? 1'b1 : 1'b0; // Almost full flat
    assign rd_almost_empty = (FIFO_size <= ALMOST_EMPTY_VAL) ? 1'b1 : 1'b0; // Almost empty flag
    /// End of Assigns

    /// Controller
    // FIFO_size counter controller
    always @(posedge clk `FIFO_BRAM_SYNC_C_ASYNC_RESET) begin
        if(!rst) FIFO_size <= 0;
        else if( wr_ctrl && !rd_ctrl) FIFO_size <= FIFO_size + 1'b1; // FIFO push
        else if(!wr_ctrl &&  rd_ctrl) FIFO_size <= FIFO_size - 1'b1; // FIFO pull
                                                                     // Otherwise, both push & pull OR no change
    end

    // WRITE address controller
    always @(posedge clk `FIFO_BRAM_SYNC_C_ASYNC_RESET) begin
        if(!rst) ADDR_wr <= 0;
        else if(wr_ctrl) ADDR_wr <= ADDR_wr + 1'b1; // FIFO push
    end

    // READ address controller
    always @(posedge clk `FIFO_BRAM_SYNC_C_ASYNC_RESET) begin
        if(!rst) ADDR_rd <= 0;
        else if(rd_ctrl) ADDR_rd <= ADDR_rd + 1'b1; // FIFO pull
    end

    // FIFO controller
    assign BRAM_WE = (wr_ctrl) ? 1'b1 : 1'b0;
    assign BRAM_RE = 1'b1;
    /// End of Controller

endmodule