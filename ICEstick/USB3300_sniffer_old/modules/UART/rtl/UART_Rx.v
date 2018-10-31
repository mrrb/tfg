/*
 *
 * UART Transmitter sub-module
 * This module allows the FPGA to transmit 8-bit data to other devices via a Serial interface.
 *
 * States:
 *  - Rx_IDLE. .
 *  - Rx_RECV. .
 *  - Rx_SAVE. .
 *  - Rx_RST.  .
 * 
 */

`default_nettype none
`include "./modules/shift_register.vh" // Shift register module

module UART_Rx(
               // System signals
               input  wire rst,
               input  wire clk,
               input  wire clk_baud,
               input  wire clk_pulse,

               // UART signals
               input  wire Rx,

               // Data signals
               output wire [7:0]O_DATA,

               // Control signals
               output wire NrD
              );

    /// Shift register init
    wire Rx_shift_enable_w;   // Signal that enable the Rx shift register
    wire [8:0]Rx_shift_out_w; // Parallel data stored in the Rx shift register
    wire Rx_shift_bit_out_w;  // Shift register bit out
    wire Rx_shift_par_en_w;   // Signal to enable parallel data input into the Rx shift register
    shift_register #(.bits(9))
          shift_Rx  (.enable(Rx_shift_enable_w),        .clk(clk_baud),
                     .DATA_out(Rx_shift_out_w),         .bit_out(Rx_shift_bit_out_w),
                     .PARALLEL_EN(Rx_shift_par_en_w),   .rst(rst),
                     .DATA_in(9'b0),                    .bit_in(Rx));
    /// End of Shift register init

    /// Rx Regs and wires
    // Output
    reg [7:0]O_DATA_r = 8'b0;

    // Control registers
    reg [1:0]Rx_state_r = 2'b0;
    reg [3:0]Rx_count_r = 4'b0;

    // Flags
    wire Rx_s_IDLE;
    wire Rx_s_LOAD;
    wire Rx_s_TRANS;
    wire Rx_s_RST;

    // Assigns
    assign Rx_s_IDLE = (Rx_state_r == Rx_IDLE) ? 1'b1 : 1'b0; // #FLAG
    assign Rx_s_LOAD = (Rx_state_r == Rx_LOAD) ? 1'b1 : 1'b0; // #FLAG
    assign Rx_s_RECV = (Rx_state_r == Rx_RECV) ? 1'b1 : 1'b0; // #FLAG
    assign Rx_s_RST  = (Rx_state_r == Rx_RST)  ? 1'b1 : 1'b0; // #FLAG

    assign O_DATA = O_DATA_r; // #OUTPUT

    assign Rx_shift_par_en_w = Rx_s_LOAD; // #SHIFT_REGISTER
    assign Rx_shift_enable_w = TiP; // #SHIFT_REGISTER
    /// End of Rx Regs and wires

    /// Rx States (See module description at the beginning to get more info)
    localparam Rx_IDLE = 0;
    localparam Rx_RECV = 1;
    localparam Rx_SAVE = 2;
    localparam Rx_RST  = 3;
    /// End of Rx

    /// Rx controller
    // #FIGURE_NUMBER Rx_state_machine
    // Transactions
    always @(posedge clk) begin
        if(!rst) Rx_state_r <= Rx_RST;
        else begin
            case(Rx_state_r)
                Rx_IDLE: begin
                    if() Rx_state_r <= Rx_LOAD;
                    else          Rx_state_r <= Rx_IDLE;
                end
                Rx_RECV: begin
                    if(Rx_count_r == 4'b1010) Rx_state_r <= Rx_RST;
                    else Rx_state_r <= Rx_RECV;
                end
                Rx_SAVE: begin
                    
                end
                Rx_RST: begin
                    Rx_state_r <= Rx_IDLE;
                end
                default: Rx_state_r <= Rx_RST;
            endcase
        end
    end

    // Actions
    always @(posedge clk_baud) begin
        if(!rst) begin
        end
        else begin
            case(Rx_state_r)
                Rx_IDLE: begin

                end
                Rx_RECV: begin

                end
                Rx_SAVE: begin

                end
                Rx_RST: begin
                
                end
                default: begin
                end
            endcase
        end
    end

    // Clk Baud control
    always @(posedge clk_baud) begin
        if(Rx_s_TRANS) Rx_count_r <= Rx_count_r + 1'b1;
    end
    /// End of Rx controller
    
endmodule