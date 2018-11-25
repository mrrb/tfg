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

`include "./modules/ULPI_RW.vh" // ULPI_REG_WRITE submodule 
`include "./modules/ULPI_RR.vh" // ULPI_REG_READ submodule

 module ULPI (
              // System signals
              input  wire rst,       // Reset signal
              input  wire clk_ice,   // 12MHz ICEstick reference clock
              input  wire clk_ULPI,  // 60MHz ULPI clock

              // Control signals
              input  wire PrW,
              input  wire PrR,
              output wire NrD,
              output wire [2:0]status,

              // Register signals
              input  wire [5:0]ADDR,
              input  wire [7:0]REG_VAL_W,
              output wire [7:0]REG_VAL_R,

              // ULPI signals
              input  wire DIR,       // ULPI DIR (DIRection) signal
              input  wire NXT,       // ULPI NXT (NeXT) signal
              inout  wire [7:0]DATA, // ULPI inout DATA signals
              output wire STP,       // ULPI STP (SToP) signal
              output wire U_RST      // ULPI RST (ReSeT) signal
             );

    /// ULPI reset
    assign U_RST = rst;
    /// End of ULPI reset

    /// DATA inout selector
    reg [7:0]DATA_out; // Data generated in the FPGA (link)
    assign DATA = (DIR) ? 8'bz : DATA_out; // When the PHY has the ownership of the bus, the FPGA must have the inputs in a HIGH impedance mode
                                           // so there will not have any conflicts.
    wire [7:0]DATA_in;
    assign DATA_in = DATA;
    /// End of DATA inout selector

    // /// Metastability solver
    // // Check the reference doc FPGA_ICE40/wp-01082-quartus-ii-metastability.pdf for more info
    // // (Or https://www.intel.com/content/dam/www/programmable/us/en/pdfs/literature/wp/wp-01082-quartus-ii-metastability.pdf)
    // reg [7:0]DATA_A, DATA_B;
    // wire [7:0]DATA_in;
    // assign DATA_in = DATA_B;

    // always @(posedge clk_ULPI `ULPI_ASYNC_RESET) begin
    //     if(!rst) begin
    //         DATA_A <= 0;
    //         DATA_B <= 0;
    //     end
    //     else if(DIR) begin
    //         DATA_A <= DATA;
    //         DATA_B <= DATA_A;
    //     end
    // end
    // /// End of Metastability solver

    /// Reg_Write submodule init
    wire RW_busy;
    wire [7:0]DATA_out_RW;
    wire STP_RW;
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
    wire RR_busy;
    wire [7:0]DATA_out_RR;
    wire STP_RR;
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
    wire RECV_busy; assign RECV_busy = 0;
    wire [7:0]DATA_out_RECV; assign DATA_out_RECV = 0;
    wire STP_RECV; assign STP_RECV = 0;
    /// End of ULPI reciver submodule init

    /// ULPI master controller
    // Regs and wires
    reg [2:0]ULPI_state_r = 0; // Register that stores the current ULPI_RR state

    reg STP_r;

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

    assign STP = STP_r; // #OUTPUT
    assign status = ULPI_state_r - 1'b1; // #OUTPUT

    // States
    localparam ULPI_START     = 0;
    localparam ULPI_IDLE      = 1;
    localparam ULPI_RECV      = 2;
    localparam ULPI_REG_WRITE = 3;
    localparam ULPI_REG_READ  = 4;

    // Output mux
    always @(*) begin
        if(ULPI_s_START)          DATA_out = 8'b0;
        else if(ULPI_s_IDLE)      DATA_out = 8'b0;
        else if(ULPI_s_REG_WRITE) DATA_out = DATA_out_RW;
        else if(ULPI_s_REG_READ)  DATA_out = DATA_out_RR;
        else if(ULPI_s_RECV)      DATA_out = DATA_out_RECV;
    end

    always @(*) begin
        if(ULPI_s_START)          STP_r = 8'b1;
        else if(ULPI_s_IDLE)      STP_r = 8'b0;
        else if(ULPI_s_REG_WRITE) STP_r = STP_RW;
        else if(ULPI_s_REG_READ)  STP_r = STP_RR;
        else if(ULPI_s_RECV)      STP_r = STP_RECV;
    end
    assign DATA_out = (ULPI_s_REG_WRITE) ? DATA_out_RW   :
                      (ULPI_s_REG_READ)  ? DATA_out_RR   :
                      (ULPI_s_RECV)      ? DATA_out_RECV : 8'b0;
                   
    assign STP_r = (ULPI_s_START)     ? 8'b1     :
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
