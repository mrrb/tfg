/*
 *
 * clk_pulse module
 * This module generates a pulse once every period of the slower clock. The pulse occurs at the same time that both clocks are HIGH.
 *
 */


module clk_pulse (
                  input  wire clk_fast,   // Faster clock input
                  input  wire clk_slow,   // Slower clock input
                  input  wire firts_edge, // Detect rising edge (firts_edge=0) or falling edge (firts_edge=1)
                  output wire clk_pulse   // Output pulse
                 );

    wire clk_slow_ctrl;
    assign clk_slow_ctrl = firts_edge ? !clk_slow : clk_slow;

    reg clk_slow_done_r = 1'b0;

    assign clk_pulse = clk_fast && clk_slow_ctrl && !clk_slow_done_r;

    always @(negedge clk_fast) begin
        if(clk_pulse) clk_slow_done_r = 1'b1;
        else if(!clk_slow_ctrl) clk_slow_done_r = 1'b0;    
    end

endmodule