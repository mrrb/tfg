// Modulo de comunicación SPI.
// Mario Rubio. 2017.

/*
  Inputs:
    - clk_in [1>wire]
    - MISO (Master Out Slave In)[1>wire]
    - PC   (Perform Communication)[1>wire]: on posedge, the
    - DATA_out [frame_length_MOSI>reg]

  Outputs:
    - SCLK [1>wire]: clk signal for the communication
    - MOSI (Master In Slave Out)[1>wire]
    - DATA_in [frame_length_MISO>wire]

  Inouts:

  Parameters:
    - frame_length_MOSI:  Bits to send in the MOSI output.
    - frame_length_MISO:  Bits to receive in the MISO input.
    - clk_prescaler
*/

`include "../../../memory/memory.v"

module master #(parameter frame_length_MOSI = 4,
                parameter frame_length_MISO = 4,
                parameter clk_prescaler     = 4)
               (input wire clk_in,
                input wire MISO,
                output wire SCLK,
                output wire MOSI);

  // Clock init
  // ToDo

  //
// genvar
endmodule
