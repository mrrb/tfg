/*
 *
 * UART_Rx module
 * This module let the FPGA receive serial data (Config: 8N1).
 *
 * Parameters:
 *  - BAUDS. Optimal counter value to generate the baud rate clock.
 *
 * Inputs:
 *  - rst. Synchronous reset signal [Active LOW].
 *  - clk. Reference clock.
 *  - Rx. Serial Data input.
 *
 * Outputs:
 *  - clk_Rx. Clock signal at the desired baud rate used to receive the data.
 *            It has a delay equal to a half of BAUDS, so it can read the Rx value properly.
 *  - O_DATA. 8-bits data received.
 *  - NrD. New received Data flag. At the end of every DATA reception, this signal will be HIGH a clk cycle.
 *
 */

`default_nettype none

`include "./rtl/bauds.vh"

`include "./modules/clk_baud_pulse.vh"
`include "./modules/shift_register.vh"

 module UART_Rx #(
                  parameter BAUDS = `B115200
                 )
                 (
                  // System signals
                  input  wire rst,         // Reset signal
                  input  wire clk,         // Reference clock input
                  output wire clk_Rx,      // Generated clock, used to receive the data

                  // UART signals
                  input  wire Rx,          // Serial Data input

                  // Data signals
                  output wire [7:0]O_DATA, // 8-bits data received

                  // Control signals
                  output wire NrD          // New received Data flag
                 );

    /// Reception clock generation
    wire enable;
    assign enable = (Rx_s_RECV) ? 1'b1 : 1'b0;

    clk_baud_pulse #(
                     .COUNTER_VAL(BAUDS),
                     .PULSE_DELAY(BAUDS/2)
                    )
       clk_baud_Rx  (
                     .clk_in(clk),
                     .clk_pulse(clk_Rx),
                     .enable(enable)
                    );
    /// End of Reception clock generation

    /// Shift register init
    wire clk_shift;
    assign clk_shift = (Rx_s_RECV) ? clk_Rx : 1'b0;

    wire bit_in;
    assign bit_in = Rx;
    
    wire [1:0]shift_mode;
    assign shift_mode = (Rx_s_RECV) ? 2'b10 : 2'b00;

    reg [9:0]DATA_in = 10'b0;

    wire bit_out;
    wire [9:0]DATA_out;

    shift_register #(.BITS(10))
          shift_Rx  (
                     .clk(clk_shift),   .rst(rst),         // System signals
                     .bit_in(bit_in),   .bit_out(bit_out), // Serial data
                     .DATA_IN(DATA_in), .DATA(DATA_out),   // Parallel data
                     .mode(shift_mode)                     // Control signals
                    );
    /// End of Shift register init

    /// Rx Regs and wires
    // Outputs
    reg [7:0]O_DATA_r = 8'b0;

    // Control registers
    reg [1:0]Rx_state_r   = 2'b0;
    reg [3:0]Rx_counter_r = 4'b0;

    // Flags
    wire Rx_s_IDLE;
    wire Rx_s_INIT;
    wire Rx_s_RECV;
    wire Rx_s_SAVE;

    // Assigns
    assign Rx_s_IDLE = (Rx_state_r == Rx_IDLE) ? 1'b1 : 1'b0; // #FLAG
    assign Rx_s_INIT = (Rx_state_r == Rx_INIT) ? 1'b1 : 1'b0; // #FLAG
    assign Rx_s_RECV = (Rx_state_r == Rx_RECV) ? 1'b1 : 1'b0; // #FLAG
    assign Rx_s_SAVE = (Rx_state_r == Rx_SAVE) ? 1'b1 : 1'b0; // #FLAG

    assign O_DATA = O_DATA_r;  // #OUTPUT
    assign NrD    = Rx_s_SAVE; // #OUTPUT
    /// End of Rx Regs and wires

    /// Rx States (See module description at the beginning of this file to get more info)
    localparam Rx_IDLE = 2'b00;
    localparam Rx_INIT = 2'b01;
    localparam Rx_RECV = 2'b10;
    localparam Rx_SAVE = 2'b11;
    /// End of Rx

    /// Rx controller
    // States
    always @(posedge clk) begin
        if(!rst) Rx_state_r <= Rx_IDLE;
        else begin
            case(Rx_state_r)
                Rx_IDLE: begin
                    if(!Rx) Rx_state_r <= Rx_INIT;
                    else    Rx_state_r <= Rx_IDLE;
                end
                Rx_INIT: begin
                    Rx_state_r <= Rx_RECV;
                end
                Rx_RECV: begin
                    if(Rx_counter_r == 4'd10) Rx_state_r <= Rx_SAVE;
                    else                      Rx_state_r <= Rx_RECV;
                end
                Rx_SAVE: begin
                    Rx_state_r <= Rx_IDLE;
                end
                default: Rx_state_r <= Rx_IDLE;
            endcase
        end
    end

    always @(posedge clk) begin
        if(!rst) O_DATA_r <= 8'b0;
        else if(Rx_s_SAVE) O_DATA_r <= DATA_out[8:1];
    end

    // Bit counter
    always @(posedge clk) begin
        if(Rx_s_INIT) Rx_counter_r <= 4'b0;
        else if(clk_shift && Rx_s_RECV) Rx_counter_r <= Rx_counter_r + 1'b1;
    end
    /// End of Rx controller

 endmodule