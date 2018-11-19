/*
 *
 * FIFO_REG module
 * This module generates a SYNCHRONOUS FIFO memory based on registers.
 *
 *  1 2 3 4 5
 *  _ _ _ _ _ 
 * |_ _ _ _ _|  1.
 * |_ _ _ _ _|  2.  DATA_WIDTH
 * |_ _ _ _ _|  3.
 * DATA_DEPTH
 *
 * Parameters:
 *  - DATA_WIDTH. Number of bits that the FIFO memory con store.
 *  - DATA_DEPTH. Size of the FIFO memory (Total = ).
 *  - ALMOST_FULL_VAL. The wr_almost_full signal will be HIGH when FIFO_size is equal or greater than this value. 
 *  - ALMOST_EMPTY_VAL. The rd_almost_empty signal will be HIGH when FIFO_size is equal or lower than this value. 
 *
 * Inputs:
 *  - rst. Reset signal, active LOW
 *  - clk_wr. Write reference clock.
 *  - wr_dv. Write Data Valid, if HIGH and posedge of clk_wr, a write process occurs.
 *  - wr_DATA. Data that is going to be stored in the FIFO memory.
 *  - clk_rd. Read reference clock.
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
    `define FIFO_REG_ASYNC_RESET or negedge rst
`else
    `define FIFO_REG_ASYNC_RESET
`endif

module FIFO_REG #(
                  parameter DATA_WIDTH = 4,
                  parameter DATA_DEPTH = 8,
                  parameter ALMOST_FULL_VAL  = 6,
                  parameter ALMOST_EMPTY_VAL = 2
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

    localparam ADDR_SIZE = $clog2(DATA_DEPTH);

    /// Main reg init
    reg [(DATA_WIDTH-1):0]FIFO_r[0:(DATA_DEPTH-1)];
    /// End of Main reg init

    /// Regs and wires
    reg [(ADDR_SIZE-1):0]wr_addr = 0; // Address where the DATA is going to be add
    reg [(ADDR_SIZE-1):0]rd_addr = 0; // Address where the DATA is going to be read
    reg [ADDR_SIZE:0]FIFO_size   = 0; // Current slots stored in the FIFO

    reg [(DATA_WIDTH-1):0]rd_DATA_r = 0; // Output buffer
    /// End of Regs and wires

    /// Assigns
    assign wr_full  = (FIFO_size == DATA_DEPTH) ? 1'b1 : 1'b0;
    assign rd_empty = (FIFO_size == 0)          ? 1'b1 : 1'b0;

    assign wr_almost_full  = (FIFO_size >= ALMOST_FULL_VAL)  ? 1'b1 : 1'b0;
    assign rd_almost_empty = (FIFO_size <= ALMOST_EMPTY_VAL) ? 1'b1 : 1'b0;

    assign rd_DATA = rd_DATA_r;
    /// End of Assigns

    /// Controller
    // FIFO_size counter controller
    always @(posedge clk `FIFO_REG_ASYNC_RESET) begin
        if(!rst) FIFO_size <= 0;
        else if(wr_dv && !wr_full)  FIFO_size <= FIFO_size + 1'b1;
        else if(rd_en && !rd_empty) FIFO_size <= FIFO_size - 1'b1;
    end

    // Address controller
    always @(posedge clk `FIFO_REG_ASYNC_RESET) begin
        if(!rst) begin
            wr_addr <= 0;
            rd_addr <= 0;
        end
        else if(wr_dv && !wr_full)  wr_addr <= wr_addr + 1'b1;
        else if(rd_en && !rd_empty) rd_addr <= rd_addr + 1'b1;
    end

    // FIFO controller
    always @(posedge clk `FIFO_REG_ASYNC_RESET) begin
        if(!rst) FIFO_r[0] <= 0;
        else if(wr_dv && !wr_full)  FIFO_r[wr_addr] <= wr_DATA;
        else if(rd_en && !rd_empty) rd_DATA_r <= FIFO_r[rd_addr];
    end
    /// End of Controller

endmodule