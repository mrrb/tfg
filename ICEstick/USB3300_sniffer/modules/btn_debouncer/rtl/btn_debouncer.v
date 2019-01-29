/*
 *
 * btn_debouncer module
 *
 * Inputs:
 *  - clk. Debouncing reference clock.
 *  - btn_in. Physical button input.
 *
 * Outputs:
 *  - btn_out. Debounce button output.
 *
 */

`default_nettype none

`ifdef ASYNC_RESET
    `define BTN_DEBOUNCER_ASYNC_RESET
`else
    `define BTN_DEBOUNCER_ASYNC_RESET
`endif

module btn_debouncer (
                      // System signals
                      input  wire clk,    // Debouncing reference clock

                      // Button
                      input  wire btn_in, // Physical button input
                      output wire btn_out // Debounce button output
                     );

    assign btn_out = r1 & r2 & r3;

    reg r1, r2, r3;

    always @(posedge clk) begin
        r1 <= btn_in;
        r2 <= r1;
        r3 <= r2;
    end

endmodule