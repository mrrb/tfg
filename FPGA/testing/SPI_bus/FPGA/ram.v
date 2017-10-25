// Modulo de memoria RAM
// Mario Rubio.

module ram #(parameter size = 16, parameter block_size = 8)
            (inout [size-1:0]data,
             input clk);

  // Memory Init
  reg [size-1:0]memory[block_size-1:0];



endmodule
