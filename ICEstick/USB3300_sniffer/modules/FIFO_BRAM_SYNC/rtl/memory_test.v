module memory #(
                parameter DATA_WIDTH = 8,
                parameter MEM_SIZE   = 512
               )
               (
                input  wire clk,
                input  wire BRAM_WE,
                input  wire [($clog2(MEM_SIZE)-1):0]BRAM_ADDR_wr,
                input  wire [(DATA_WIDTH-1):0]BRAM_DATA_wr,
                input  wire BRAM_RE,
                input  wire [($clog2(MEM_SIZE)-1):0]BRAM_ADDR_rd,
                output wire [(DATA_WIDTH-1):0]BRAM_DATA_rd
               );

    reg [(DATA_WIDTH-1):0]BRAM[0:(MEM_SIZE-1)];
    reg [(DATA_WIDTH-1):0]BRAM_read = 0;

    assign BRAM_DATA_rd = BRAM_read;
    always @(posedge clk) begin
        if(BRAM_WE) BRAM[BRAM_ADDR_wr] <= BRAM_DATA_wr;
        if(BRAM_RE) BRAM_read <= BRAM[BRAM_ADDR_rd];
    end

endmodule