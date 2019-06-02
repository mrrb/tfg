/*
 *
 * FIFO_BRAM_SYNC module
 * This module genereates a SYNCHRONOUS FIFO memory based on a BRAM.
 *
 * Parameters:
 *  - ALMOST_FULL. Ratio* that makes wr_almost_full HIGH (ALMOST_FULL to 1). [Default: 0.9]
 *  - ALMOST_EMPTY. Ratio* that makes rd_almost_empty LOW (0 to ALMOST_EMPTY). [Default: 0.1]
 *  - DATA_WIDTH. Size of each cell. [Default: 8-bits]
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
    `define FIFO_BRAM_SYNC_ASYNC_RESET or negedge rst
`else
    `define FIFO_BRAM_SYNC_ASYNC_RESET
`endif

`ifndef FIFO_BRAM_S
    `define FIFO_BRAM_16 16
    `define FIFO_BRAM_8  8
    `define FIFO_BRAM_4  4
    `define FIFO_BRAM_2  2
    `define FIFO_BRAM_S
`endif

module FIFO_BRAM_SYNC #(
                        parameter ALMOST_FULL  = 0.9,
                        parameter ALMOST_EMPTY = 0.1,
                        parameter DATA_WIDTH   = `FIFO_BRAM_8,
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

    localparam BRAM_MODE  = 4-$clog2(DATA_WIDTH); // ICE40 BRAM mode
    localparam BRAM_SIZE  = 256*(2**BRAM_MODE);   // Maximum number of bytes that can be stored in the FIFO
    localparam ADDR_SIZE  = $clog2(BRAM_SIZE);    // Bits of the address

    localparam ALMOST_FULL_VAL  = $ceil(BRAM_SIZE*ALMOST_FULL);  // Minimum value that makes wr_almost_full HIGH.
    localparam ALMOST_EMPTY_VAL = $ceil(BRAM_SIZE*ALMOST_EMPTY); // Maximum value that makes rd_almost_empty HIGH.

    /// Error control
    // wire wr_error, rd_error;
    // assign wr_error = wr_dv && wr_full;
    // assign rd_error = rd_en && rd_empty;
    /// End of Error control

    /// BRAM init
    wire [(DATA_WIDTH-1):0]BRAM_DATA_wr, BRAM_DATA_rd; // ICE40 BRAM DATA
    wire  [(ADDR_SIZE-1):0]BRAM_ADDR_wr, BRAM_ADDR_rd; // ICE40 BRAM ADDRESSES
    wire BRAM_WE, BRAM_RE;

    wire [(DATA_WIDTH-1):0]DW, DR;     // Shorter names for the DATA I/O
    wire [(16-DATA_WIDTH-1):0]_NULLR_; // Null vector for the READ DATA
    assign DW = BRAM_DATA_wr; // Input assignment
    assign BRAM_DATA_rd = DR; // Output assignment

    // BRAM block mask generator
    wire [15:0]WDATA_temp, RDATA_temp;
    wire [10:0]WADDR_temp, RADDR_temp;
    generate
        if(BRAM_MODE == 0) begin
            assign WDATA_temp = DW;
            assign DR = RDATA_temp;
            assign WADDR_temp = {3'b0, BRAM_ADDR_wr};
            assign RADDR_temp = {3'b0, BRAM_ADDR_rd};
        end
        else if(BRAM_MODE == 1) begin
            assign WDATA_temp = {1'hx, DW[7], 1'hx, DW[6], 1'hx, DW[5], 1'hx, DW[4], 
                                 1'hx, DW[3], 1'hx, DW[2], 1'hx, DW[1], 1'hx, DW[0]};
            assign {_NULLR_[7], DR[7], _NULLR_[6], DR[6], _NULLR_[5], DR[5], _NULLR_[4], DR[4],
                    _NULLR_[3], DR[3], _NULLR_[2], DR[2], _NULLR_[1], DR[1], _NULLR_[0], DR[0]} = RDATA_temp;
            assign WADDR_temp = {2'b0, BRAM_ADDR_wr};
            assign RADDR_temp = {2'b0, BRAM_ADDR_rd};
        end
        else if(BRAM_MODE == 2) begin
            assign WDATA_temp = {1'hx, DW[3], 1'hx, 1'hx, 1'hx, 1'hx, DW[2], 1'hx, 
                                 1'hx, DW[1], 1'hx, 1'hx, 1'hx, 1'hx, DW[0], 1'hx};
            assign {_NULLR_[11], _NULLR_[10], DR[3], _NULLR_[9], _NULLR_[8], _NULLR_[7], DR[2], _NULLR_[6],
                    _NULLR_[5],  _NULLR_[4],  DR[1], _NULLR_[3], _NULLR_[2], _NULLR_[1], DR[0], _NULLR_[0]} = RDATA_temp;
            assign WADDR_temp = {1'b0, BRAM_ADDR_wr};
            assign RADDR_temp = {1'b0, BRAM_ADDR_rd};
        end
        else if(BRAM_MODE == 3) begin
            assign WDATA_temp = {1'hx, 1'hx, 1'hx, 1'hx, DW[1], 1'hx, 1'hx, 1'hx, 
                                 1'hx, 1'hx, 1'hx, 1'hx, DW[0], 1'hx, 1'hx, 1'hx};
            assign {_NULLR_[13], _NULLR_[12], _NULLR_[11], _NULLR_[10], DR[1], _NULLR_[9], _NULLR_[8], _NULLR_[7],
                    _NULLR_[6],  _NULLR_[5],  _NULLR_[4],  _NULLR_[3],  DR[0], _NULLR_[2], _NULLR_[1], _NULLR_[0]} = RDATA_temp;
            assign WADDR_temp = {BRAM_ADDR_wr};
            assign RADDR_temp = {BRAM_ADDR_rd};
        end
    endgenerate

    SB_RAM40_4K #(
                  .WRITE_MODE(BRAM_MODE), // DATA Width
                  .READ_MODE(BRAM_MODE)   // DATA Width
                 )
    FIFO_BRAM    (
                  // WRITE signals
                  .WDATA(WDATA_temp), // [Input, 16bits]
                  .WADDR(WADDR_temp), // [Input, 11bits]
                  .WE(BRAM_WE),       // [Input]
                  .WCLK(clk),         // [Input]
                  .WCLKE(BRAM_WE),    // [Input]

                  // READ signals
                  .RDATA(RDATA_temp), // [Output, 16bits]
                  .RADDR(RADDR_temp), // [Input, 11bits]
                  .RE(BRAM_RE),       // [Input]
                  .RCLK(!clk),        // [Input]
                  .RCLKE(BRAM_RE)     // [Input]
                 );
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

    // assign wr_almost_full  = (FIFO_size >= ALMOST_FULL_VAL)  ? 1'b1 : 1'b0; // Almost full flat
    // assign rd_almost_empty = (FIFO_size <= ALMOST_EMPTY_VAL) ? 1'b1 : 1'b0; // Almost empty flag
    assign wr_almost_full  = wr_full; // Almost full flat
    assign rd_almost_empty = rd_empty; // Almost empty flag
    /// End of Assigns

    /// Controller
    // FIFO_size counter controller
    always @(posedge clk `FIFO_BRAM_SYNC_ASYNC_RESET) begin
        if(!rst) FIFO_size <= 0;
        else if( wr_ctrl && !rd_ctrl) FIFO_size <= FIFO_size + 1'b1; // FIFO push
        else if(!wr_ctrl &&  rd_ctrl) FIFO_size <= FIFO_size - 1'b1; // FIFO pull
                                                                     // Otherwise, both push & pull OR no change
    end

    // WRITE address controller
    always @(posedge clk `FIFO_BRAM_SYNC_ASYNC_RESET) begin
        if(!rst) ADDR_wr <= 0;
        else if(wr_ctrl) ADDR_wr <= ADDR_wr + 1'b1; // FIFO push
    end

    // READ address controller
    always @(posedge clk `FIFO_BRAM_SYNC_ASYNC_RESET) begin
        if(!rst) ADDR_rd <= 0;
        else if(rd_ctrl) ADDR_rd <= ADDR_rd + 1'b1; // FIFO pull
    end

    // FIFO controller
    assign BRAM_WE = (wr_ctrl) ? 1'b1 : 1'b0;
    assign BRAM_RE = 1'b1;
    /// End of Controller

endmodule