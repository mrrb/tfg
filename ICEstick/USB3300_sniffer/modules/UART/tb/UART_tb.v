module UART_tb();
   
    // Registers and wires
    reg  [7:0]data = 8'b0;
    reg  clk = 1'b0;
    reg  send_data = 1'b0;
    wire Tx;
    wire Rx;
    wire TiP;
    wire NrD;
    wire [7:0]O_DATA;

    wire ctrl;
    UART #(.BAUD_DIVIDER(1)) U1 (Rx, clk, data, send_data, Tx, TiP, NrD, O_DATA, ctrl);

    // Clock
    always #1 clk = ~clk;

    //
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