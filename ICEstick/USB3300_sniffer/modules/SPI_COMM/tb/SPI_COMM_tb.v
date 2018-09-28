`include "modules/shift_register/rtl/shift_register.v"
`include "modules/clk_pulse/rtl/clk_pulse.v"

module SPI_COMM_tb ();

    // Registers and wires
    reg clk_fast = 1'b0;    
    reg clk_slow = 1'b0;
    reg SS_r = 1'b1;
    reg MOSI_r = 1'b0;
    reg data_out_latched_r = 1'b0;
    reg [7:0]DATA_in_r = 8'b0;

    wire [7:0]DATA_out_w;
    wire MISO_w;
    wire EoB_w;
    wire [2:0]status_w;
    wire err_w;
    wire data_in_latched_w;

    wire trans_flag; assign trans_flag = (status_w == 2) ? 1'b1 : 1'b0;

    // Module Init
    SPI_COMM spi (.clk(clk_fast), .rst(1'b0), .SCLK(clk_slow && trans_flag), .SS(SS_r), .MOSI(MOSI_r), .MISO(MISO_w), .DATA_in(DATA_in_r), .data_out_latched(data_out_latched_r), .DATA_out(DATA_out_w), .data_in_latched(data_in_latched_w), .err(err_w), .EoB(EoB_w), .status(status_w));

    // CLK gen
    always #3  clk_fast <= ~clk_fast;
    always #10 clk_slow <= ~clk_slow;

    // Simulation
    initial begin
        $dumpfile("sim/SPI_COMM_tb.vcd");
        $dumpvars(0, SPI_COMM_tb);

        #5

        SS_r = 0;
        DATA_in_r = 8'hAA;
        
        #0  MOSI_r = 0;
        #20
        #20
        #20
        #20
        #20 MOSI_r = 1;
        #20 MOSI_r = 1;
        #20 MOSI_r = 0;


        #180

        SS_r = 1;

        
        #100 $finish;
    end


endmodule
