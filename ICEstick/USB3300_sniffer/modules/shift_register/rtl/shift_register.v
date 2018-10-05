/*
 *
 * shift_register module
 * This modules creates a Shift Register with parallel data input capabilities.
 * 
 * To use the parallel input, the signals 'enable' and 'PARALLEL_EN' must be HIGH.
 * To use the module like a normal Shift Register, 'enable' must be HIGH and 'PARALLEL_EN' LOW.
 * All the operations occour in the rising edge of the clock.
 *
 */

module shift_register #(
                        parameter bits = 8 
                       )
                       (
                        // System signals
                        input  wire clk, // Master clock signal

                        // Shift register signals
                        input  wire enable,  // The shift register only works when this signal is HIGH
                        input  wire bit_in,  // New bit to store in the register
                        output wire bit_out, // Overflow bit
                        output wire [(bits - 1):0]DATA_out, // Data stored in the register

                        // Parallel input
                        input  wire [(bits - 1):0]DATA_in,  // Data input
                        input  wire PARALLEL_EN // Parallel enable signal. When this signal is HIGH, the data in DATA_in is stored in the register.
                       );

    // Main register
    reg [(bits - 1):0]DATA = {bits{1'b0}};
    assign DATA_out = DATA;

    // Overflow bit
    reg bit_out_r = 1'b0;
    assign bit_out = bit_out_r;

    // Main controller
    always @(posedge clk) begin
        if(enable) begin
            if(PARALLEL_EN) DATA <= DATA_in;
            else begin
                bit_out_r <= DATA[0];
                DATA <= {bit_in, DATA[(bits - 1):1]};
            end
        end
    end

endmodule