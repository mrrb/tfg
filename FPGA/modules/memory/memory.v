// Modulo de memoria.
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
    - ERR    (Error)[1]:            Error detected.
    - SVO    (Shift Value Old)[1>wire]:
    - DEBUG  (DEBUG)[1>wire]:

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
    3. Put PR input HIGH to obtain the values wanted on the DATA bus, once you have finished, put LOW the input again to free the bus.

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

// Not valid > NOT SUPPORTED IN YOSYS!
// Only return 1 if the 2 first imputs are HIGH and the others LOW
// primitive func_selector (output OUT, input I1, input I2, input I3, input I4);
//   table
//     1 1 0 0 : 1;
//     0 ? ? ? : 0;
//     1 0 ? ? : 0;
//   endtable
// endprimitive

module memory #(parameter Addr_width = 2,
                parameter Data_width = 8)
               (input  wire CS,
                input  wire PW,
                input  wire PR,
                input  wire PS,
                input  wire SD,
                input  wire SV,
                input  wire [Addr_width-1:0]ADDR,
                output wire ERR,
                inout  wire [Data_width-1:0]DATA);


  // Initial status
  reg [Data_width-1:0] memory [(2**Addr_width)-1:0]; // Memory block

  // Control logic
  wire S, R, W;
  assign S = (CS & ~PW) & (~PR & PS);
  assign R = (CS & ~PW) & (PR & ~PS);
  assign W = (CS & PW)  & (~PR & ~PS);


  // Memory Read
  // Not Valid > Tri-states gates support limited with Yosys
  // assign DATA = R?memory[ADDR]:8'bZZZZZZZZ;
  reg [Data_width-1:0] ctrl_read = {Data_width{1'bz}};
  assign DATA = R?memory[ADDR]:ctrl_read;

  // Memory Write
  always @ ( posedge W ) begin
    memory[ADDR] <= DATA;
  end

  // Memory Shift
  // ToDo
  reg [Data_width-1:0] current_data = {Data_width{1'bz}};
  always @ ( posedge S ) begin
    if(SD == 1) begin
      memory[ADDR] <= (memory[ADDR]>>1)+{SV, {(Data_width-1){1'b0}}};
    end
    else begin
      memory[ADDR] <= (memory[ADDR]<<1)+SV;
    end
  end

  // Error BIT
  // ToDo


endmodule
