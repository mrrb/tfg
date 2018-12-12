// Code from https://github.com/YosysHQ/arachne-pnr/issues/24#issuecomment-217298163

module top1 (
        input  clk,
        output LED1, LED2, LED3, LED4,
        inout LED5
);
        localparam LOG2DELAY = 22;
        reg [LOG2DELAY-1:0] counter = 0;
        reg [1:0] outcnt = 0;
        reg dummy;

        always@(posedge clk) begin
                if (counter == 0) begin
                        case (outcnt)
                          2'b00: outcnt <= 2'b01;
                          2'b01: outcnt <= 2'b10;
                          default: outcnt <= 2'b00;
                        endcase
                end
                counter <= counter + 1;
        end

        assign LED1 = dummy;

        SB_IO #(
          .PIN_TYPE(6'b 1010_01),
          .PULLUP(1'b 0)
        ) led_io (
          .PACKAGE_PIN(LED5),
          .OUTPUT_ENABLE(outcnt[0]),
          .D_OUT_0(outcnt[1]),
          .D_IN_0(dummy)
        );
endmodule


// Code from https://github.com/YosysHQ/arachne-pnr/issues/24#issue-130534876

module top2_no_SB_IO(input din, en, output dout, inout io);
  assign io = en ? din : 1'bz, dout = io;
endmodule

module top2(input din, en, output dout, inout io);
  SB_IO #(
    .PIN_TYPE(6'b 1010_01),
    .PULLUP(1'b 0)
  ) iobuf (
    .PACKAGE_PIN(io),
    .OUTPUT_ENABLE(en),
    .D_OUT_0(din),
    .D_IN_0(dout)
  );
endmodule