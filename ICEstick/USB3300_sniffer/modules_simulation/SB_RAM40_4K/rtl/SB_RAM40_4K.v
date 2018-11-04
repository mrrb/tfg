module SB_RAM40_4K #(
                     parameter WRITE_MODE = 1,
                     parameter READ_MODE  = 1
                    )
                    (

                     input  wire [7:0]WDATA,
                     input  wire [8:0]WADDR,
                     input  wire WE,
                     input  wire WCLK,
                     input  wire WCLKE,

                     output wire [7:0]RDATA,
                     input  wire [8:0]RADDR,
                     input  wire RE,
                     input  wire RCLK,
                     input  wire RCLKE
                    );

    reg [7:0]DATA_out;
    assign RDATA = DATA_out;

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
        if(WE && WCLKE) DATA_r[WADDR] <= WDATA;
    end

    always @(posedge RCLK) begin
        if(RE && RCLKE) DATA_out <= DATA_r[RADDR];
    end

endmodule