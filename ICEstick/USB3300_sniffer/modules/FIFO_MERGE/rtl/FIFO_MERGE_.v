//! BROKEN MODULE, NOT USE!

/*
 *
 * FIFO_MERGE module
 * This module merges some FIFOs into one
 *
 * Parameters:
 *  - FIFO_COUNT. Number of FIFO that are going to merge into one.
 *  - ALMOST_EMPTY. Ratio* that makes rd_almost_empty LOW (0 to ALMOST_EMPTY). [Default: 0.1]
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
    `define FIFO_MERGE_ASYNC_RESET or negedge rst
`else
    `define FIFO_MERGE_ASYNC_RESET
`endif

`include "./modules/FIFO_BRAM_SYNC.vh"

module FIFO_MERGE #(
                    parameter FIFO_COUNT   = 5,
                    parameter ALMOST_FULL  = 0.9,
                    parameter ALMOST_EMPTY = 0.1
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

    localparam DATA_WIDTH = `FIFO_BRAM_8; // FIFO DATA size

    wire [(FIFO_COUNT-1):0]wr_dv_w, wr_full_w, wr_almost_full_w;   // All the WRITE related signals from the FIFOs
    wire [(FIFO_COUNT-1):0]rd_en_w, rd_empty_w, rd_almost_empty_w; // All the READ related signals from the FIFOs

    wire [(DATA_WIDTH-1):0]DATA_out_w[0:(FIFO_COUNT-1)]; // All the DATA output signals from each FIFO

    reg [(FIFO_COUNT-1):0]wr_full_r, wr_almost_full_r;   // Buffer for the status WRITE signals
    reg [(FIFO_COUNT-1):0]rd_empty_r, rd_almost_empty_r; // Buffer for the status READ signals

    always @(posedge clk `FIFO_MERGE_ASYNC_RESET) begin
        if(!rst) begin
            wr_full_r <= 0;
            wr_almost_full_r <= 0;
            rd_empty_r <= 0;
            rd_almost_empty_r <= 0;
        end
        else begin
            wr_full_r <= wr_full_w;
            wr_almost_full_r <= wr_almost_full_w;
            rd_empty_r <= rd_empty_w;
            rd_almost_empty_r <= rd_almost_empty_w;
        end
    end

    assign wr_full = wr_full_w[FIFO_COUNT-1];               // The FULL signal corresponds to the signal from the LAST FIFO
    assign wr_almost_full = wr_almost_full_w[FIFO_COUNT-1]; // The ALMOST_FULL signal corresponds to the signal from the LAST FIFO

    assign rd_empty = rd_empty_w[0];               // The EMPTY signal corresponds to the signal from the FIRST FIFO
    assign rd_almost_empty = rd_almost_empty_w[0]; // The ALMOST_EMPTY signal corresponds to the signal from the FIRST FIFO

    assign wr_dv_w[0] = wr_dv;
    assign rd_en_w[FIFO_COUNT-1] = rd_en;
    
    // ToDo
    // assign rd_DATA = (!rd_empty_r[2]) ? DATA_out_w[2] :
    //                  (!rd_empty_r[1]) ? DATA_out_w[1] :
    //                  (!rd_empty_r[0]) ? DATA_out_w[0] : DATA_out_w[0];
    assign rd_DATA = (!rd_empty_r[4]) ? DATA_out_w[4] :
                     (!rd_empty_r[3]) ? DATA_out_w[3] :
                     (!rd_empty_r[2]) ? DATA_out_w[2] :
                     (!rd_empty_r[1]) ? DATA_out_w[1] :
                     (!rd_empty_r[0]) ? DATA_out_w[0] : DATA_out_w[0];
    // end of ToDo

    // Generate block that creates a new BRAM_SYNC FIFO each iteration
    genvar i;
    generate
        for(i=0; i<FIFO_COUNT; i=i+1) begin: FIFO_MERGE_GEN
            FIFO_BRAM_SYNC #(.ALMOST_FULL(ALMOST_FULL), .ALMOST_EMPTY(ALMOST_EMPTY))
                    FIFO_m (
                            // System signals
                            .rst(rst), .clk(clk),
                            // Write control signals
                            .wr_dv(wr_dv_w[i]),
                            // Write data signals
                            .wr_DATA(wr_DATA),
                            // Write flags
                            .wr_full(wr_full_w[i]), .wr_almost_full(wr_almost_full_w[i]),
                            // Read control signals
                            .rd_en(rd_en_w[i]),
                            // Read data signals
                            .rd_DATA(DATA_out_w[i]),
                            // Read flags
                            .rd_empty(rd_empty_w[i]), .rd_almost_empty(rd_almost_empty_w[i])
                           );
            if(i!=0) begin
                assign wr_dv_w[i] = wr_full_w[i-1] & wr_dv;
            end
            if(i!=(FIFO_COUNT-1)) begin
                assign rd_en_w[i] = rd_empty_w[i+1] & rd_en;
            end
        end
    endgenerate

    // generate
    //     for(i=(FIFO_COUNT-1); i>=0; i=i-1) begin: FIFO_MERGE_OUT_GEN
    //         if(i==0) assign rd_DATA = (!rd_empty_w[0]) ? DATA_out_w[0] : DATA_out_w[0];
    //         else assign rd_DATA = (!rd_empty_w[i]) ? DATA_out_w[i] : 8'bz;
    //     end
    // endgenerate

endmodule