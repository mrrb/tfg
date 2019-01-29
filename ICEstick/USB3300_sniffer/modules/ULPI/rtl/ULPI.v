/*
 *
 * ULPI module
 * This module lets the FPGA communicate with a ULPI compliant device (in this case, the USB3300 ic).
 *
 * In this module are instantiated all the required submodules:
 *  - 
 *
 */

`default_nettype none

`ifdef ASYNC_RESET
    `define ULPI_ASYNC_RESET or negedge rst
`else
    `define ULPI_ASYNC_RESET
`endif

`include "./modules/ULPI_RW.vh"   // ULPI_REG_WRITE submodule 
`include "./modules/ULPI_RR.vh"   // ULPI_REG_READ submodule
`include "./modules/ULPI_RECV.vh" // ULPI_RECV submodule

 module ULPI (
              // System signals
              input  wire rst,       // Reset signal
              input  wire clk_ice,   // 12MHz ICEstick reference clock
              input  wire clk_ULPI,  // 60MHz ULPI clock

              // Control signals
              input  wire PrW,
              input  wire PrR,
              output wire [2:0]status,
              output wire busy,

              // Register signals
              input  wire [5:0]ADDR,
              input  wire [7:0]REG_VAL_W,
              output wire [7:0]REG_VAL_R,

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
              input  wire DIR,           // ULPI DIR (DIRection) signal
              input  wire NXT,           // ULPI NXT (NeXT) signal
              input  wire [7:0]DATA_in,  // ULPI inout DATA signals
              output wire [7:0]DATA_out, // ULPI inout DATA signals
              output wire STP,           // ULPI STP (SToP) signal
              output wire U_RST          // ULPI RST (ReSeT) signal
             );

    /// ULPI reset
    assign U_RST = !rst;
    /// End of ULPI reset

    /// Reg_Write submodule init
    wire STP_RW;  // ULPI STP signal from the Register_Write submodule
    wire RW_busy; // Signal that indicates the submodule Register_Write is currently active
    wire [7:0]DATA_out_RW; // ULPI DATA signals from the Register_Write submodule
    ULPI_REG_WRITE ULPI_RW (
                            // System signals
                            .rst(rst),            // [Input]
                            .clk_ULPI(clk_ULPI),  // [Input]

                            // Control signals
                            .PrW(ctrl_PrW),       // [Input]
                            .busy(RW_busy),       // [Output]

                            // Register values
                            .ADDR(ADDR),          // [Input]
                            .REG_VAL(REG_VAL_W),  // [Input]

                            // ULPI signals
                            .DIR(DIR),            // [Input]
                            .NXT(NXT),            // [Input]
                            .DATA_I(DATA_in),     // [Input]
                            .DATA_O(DATA_out_RW), // [Output]
                            .STP(STP_RW)          // [Output]
                           );
    /// End of Reg_Write submodule init

    /// Reg_Read submodule init
    wire STP_RR;  // ULPI STP signal from the Register_Read submodule
    wire RR_busy; // Signal that indicates the submodule Register_Read is currently active
    wire [7:0]DATA_out_RR; // ULPI DATA signals from the Register_Read submodule
    ULPI_REG_READ ULPI_RR (
                           // System signals
                           .rst(rst),            // [Input]
                           .clk_ULPI(clk_ULPI),  // [Input]

                           // Control signals
                           .PrR(ctrl_PrR),       // [Input]
                           .busy(RR_busy),       // [Output]

                           // Register values
                           .ADDR(ADDR),          // [Input]
                           .REG_VAL(REG_VAL_R),  // [Output]

                           // ULPI signals
                           .DIR(DIR),            // [Input]
                           .NXT(NXT),            // [Input]
                           .DATA_I(DATA_in),     // [Input]
                           .DATA_O(DATA_out_RR), // [Output]
                           .STP(STP_RR)          // [Output]
                          );
    /// End of Reg_Read submodule init

    /// ULPI reciver submodule init
    wire RECV_busy;

    wire [7:0]DATA_out_RECV; // ULPI DATA signals from the ULPI_receiver submodule
    wire STP_RECV;  // ULPI STP signal from the ULPI_receiver submodule
    ULPI_RECV ULPI_RV (
                       // System signals
                       .rst(rst), // [Input]
                       .clk_ULPI(clk_ULPI), // [Input]

                       // Control signals
                       .ReadAllow(ULPI_s_IDLE), // [Input]
                       .busy(RECV_busy),

                       // Rx states
                       .RxCMD(RxCMD), // [Output]
                       .RxLineState(RxLineState), // [Output]
                       .RxVbusState(RxVbusState), // [Output]
                       .RxActive(RxActive), // [Output]
                       .RxError(RxError), // [Output]
                       .RxHostDisconnect(RxHostDisconnect), // [Output]
                       .RxID(RxID), // [Output]

                       // Buffer control
                       .DATA_re(DATA_re), // [Input]
                       .INFO_re(INFO_re), // [Input]
                       .USB_DATA(USB_DATA), // [Output]
                       .USB_INFO_DATA(USB_INFO_DATA), // [Output]
                       .DATA_buff_full(DATA_buff_full), // [Output]
                       .DATA_buff_empty(DATA_buff_empty), // [Output]
                       .INFO_buff_full(INFO_buff_full), // [Output]
                       .INFO_buff_empty(INFO_buff_empty), // [Output]

                       // ULPI signals
                       .DIR(DIR), // [Input]
                       .NXT(NXT), // [Input]
                       .DATA_I(DATA_in), // [Input]
                       .DATA_O(DATA_out_RECV), // [Output]
                       .STP(STP_RECV) // [Output]
                      );
    /// End of ULPI reciver submodule init

    /// ULPI REG/READ stack
    
    /// End of ULPI REG/READ stack

    /// ULPI master controller
    // Regs and wires
    reg [2:0]ULPI_state_r = 0; // Register that stores the current ULPI_RR state

    wire STP_out;
    wire ctrl_PrW;
    wire ctrl_PrR;

    // Flags
    wire ULPI_s_START;     // HIGH if ULPI_state_r == ULPI_START, else LOW
    wire ULPI_s_IDLE;      // HIGH if ULPI_state_r == ULPI_IDLE,  else LOW
    wire ULPI_s_REG_WRITE; // HIGH if ULPI_state_r == ULPI_REG_WRITE, else LOW
    wire ULPI_s_REG_READ;  // HIGH if ULPI_state_r == ULPI_REG_READ,  else LOW
    wire ULPI_s_RECV;      // HIGH if ULPI_state_r == ULPI_RECV, else LOW

    // Assign
    assign ULPI_s_START     = (ULPI_state_r == ULPI_START)     ? 1'b1 : 1'b0; // #FLAG
    assign ULPI_s_IDLE      = (ULPI_state_r == ULPI_IDLE)      ? 1'b1 : 1'b0; // #FLAG
    assign ULPI_s_REG_WRITE = (ULPI_state_r == ULPI_REG_WRITE) ? 1'b1 : 1'b0; // #FLAG
    assign ULPI_s_REG_READ  = (ULPI_state_r == ULPI_REG_READ)  ? 1'b1 : 1'b0; // #FLAG
    assign ULPI_s_RECV      = (ULPI_state_r == ULPI_RECV)      ? 1'b1 : 1'b0; // #FLAG

    assign ctrl_PrW = PrW && ULPI_s_IDLE && !DIR; // #CONTROL
    assign ctrl_PrR = PrR && ULPI_s_IDLE && !DIR; // #CONTROL

    assign STP = STP_out; // #OUTPUT
    assign status = ULPI_state_r; // #OUTPUT
    assign busy = !ULPI_s_IDLE; // #OUTPUT

    // States
    localparam ULPI_START     = 0;
    localparam ULPI_IDLE      = 1;
    localparam ULPI_RECV      = 2;
    localparam ULPI_REG_WRITE = 3;
    localparam ULPI_REG_READ  = 4;

    // Output mux
    assign DATA_out = (ULPI_s_REG_WRITE) ? DATA_out_RW   :
                      (ULPI_s_REG_READ)  ? DATA_out_RR   :
                      (ULPI_s_RECV)      ? DATA_out_RECV : 8'b0;
                   
    assign STP_out  = (ULPI_s_START)     ? 1'b0     :
                      (ULPI_s_REG_WRITE) ? STP_RW   :
                      (ULPI_s_REG_READ)  ? STP_RR   :
                      (ULPI_s_RECV)      ? STP_RECV : 1'b0;

    // State machine
    always @(posedge clk_ULPI `ULPI_ASYNC_RESET) begin
        if(!rst) ULPI_state_r <= ULPI_START;
        else begin
            case(ULPI_state_r)
                ULPI_START: begin
                    if(!DIR) ULPI_state_r <= ULPI_IDLE;
                    else     ULPI_state_r <= ULPI_START;
                end
                ULPI_IDLE: begin
                    if(RECV_busy)     ULPI_state_r <= ULPI_RECV;
                    else if(ctrl_PrW) ULPI_state_r <= ULPI_REG_WRITE;
                    else if(ctrl_PrR) ULPI_state_r <= ULPI_REG_READ;
                    else              ULPI_state_r <= ULPI_IDLE;
                end
                ULPI_RECV: begin
                    if(!RECV_busy) ULPI_state_r <= ULPI_IDLE;
                    else           ULPI_state_r <= ULPI_RECV;
                end
                ULPI_REG_WRITE: begin
                    if(!RW_busy) ULPI_state_r <= ULPI_IDLE;
                    else         ULPI_state_r <= ULPI_REG_WRITE;
                end
                ULPI_REG_READ: begin
                    if(!RR_busy) ULPI_state_r <= ULPI_IDLE;
                    else         ULPI_state_r <= ULPI_REG_READ;
                end
                default: ULPI_state_r <= ULPI_IDLE;
            endcase
        end
    end
    /// End of ULPI master controller

 endmodule
