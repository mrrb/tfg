// Modulo de captura de BUS SPI
// Mario Rubio.

module SPI_bus #(parameter frame_len = 8)
               (input wire sclk,
                input wire MISO,
                input wire MOSI,
                input wire SS,
                input wire clk_12);

  // -- Parameters --
  // frame_len => Length of the captured frame

  // -- Registers --
  // End-of-frame register
  reg frame_end = 0;

  // Memory Block
  

endmodule
