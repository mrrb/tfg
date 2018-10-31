`include "./modules/clk_div_gen.vh"
`include "./modules/UART.vh"

module UART_sint(
                 input  wire clk,
                 input  wire Rx,
                 output wire Tx,
                 output wire [2:0]test
                );

    wire clk_pulse_w;
    wire clk_time_w;
    clk_div_gen #(.DIVIDER(24))
       time_clk  (.clk(clk), .enable(1'b1), .new_clk(clk_time_w), .clk_pulse(clk_pulse_w));

    wire clk_baud_W;
    wire TiP;
    wire NrD;
    wire [7:0]O_DATA;
    reg  [7:0]I_DATA = 8'b0;
    UART #(.BAUD_DIVIDER(9)) U1 (.rst(1'b1), .clk(clk), .clk_baud(clk_baud_W),   // System signals
                                 .Rx(Rx), .Tx(Tx),                               // UART signals
                                 .I_DATA(I_DATA), .O_DATA(O_DATA),               // Data signals
                                 .send_data(1'b1), .TiP(TiP), .NrD(NrD)); // Control signals

    always @(posedge clk) begin
        I_DATA <= "a";
        // I_DATA <= 8'b00001011;
        // I_DATA <= 8'b11010000;
    end

    assign test[0] = clk_time_w;
    assign test[1] = Tx;
    assign test[2] = TiP;

endmodule