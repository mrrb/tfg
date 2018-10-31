/*
 *
 * clk_div_gen module
 * This module generates a slower frequency signal, given a divider value
 * clk_out_freq = clk_in_freq / (2^divider)
 *
 */

`default_nettype none

module clk_div_gen #(
                     parameter DIVIDER = 9
                    )
                    (
                     input  wire clk,       // Reference clock
                     input  wire enable,    // Enable pin (Active HIGH)
                     output wire new_clk,   // Slower generated clock
                     output wire clk_pulse  // Pulse w/ the double width that the reference clock that occurs once every time the new clock is HIGH 
                    );

    // Main clock gen
    reg  [DIVIDER-1:0]new_clk_r = {DIVIDER{1'b0}};
    assign new_clk = (enable == 1'b1) ? new_clk_r[DIVIDER-1] : 1'b0;

    always @(posedge clk) begin
        if(enable) begin
            new_clk_r <= new_clk_r + 1;
        end
        else begin
            new_clk_r <= {DIVIDER{1'b0}}; // If the module is disable, the output clock is keeped HIGH
        end
    end

    // Pulse gen
    reg baud_last_r    = 1'b0;
    reg baud_posedge_r = 1'b0;

    always @(posedge clk) begin
        if(enable) baud_last_r <= new_clk;

        baud_posedge_r <= !baud_last_r & new_clk;
    end

    assign clk_pulse = baud_posedge_r;

endmodule