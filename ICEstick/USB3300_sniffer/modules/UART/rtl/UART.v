/*
 * Ciertas partes de este código se basan en:
 * https://github.com/Obijuan/open-fpga-verilog-tutorial/wiki/Cap%C3%ADtulo-24%3A-Unidad-de-transmisi%C3%B3n-serie-as%C3%ADncrona
 */

`default_nettype none
`include "./modules/clk_div_gen.vh" // Clock divider module

module UART #(parameter BAUD_DIVIDER = 9)
             (input  wire Rx,          // Rx input pin
              input  wire clk,         // reference clock input pin
              input  wire [7:0]I_DATA, // 8-bits data to send
              input  wire send_data,   // Send the current data in DATA IF there isn't any trasmission in progress
              output wire Tx,          // Tx output pin
              output wire TiP,         // Trasmission in Progress flag
              output wire NrD,         // New received Data flag
              output wire [7:0]O_DATA, // 8-bits data received
              output wire clk_baud     // Baudrate output
              );


    /// Baud clock gen
    wire baud_pulse;
    clk_div_gen #(.DIVIDER(BAUD_DIVIDER)) baud (clk, TiP, clk_baud, baud_pulse);
    /// End Baud clock gen

    /// Tx regs and wires
    // Outputs
    reg Tx_r  = 1'b1; assign Tx = Tx_r;
    
    // Inputs
    reg [7:0]I_DATA_r = 8'b0;
    reg send_data_r   = 1'b0;
    always @(posedge clk) begin
        send_data_r <= send_data;
    end
    always @(posedge clk) begin
        if(Tx_s_IDLE && send_data == 1'b1)
            I_DATA_r <= I_DATA;
    end

    // Buffers
    reg [9:0]Tx_buf_r   = {10{1'b1}};

    // Control registers
    reg [3:0]Tx_ctrl_r  = 4'b0;
    reg [1:0]Tx_state_r = 2'b0;

    // Flags
    wire Tx_s_IDLE;
    wire Tx_s_TRANS;
    wire Tx_s_LOAD;
    wire Tx_s_WAIT;

    // Assigns
    assign Tx_s_IDLE  = (Tx_state_r == Tx_IDLE)  ? 1'b1 : 1'b0;
    assign Tx_s_LOAD  = (Tx_state_r == Tx_LOAD)  ? 1'b1 : 1'b0;
    assign Tx_s_TRANS = (Tx_state_r == Tx_TRANS) ? 1'b1 : 1'b0;
    assign Tx_s_WAIT  = (Tx_state_r == Tx_WAIT)  ? 1'b1 : 1'b0;
    assign TiP        = !Tx_s_IDLE;

    /// End of Tx regs and wires

    /// Tx States
    localparam Tx_IDLE   = 2'b00;
    localparam Tx_LOAD   = 2'b01;
    localparam Tx_TRANS  = 2'b10;
    localparam Tx_WAIT   = 2'b11;
    /// End of Tx States

    /// Tx controller
    always @(posedge clk) begin
        case (Tx_state_r)
            Tx_IDLE:  begin
                if(send_data_r == 1'b1) begin
                    Tx_state_r <= Tx_LOAD;
                end
                else begin
                    Tx_state_r <= Tx_IDLE;
                end
            end
            Tx_LOAD: begin
                Tx_state_r <= Tx_TRANS;
            end
            Tx_TRANS: begin
                if(clk_baud == 1'b1) begin
                    Tx_state_r <= Tx_WAIT;
                end
                else begin
                    Tx_state_r <= Tx_TRANS;
                end
            end 
            Tx_WAIT: begin
                if(Tx_ctrl_r == 4'b1011) begin
                    Tx_state_r <= Tx_IDLE;
                end
                else if(clk_baud == 1'b0) begin
                    Tx_state_r <= Tx_TRANS;
                end
                else begin
                    Tx_state_r <= Tx_WAIT;
                end
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