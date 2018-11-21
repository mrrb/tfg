/*
 *
 * UART_Tx module
 * This module let the FPGA transfer serial data (Config: 8N1).
 *
 * Parameters:
 *  - BAUDS. Optimal counter value to generate the baud rate clock. Definitions in rtl/bauds.vh.
 *
 * Inputs:
 *  - rst. Synchronous/Asynchronous reset signal [Active LOW].
 *  - clk. Reference clock.
 *  - I_DATA. 8-bit Data that It's going to be sent.
 *  - send_data. Input signal that starts a serial transfer with the DATA in I_DATA.
 *
 * Outputs:
 *  - clk_Tx. Clock signal at the desired baud rate used to transfer the data.
 *  - Tx. Serial Data output.
 *  - TiP. Signal indicating that the module is transmitting.
 *  - Tx_FULL. Signal that indicates that the internal buffer is FULL.
 *
 * States:
 *  - Tx_IDLE. The module is waiting to transfer a new byte.
 *  - Tx_LOAD. The module saves the incoming byte and resets the control counter.
 *  - Tx_TRANS. The module tranfers each bit of the DATA + the START and END bit.
 *
 */

`default_nettype none

`ifdef ASYNC_RESET
    `define UART_TX_ASYNC_RESET or negedge rst
`else
    `define UART_TX_ASYNC_RESET
`endif

`include "./rtl/bauds.vh"

`include "./modules/clk_baud_pulse.vh"
`include "./modules/shift_register.vh"
`include "./modules/FIFO_BRAM_SYNC.vh"

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
                  output wire TiP,         // Trasmission in Progress flag
                  output wire Tx_FULL      // Internal buffer full flag
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

    /// 512bytes buffer
    wire wr_dv, rd_en;              // Write/Read enable flags
    wire wr_full, wr_almost_full;   // Write flags
    wire [7:0]Tx_DATA, Tx_DATA_in;  // OUT/IN DATA
    wire rd_empty, rd_almost_empty; // Read flags

    assign wr_dv      = send_data;
    assign rd_en      = !rd_empty && !TiP;
    assign Tx_DATA_in = I_DATA;
    FIFO_BRAM_SYNC Tx_buffer (
                              // System signals
                              .rst(rst),
                              .clk(clk),

                              // Write control signals
                              .wr_dv(wr_dv),

                              // Write data signals
                              .wr_DATA(Tx_DATA_in),

                              // Write flags
                              .wr_full(wr_full),
                              .wr_almost_full(wr_almost_full),

                              // Read control signals
                              .rd_en(rd_en),

                              // Read data signals
                              .rd_DATA(Tx_DATA),

                              // Read flags
                              .rd_empty(rd_empty),
                              .rd_almost_empty(rd_almost_empty)
                            );
    /// End of 512bytes buffer

    /// Shift register init
    // Shift register control clock
    wire clk_shift;
    assign clk_shift = (Tx_s_LOAD) ? clk : clk_Tx;

    // Shift-in bit [Equal to the UART default value]
    wire bit_in;
    assign bit_in = 1'b1;
    
    // Parallel load in the Tx_LOAD state, otherwise, shift right mode
    wire [1:0]shift_mode;
    assign shift_mode = (Tx_s_LOAD) ? 2'b11 : 2'b10;

    reg [7:0]DATA_in = 0; // Data itself

    wire bit_out;        // Tx value 
    wire [10:0]DATA_out; // Parallel DATA out. (Not useful in this case)

    wire [10:0]shift_in; // Shift register input WITH start and end bits
    assign shift_in = {2'b11, DATA_in, 1'b0};
    shift_register #(.BITS(11))
          shift_Tx  (
                     .clk(clk_shift),    .rst(rst),         // System signals
                     .bit_in(bit_in),    .bit_out(bit_out), // Serial data
                     .DATA_IN(shift_in), .DATA(DATA_out),   // Parallel data
                     .mode(shift_mode)                      // Control signals
                    );
    /// End of Shift register init

    /// Tx Regs and wires
    // Inputs
    always @(posedge clk) begin
        if(Tx_s_IDLE && !rd_empty) DATA_in <= Tx_DATA;
    end

    // Control registers
    reg [1:0]Tx_state_r   = 2'b0; // Register that stores the current Tx state
    reg [3:0]Tx_counter_r = 4'b0; // Register that counts how many bits has been already sent

    // Flags
    wire Tx_s_IDLE;  // HIGH if Tx_state_r == Tx_IDLE,  else LOW
    wire Tx_s_LOAD;  // HIGH if Tx_state_r == Tx_LOAD,  else LOW
    wire Tx_s_TRANS; // HIGH if Tx_state_r == Tx_TRANS, else LOW

    // Assigns
    assign Tx_s_IDLE  = (Tx_state_r == Tx_IDLE)  ? 1'b1 : 1'b0; // #FLAG
    assign Tx_s_LOAD  = (Tx_state_r == Tx_LOAD)  ? 1'b1 : 1'b0; // #FLAG
    assign Tx_s_TRANS = (Tx_state_r == Tx_TRANS) ? 1'b1 : 1'b0; // #FLAG

    assign Tx  = (Tx_s_TRANS) ? bit_out : 1'b1; // #OUTPUT
    assign TiP = !Tx_s_IDLE;  // #OUTPUT
    assign Tx_FULL = wr_full; // #OUTPUT
    /// End of Tx Regs and wires

    /// Tx States (See module description at the beginning of this file to get more info)
    localparam Tx_IDLE  = 2'b00;
    localparam Tx_LOAD  = 2'b01;
    localparam Tx_TRANS = 2'b10;
    /// End of Tx States

    /// Tx controller
    // States
    always @(posedge clk `UART_TX_ASYNC_RESET) begin
        if(!rst) Tx_state_r <= Tx_IDLE;
        else begin
            case(Tx_state_r)
                Tx_IDLE: begin
                    if(!rd_empty) Tx_state_r <= Tx_LOAD;
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
    // Each time a UART_Tx bit is transmit, this register will increment by one
    always @(posedge clk) begin
        if(Tx_s_LOAD) Tx_counter_r <= 4'b0;
        else if(clk_shift && Tx_s_TRANS) Tx_counter_r <= Tx_counter_r + 1'b1;
    end
    /// End of Tx controller

 endmodule