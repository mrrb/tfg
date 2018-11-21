/*
 *
 * UART_Rx module
 * This module let the FPGA receive serial data (Config: 8N1).
 *
 * Parameters:
 *  - BAUDS. Optimal counter value to generate the baud rate clock.
 *
 * Inputs:
 *  - rst. Synchronous/Asynchronous reset signal [Active LOW].
 *  - clk. Reference clock.
 *  - Rx. Serial Data input.
 *  - Nxt. Next byte. It pull a byte (if available) from the internal FIFO.
 *
 * Outputs:
 *  - clk_Rx. Clock signal at the desired baud rate used to receive the data.
 *            It has a delay equal to a half of BAUDS, so it can read the Rx value properly.
 *  - O_DATA. 8-bits data received.
 *  - NrD. New received Data flag. At the end of every DATA reception, this signal will be HIGH a clk cycle.
 *  - Rx_FULL. Signal that indicates that the internal buffer is FULL.
 *  - Rx_EMPTY. Signal that indicates that the internal buffer is EMPTY.
 *
 * States:
 *  - Rx_IDLE. The module is waiting for a START BIT (Rx goes from HIGH to LOW).
 *  - Rx_INIT. The Rx counter restart.
 *  - Rx_RECV. The module reads each bit and stores them in a register. 1 START bit + 8 bits DATA + 1 bit STOP = 10 bits total.
 *  - Rx_SAVE. The module stores the new byte in the FIFO and goes back to the IDLE state.
 */

`default_nettype none

`ifdef ASYNC_RESET
    `define UART_RX_ASYNC_RESET or negedge rst
`else
    `define UART_RX_ASYNC_RESET
`endif

