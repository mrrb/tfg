module clk_pulse_tb();

    // Wires and registers
    reg clk_fast = 1'b0;
    reg clk_slow = 1'b0;

    wire clk_pulse;

    // Module Init
    clk_pulse pulse (clk_fast, clk_slow, clk_pulse);

    // CLK gen
    always #3  clk_fast <= ~clk_fast;
    always #10 clk_slow <= ~clk_slow;

    initial begin
        $dumpfile("sim/clk_pulse_tb.vcd");
        $dumpvars(0, clk_pulse_tb);


        #500  $finish;
    end

endmodule