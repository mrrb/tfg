`default_nettype none

`include "./modules/clk_div.vh"

module btns_test (
                  input  wire clk,
                  input  wire [1:0]IO_BTNs,
                  output wire [4:0]IO_LEDs
                 );

    assign IO_LEDs[0] = buff[0];
    assign IO_LEDs[1] = buff[1];
    assign IO_LEDs[2] = clk_div_ice;
    assign IO_LEDs[3] = 1'b1;
    assign IO_LEDs[4] = 0;


    reg [1:0] buff = 0;
    always @(posedge clk) begin
        if(IO_BTNs[0])
            buff[0] = 1;
        else
            buff[0] = 0;
    end

    always @(posedge clk) begin
        if(IO_BTNs[1])
            buff[1] = 1;
        else
            buff[1] = 0;
    end

    wire clk_div_ice, clk_div_ice_pulse;
    clk_div       #(.DIVIDER(24))
    clk_div_ice_m  (
                    // Clock signals
                    .clk_in(clk),                  // [Input]
                    .clk_out(clk_div_ice),         // [Output]
                    .clk_pulse(clk_div_ice_pulse), // [Output]

                    // Control signals
                    .enable(1'b1)                  // [Input]
                   );

endmodule
