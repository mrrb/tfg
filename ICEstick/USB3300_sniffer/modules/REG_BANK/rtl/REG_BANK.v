/*
 *
 */


module REG_BANK #(parameter ADDR_BITS = 4, // Width of the addresses of the register bank
                  parameter DATA_BITS = 8  // Width of the data of the register bank
                 )
                 (
                  input  wire clk, // Master clock
                  input  wire WD,  // "Write Data" control input. When high, the data in DATA_in will be saved in the bank.
                  input  wire [(2**ADDR_BITS - 1):0] ADDR,     // Address where the data have to be save/read
                  input  wire [(DATA_BITS - 1):0] DATA_in,  // Data to be save in the bank
                  output wire [(DATA_BITS - 1):0] DATA_out  // Data read from the bank
                 );


    // Main register
    reg [(DATA_BITS - 1):0] bank_r [(2**ADDR_BITS - 1):0];

    // Output Data
    assign DATA_out = bank_r[ADDR];

    // Controller
    always @(posedge clk) begin
        if(WD) begin
            bank_r[ADDR] <= DATA_in;
        end
    end


endmodule