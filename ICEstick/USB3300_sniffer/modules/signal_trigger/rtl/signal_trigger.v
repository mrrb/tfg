/*
 *
 * signal_trigger module
 * This module generates a pulse in output_signal with the same width that the input clock whenever input_signal is HIGH.
 * input_signal first must be go back to a LOW state to generate again another pulse.
 *
 * Inputs:
 *  - clk. Reference clock.
 *  - input_signal. Signal from which the module generates a pulse.
 *
 * Outputs:
 *  - output_signal. Generated pulse.
 *
 */

`default_nettype none

`ifdef ASYNC_RESET
    `define SIGNAL_TRIGGER_ASYNC_RESET
`else
    `define SIGNAL_TRIGGER_ASYNC_RESET
`endif

module signal_trigger (
                       input  wire clk,
                       input  wire input_signal,
                       output wire output_signal
                      );

    reg [1:0] status_r = 0;

    assign output_signal = (status_r == 2'b01) ? 1'b1 : 1'b0;

    always @(posedge clk) begin
        status_r <= {status_r[0], input_signal};
    end

endmodule