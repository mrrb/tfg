// Modulo de memoria RAM
// Mario Rubio.

// Little-endian [N:0] or Big-endian [0:N]??
// Change RAM to memory block w/ shifts and RAM utils
//
/*
  Input pins:
    - CS (Chip Select): Enable acces to memory module.
    - R  (Read): Read DATA from the Bus.
    - W  (Write): Write DATA to the bus.
    - SC (Shift Control): Control Shift direction Right Or Left.
    - SE (Shift Enable): Enable

  Output pins:
    -
    -

  Inout pins:
    - Data: register of N bits to store transient data (Mem > Bus OR Bus > Mem).
*/

module ram #(parameter addrs = 4,
             parameter block_size = 8)
            (inout [size-1:0]data,
             input clk);

endmodule
