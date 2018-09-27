/*
 *
 */


module clk_pulse(
                 input  wire clk_fast,
                 input  wire clk_slow,
                 output wire clk_pulse
                );


    reg clk_slow_done_r = 1'b0;

    assign clk_pulse = clk_fast && clk_slow && !clk_slow_done_r;

    always @(negedge clk_fast) begin
        if(clk_pulse) clk_slow_done_r = 1'b1;
        else if(!clk_slow) clk_slow_done_r = 1'b0;    
    end

endmodule