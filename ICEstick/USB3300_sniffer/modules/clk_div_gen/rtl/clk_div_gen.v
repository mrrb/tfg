/*
 *
 */


module clk_div_gen #(
                     parameter DIVIDER = 9
                    )
                    (
                     input  wire clk,
                     input  wire enable,
                     output wire new_clk,
                     output wire clk_pulse
                    );

    // Main clock gen
    reg  [DIVIDER-1:0]new_clk_r = {DIVIDER{1'b0}};
    assign new_clk = (enable == 1'b1) ? new_clk_r[DIVIDER-1] : 1'b0;
    always @(posedge clk) begin
        if(enable) begin
            new_clk_r <= new_clk_r + 1;
        end
        else begin
            new_clk_r <= {DIVIDER{1'b1}};
        end
    end

    // Pulse gen
    reg baud_last_r    = 1'b0;
    reg baud_posedge_r = 1'b0;
    always @(posedge clk) begin
        baud_posedge_r  <= !baud_last_r & new_clk;
    end
    always @(posedge clk) begin
        if(enable)
            baud_last_r <= new_clk;
    end
    assign clk_pulse = baud_posedge_r;

endmodule