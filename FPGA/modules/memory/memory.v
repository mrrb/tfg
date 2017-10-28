// Modulo de memoria RAM
// Mario Rubio.

// Little-endian [N:0] or Big-endian [0:N]??
// Change RAM to memory block w/ shifts and RAM utils
//
/*
  Input:
    - CS (Chip Select):    Enable access to memory module.
    - WE (Write Enable):   Write DATA to the memory.
    - SE (Shift Enable):   Enable shift data
    - SC (Shift Control):  Control Shift direction Right or Left.
    - SC (Signal Control): Control witch signal is use for perform task

  Output:
    - LS (Last Shifted value): Return the value of the last
    -

  Inout:
    - Data: register of N bits to store transient data (Mem > Bus OR Bus > Mem).

  parameters:
    -
    -

  Inputs:
    - CS (Chip Select): Enable access to memory module.
    - WE (Write Enable):
    - RE (Read Enable):
    - SE (Shift Enable):
    - SD (Shift Direction):
    - ADDR (Addr)

  Outputs:

  Inouts:

  Parameters:
*/

module ram #(parameter addrs = 4,
             parameter block_size = 8)
            (inout [size-1:0]data,
             input clk);

endmodule
