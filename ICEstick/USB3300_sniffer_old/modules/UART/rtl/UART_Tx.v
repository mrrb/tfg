/*
 *
 * UART Transmitter sub-module
 * This module allows the FPGA to transmit 8-bit data to other devices via a Serial interface.
 *
 * States:
 *  - Tx_IDLE.  .
 *  - Tx_LOAD.  .
 *  - Tx_TRANS. .
 *  - Tx_RST.   .
 * 
 */

`default_nettype none
`include "./modules/shift_register.vh" // Shift register module

module UART_Tx(
               // System signals
               input  wire rst,
               input  wire clk,
               input  wire clk_baud,
               input  wire clk_pulse,

               // UART signals
               output wire Tx,

               // Data signals
               input  wire [7:0]I_DATA,

               // Control signals
               input  wire send_data,
               output wire TiP
              );

    /// Shift register init
    wire Tx_shift_clock;      // Shift register clock
    wire Tx_shift_enable_w;   // Signal that enable the Tx shift register
    wire [9:0]Tx_shift_out_w; // Parallel data stored in the Tx shift register
    wire Tx_shift_bit_out_w;  // Shift register bit out
    wire Tx_shift_par_en_w;   // Signal to enable parallel data input into the Tx shift register

    assign Tx_shift_clock = (Tx_s_TRANS) ? clk_pulse : clk;

    shift_register #(.bits(10))
          shift_Tx  (.enable(Tx_shift_enable_w),        .clk(!Tx_shift_clock),
                     .DATA_out(Tx_shift_out_w),         .bit_out(Tx_shift_bit_out_w),
                     .PARALLEL_EN(Tx_shift_par_en_w),   .rst(rst),
                     .DATA_in({1'b1,I_DATA[7:0],1'b0}), .bit_in(1'b1));
    /// End of Shift register init

    /// Tx Regs and wires
    // Control registers
    reg [1:0]Tx_state_r = 2'b0;
    reg [3:0]Tx_count_r = 4'b0;
    reg SET_r = 1'b0;

    // Flags
    wire Tx_s_IDLE;
    wire Tx_s_LOAD;
    wire Tx_s_TRANS;
    wire Tx_s_RST;

    // Assigns
    assign Tx_s_IDLE  = (Tx_state_r == Tx_IDLE)  ? 1'b1 : 1'b0; // #FLAG
    assign Tx_s_LOAD  = (Tx_state_r == Tx_LOAD)  ? 1'b1 : 1'b0; // #FLAG
    assign Tx_s_TRANS = (Tx_state_r == Tx_TRANS) ? 1'b1 : 1'b0; // #FLAG
    assign Tx_s_RST   = (Tx_state_r == Tx_RST)   ? 1'b1 : 1'b0; // #FLAG

    assign Tx  = (Tx_s_TRANS ? Tx_shift_bit_out_w : 1'b1); // #OUTPUT
    assign TiP = !Tx_s_IDLE;         // #OUTPUT

    assign Tx_shift_par_en_w = Tx_s_LOAD && !SET_r; // #SHIFT_REGISTER
    assign Tx_shift_enable_w = TiP;       // #SHIFT_REGISTER
    /// End of Tx Regs and wires

    /// Tx States (See module description at the beginning to get more info)
    localparam Tx_IDLE  = 0;
    localparam Tx_LOAD  = 1;
    localparam Tx_TRANS = 2;
    localparam Tx_RST   = 3;
    /// End of Tx

    /// Tx controller
    // #FIGURE_NUMBER Tx_state_machine
    // Transactions
    always @(posedge clk) begin
        if(!rst) Tx_state_r <= Tx_RST;
        else begin
            case(Tx_state_r)
                Tx_IDLE: begin
                    if(send_data) Tx_state_r <= Tx_LOAD;
                    else          Tx_state_r <= Tx_IDLE;
                end
                Tx_LOAD: begin
                    if(clk_pulse) Tx_state_r <= Tx_TRANS;
                    else Tx_state_r <= Tx_LOAD;
                end
                Tx_TRANS: begin
                    if(Tx_count_r == 4'b1010) Tx_state_r <= Tx_RST;
                    else Tx_state_r <= Tx_TRANS;
                end
                Tx_RST: begin
                    Tx_state_r <= Tx_IDLE;
                end
                default: Tx_state_r <= Tx_RST;
            endcase
        end
    end

    // Actions
    always @(posedge clk) begin
        if(!rst) begin
        end
        else begin
            case(Tx_state_r)
                Tx_IDLE: begin

                end
                Tx_LOAD: begin
                    SET_r <= 1'b1;
                end
                Tx_TRANS: begin

                end
                Tx_RST: begin
                    SET_r <= 1'b0;
                end
                default: begin
                end
            endcase
        end
    end

    // Clk Baud control
    always @(posedge clk_pulse) begin
        if(Tx_s_TRANS)    Tx_count_r <= Tx_count_r + 1'b1;
        else if(Tx_s_RST) Tx_count_r <= 4'b0;
    end
    /// End of Tx controller


    // /// Shift register init
    // wire Tx_shift_clock;      // Shift register clock
    // wire Tx_shift_enable_w;   // Signal that enable the Tx shift register
    // wire [9:0]Tx_shift_out_w; // Parallel data stored in the Tx shift register
    // wire Tx_shift_bit_out_w;  // Shift register bit out
    // wire Tx_shift_par_en_w;   // Signal to enable parallel data input into the Tx shift register

    // assign Tx_shift_clock = (Tx_s_TRANS) ? clk_pulse : clk;

    // shift_register #(.bits(10))
    //       shift_Tx  (.enable(Tx_shift_enable_w),        .clk(Tx_shift_clock),
    //                  .DATA_out(Tx_shift_out_w),         .bit_out(Tx_shift_bit_out_w),
    //                  .PARALLEL_EN(Tx_shift_par_en_w),   .rst(rst),
    //                  .DATA_in({1'b1,I_DATA[7:0],1'b0}), .bit_in(1'b1));
    // /// End of Shift register init

    // /// Tx Regs and wires
    // // Control registers
    // reg [1:0]Tx_state_r = 2'b0;
    // reg [3:0]Tx_count_r = 4'b0;

    // // Flags
    // wire Tx_s_IDLE;
    // wire Tx_s_LOAD;
    // wire Tx_s_TRANS;
    // wire Tx_s_RST;

    // // Assigns
    // assign Tx_s_IDLE  = (Tx_state_r == Tx_IDLE)  ? 1'b1 : 1'b0; // #FLAG
    // assign Tx_s_LOAD  = (Tx_state_r == Tx_LOAD)  ? 1'b1 : 1'b0; // #FLAG
    // assign Tx_s_TRANS = (Tx_state_r == Tx_TRANS) ? 1'b1 : 1'b0; // #FLAG
    // assign Tx_s_RST   = (Tx_state_r == Tx_RST)   ? 1'b1 : 1'b0; // #FLAG

    // assign Tx  = (Tx_s_TRANS ? Tx_shift_bit_out_w : 1'b1); // #OUTPUT
    // assign TiP = !Tx_s_IDLE;         // #OUTPUT

    // assign Tx_shift_par_en_w = Tx_s_LOAD; // #SHIFT_REGISTER
    // assign Tx_shift_enable_w = TiP;       // #SHIFT_REGISTER
    // /// End of Tx Regs and wires

    // /// Tx States (See module description at the beginning to get more info)
    // localparam Tx_IDLE  = 0;
    // localparam Tx_LOAD  = 1;
    // localparam Tx_TRANS = 2;
    // localparam Tx_RST   = 3;
    // /// End of Tx

    // /// Tx controller
    // // #FIGURE_NUMBER Tx_state_machine
    // // Transactions
    // always @(posedge clk) begin
    //     if(!rst) Tx_state_r <= Tx_RST;
    //     else begin
    //         case(Tx_state_r)
    //             Tx_IDLE: begin
    //                 if(send_data) Tx_state_r <= Tx_LOAD;
    //                 else          Tx_state_r <= Tx_IDLE;
    //             end
    //             Tx_LOAD: begin
    //                 Tx_state_r <= Tx_TRANS;
    //             end
    //             Tx_TRANS: begin
    //                 if(Tx_count_r == 4'b1011) Tx_state_r <= Tx_RST;
    //                 else Tx_state_r <= Tx_TRANS;
    //             end
    //             Tx_RST: begin
    //                 Tx_state_r <= Tx_IDLE;
    //             end
    //             default: Tx_state_r <= Tx_RST;
    //         endcase
    //     end
    // end

    // // Actions
    // always @(posedge clk) begin
    //     if(!rst) begin
    //     end
    //     else begin
    //         case(Tx_state_r)
    //             Tx_IDLE: begin

    //             end
    //             Tx_LOAD: begin

    //             end
    //             Tx_TRANS: begin

    //             end
    //             Tx_RST: begin
    //                 Tx_count_r <= 4'b0;
    //             end
    //             default: begin
    //             end
    //         endcase
    //     end
    // end

    // // Clk Baud control
    // always @(negedge clk_pulse) begin
    //     if(Tx_s_TRANS) Tx_count_r <= Tx_count_r + 1'b1;
    // end
    // /// End of Tx controller

endmodule