/*
 *
 * Test bench for the UART module
 * Execute "make gtk" to view the results
 * 
 */

module UART_tb();
   
    // Registers and wires
    reg  clk       = 1'b0;
    reg  [7:0]data = 8'b0;
    reg  send_data = 1'b0;

    wire ctrl;
    wire Rx;
    wire Tx;
    wire [7:0]O_DATA;
    wire TiP;
    wire NrD;

    // Module under test init
    UART #(.BAUD_DIVIDER(2)) U1 (.clk(clk), .clk_baud(ctrl),                    // System signals
                                 .Rx(Rx), .Tx(Tx),                              // UART signals
                                 .I_DATA(data), .O_DATA(O_DATA),                // Data signals
                                 .send_data(send_data), .TiP(TiP), .NrD(NrD));  // Control signals

    // Clock gen
    always #1 clk = ~clk;

    // Simulation
    initial begin
        $dumpfile("sim/UART_tb.vcd");
        $dumpvars(0, UART_tb);

        $monitor("data=%8b send_data=%1b Tx=%1b TiP=%1b",data, send_data, Tx, TiP);
        #2
        #2   data = 8'b01010101; send_data =1'b1;
        #2   send_data =1'b0;

        #100 $display("End!"); $finish;
    end

endmodule