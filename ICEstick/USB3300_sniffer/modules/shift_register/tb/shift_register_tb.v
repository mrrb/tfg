/*
 *
 * Test bench for the shift_register module
 * Execute "make gtk" to view the results
 * 
 */

`default_nettype none
`timescale 100ns/10ns

module shift_register_tb ();

    /// Regs and wires
    reg rst = 1'b1;
    reg bit_in = 1'b0;
    reg [7:0]DATA_IN = 8'b0;
    reg [1:0]mode = 2'b00;

    wire bit_out;
    wire [7:0]DATA_OUT;
    /// End of Regs and wires

    /// Module under test init
    shift_register #(.BITS(8))
                sr  (
                     .clk(clk), .rst(rst),               // System signals
                     .bit_in(bit_in), .bit_out(bit_out), // Serial data
                     .DATA_IN(DATA_IN), .DATA(DATA_OUT), // Parallel data
                     .mode(mode)                         // Control signals
                    );
    /// End of Module under test init

    /// Clock gen
    reg clk = 1'b0;
    always #0.5 clk = ~clk;
    /// End of Clock gen

    /// Simulation
    initial begin
        $dumpfile("./sim/shift_register_tb.vcd");
        $dumpvars();

        #1 DATA_IN = 8'h00; mode = 2'b11;
        #1 mode = 2'b10; bit_in = 1'b1;
        #4 bit_in = 1'b0;
        #2 bit_in = 1'b1;
        #4 bit_in = 1'b0; mode = 2'b00;

        #1 DATA_IN = 8'hFA; mode = 2'b11;
        #1 mode = 2'b01;
        #12

        #1 DATA_IN = 8'hFA; mode = 2'b11;
        #1 mode = 2'b00;
        #12

        #1 DATA_IN = 8'hFA; mode = 2'b11; rst = 1'b0;
        #1 mode = 2'b00;
        #12

        #1 DATA_IN = 8'hFA; mode = 2'b11; rst = 1'b1;
        #1 mode = 2'b00;
        #12

        #1 DATA_IN = 8'hFA; mode = 2'b11;
        #1 mode = 2'b10;
        #12

        bit_in = 1'b1;

        #1 DATA_IN = 8'hFA; mode = 2'b11;
        #1 mode = 2'b01;
        #12

        #1 DATA_IN = 8'hFA; mode = 2'b11;
        #1 mode = 2'b10;
        #12

        #1 $finish;
    end
    /// End of Simulation

endmodule