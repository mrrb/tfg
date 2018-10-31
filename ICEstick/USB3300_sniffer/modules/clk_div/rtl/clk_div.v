/*
 *
 * clk_div module
 * This module generates a pulse with a frequency proporcional to COUNTER_VAL and a pulse width equal to a clk_in cycle
 *
 * Parameters:
 *  - DIVIDER. Times the reference clock is divided. f_clk_out = f_clk_in / (2^DIVIDER)
 *
 * Inputs:
 *  - enable. When HIGH, the module will generate the output clock and pulse, otherwise, both outputs will be LOW and the counter register reset.
 *  - clk_in. Reference clock from which the output clock is generated.
 *
 * Outputs:
 *  - clk_out. A signal of the desired divided frequency. f_clk_out = f_clk_in / (2^DIVIDER)
 *  - clk_pulse. Signal with the same frequency that clk_out and the same width that a clk_in cycle
 *
 */

`default_nettype none

module clk_div #(
                 parameter DIVIDER = 5  // Optimal counter value 
                )
                (
                 // Clock signals
                 input  wire clk_in,    // Reference clock input
                 output wire clk_out,   // Generated clock 
                 output wire clk_pulse, // Pulse with the same frequency that clk_out and the same width that a clk_in cycle

                 // Control signals
                 input  wire enable     // Module enable signal
                );

    /// Counter register
    reg [DIVIDER-1:0]clk_div_r = {DIVIDER{1'b0}};
    /// End of Counter register

    /// Assigns
    reg clk_out_r;
    reg clk_pulse_r;
    // assign clk_out = (enable) ? clk_div_r[DIVIDER-1] : 1'b0;
    // assign clk_pulse = (clk_div_r == {1'b1,{(DIVIDER-1){1'b0}}}) ? 1'b1 : 1'b0;
    always @(*) begin
        if(enable) clk_out_r = clk_div_r[DIVIDER-1];
        else clk_out_r = 1'b0;
    end
    always @(*) begin
        if(clk_div_r == {1'b1,{(DIVIDER-1){1'b0}}}) clk_pulse_r = 1'b1;
        else clk_pulse_r = 1'b0;
    end
    /// End of Assigns

    /// Controller
    always @(posedge clk_in) begin
        if(!enable) clk_div_r <= {1'b0,{(DIVIDER-1){1'b1}}};
        else clk_div_r <= clk_div_r + 1'b1;
    end
    /// End of Controller

endmodule