module test();

    // Registers and wires
    reg CPOL = 1'b0;
    reg CPHA = 1'b0;
    reg clk  = 1'b0;
    reg SS   = 1'b1;

    wire clk_pre; assign clk_pre = CPOL ? !clk : clk;
    wire clk_new; assign clk_new = SS   ? CPOL : (CPHA ? !clk_pre : clk_pre);

    // CLK gen
    always #1  clk <= ~clk;

    // Simulation
    initial begin
        $dumpfile("sim/test.vcd");
        $dumpvars(0, test);

        #16 SS = 0; CPOL = 0; CPHA = 0;
        #16 SS = 1;
        #16 SS = 0; CPOL = 0; CPHA = 1;
        #16 SS = 1;
        #15 SS = 0; CPOL = 1; CPHA = 0;
        #16 SS = 1;
        #16 SS = 0; CPOL = 1; CPHA = 1;
        #16 SS = 1;
        
        #0 $finish;
    end


endmodule