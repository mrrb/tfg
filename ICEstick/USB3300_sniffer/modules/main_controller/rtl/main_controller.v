/*
 *
 * main_controller module
 * This module controls all the others submodules.
 *
 * Inputs:
 *  - rst. Reset signal.
 *  - clk. Reference clock.
 *  - force_send. This signal forces the send of a byte through the serial port.
 *  - op_stack_msg. Operation that the controller has to do.
 *  - op_stack_empty. Signal that indicates that the operation buffer is empty.
 *  - ULPI_busy. Signal that indicates that the ULPI controller is busy.
 *  - ULPI_USB_DATA. Data received through the ULPI module that is stored in the buffer.
 *  - ULPI_USB_INFO_DATA. Information about the data stored in the buffer (Last TxCMD and size). 
 *  - ULPI_DATA_buff_empty. Signal that indicates that the ULPI DATA buffer is empty
 *  - ULPI_INFO_buff_empty. Signal that indicates that the ULPI INFO buffer is empty
 *  - ULPI_REG_VAL_R. Value stored in the register with the address given by ULPI_ADDR of the USB3300 ic.
 *  - UART_Tx_FULL. Signal that indicates that the UART transmission buffer is full.
 *
 * Outputs:
 *  - op_stack_pull. Signal that makes the operation stack gets the next operation.
 *  - ULPI_DATA_re. Signal that makes the ULPI_DATA buffer gets the next stored value.
 *  - ULPI_INFO_re. Signal that makes the ULPI_INFO buffer gets the next stored value.
 *  - ULPI_REG_VAL_W. Data that is going to be stored in a USB3300 register.
 *  - ULPI_ADDR. Address that is going to be read/write.
 *  - ULPI_PrW. Signal that makes the ULPI controller write the USB3300 ULPI_ADDR register with the data in ULPI_REG_VAL_W.
 *  - ULPI_PrR. Signal that makes the ULPI controller read the USB3300 ULPI_ADDR register.
 *  - UART_Tx_DATA. Data that is going to be send in through the serial port.
 *  - UART_send. Signal that send the data of UART_Tx_DATA.
 *
 * States:
 *  - MAIN_IDLE. The module is waiting for a new operation.
 *  - MAIN_REG_READ. The module activates the signal that controls the REGISTER READ operation.
 *  - MAIN_REG_WRITE. The module activates the signal that controls the REGISTER WRITE operation.
 *  - MAIN_REG_WAIT. The module waits until the ULPI module isn't busy.
 *  - MAIN_REG_SEND. The module stores the ULPI_REG_VAL_R data in the UART_Tx register.
 *  - MAIN_FORCE_SEND. The module stores an arbitrary value in the UART_Tx register.
 *  - MAIN_UART_WAIT. The module waits until the data in the UART_Tx register has been accepetd by the UART module.
 *  - MAIN_RECV. If enabled, the module prepares the data stored in the ULPI buffer.
 *  - MAIN_RECV_SEND1. The module sends the 2bytes of INFO data.
 *  - MAIN_RECV_WAIT. The module waits until the UART_Tx buffer is empty and goes back to the IDLE state if there isn't any data in the buffer or goes to the second sending state.
 *  - MAIN_RECV_SEND2. The module send n bytes (n was obtained in the INFO data) of data through the UART connection.
 *  - MAIN_RECV_TOGGLE. The module turns on/off the capability to send the data stored in the ULPI buffer.
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
                        input  wire rst,                       // Reset signal
                        input  wire clk,                       // Reference clock input
                        input  wire force_send,                // Send an arbitrary value

                        // Op stack
                        input  wire [15:0] op_stack_msg,       // Next operation stored in the op_buffer
                        input  wire op_stack_empty,            // Signal that indicates that the op_stack is empty
                        output wire op_stack_pull,             // Signal that request a new operation

                        // General ULPI signals
                        input  wire ULPI_busy,                 // Sgnal that indicates that the ULPI module is busy
                        
                        // DATA ULPI signals
                        input  wire [7:0] ULPI_USB_DATA,       // USB DATA ready to be read
                        input  wire [15:0] ULPI_USB_INFO_DATA, // INFORMATION about the USB DATA
                        input  wire ULPI_DATA_buff_empty,      // Signal that indicates that the ULPI_DATA_buff is empty
                        input  wire ULPI_INFO_buff_empty,      // Signal that indicates that the ULPI_INFO_buff is empty
                        output wire ULPI_DATA_re,              // Signal that requests the next stored data byte
                        output wire ULPI_INFO_re,              // Signal that requests the next INFO DATA

                        // Register ULPI signals
                        input  wire [7:0] ULPI_REG_VAL_R,      // Readed ULPI register value
                        output wire [7:0] ULPI_REG_VAL_W,      // ULPI register value to be written
                        output wire [5:0] ULPI_ADDR,           // ULPI register address
                        output wire ULPI_PrW,                  // Perform Register Write
                        output wire ULPI_PrR,                  // Perform Register Read

                        // UART
                        input  wire UART_Tx_FULL,              // Signal that indicates that the UART_Tx buffer is empty
                        output wire [7:0] UART_Tx_DATA,        // UART data
                        output wire UART_send                  // Signal that makes the UART module send a byte
                       );

    /// TOP controller
    // TOP Regs and wires
    // Control registers and wires
    reg [3:0] MAIN_state_r = 0; // Register that stores the current module state
    reg [1:0] MAIN_cmd_r = 0;   // Register that stores the command that the controller is doing

    reg [5:0] ULPI_ADDR_r = 0;      // Address where the ULPI module has to read/write
    reg [7:0] ULPI_REG_VAL_W_r = 0; // Register where the register value that is going to be write is temporarily stored

    reg [5:0] RxCMD_r = 0;      // Last RxCMD known
    reg [1:0] INFO_count_r = 0; // Register thar gets track of the current INFO byte transferred
    reg [9:0] DATA_count_r = 0; // Register that gets track of the current DATA byte trasnferred

    reg [7:0] UART_Tx_DATA_r = 0; // Register that stores the byte that is going to be send through the serial port

    reg toggle_r = 0; // Register that activates the automatic data send

    // Flags
    wire MAIN_s_IDLE;        // HIGH if MAIN_state_r == MAIN_IDLE,        else LOW
    wire MAIN_s_REG_READ;    // HIGH if MAIN_state_r == MAIN_REG_READ,    else LOW
    wire MAIN_s_REG_WRITE;   // HIGH if MAIN_state_r == MAIN_REG_WRITE,   else LOW
    wire MAIN_s_REG_WAIT;    // HIGH if MAIN_state_r == MAIN_REG_WAIT,    else LOW
    wire MAIN_s_REG_SEND;    // HIGH if MAIN_state_r == MAIN_REG_SEND,    else LOW
    wire MAIN_s_FORCE_SEND;  // HIGH if MAIN_state_r == MAIN_FORCE_SEND,  else LOW
    wire MAIN_s_UART_WAIT;   // HIGH if MAIN_state_r == MAIN_UART_WAIT,   else LOW
    wire MAIN_s_RECV;        // HIGH if MAIN_state_r == MAIN_RECV,        else LOW
    wire MAIN_s_RECV_SEND1;  // HIGH if MAIN_state_r == MAIN_RECV_SEND1,  else LOW
    wire MAIN_s_RECV_WAIT;   // HIGH if MAIN_state_r == MAIN_RECV_WAIT,   else LOW
    wire MAIN_s_RECV_SEND2;  // HIGH if MAIN_state_r == MAIN_RECV_SEND2,  else LOW
    wire MAIN_s_RECV_TOGGLE; // HIGH if MAIN_state_r == MAIN_RECV_TOGGLE, else LOW

    // Assigns
    assign MAIN_s_IDLE        = (MAIN_state_r == MAIN_IDLE)        ? 1'b1 : 1'b0; // #FLAG
    assign MAIN_s_REG_READ    = (MAIN_state_r == MAIN_REG_READ)    ? 1'b1 : 1'b0; // #FLAG
    assign MAIN_s_REG_WRITE   = (MAIN_state_r == MAIN_REG_WRITE)   ? 1'b1 : 1'b0; // #FLAG
    assign MAIN_s_REG_WAIT    = (MAIN_state_r == MAIN_REG_WAIT)    ? 1'b1 : 1'b0; // #FLAG
    assign MAIN_s_REG_SEND    = (MAIN_state_r == MAIN_REG_SEND)    ? 1'b1 : 1'b0; // #FLAG
    assign MAIN_s_FORCE_SEND  = (MAIN_state_r == MAIN_FORCE_SEND)  ? 1'b1 : 1'b0; // #FLAG
    assign MAIN_s_UART_WAIT   = (MAIN_state_r == MAIN_UART_WAIT)   ? 1'b1 : 1'b0; // #FLAG
    assign MAIN_s_RECV        = (MAIN_state_r == MAIN_RECV)        ? 1'b1 : 1'b0; // #FLAG
    assign MAIN_s_RECV_SEND1  = (MAIN_state_r == MAIN_RECV_SEND1)  ? 1'b1 : 1'b0; // #FLAG
    assign MAIN_s_RECV_WAIT   = (MAIN_state_r == MAIN_RECV_WAIT)   ? 1'b1 : 1'b0; // #FLAG
    assign MAIN_s_RECV_SEND2  = (MAIN_state_r == MAIN_RECV_SEND2)  ? 1'b1 : 1'b0; // #FLAG
    assign MAIN_s_RECV_TOGGLE = (MAIN_state_r == MAIN_RECV_TOGGLE) ? 1'b1 : 1'b0; // #FLAG

    assign ULPI_ADDR = ULPI_ADDR_r; // #OUTPUT
    assign ULPI_REG_VAL_W = ULPI_REG_VAL_W_r; // #OUTPUT
    assign ULPI_PrW = (MAIN_cmd_r == 2'b10) ? MAIN_s_REG_WAIT : 1'b0; // #OUTPUT
    assign ULPI_PrR = (MAIN_cmd_r == 2'b11) ? MAIN_s_REG_WAIT : 1'b0; // #OUTPUT

    assign UART_Tx_DATA = UART_Tx_DATA_r; // #OUTPUT
    assign UART_send = MAIN_s_UART_WAIT  ||
                       MAIN_s_RECV_SEND1 ||
                       MAIN_s_RECV_SEND2;   // #OUTPUT

    assign op_stack_pull = MAIN_s_REG_READ    ||
                           MAIN_s_REG_WRITE   ||
                           MAIN_s_RECV        ||
                           MAIN_s_RECV_TOGGLE ||
                           MAIN_s_REG_SEND;      // #OUTPUT

    assign ULPI_INFO_re = MAIN_s_RECV; // #OUTPUT
    assign ULPI_DATA_re = MAIN_s_RECV_SEND2 && !UART_Tx_FULL; // #OUTPUT
    // End of TOP Regs and wires

    // TOP States
    localparam MAIN_IDLE        = 0;
    localparam MAIN_REG_READ    = 1;
    localparam MAIN_REG_WRITE   = 2;
    localparam MAIN_REG_WAIT    = 3;
    localparam MAIN_REG_SEND    = 4;
    localparam MAIN_FORCE_SEND  = 5;
    localparam MAIN_UART_WAIT   = 6;
    localparam MAIN_RECV        = 7;
    localparam MAIN_RECV_SEND1  = 8;
    localparam MAIN_RECV_WAIT   = 9;
    localparam MAIN_RECV_SEND2  = 10;
    localparam MAIN_RECV_TOGGLE = 11;
    // End of TOP States

    // TOP controller
    // States
    always @(posedge clk `MAIN_CONTROLLER_ASYNC_RESET) begin
        if(!rst) MAIN_state_r <= MAIN_IDLE;
        else begin
            case(MAIN_state_r)
                MAIN_IDLE: begin
                    if(!op_stack_empty) begin
                        /*
                           00 -> RECV_TOGGLE
                           01 -> REG_SEND
                           10 -> REG_WRITE
                           11 -> REG_READ
                         */
                        if(op_stack_msg[15:14] == 2'b00)
                            MAIN_state_r <= MAIN_RECV_TOGGLE;
                        else if(op_stack_msg[15:14] == 2'b01)
                            MAIN_state_r <= MAIN_REG_SEND;
                        if(op_stack_msg[15:14] == 2'b10)
                            MAIN_state_r <= MAIN_REG_WRITE;
                        else if(op_stack_msg[15:14] == 2'b11)
                            MAIN_state_r <= MAIN_REG_READ;
                    end
                    else if(!ULPI_INFO_buff_empty && toggle_r)
                        MAIN_state_r <= MAIN_RECV;
                    else if(force_send)
                        MAIN_state_r <= MAIN_FORCE_SEND;
                    else
                        MAIN_state_r <= MAIN_IDLE;
                end
                MAIN_REG_READ: begin
                    MAIN_state_r <= MAIN_REG_WAIT;
                end
                MAIN_REG_WRITE: begin
                    MAIN_state_r <= MAIN_REG_WAIT;
                end
                MAIN_REG_WAIT: begin
                    if(!ULPI_busy) MAIN_state_r <= MAIN_IDLE;
                    // if(!ULPI_busy) MAIN_state_r <= MAIN_FORCE_SEND;
                    else           MAIN_state_r <= MAIN_REG_WAIT;
                end
                MAIN_REG_SEND: begin
                    MAIN_state_r <= MAIN_UART_WAIT;
                end
                MAIN_FORCE_SEND: begin
                    MAIN_state_r <= MAIN_UART_WAIT;
                end
                MAIN_UART_WAIT: begin
                    if(UART_Tx_FULL) MAIN_state_r <= MAIN_UART_WAIT;
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
                MAIN_RECV_TOGGLE: begin
                    MAIN_state_r <= MAIN_IDLE;
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
        else if(MAIN_s_FORCE_SEND)
            // UART_Tx_DATA_r <= "M";
            UART_Tx_DATA_r <= ULPI_REG_VAL_R;
            // UART_Tx_DATA_r <= 8'b10110010;
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

    // Toggle
    always @(negedge clk `MAIN_CONTROLLER_ASYNC_RESET) begin
        if(!rst)
            toggle_r = 0;
        else if(MAIN_s_RECV_TOGGLE && op_stack_msg[7:0] == 8'b10010110)
            toggle_r = !toggle_r;
    end
    // End of TOP controllers
/// End of TOP controller

endmodule