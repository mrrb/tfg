/*
 *
 * ULPI_RECV module
 * This module lets the FPGA receive USB DATA from the ULPI capable IC (usb3300 in this case)
 *
 *
 * Inputs:
 *  - rst. Synchronous/Asynchronous reset signal [Active LOW].
 *  - clk_ULPI. PHY external clock at 60MHz.
 *  - PrW. Perform register Write [Active HIGH].
 *  - ADDR. PHY address where the value will be store.
 *  - REG_VAL. Value that is going to be stored in the PHY register.
 *  - DIR. ULPI DIR (DIRection) signal.
 *  - NXT. ULPI NXT (NeXT) signal.
 *  - DATA_I. ULPI input DATA signals [PHY => LINK].
 *
 * Outputs:
 *  - busy. The module is currently writing a register.
 *  - DATA_O. ULPI output DATA signals [LINK => PHY].
 *  - STP. ULPI STP (SToP) signal.
 *
 * States:
 *  - ULPI_RECV_IDLE. .
 */

`default_nettype none

`ifdef ASYNC_RESET
    `define ULPI_RECV_ASYNC_RESET or negedge rst
`else
    `define ULPI_RECV_ASYNC_RESET
`endif

`include "./modules/FIFO_BRAM_SYNC.vh"
`include "./modules/FIFO_BRAM_SYNC_CUSTOM.vh"
`include "./modules/FIFO_MERGE.vh"

module ULPI_RECV (
                  // System signals
                  input  wire rst,          // Reset signal
                  input  wire clk_ULPI,     // 60MHz ULPI clock

                  // Control signals
                  output wire NrD,          // New received Data
                  output wire busy,         // Module busy

                  // States values
                  output wire [1:0]linestate,
                  output wire [1:0]Vbus_state,
                  output wire RxActive,
                  output wire RxError,
                  output wire HostDisconnect,
                  output wire ID_state,

                  // Buffer control
                  input  wire USB_DATA_rd_en,
                  input  wire PCK_INFO_rd_en,
                  output wire [7:0]USB_DATA_o,
                  output wire [15:0]PCK_INFO_o,
                  output wire BUFF_FULL,
                  output wire BUFF_A_FULL,
                  output wire BUFF_EMPTY,
                  output wire BUFF_A_EMPTY,

                  // Status signals

                  // ULPI signals
                  input  wire DIR,          // ULPI DIR (DIRection) signal
                  input  wire NXT,          // ULPI NXT (NeXT) signal
                  input  wire [7:0]DATA_I,  // ULPI input DATA signals [PHY => LINK]
                  output wire [7:0]DATA_O,  // ULPI output DATA signals [LINK => PHY]
                  output wire STP           // ULPI STP (SToP) signal
                 );

    /// ULPI_RECV Regs and wires
    // Outputs
    assign linestate = RxCMD[1:0];

    assign Vbus_state = RxCMD[3:2];

    wire [1:0]Rx_event;
    assign Rx_event = RxCMD[5:4];

    assign RxActive = ((Rx_event == 2'b01) || (Rx_event == 2'b11)) ? 1'b1 : 1'b0;
    assign RxError  =  (Rx_event == 2'b11) ? 1'b1 : 1'b0;
    assign HostDisconnect = (Rx_event == 2'b10) ? 1'b1 : 1'b0;

    assign ID_state = RxCMD[6];

    assign DATA_O = 8'b0;
    assign STP    = 1'b0;

    // Control registers and wires
    reg [1:0]ULPI_RECV_state_r = 2'b0; // Register that stores the current ULPI_RECV state
    reg [7:0]RxCMD = 0; // Register that stores the current Rxd Command
    reg [7:0]USB_DATA = 0;
    reg [9:0]DATA_COUNTER = 0;

    reg DATA_CTRL_r = 0;
    reg RxCMD_CTRL_r = 0;
    reg SAVE_CTRL_r = 0;

    wire DATA_CTRL;
    wire RxCMD_CTRL;

    // Flags
    wire ULPI_RECV_s_IDLE; // HIGH if ULPI_RECV_state_r == ULPI_RECV_IDLE, else LOW
    wire ULPI_RECV_s_READ; // HIGH if ULPI_RECV_state_r == ULPI_RECV_READ, else LOW
    wire ULPI_RECV_s_SAVE; // HIGH if ULPI_RECV_state_r == ULPI_RECV_SAVE, else LOW

    // Assigns
    assign ULPI_RECV_s_IDLE = (ULPI_RECV_state_r == ULPI_RECV_IDLE) ? 1'b1 : 1'b0; // #FLAG
    assign ULPI_RECV_s_READ = (ULPI_RECV_state_r == ULPI_RECV_READ) ? 1'b1 : 1'b0; // #FLAG
    assign ULPI_RECV_s_SAVE = (ULPI_RECV_state_r == ULPI_RECV_SAVE) ? 1'b1 : 1'b0; // #FLAG

    assign busy = !ULPI_RECV_s_IDLE; // #OUTPUT
    assign NrD  = ULPI_RECV_s_SAVE;  // #OUTPUT

    assign DATA_CTRL  = DIR &  NXT & !ULPI_RECV_s_IDLE; // #CONTROL
    assign RxCMD_CTRL = DIR & !NXT & !ULPI_RECV_s_IDLE; // #CONTROL
    /// End of ULPI_RECV Regs and wires

    /// ULPI_RECV States (See module description at the beginning of this file to get more info)
    localparam ULPI_RECV_IDLE = 0;
    localparam ULPI_RECV_READ = 1;
    localparam ULPI_RECV_SAVE = 2;
    /// End of ULPI_RECV States

    /// ULPI_RECV controller
    // States
    always @(posedge clk_ULPI `ULPI_RECV_ASYNC_RESET) begin
        if(!rst) ULPI_RECV_state_r <= ULPI_RECV_IDLE;
        else begin
            case(ULPI_RECV_state_r)
                ULPI_RECV_IDLE: begin
                    if(DIR && NXT) ULPI_RECV_state_r <= ULPI_RECV_READ;
                    else           ULPI_RECV_state_r <= ULPI_RECV_IDLE;
                end
                ULPI_RECV_READ: begin
                    if(!DIR) ULPI_RECV_state_r <= ULPI_RECV_SAVE;
                    else     ULPI_RECV_state_r <= ULPI_RECV_READ;
                end
                ULPI_RECV_SAVE: begin
                    ULPI_RECV_state_r <= ULPI_RECV_IDLE;
                end
                default: ULPI_RECV_state_r <= ULPI_RECV_IDLE;
            endcase
        end
    end

    // Control signals
    always @(negedge clk_ULPI `ULPI_RECV_ASYNC_RESET) begin
        if(!rst) begin
            DATA_CTRL_r <= 0;
            RxCMD_CTRL_r <= 0;
        end
        else if(!ULPI_RECV_s_IDLE) begin
            DATA_CTRL_r <= DATA_CTRL;
            RxCMD_CTRL_r <= RxCMD_CTRL;
        end
    end

    // DATA counter
    always @(negedge clk_ULPI `ULPI_RECV_ASYNC_RESET) begin
        if(!rst) DATA_COUNTER <= 0;
        else if(ULPI_RECV_s_IDLE) DATA_COUNTER <= 0;
        else if(DATA_CTRL) DATA_COUNTER <= DATA_COUNTER + 1'b1;
    end

    // DATA counter save
    // always @(negedge clk_ULPI `ULPI_RECV_ASYNC_RESET) begin
    //     if(!rst) SAVE_CTRL_r <= 0;
    //     else if(ULPI_RECV_s_READ && !DIR) SAVE_CTRL_r <= 1'b1;
    //     else SAVE_CTRL_r <= 0;
    // end

    // Input save
    always @(negedge clk_ULPI `ULPI_RECV_ASYNC_RESET) begin
        if(!rst) begin
            RxCMD <= 0;
            USB_DATA <= 0;
        end
        else if(ULPI_RECV_s_IDLE) USB_DATA <= 0;
        else if(ULPI_RECV_s_READ) begin
            if(DATA_CTRL) USB_DATA <= DATA_I;
            else if(RxCMD_CTRL) RxCMD <= DATA_I;
        end
    end
    /// End of ULPI_RECV controller

    /// Buffers
    // DATA Buffer
    wire DATA_BUFF_FULL, DATA_BUFF_A_FULL;
    wire DATA_BUFF_EMPTY, DATA_BUFF_A_EMPTY;
    FIFO_BRAM_SYNC DATA_BUFF  (
                               // System signals
                               .rst(rst),
                               .clk(clk_ULPI),

                               // Write control signals
                               .wr_dv(DATA_CTRL_r),

                               // Write data signals
                               .wr_DATA(USB_DATA),

                               // Write flags
                               .wr_full(DATA_BUFF_FULL),
                               .wr_almost_full(DATA_BUFF_A_FULL),

                               // Read control signals
                               .rd_en(USB_DATA_rd_en),

                               // Read data signals
                               .rd_DATA(USB_DATA_o),

                               // Read flags
                               .rd_empty(DATA_BUFF_EMPTY),
                               .rd_almost_empty(DATA_BUFF_A_EMPTY)
                              );

    // Size buffer
    wire DATA_SIZE_FULL, DATA_SIZE_A_FULL;
    wire DATA_SIZE_EMPTY, DATA_SIZE_A_EMPTY;
    FIFO_BRAM_SYNC_CUSTOM #(.DATA_WIDTH(`FIFO_BRAM_16))
           DATA_SIZE_BUFF  (
                            // System signals
                            .rst(rst),
                            .clk(!clk_ULPI),

                            // Write control signals
                            .wr_dv(ULPI_RECV_s_SAVE),

                            // Write data signals
                            .wr_DATA({RxCMD[5:0], DATA_COUNTER}),

                            // Write flags
                            .wr_full(DATA_SIZE_FULL),
                            .wr_almost_full(DATA_SIZE_A_FULL),

                            // Read control signals
                            .rd_en(PCK_INFO_rd_en),

                            // Read data signals
                            .rd_DATA(PCK_INFO_o),

                            // Read flags
                            .rd_empty(DATA_SIZE_EMPTY),
                            .rd_almost_empty(DATA_SIZE_A_EMPTY)
                           );
    /// End of Buffers

endmodule