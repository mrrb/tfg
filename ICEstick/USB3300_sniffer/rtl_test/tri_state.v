`default_nettype none

 module USB3300_sniffer (
                         // System signals
                         input  wire clk_ice,        // 12MHz clock located in the ICEstick board

                         // Test signals
                         input  wire input1,
                         input  wire input2,
                         output wire output1,
                         output wire output2,
                         inout  wire inout1
                        );

    // Yosys is warning "Warning: Yosys has only limited support for tri-state logic at the moment."
    // After doing this test that simulates the same scenario that in the real project, everything works as expected, but...
    // 

    assign inout1 = (input1) ? 1'bz : input2;

    assign output1 = inout1;

    reg inout1_reg = 0;
    assign output2 = inout1_reg;

    always @(posedge clk_ice) begin
        if(input1)
            inout1_reg <= inout1;
    end

endmodule