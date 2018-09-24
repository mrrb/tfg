/*
 *
 */


module mux #(
             parameter n_bits  = 2 // Bits of the multiplexer
            )
            (
             input  wire [0:2**n_bits-1]ch,  // Input channels (2^n_bits)
             input  wire [n_bits-1:0]sel,    // Selecction input (n_bits)
             output wire out                 // Mux output
            );

    assign out = ch[sel];

endmodule