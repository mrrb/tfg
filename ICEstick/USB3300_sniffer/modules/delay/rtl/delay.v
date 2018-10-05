/*
 *
 * delay module
 * TThis module delay a signal a given number of times
 *
 */


module delay #(
               parameter DELAY_VAL = 2  // Number of delay steps
              )
              (
               input  wire clk,         // Reference clock
               input  wire sig_in,      // Input signal
               output wire sig_out      // Delayed signal
              );

    /// Delay controller
    reg [DELAY_VAL-1+1:0]buffer = {DELAY_VAL+1{1'b0}};

    always @(posedge clk) begin
        buffer <= {sig_in, buffer[DELAY_VAL-1+1:1]};
    end
    
    assign sig_out = buffer[0];
    /// End of Delay controller

endmodule