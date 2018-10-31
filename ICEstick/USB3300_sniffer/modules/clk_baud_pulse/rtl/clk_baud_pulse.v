/*
 *
 * clk_baud_pulse module
 * This module generates a pulse with a frequency proporcional to COUNTER_VAL and a pulse width equal to a clk_in cycle
 *
 * Parameters:
 *  - COUNTER_VAL. Optimal counter value to generate the requested pulse.
 *  - PULSE_DELAY. Number of clk_in cycles to wait before performing the pulse.
 *
 * Inputs:
 *  - enable. When HIGH, the module will generate the output pulse, otherwise, clk_pulse will be driven LOW and the counter register reset.
 *  - clk_in. Reference clock from which the output clock is generated.
 *
 * Outputs:
 *  - clk_pulse. Pulse generated at the desired baud rate.
 *
 */

`default_nettype none

`include "./rtl/bauds.vh"

module clk_baud_pulse #(
                        parameter COUNTER_VAL = `B115200, // Optimal counter value 
                        parameter PULSE_DELAY = 0         // Pulse delay
                       )
                       (
                        // Clock signals
                        input  wire clk_in,    // Reference clock input
                        output wire clk_pulse, // Pulse with the same frequency that clk_out and the same width that clk_in

                        // Control signals
                        input  wire enable     // Pulse generated at the desired frequency
                       );

    localparam DIVIDER = $clog2(COUNTER_VAL);

    /// Counter register
    reg [DIVIDER-1:0]clk_div_r = {DIVIDER{1'b0}};
    /// End of Counter register

    /// Assigns
    assign clk_pulse = ((clk_div_r == PULSE_DELAY) && enable) ? 1'b1 : 1'b0;
    /// End of Assigns

    /// Controller
    always @(posedge clk_in) begin
        if(!enable) clk_div_r <= COUNTER_VAL-1;
        else clk_div_r <= (clk_div_r == COUNTER_VAL-1) ? {DIVIDER{1'b0}} : clk_div_r + 1'b1;
    end
    /// End of Controller

endmodule