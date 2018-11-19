module SB_RAM40_4K #(
                     parameter WRITE_MODE = 1,
                     parameter READ_MODE  = 1
                    )
                    (

                     input  wire [15:0]WDATA,
                     input  wire [10:0]WADDR,
                     input  wire WE,
                     input  wire WCLK,
                     input  wire WCLKE,

                     output wire [15:0]RDATA,
                     input  wire [10:0]RADDR,
                     input  wire RE,
                     input  wire RCLK,
                     input  wire RCLKE
                    );

    wire [7:0]WDATA_t, RDATA_t;
    assign WDATA_t = WDATA[7:0];
    assign RDATA   = {8'b0, RDATA_t};

    wire [8:0]WADDR_t, RADDR_t;
    assign WADDR_t = WADDR[8:0];
    assign RADDR_t = RADDR[8:0];

    reg [7:0]DATA_out;
    assign RDATA_t = DATA_out;

    reg [7:0]DATA_r[0:511];

    reg ctrl = 0;
    integer i;
    always@(posedge WCLK or posedge RCLK) begin
        if (!ctrl) begin
            ctrl = 1;
            for (i=0; i<512; i=i+1) DATA_r[i] <= 0;
        end
    end

    always @(posedge WCLK) begin
        if(WE && WCLKE) DATA_r[WADDR_t] <= WDATA_t;
    end

    always @(posedge RCLK) begin
        if(RE && RCLKE) DATA_out <= DATA_r[RADDR_t];
    end

endmodule