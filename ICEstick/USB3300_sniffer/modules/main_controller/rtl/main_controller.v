/*
 *
 * main_controller module
 * main_controller module let 
 *
 * Inputs:
 *  - 
 *
 * Outputs:
 *  - 
 *
 */

`default_nettype none

`ifdef ASYNC_RESET
    `define MAIN_CONTROLLER_ASYNC_RESET or negedge rst
`else
    `define MAIN_CONTROLLER_ASYNC_RESET
`endif

module main_controller (
                        // System signals
                        input  wire rst,            // Reset signal
                        input  wire clk,            // Reference clock input
                        input  wire force_send,

                        // Op stack
                        input  wire [15:0] op_stack_msg,
                        input  wire op_stack_empty,                        
                        output wire op_stack_pull,

                        // General ULPI signals
                        input  wire ULPI_busy,
                        
                        // DATA ULPI signals
                        input  wire [7:0] ULPI_USB_DATA,
                        input  wire [15:0] ULPI_USB_INFO_DATA,
                        input  wire ULPI_DATA_buff_empty,
                        input  wire ULPI_INFO_buff_empty,
                        output wire ULPI_DATA_re,
                        output wire ULPI_INFO_re,

                        // Register ULPI signals
                        input  wire [7:0] ULPI_REG_VAL_R,
                        output wire [7:0] ULPI_REG_VAL_W,
                        output wire [5:0] ULPI_ADDR,
                        output wire ULPI_PrW,
                        output wire ULPI_PrR,

                        // UART
                        input  wire UART_Tx_FULL,
                        output wire [7:0] UART_Tx_DATA,
                        output wire UART_send
                       );

    /// TOP controller
    // TOP Regs and wires
    // Control registers and wires
    reg [3:0] MAIN_state_r = 0; // Register that stores the current TOP state
    reg [1:0] MAIN_cmd_r = 0;

    reg [5:0] ULPI_ADDR_r = 0;
    reg [7:0] ULPI_REG_VAL_W_r = 0;

    reg [5:0] RxCMD_r = 0;
    reg [1:0] INFO_count_r = 0;
    reg [9:0] DATA_count_r = 0;

    reg [7:0] UART_Tx_DATA_r = 0;

    // Flags
    wire MAIN_s_IDLE;       // HIGH if MAIN_state_r == MAIN_IDLE,       else LOW
    wire MAIN_s_REG_READ;   // HIGH if MAIN_state_r == MAIN_REG_READ,   else LOW
    wire MAIN_s_REG_WRITE;  // HIGH if MAIN_state_r == MAIN_REG_WRITE,  else LOW
    wire MAIN_s_REG_WAIT1;  // HIGH if MAIN_state_r == MAIN_REG_WAIT1,  else LOW
    wire MAIN_s_REG_SEND;   // HIGH if MAIN_state_r == MAIN_REG_SEND,   else LOW
    wire MAIN_s_REG_WAIT2;  // HIGH if MAIN_state_r == MAIN_REG_WAIT2,  else LOW
    wire MAIN_s_RECV;       // HIGH if MAIN_state_r == MAIN_RECV,       else LOW
    wire MAIN_s_RECV_SEND1; // HIGH if MAIN_state_r == MAIN_RECV_SEND1, else LOW
    wire MAIN_s_RECV_WAIT;  // HIGH if MAIN_state_r == MAIN_RECV_WAIT,  else LOW
    wire MAIN_s_RECV_SEND2; // HIGH if MAIN_state_r == MAIN_RECV_SEND2, else LOW

    // Assigns
    assign MAIN_s_IDLE       = (MAIN_state_r == MAIN_IDLE)       ? 1'b1 : 1'b0; // #FLAG
    assign MAIN_s_REG_READ   = (MAIN_state_r == MAIN_REG_READ)   ? 1'b1 : 1'b0; // #FLAG
    assign MAIN_s_REG_WRITE  = (MAIN_state_r == MAIN_REG_WRITE)  ? 1'b1 : 1'b0; // #FLAG
    assign MAIN_s_REG_WAIT1  = (MAIN_state_r == MAIN_REG_WAIT1)  ? 1'b1 : 1'b0; // #FLAG
    assign MAIN_s_REG_SEND   = (MAIN_state_r == MAIN_REG_SEND)   ? 1'b1 : 1'b0; // #FLAG
    assign MAIN_s_REG_WAIT2  = (MAIN_state_r == MAIN_REG_WAIT2)  ? 1'b1 : 1'b0; // #FLAG
    assign MAIN_s_RECV       = (MAIN_state_r == MAIN_RECV)       ? 1'b1 : 1'b0; // #FLAG
    assign MAIN_s_RECV_SEND1 = (MAIN_state_r == MAIN_RECV_SEND1) ? 1'b1 : 1'b0; // #FLAG
    assign MAIN_s_RECV_WAIT  = (MAIN_state_r == MAIN_RECV_WAIT)  ? 1'b1 : 1'b0; // #FLAG
    assign MAIN_s_RECV_SEND2 = (MAIN_state_r == MAIN_RECV_SEND2) ? 1'b1 : 1'b0; // #FLAG

    assign ULPI_ADDR = ULPI_ADDR_r; // #OUTPUT
    assign ULPI_REG_VAL_W = ULPI_REG_VAL_W_r; // #OUTPUT
    assign ULPI_PrW = (MAIN_cmd_r == 2'b10) ? MAIN_s_REG_WAIT1 : 1'b0; // #OUTPUT
    assign ULPI_PrR = (MAIN_cmd_r == 2'b11) ? MAIN_s_REG_WAIT1 : 1'b0; // #OUTPUT

    assign UART_Tx_DATA = UART_Tx_DATA_r; // #OUTPUT
    assign UART_send = MAIN_s_REG_WAIT2  ||
                       MAIN_s_RECV_SEND1 ||
                       MAIN_s_RECV_SEND2;   // #OUTPUT

    assign op_stack_pull = MAIN_s_REG_READ  ||
                           MAIN_s_REG_WRITE ||
                           MAIN_s_RECV      ||
                           MAIN_s_REG_SEND;   // #OUTPUT

    assign ULPI_INFO_re = MAIN_s_RECV; // #OUTPUT
    assign ULPI_DATA_re = MAIN_s_RECV_SEND2 && !UART_Tx_FULL; // #OUTPUT
    // End of TOP Regs and wires

    // TOP States
    localparam MAIN_IDLE       = 0;
    localparam MAIN_REG_READ   = 1;
    localparam MAIN_REG_WRITE  = 2;
    localparam MAIN_REG_WAIT1  = 3;
    localparam MAIN_REG_SEND   = 4;
    localparam MAIN_REG_WAIT2  = 5;
    localparam MAIN_RECV       = 6;
    localparam MAIN_RECV_SEND1 = 7;
    localparam MAIN_RECV_WAIT  = 8;
    localparam MAIN_RECV_SEND2 = 9;
    // End of TOP States

    // TOP controller
    // States
    always @(posedge clk `MAIN_CONTROLLER_ASYNC_RESET) begin
        if(!rst) MAIN_state_r <= MAIN_IDLE;
        else begin
            case(MAIN_state_r)
                MAIN_IDLE: begin
                    if(!op_stack_empty || force_send) begin
                        /*
                           00 -> DATA_RECV
                           01 -> REG_SEND
                           10 -> REG_WRITE
                           11 -> REG_READ
                         */
                        if(op_stack_msg[15:14] == 2'b00 && !ULPI_INFO_buff_empty)
                            MAIN_state_r <= MAIN_RECV;
                        else if(op_stack_msg[15:14] == 2'b01 || force_send)
                            MAIN_state_r <= MAIN_REG_SEND;
                        if(op_stack_msg[15:14] == 2'b10)
                            MAIN_state_r <= MAIN_REG_WRITE;
                        else if(op_stack_msg[15:14] == 2'b11)
                            MAIN_state_r <= MAIN_REG_READ;
                    end
                    else
                        MAIN_state_r <= MAIN_IDLE;
                end
                MAIN_REG_READ: begin
                    MAIN_state_r <= MAIN_REG_WAIT1;
                end
                MAIN_REG_WRITE: begin
                    MAIN_state_r <= MAIN_REG_WAIT1;
                end
                MAIN_REG_WAIT1: begin
                    if(!ULPI_busy) MAIN_state_r <= MAIN_IDLE;
                    else           MAIN_state_r <= MAIN_REG_WAIT1;
                end
                MAIN_REG_SEND: begin
                    MAIN_state_r <= MAIN_REG_WAIT2;
                end
                MAIN_REG_WAIT2: begin
                    if(UART_Tx_FULL) MAIN_state_r <= MAIN_REG_WAIT2;
                    else             MAIN_state_r <= MAIN_IDLE;
                end
                MAIN_RECV: begin
                    MAIN_state_r <= MAIN_RECV_SEND1;
                end
                MAIN_RECV_SEND1: begin                 
                    if(UART_Tx_FULL || INFO_count_r != 0) MAIN_state_r <= MAIN_RECV_SEND1;
                    else             MAIN_state_r <= MAIN_RECV_WAIT;
                end
                MAIN_RECV_WAIT: begin       
                    if(UART_Tx_FULL)
                        MAIN_state_r <= MAIN_RECV_WAIT;
                    else begin
                        if(DATA_count_r == 0)
                            MAIN_state_r <= MAIN_IDLE;
                        else
                            MAIN_state_r <= MAIN_RECV_SEND2;
                    end
                end
                MAIN_RECV_SEND2: begin
                    if(UART_Tx_FULL || DATA_count_r != 0) MAIN_state_r <= MAIN_RECV_SEND2;
                    else             MAIN_state_r <= MAIN_IDLE;
                end
                default: MAIN_state_r <= MAIN_IDLE;
            endcase
        end
    end

    // REG data & address & CMD
    always @(negedge clk `MAIN_CONTROLLER_ASYNC_RESET) begin
        if(!rst) begin
            MAIN_cmd_r <= 2'b0;
            ULPI_ADDR_r <= 6'h0;
            ULPI_REG_VAL_W_r <= 8'b0;
        end
        else if(MAIN_s_REG_READ) begin
            MAIN_cmd_r <= op_stack_msg[15:14];
            ULPI_ADDR_r <= op_stack_msg[13:8];
        end
        else if(MAIN_s_REG_WRITE) begin
            MAIN_cmd_r <= op_stack_msg[15:14];
            ULPI_ADDR_r <= op_stack_msg[13:8];
            ULPI_REG_VAL_W_r <= op_stack_msg[7:0];
        end
        else if(MAIN_s_REG_SEND) begin
            MAIN_cmd_r <= op_stack_msg[15:14];
        end
    end

    // UART data
    always @(negedge clk `MAIN_CONTROLLER_ASYNC_RESET) begin
        if(!rst)
            UART_Tx_DATA_r <= 0;
        else if(MAIN_s_REG_SEND)
            UART_Tx_DATA_r <= ULPI_REG_VAL_R;
        // else if(MAIN_s_RECV)
        //     UART_Tx_DATA_r <= ULPI_USB_INFO_DATA[15:8];
        else if(MAIN_s_RECV_SEND1 && INFO_count_r == 2)
            UART_Tx_DATA_r <= {RxCMD_r, DATA_count_r[9:8]};
        else if(MAIN_s_RECV_SEND1 && INFO_count_r == 1)
            UART_Tx_DATA_r <= DATA_count_r[7:0];
        else if(MAIN_s_RECV_SEND2)
            UART_Tx_DATA_r <= ULPI_USB_DATA;
    end

    // DATA counter & RxCMD
    always @(negedge clk `MAIN_CONTROLLER_ASYNC_RESET) begin
        if(!rst) begin
            RxCMD_r <= 6'b0;
            DATA_count_r <= 10'b0;
        end
        else if(MAIN_s_RECV) begin
            RxCMD_r <= ULPI_USB_INFO_DATA[15:10];
            DATA_count_r <= ULPI_USB_INFO_DATA[9:0];
        end
        // else if(MAIN_s_RECV_WAIT)
        //     DATA_count_r <= DATA_count_r + 1'b1;
        else if(MAIN_s_RECV_SEND2 && !UART_Tx_FULL)
            DATA_count_r <= DATA_count_r - 1'b1;
    end

    // INFO counter
    always @(negedge clk `MAIN_CONTROLLER_ASYNC_RESET) begin
        if(!rst)
            INFO_count_r <= 0;
        else if(MAIN_s_RECV)
            INFO_count_r <= 2;
        else if(MAIN_s_RECV_SEND1 && !UART_Tx_FULL)
            INFO_count_r <= INFO_count_r - 1'b1;
    end
    // End of TOP controllers
/// End of TOP controller

endmodule