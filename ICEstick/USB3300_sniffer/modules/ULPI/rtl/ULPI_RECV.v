/*
 *
 * ULPI_RECV module
 * This module lets the FPGA receive USB DATA from the ULPI capable IC (usb3300 in this case)
 *
 */

`default_nettype none

`ifdef ASYNC_RESET
    `define ULPI_RECV_ASYNC_RESET or negedge rst
`else
    `define ULPI_RECV_ASYNC_RESET
`endif

`include "./modules/FIFO_BRAM_SYNC_CUSTOM.vh"

module ULPI_RECV (
                  // System signals
                  input  wire rst,          // Reset signal
                  input  wire clk_ULPI,     // 60MHz ULPI clock

                  // Control signals
                  input  wire ReadAllow,
                  output wire busy,

                  // Rx states
                  output wire [7:0]RxCMD,
                  output wire [1:0]RxLineState,
                  output wire [1:0]RxVbusState,
                  output wire RxActive,
                  output wire RxError,
                  output wire RxHostDisconnect,
                  output wire RxID,

                  // Buffer control
                  input  wire DATA_re,
                  input  wire INFO_re,
                  output wire [7:0]USB_DATA,
                  output wire [15:0]USB_INFO_DATA,
                  output wire DATA_buff_full,
                  output wire DATA_buff_empty,
                  output wire INFO_buff_full,
                  output wire INFO_buff_empty,

                  // ULPI signals
                  input  wire DIR,          // ULPI DIR (DIRection) signal
                  input  wire NXT,          // ULPI NXT (NeXT) signal
                  input  wire [7:0]DATA_I,  // ULPI input DATA signals [PHY => LINK]
                  output wire [7:0]DATA_O,  // ULPI output DATA signals [LINK => PHY]
                  output wire STP           // ULPI STP (SToP) signal
                 );

    /// ULPI_RECV Regs and wires
    // Outputs
    wire [1:0]RxEventEncoding;
    assign RxEventEncoding = RxCMD_r[5:4];

    // Control registers and wires
    reg [1:0]ULPI_RECV_state_r = 0;
    reg [7:0]RxCMD_r = 0;
    reg [7:0]USB_DATA_r = 0;
    reg [9:0]DATA_COUNTER = 0; 

    wire ctrl_RxCMD;
    wire ctrl_DATA;

    // Flags
    wire ULPI_RECV_s_IDLE; // HIGH if ULPI_RECV_state_r == ULPI_RECV_IDLE, else LOW
    wire ULPI_RECV_s_READ; // HIGH if ULPI_RECV_state_r == ULPI_RECV_READ, else LOW
    
    // Assigns
    assign ULPI_RECV_s_IDLE = (ULPI_RECV_state_r == ULPI_RECV_IDLE) ? 1'b1 : 1'b0; // #FLAG
    assign ULPI_RECV_s_READ = (ULPI_RECV_state_r == ULPI_RECV_READ) ? 1'b1 : 1'b0; // #FLAG

    assign DATA_O = 0; // #OUTPUT
    assign STP = 0; // #OUTPUT
    assign busy = !ULPI_RECV_s_IDLE; // #OUTPUT

    assign RxCMD = RxCMD_r; // #OUTPUT
    assign RxLineState = RxCMD_r[1:0]; // #OUTPUT
    assign RxVbusState = RxCMD_r[3:2]; // #OUTPUT
    assign RxActive = RxEventEncoding[0]; // #OUTPUT
    assign RxError = (RxEventEncoding == 2'b11) ? 1'b1 : 1'b0; // #OUTPUT
    assign RxHostDisconnect = (RxEventEncoding == 2'b10) ? 1'b1 : 1'b0; // #OUTPUT
    assign RxID = RxCMD_r[6]; // #OUTPUT

    assign ctrl_DATA = DIR && NXT; // #CTRL
    assign ctrl_RxCMD = DIR && !NXT; // #CTRL
    /// End of ULPI_RECV Regs and wires

    /// ULPI_RECV States (See module description at the beginning of this file to get more info)
    localparam ULPI_RECV_IDLE = 0;
    localparam ULPI_RECV_READ = 1;
    /// End of ULPI_RECV States

    /// ULPI_RECV controller
    // States
    always @(negedge clk_ULPI `ULPI_RECV_ASYNC_RESET) begin
        if(!rst) ULPI_RECV_state_r <= ULPI_RECV_IDLE;
        else begin
            case(ULPI_RECV_state_r)
                ULPI_RECV_IDLE: begin
                    if((ctrl_DATA || ctrl_RxCMD) && ReadAllow) ULPI_RECV_state_r <= ULPI_RECV_READ;
                    else ULPI_RECV_state_r <= ULPI_RECV_IDLE;
                end
                ULPI_RECV_READ: begin
                    if(!(ctrl_DATA || ctrl_RxCMD)) ULPI_RECV_state_r <= ULPI_RECV_IDLE;
                    else ULPI_RECV_state_r <= ULPI_RECV_READ;
                end
                default: ULPI_RECV_state_r <= ULPI_RECV_IDLE;
            endcase
        end
    end

    // DATA save
    always @(negedge clk_ULPI `ULPI_RECV_ASYNC_RESET) begin
        if(!rst) begin
            RxCMD_r <= 0;
            USB_DATA_r <= 0;
        end
        else if(ctrl_RxCMD) RxCMD_r <= DATA_I;
        else if(ctrl_DATA)  USB_DATA_r <= DATA_I;
    end

    // DATA counter
    always @(negedge clk_ULPI `ULPI_RECV_ASYNC_RESET) begin
        if(!rst) DATA_COUNTER <= 0;
        else if(ULPI_RECV_s_IDLE) DATA_COUNTER <= 0;
        else if(ctrl_DATA) DATA_COUNTER <= DATA_COUNTER + 1'b1;
    end
    /// End of ULPI_RECV controller

    /// ULPI_RECV Buffers
    // Control
    wire DATA_buff_a_full, DATA_buff_a_empty;
    wire INFO_buff_a_full, INFO_buff_a_empty;
    reg DATA_dv_r = 0;
    always @(negedge clk_ULPI `ULPI_RECV_ASYNC_RESET) begin
        if(!rst) DATA_dv_r <= 0;
        else if(ctrl_DATA && busy) DATA_dv_r <= 1;
        else DATA_dv_r <= 0;
    end
    reg INFO_dv_r = 0;
    always @(negedge clk_ULPI `ULPI_RECV_ASYNC_RESET) begin
        if(!rst) INFO_dv_r <= 0;
        else if(ULPI_RECV_s_READ && !(ctrl_DATA || ctrl_RxCMD))
            INFO_dv_r <= 1;
        else INFO_dv_r <= 0;
    end

    // DATA buffer
    FIFO_BRAM_SYNC_CUSTOM #(.DATA_WIDTH(`FIFO_BRAM_8))
                DATA_BUFF  (
                            // System signals
                            .rst(rst),
                            .clk(clk_ULPI),

                            // Write control signals
                            .wr_dv(DATA_dv_r),

                            // Write data signals
                            .wr_DATA(USB_DATA_r),

                            // Write flags
                            .wr_full(DATA_buff_full),
                            .wr_almost_full(DATA_buff_a_full),

                            // Read control signals
                            .rd_en(DATA_re),

                            // Read data signals
                            .rd_DATA(USB_DATA),

                            // Read flags
                            .rd_empty(DATA_buff_empty),
                            .rd_almost_empty(DATA_buff_a_empty)
                           );

    // INFO buffer
    FIFO_BRAM_SYNC_CUSTOM #(.DATA_WIDTH(`FIFO_BRAM_16))
                INFO_BUFF  (
                            // System signals
                            .rst(rst),
                            .clk(clk_ULPI),

                            // Write control signals
                            .wr_dv(INFO_dv_r),

                            // Write data signals
                            .wr_DATA({RxCMD[5:0], DATA_COUNTER}),

                            // Write flags
                            .wr_full(INFO_buff_full),
                            .wr_almost_full(INFO_buff_a_full),

                            // Read control signals
                            .rd_en(INFO_re),

                            // Read data signals
                            .rd_DATA(USB_INFO_DATA),

                            // Read flags
                            .rd_empty(INFO_buff_empty),
                            .rd_almost_empty(INFO_buff_a_empty)
                           );
    /// End of ULPI_RECV Buffers

endmodule