`include "./rtl/bauds.vh"

`include "./modules/clk_baud_pulse.vh"
`include "./modules/shift_register.vh"
`include "./modules/FIFO_BRAM_SYNC.vh"

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
                  input  wire NxT,         // Next byte. It pull a byte (if available) from the internal FIFO
                  output wire NrD,         // New received Data flag
                  output wire Rx_FULL,     // Internal buffer FULL flag
                  output wire Rx_EMPTY     // Internal buffer EMPTY flag
                 );

    /// Reception clock generation
    wire enable;
    assign enable = (Rx_s_RECV) ? 1'b1 : 1'b0;

    clk_baud_pulse #(
                     .COUNTER_VAL(BAUDS),
                     .PULSE_DELAY(BAUDS/2) // The pulse is delayed so it can read the Rx signal at the proper time (just in the middle)
                    )
       clk_baud_Rx  (
                     .clk_in(clk),
                     .clk_pulse(clk_Rx),
                     .enable(enable)
                    );
    /// End of Reception clock generation

    /// 512bytes buffer
    wire wr_dv, rd_en;              // Write/Read enable flags
    wire wr_full, wr_almost_full;   // Write flags
    wire [7:0]Rx_DATA, Rx_DATA_in;  // OUT/IN DATA
    wire rd_empty, rd_almost_empty; // Read flags

    assign wr_dv      = NrD; // Data push into the shift register in the Rx_SAVE state
    assign rd_en      = NxT; // Data pull out of the register when the NxT signal is asserted
    assign O_DATA     = Rx_DATA;
    assign Rx_DATA_in = DATA_out[8:1]; // The START and END bits are discarded
    // assign Rx_DATA_in = DATA_buff; [OLD]
    FIFO_BRAM_SYNC Rx_buffer (
                              // System signals
                              .rst(rst),
                              .clk(clk),

                              // Write control signals
                              .wr_dv(wr_dv),

                              // Write data signals
                              .wr_DATA(Rx_DATA_in),

                              // Write flags
                              .wr_full(wr_full),
                              .wr_almost_full(wr_almost_full),

                              // Read control signals
                              .rd_en(rd_en),

                              // Read data signals
                              .rd_DATA(Rx_DATA),

                              // Read flags
                              .rd_empty(rd_empty),
                              .rd_almost_empty(rd_almost_empty)
                            );
    /// End of 512bytes buffer

    /// Shift register init
    // Shift register control clock
    wire clk_shift;
    assign clk_shift = (Rx_s_RECV) ? clk_Rx : 1'b0;

    // Metastability registers and wires
    reg Rx_A_r, Rx_B_r;
    wire bit_in;
    assign bit_in = Rx_B_r;
    
    // The shift register shifts Right in the Rx_RECV state, otherwise, It does nothing
    wire [1:0]shift_mode;
    assign shift_mode = (Rx_s_RECV) ? 2'b10 : 2'b00;

    // Parallel DATA in. (Not use in this case)
    wire [9:0]DATA_in;
    assign DATA_in = 0;

    wire bit_out;       // Bit obtained by doing the shift. (Not useful in this case)
    wire [9:0]DATA_out; // Data received

    shift_register #(.BITS(10))
          shift_Rx  (
                     .clk(clk_shift),   .rst(rst),         // System signals
                     .bit_in(bit_in),   .bit_out(bit_out), // Serial data
                     .DATA_IN(DATA_in), .DATA(DATA_out),   // Parallel data
                     .mode(shift_mode)                     // Control signals
                    );
    /// End of Shift register init

    /// Rx Regs and wires
    // Control registers
    reg [1:0]Rx_state_r   = 2'b0; // Register that stores the current Rx state
    reg [3:0]Rx_counter_r = 4'b0; // Register that counts how many bits has been already sent
    // reg [7:0]DATA_buff    = 8'b0; // Buffer where the received data is temporarily stored [OLD]

    // Flags
    wire Rx_s_IDLE; // HIGH if Rx_state_r == Rx_IDLE,  else LOW
    wire Rx_s_INIT; // HIGH if Rx_state_r == Rx_INIT,  else LOW
    wire Rx_s_RECV; // HIGH if Rx_state_r == Rx_RECV,  else LOW
    wire Rx_s_SAVE; // HIGH if Rx_state_r == Rx_SAVE,  else LOW

    // Assigns
    assign Rx_s_IDLE = (Rx_state_r == Rx_IDLE) ? 1'b1 : 1'b0; // #FLAG
    assign Rx_s_INIT = (Rx_state_r == Rx_INIT) ? 1'b1 : 1'b0; // #FLAG
    assign Rx_s_RECV = (Rx_state_r == Rx_RECV) ? 1'b1 : 1'b0; // #FLAG
    assign Rx_s_SAVE = (Rx_state_r == Rx_SAVE) ? 1'b1 : 1'b0; // #FLAG

    assign NrD      = Rx_s_SAVE; // #OUTPUT
    assign Rx_FULL  = wr_full;   // #OUTPUT
    assign Rx_EMPTY = rd_empty;  // #OUTPUT
    /// End of Rx Regs and wires

    /// Rx States (See module description at the beginning of this file to get more info)
    localparam Rx_IDLE = 2'b00;
    localparam Rx_INIT = 2'b01;
    localparam Rx_RECV = 2'b10;
    localparam Rx_SAVE = 2'b11;
    /// End of Rx States

    /// Rx controller
    // States
    always @(posedge clk `UART_RX_ASYNC_RESET) begin
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

    // Metastability solver
    // Check the reference doc FPGA_ICE40/wp-01082-quartus-ii-metastability.pdf for more info
    // (Or https://www.intel.com/content/dam/www/programmable/us/en/pdfs/literature/wp/wp-01082-quartus-ii-metastability.pdf)
    always @(posedge clk `UART_RX_ASYNC_RESET) begin
        if(!rst) begin
            Rx_A_r <= 1'b0;
            Rx_B_r <= 1'b0;
        end
        else if(!Rx_s_IDLE) begin
            Rx_A_r <= Rx;
            Rx_B_r <= Rx_A_r;
        end
    end

    // // Output Data [OLD]
    // // At the end of the Rx_RECV  state, the data in the shift register is passed to the DATA buffer
    // always @(posedge clk `UART_RX_ASYNC_RESET) begin
    //     if(!rst) DATA_buff <= 8'b0;
    //     else if(Rx_s_RECV && Rx_counter_r == 4'd10) DATA_buff <= DATA_out[8:1];
    // // end

    // Bit counter
    // Each time a UART_Tx bit is transmit, this register will increment by one
    always @(posedge clk) begin
        if(Rx_s_INIT) Rx_counter_r <= 4'b0;
        else if(clk_shift && Rx_s_RECV) Rx_counter_r <= Rx_counter_r + 1'b1;
    end
    /// End of Rx controller

 endmodule