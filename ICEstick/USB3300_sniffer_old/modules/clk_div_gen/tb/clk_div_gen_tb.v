/*
 *
 * Test bench for the clk_div_gen module
 * Execute "make gtk" to view the results
 * 
 */

module clk_div_gen_tb();

    // Wires and registers
    reg clk    = 1'b0;
    reg enable = 1'b0;

    wire clk_out;
    wire clk_pulse;

    // Module Init
    clk_div_gen #(.DIVIDER(4))
        clk_div  (clk, enable, clk_out, clk_pulse);

    // CLK gen
    always #1 clk <= ~clk;

    initial begin
        $dumpfile("sim/clk_div_gen_tb.vcd");
        $dumpvars(0, clk_div_gen_tb);

        #60 enable = 1;
        #600 enable = 0;
        #60 enable = 1;
        #600 enable = 0;

        #0 $finish;
    end

endmodule