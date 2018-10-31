/*
 *
 * UART_Tx module
 * This module let the FPGA transfer serial data (Config: 8N1).
 *
 * Parameters:
 *  - BAUDS. Optimal counter value to generate the baud rate clock.
 *
 * Inputs:
 *  - rst. Synchronous reset signal [Active LOW].
 *  - clk. Reference clock.
 *  - I_DATA. 8-bit Data that It's going to be sent.
 *  - send_data. Input signal that starts a serial transfer with the DATA in I_DATA.
 *
 * Outputs:
 *  - clk_Tx. Clock signal at the desired baud rate used to transfer the data.
 *  - Tx. Serial Data output.
 *  - TiP. Signal indicating that the module is transmitting.
 *
 */

`default_nettype none

`include "./rtl/bauds.vh"

`include "./modules/clk_baud_pulse.vh"
`include "./modules/shift_register.vh"

 module UART_Tx #(
                  parameter BAUDS = `B115200
                 )
                 (
                  // System signals
                  input  wire rst,         // Reset signal
                  input  wire clk,         // Reference clock input
                  output wire clk_Tx,      // Generated clock, used to transmit the data

                  // UART signals
                  output wire Tx,          // Serial Data output

                  // Data signals
                  input  wire [7:0]I_DATA, // 8-bits data to send

                  // Control signals
                  input  wire send_data,   // Send the current data in DATA IF there isn't any trasmission in progress
                  output wire TiP          // Trasmission in Progress flag
                 );

    /// Transmission clock generation
    wire enable;
    assign enable = (Tx_s_TRANS) ? 1'b1 : 1'b0;

    clk_baud_pulse #(
                     .COUNTER_VAL(BAUDS),
                     .PULSE_DELAY(0)
                    )
       clk_baud_Tx  (
                     .clk_in(clk),
                     .clk_pulse(clk_Tx),
                     .enable(enable)
                    );
    /// End of Transmission clock generation

    /// Shift register init
    wire clk_shift;
    assign clk_shift = (Tx_s_LOAD) ? clk : clk_Tx;

    wire bit_in;
    assign bit_in = 1'b1;
    
    wire [1:0]shift_mode;
    assign shift_mode = (Tx_s_LOAD) ? 2'b11 : 2'b10;

    reg [10:0]DATA_in = 11'b0;
    // wire [10:0]DATA_in;
    // assign DATA_in = {2'b11, DATA_r, 1'b0};

    wire bit_out;
    wire [10:0]DATA_out;

    shift_register #(.BITS(11))
          shift_Tx  (
                     .clk(clk_shift),   .rst(rst),         // System signals
                     .bit_in(bit_in),   .bit_out(bit_out), // Serial data
                     .DATA_IN(DATA_in), .DATA(DATA_out),   // Parallel data
                     .mode(shift_mode)                     // Control signals
                    );
    /// End of Shift register init

    /// Tx Regs and wires
    // Inputs
    // reg [7:0]DATA_r = 8'b0;
    always @(posedge clk) begin
        if(Tx_s_IDLE && send_data) DATA_in <= {2'b11, I_DATA, 1'b0};
    end

    // Control registers
    reg [1:0]Tx_state_r   = 2'b0;
    reg [3:0]Tx_counter_r = 4'b0;

    // Flags
    wire Tx_s_IDLE;
    wire Tx_s_LOAD;
    wire Tx_s_TRANS;

    // Assigns
    assign Tx_s_IDLE  = (Tx_state_r == Tx_IDLE)  ? 1'b1 : 1'b0; // #FLAG
    assign Tx_s_LOAD  = (Tx_state_r == Tx_LOAD)  ? 1'b1 : 1'b0; // #FLAG
    assign Tx_s_TRANS = (Tx_state_r == Tx_TRANS) ? 1'b1 : 1'b0; // #FLAG

    assign Tx  = (Tx_s_TRANS) ? bit_out : 1'b1; // #OUTPUT
    assign TiP = !Tx_s_IDLE; // #OUTPUT
    /// End of Tx Regs and wires

    /// Tx States (See module description at the beginning of this file to get more info)
    localparam Tx_IDLE  = 2'b00;
    localparam Tx_LOAD  = 2'b01;
    localparam Tx_TRANS = 2'b10;
    /// End of Tx

    /// Tx controller
    // States
    always @(posedge clk) begin
        if(!rst) Tx_state_r <= Tx_IDLE;
        else begin
            case(Tx_state_r)
                Tx_IDLE: begin
                    if(send_data) Tx_state_r <= Tx_LOAD;
                    else          Tx_state_r <= Tx_IDLE;
                end
                Tx_LOAD: begin
                    Tx_state_r <= Tx_TRANS;
                end
                Tx_TRANS: begin
                    if(Tx_counter_r == 4'd11) Tx_state_r <= Tx_IDLE;
                    else                      Tx_state_r <= Tx_TRANS;
                end
                default: Tx_state_r <= Tx_IDLE;
            endcase
        end
    end

    // Bit counter
    always @(posedge clk) begin
        if(Tx_s_LOAD) Tx_counter_r <= 4'b0;
        else if(clk_shift && Tx_s_TRANS) Tx_counter_r <= Tx_counter_r + 1'b1;
    end
    /// End of Tx controller

    // // Bit counter
    // always @(posedge clk_shift) begin
    //     if(Tx_s_LOAD) Tx_counter_r <= 4'b0;
    //     else Tx_counter_r <= Tx_counter_r + 1'b1;
    // end
    // /// End of Tx controller

 endmodule