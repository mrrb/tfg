/*
 *
 * Test bench for the shift_register module
 * Execute "make gtk" to view the results
 * 
 */

module shift_register_tb ();


    // Regs and wires
    reg clk = 1'b0;
    reg bit_in = 1'b0;
    reg enable = 1'b0;
    reg par_en = 1'b0;
    reg [7:0]DATA_in = 8'b0;

    wire bit_out;
    wire [7:0]DATA;

    // Module under test init
    shift_register sr (clk, enable, bit_in, bit_out, DATA, DATA_in, par_en);

    // CLK gen
    always #1 clk <= ~clk;

    // Simulation
    initial begin
        $dumpfile("sim/shift_register_tb.vcd");
        $dumpvars(0, shift_register_tb);

        #1 enable = 1;
        #2 bit_in = 1;
        #2 bit_in = 0;
        #2 bit_in = 0;
        #2 bit_in = 1;
        #2 bit_in = 1;
        #2 bit_in = 0;
        #2 bit_in = 1;
        #2 bit_in = 1;

        #2 enable = 0;

        #2 enable = 1;
        #20
        #2 bit_in = 0;
        #20
        #2 enable = 0; DATA_in = 8'b10011100;

        #2 enable = 1; par_en = 1;
        #2 enable = 0; par_en = 0;

        #4
        
        #6 $finish;
    end

endmodule