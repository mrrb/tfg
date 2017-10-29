// Modulo de memoria RAM
// Mario Rubio.

// Little-endian [N:0] or Big-endian [0:N]??
// Add address reg??
// Change RAM to memory block w/ shifts and RAM utils
//
/*
  Inputs:
    - CS   (Chip Select)[1>wire]:         Enable access to memory module.
    - PW   (Perform Write)[1>wire]:       On Posedge, perform a memory write.
    - PR   (Perform Read)[1>wire]:        On Posedge, perform a memory read.
    - PS   (Perform Shift)[1>wire]:       On Posedge, perform a memory shift.
    - SD   (Shift Direction)[1>wire]:     Control the direction of the memory shift.
    - SV   (Shift Value)[1>wire]:         Value to add when the shift is done.
    - ADDR (Address Bus)[Addr_size>wire]: Contain the memory address.

  Outputs:
    - ERR  (Error)[1]:            Error detected.
    - SVO  (Shift Value Old)[1>wire]:

  Inouts:
    - DATA (Data Bus)[Mem_size]: IN/OUT of data.

  Parameters:
    - Addr_width:  Size of the address Bus (Address Width).
    - Data_width:  Size of the memory (Data Width).
*/
/*
  Read
    1. Put CS input HIGH.
    2. Select the memory position with the address bus.
    3. Put PR input HIGH to obtain the values wanted on the DATA bus, once you have finished, put the LOW the input again to free the bus.

  Write
    1. Put CS input HIGH.
    2. Select the memory position with the address bus.
    3. Use the DATA bus to save the data wanted.
    4. Put PW input HIGH to save the data in the memory, once you have finished, put the LOW the input again to free the bus.

  Shift
    1. Put CS input HIGH.
    2. Select the memory position with the address bus.
    3. Select the direction of the shift with the SD input (HIGH > Right, LOW > Left).
    4. Pulse PS input to perform a Shift action, the deleted BIT will be outputted on the SVO pin.
*/
module memory #(parameter Addr_width = 8,
                parameter Data_width = 8)
               (input wire CS,
                input wire PW,
                input wire PR,
                input wire PS,
                input wire SD,
                input wire [Addr_width-1:0]ADDR,
                output wire ERR,
                inout wire [Data_width-1:0]DATA);

  // Control logic
  wire S, R, W;
  assign S = (CS & ~PW) & (~PR & PS);
  assign R = (CS & ~PW) & (PR & ~PS);
  assign W = (CS & PW) & (~PR & ~PS);

  // Memory Read
  // ToDo

  // Memory Write
  // ToDo

  // Memory Shift
  // ToDo

  // Initial status
  // ToDo
  initial begin

  end

endmodule
