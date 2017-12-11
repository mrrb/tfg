// Variaciones del reloj de 12hz
// Mario Rubio.

module clock_changes(input wire clk,
                     output wire clk_out,
                     output wire clk_out2,
                     output wire clk_12);

  assign clk_12 = clk;

  parameter N = 22;
  reg [N-1:0] count = 0;
  assign clk_out = count[N-1];

  always @(posedge(clk)) begin
    count <= count + 1;
  end


  SB_PLL40_CORE #(.FEEDBACK_PATH("SIMPLE"),
                  .PLLOUT_SELECT("GENCLK"),
                  .DIVR(4'b0001),
                  .DIVF(7'b1000010),
                  .DIVQ(3'b100),
                  .FILTER_RANGE(3'b001),)
             uut (.REFERENCECLK(clk),
                  .PLLOUTCORE(clk_out2),
                  .RESETB(1'b1),
                  .BYPASS(1'b0));
endmodule
