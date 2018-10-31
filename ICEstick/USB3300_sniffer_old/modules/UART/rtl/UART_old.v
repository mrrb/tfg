/*
 *
 * UART module
 * This module let the FPGA communicate with other devices via Serial interface.
 *
 * Tx states:
 *  - Tx_IDLE.  The controller is waiting for a new serial outgoing byte (send_data == 1).
 *  - Tx_LOAD.  The DATA to send is stored in a buffer.
 *  - Tx_TRANS. Each bit is transmitted in the Tx pin.
 *  - Tx_WAIT.  The controller waits until the baud clock is LOW to send the next bit.
 * 
 * Rx states:
 *  NOT YET IMPLEMENTED!!
 * 
 */
/*
 * Some parts of this code is based on:
 * https://github.com/Obijuan/open-fpga-verilog-tutorial/wiki/Cap%C3%ADtulo-24%3A-Unidad-de-transmisi%C3%B3n-serie-as%C3%ADncrona
 */

`default_nettype none
`include "./modules/clk_div_gen.vh" // Clock divider module

module UART #(
              parameter BAUD_DIVIDER = 9
             )
             (
              // System signals
              input  wire rst,         // Reset signal
              input  wire clk,         // reference clock input pin
              output wire clk_baud,    // Baudrate clock output

              // UART signals
              input  wire Rx,          // Rx input pin
              output wire Tx,          // Tx output pin

              // Data signals
              input  wire [7:0]I_DATA, // 8-bits data to send
              output wire [7:0]O_DATA, // 8-bits received data

              // Control signals
              input  wire send_data,   // Send the current data in DATA IF there isn't any trasmission in progress
              output wire TiP,         // Trasmission in Progress flag
              output wire NrD          // New received Data flag
             );

    /// Baud clock gen
    wire baud_pulse;
    clk_div_gen #(.DIVIDER(BAUD_DIVIDER)) baud (clk, TiP, clk_baud, baud_pulse);
    /// End Baud clock gen

    /// Tx regs and wires
    // Outputs
    reg Tx_r  = 1'b1;
    
    // Inputs
    reg [7:0]I_DATA_r = 8'b0;
    reg send_data_r   = 1'b0;
    always @(posedge clk) begin
        send_data_r <= send_data;
    end
    always @(posedge clk) begin
        if(Tx_s_IDLE && send_data == 1'b1) I_DATA_r <= I_DATA;
    end

    // Buffers
    reg [9:0]Tx_buf_r   = {10{1'b1}}; // Buffer to store the entire frame before sending it

    // Control registers
    reg [3:0]Tx_ctrl_r  = 4'b0; // Register to store the current bit that has been sent
    reg [1:0]Tx_state_r = 2'b0; // Register to store the current state of the UART module

    // Flags
    wire Tx_s_IDLE;  // 1 if Tx_state_r == Tx_IDLE,  else 0
    wire Tx_s_LOAD;  // 1 if Tx_state_r == Tx_LOAD,  else 0
    wire Tx_s_TRANS; // 1 if Tx_state_r == Tx_TRANS, else 0
    wire Tx_s_WAIT;  // 1 if Tx_state_r == Tx_WAIT,  else 0

    // Assigns
    assign Tx_s_IDLE  = (Tx_state_r == Tx_IDLE)  ? 1'b1 : 1'b0; // #FLAG
    assign Tx_s_LOAD  = (Tx_state_r == Tx_LOAD)  ? 1'b1 : 1'b0; // #FLAG
    assign Tx_s_TRANS = (Tx_state_r == Tx_TRANS) ? 1'b1 : 1'b0; // #FLAG
    assign Tx_s_WAIT  = (Tx_state_r == Tx_WAIT)  ? 1'b1 : 1'b0; // #FLAG
    
    assign TiP        = !Tx_s_IDLE; // #OUTPUT
    assign Tx         = Tx_r;       // #OUTPUT
    /// End of Tx regs and wires

    /// Tx States (See module description at the beginning to get more info)
    localparam Tx_IDLE   = 2'b00;
    localparam Tx_LOAD   = 2'b01;
    localparam Tx_TRANS  = 2'b10;
    localparam Tx_WAIT   = 2'b11;
    /// End of Tx States

    /// Tx controller
    // #FIGURE_NUMBER UART_state_machine
    always @(posedge clk) begin
        case (Tx_state_r)
            Tx_IDLE:  begin
                // If there is a new request to send data, the 
                if(send_data_r == 1'b1) Tx_state_r <= Tx_LOAD;
                else                    Tx_state_r <= Tx_IDLE;
            end
            Tx_LOAD: begin
                // In this state the DATA is loaded in the buffer
                Tx_state_r <= Tx_TRANS;
            end
            Tx_TRANS: begin
                // The controller waits for a new Baud clock cycle
                if(clk_baud == 1'b1) Tx_state_r <= Tx_WAIT;
                else                 Tx_state_r <= Tx_TRANS;
            end 
            Tx_WAIT: begin
                // If the FPGA has sent all the bits, It goes back to the IDLE state, otherwise, It waits for a Low Baud clock
                if(Tx_ctrl_r == 4'b1011)  Tx_state_r <= Tx_IDLE;
                else if(clk_baud == 1'b0) Tx_state_r <= Tx_TRANS;
                else                      Tx_state_r <= Tx_WAIT;
            end 
            default: begin
                Tx_state_r <= Tx_IDLE;
            end
        endcase
    end

    always @(posedge clk) begin
        Tx_r <= Tx_buf_r[0];
    end

    // Tx buffer
    always @(posedge clk) begin
        if(Tx_s_LOAD == 1'b1) begin
            Tx_buf_r <= {I_DATA_r, 2'b01};
        end
        else if(Tx_s_LOAD == 1'b0 && baud_pulse == 1'b1) begin
            Tx_buf_r <= {1'b1, Tx_buf_r[9:1]};
        end
    end

    // Tx transmission counter
    always @(posedge clk) begin
        if(Tx_s_LOAD == 1'b1) begin
            Tx_ctrl_r <= 4'b0;
        end
        else if(Tx_s_LOAD == 1'b0 && baud_pulse == 1'b1) begin
            Tx_ctrl_r <= Tx_ctrl_r + 1'b1;
        end
    end
    /// End of Tx controller


    /// Rx regs and wires
    /// End of Rx regs and wires
    
    /// Rx States
    /// End of Rx States

    /// Rx controller
    /// End of Rx controller
    
    /// Rx assigns
    assign NrD = 1'b0;
    /// End of Rx assigns

endmodule