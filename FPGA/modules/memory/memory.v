// Modulo de memoria RAM
// Mario Rubio.

// Little-endian [N:0] or Big-endian [0:N]??
// Add address reg??
// Change RAM to memory block w/ shifts and RAM utils
//
/*
  Inputs:
    - CS   (Chip Select)[1]:         Enable access to memory module.
    - PW   (Perform Write)[1]:       On Posedge, perform a memory write.
    - PR   (Perform Read)[1]:        On Posedge, perform a memory read.
    - PS   (Perform Shift)[1]:       On Posedge, perform a memory shift.
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

module ram #(parameter Addr_size = 3,
             parameter Mem_size = 3)
            ();

  initial begin
    $display("%0d %0d", $clog(3), $clog10(3));
    #1 $finish;
  end
endmodule
