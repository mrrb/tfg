// Modulo de comunicación SPI.
// Mario Rubio. 2017.

/*
  Inputs:
    - clk
    -

  Outputs:

  Inouts:
    -

  Parameters:
    - frame_length
    -
*/

`include "../../../memory/memory.v"

module master #(parameter frame_length  = 8,
                parameter clk_prescaler = 4)
               (input wire clk);

  reg PW = 0;
  wire [frame_length-1:0]DATA;
  memory #(.Addr_width(1),
           .Data_width(frame_length))
          mem
          (.CS(1'b1),
           .PW(PW),
           .PR(1'b0),
           .PS(1'b0),
           .SD(1'b0),
           .SV(1'b0),
           .ADDR(1'b1),
           .DATA(DATA));
// genvar
endmodule
