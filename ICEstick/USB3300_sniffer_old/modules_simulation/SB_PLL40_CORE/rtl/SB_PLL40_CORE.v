module #(
         parameter FEEDBACK_PATH = "SIMPLE",
         parameter DIVR = 4'b0000,
         parameter DIVF = 7'b1000010,
         parameter DIVQ = 3'b011,
         parameter FILTER_RANGE = 3'b001
        )
        (
         input  wire LOCK,
         input  wire RESETB,
         input  wire BYPASS,
         input  wire REFERENCECLK,
         output wire PLLOUTCORE
        );

    reg clk_pll = 1'b0;
    assign PLLOUTCORE = clk_pll;
    always #10 clk_pll = ~clk_pll;

endmodule