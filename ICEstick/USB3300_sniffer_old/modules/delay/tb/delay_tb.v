/*
 *
 * Test bench for the delay module
 * Execute "make gtk" to view the results
 * 
 */

module delay_tb();

    // Wires and registers
    reg  d_in = 1'b0;
    reg  clk  = 1'b1;
    wire d_out;

    // Module under test init
    delay del (clk, d_in, d_out);

    // Clock gen
    always #1 clk = ~clk;

    initial begin
        $dumpfile("sim/delay_tb.vcd");
        $dumpvars(0, delay_tb);

        #2 d_in = 1;
        #4 d_in = 0;
        #2 d_in = 1;
        #2 d_in = 0;
        #2 d_in = 1;
        #2 d_in = 0;
        #2 d_in = 1;
        #4 d_in = 0;
        #4 d_in = 1;

        #10 $finish;
    end

endmodule