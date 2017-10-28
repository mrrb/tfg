// Modulo de memoria RAM
// Mario Rubio.

// Little-endian [N:0] or Big-endian [0:N]??
// Add address reg??
// Change RAM to memory block w/ shifts and RAM utils
//
/*
  Inputs:
    - CS   (Chip Select)[1]:         Enable access to memory module.
    - WE   (Write Enable)[1]:        On Posedge, perform a memory write.
    - RE   (Read Enable)[1]:         On Posedge, perform a memory read.
    - SE   (Shift Enable)[1]:        On Posedge, perform a memory shift.
    - SD   (Shift Direction)[1]:     Control the direction of the memory shift.
    - ADDR (Address Bus)[Addr_size]: Contain the memory address.

  Outputs:
    - ERR  (Error)[1]: Error detected.

  Inouts:
    - DATA (Data Bus)[Mem_size]: IN/OUT of data.

  Parameters:
    - Addr_size: Size of the address Bus.
    - Mem_size:  Size of the memory.
*/

module ram #(parameter addrs = 4,
             parameter block_size = 8)
            (inout [size-1:0]data,
             input clk);

endmodule
