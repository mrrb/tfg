/*
 *
 * ULPI_op_stack module
 * ULPI_op_stack module let the PC control what the FPGA has to send to the PHY.
 *
 * Inputs:
 *  - rst. Synchronous/Asynchronous reset signal [Active LOW].
 *  - clk. Reference clock.
 *  - UART_Rx_EMPTY.
 *  - UART_DATA.
 *
 * Outputs:
 *  - UART_NxT.
 *  - RW_stack_msg.
 *  - RW_stack_push.
 *
 */

`default_nettype none

`ifdef ASYNC_RESET
    `define ULPI_STACK_CTRL_ASYNC_RESET
`else
    `define ULPI_STACK_CTRL_ASYNC_RESET
`endif

`include "./modules/FIFO_BRAM_SYNC_CUSTOM.vh"

module ULPI_op_stack (
                      // System signals
                      input  wire rst, // Reset signal
                      input  wire clk, // Reference clock input

                      // UART Rx Buffer signals
                      input  wire [7:0]UART_DATA, //
                      input  wire UART_Rx_EMPTY,  //
                      output wire UART_NxT,       //

                      // Stack control signals
                      input  wire op_stack_pull,
                      output wire [15:0]op_stack_msg,
                      output wire op_stack_full,
                      output wire op_stack_empty
                     );

    // DATA buffer
    wire RW_stack_full, RW_stack_a_full;
    wire RW_stack_empty, RW_stack_a_empty;

    assign op_stack_full = RW_stack_full;
    assign op_stack_empty = RW_stack_empty;

    FIFO_BRAM_SYNC_CUSTOM #(.DATA_WIDTH(`FIFO_BRAM_16))
                 op_stack  (
                            // System signals
                            .rst(rst),
                            .clk(clk),

                            // Write control signals
                            .wr_dv(SERIAL_s_PUSH),

                            // Write data signals
                            .wr_DATA(serial_msg_r),

                            // Write flags
                            .wr_full(RW_stack_full),
                            .wr_almost_full(RW_stack_a_full),

                            // Read control signals
                            .rd_en(op_stack_pull),

                            // Read data signals
                            .rd_DATA(op_stack_msg),

                            // Read flags
                            .rd_empty(RW_stack_empty),
                            .rd_almost_empty(RW_stack_a_empty)
                           );

    /// ULPI_op_stack controller
    // ULPI_op_stack Regs and wires
    // Control registers and wires
    reg [1:0] serial_state_r = 0;
    reg n_byte_r = 0;
    reg [15:0] serial_msg_r = 0;

    // Flags
    wire SERIAL_s_IDLE; // HIGH if serial_state_r == SERIAL_IDLE, else LOW
    wire SERIAL_s_READ; // HIGH if serial_state_r == SERIAL_READ, else LOW
    wire SERIAL_s_PUSH; // HIGH if serial_state_r == SERIAL_PUSH, else LOW

    // Assigns
    assign SERIAL_s_IDLE = (serial_state_r == SERIAL_IDLE) ? 1'b1 : 1'b0; // #FLAG
    assign SERIAL_s_READ = (serial_state_r == SERIAL_READ) ? 1'b1 : 1'b0; // #FLAG
    assign SERIAL_s_PUSH = (serial_state_r == SERIAL_PUSH) ? 1'b1 : 1'b0; // #FLAG

    assign UART_NxT = SERIAL_s_READ; // #OUTPUT
    // End of ULPI_op_stack Regs and wires

    // ULPI_op_stack States
    localparam SERIAL_IDLE = 0;
    localparam SERIAL_READ = 1;
    localparam SERIAL_PUSH = 2;
    // End of ULPI_op_stack States

    // ULPI_op_stack controller
    // States
    always @(posedge clk `ULPI_STACK_CTRL_ASYNC_RESET) begin
        if(!rst) serial_state_r <= SERIAL_IDLE;
        else begin
            case(serial_state_r)
                SERIAL_IDLE: begin
                    if(!UART_Rx_EMPTY) serial_state_r <= SERIAL_READ;
                    else               serial_state_r <= SERIAL_IDLE;
                end
                SERIAL_READ:
                    if(n_byte_r == 1'b1) serial_state_r <= SERIAL_PUSH;
                    else                 serial_state_r <= SERIAL_IDLE;
                SERIAL_PUSH:
                    serial_state_r <= SERIAL_IDLE;
                default:
                    serial_state_r <= SERIAL_IDLE;
            endcase
        end
    end

    // Msg parser
    always @(posedge clk `ULPI_STACK_CTRL_ASYNC_RESET) begin
        if(!rst) serial_msg_r <= 0;
        else if(SERIAL_s_READ && n_byte_r==1'b0)
            serial_msg_r[15:8] <= UART_DATA;
        else if(SERIAL_s_READ && n_byte_r==1'b1)
            serial_msg_r[7:0]  <= UART_DATA;
    end

    // Byte counter
    always @(posedge clk `ULPI_STACK_CTRL_ASYNC_RESET) begin
        if(!rst)
            n_byte_r <= 0;
        else if(SERIAL_s_READ)
            n_byte_r <= n_byte_r + 1'b1;
        else if(SERIAL_s_PUSH)
            n_byte_r <= 0;
    end
    // End of ULPI_op_stack controllers
    /// End of ULPI_op_stack contoller


endmodule