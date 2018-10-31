/*
 *
 * Test bench for the mux module
 * Execute "make gtk" to view the results
 * 
 */

module mux_tb();

    localparam n = 2;

    // Wires and registers
    reg [2**n-1:0]ch = {2**n{1'b0}};
    reg [n-1:0]sel   = {n{1'b0}};

    wire out;

    // Module under Test init
    mux mux (ch, sel, out);

    initial begin
        $dumpfile("sim/mux_tb.vcd");
        $dumpvars(0, mux_tb);

        $monitor("sel=%2b, out=%1b", sel, out);

        ch  = 4'b1001;
        sel = 0;

        #1
        sel = 1;
        
        #1
        sel = 2;
        
        #1
        sel = 3;
       
        #5  $finish;
    end

endmodule