/*
 *
 * ULPI_REG_READ module
 * This module let the FPGA read a register inside a ULPI capable PHY device (usb3300 in this case)
 *
 *
 * Inputs:
 *  - rst. Synchronous/Asynchronous reset signal [Active LOW].
 *  - clk_ULPI. PHY external clock at 60MHz.
 *  - PrR. Perform register Read [Active HIGH].
 *  - ADDR. PHY address where the value will be read.
 *  - DIR. ULPI DIR (DIRection) signal.
 *  - NXT. ULPI NXT (NeXT) signal.
 *  - DATA_I. ULPI input DATA signals [PHY => LINK].
 *
 * Outputs:
 *  - busy. The module is currently reading a register.
 *  - REG_VAL. The value obtained from the PHY.
 *  - DATA_O. ULPI output DATA signals [LINK => PHY].
 *  - STP. ULPI STP (SToP) signal.
 *
 * States:
 *  - ULPI_RR_IDLE.  The module is waiting to do a register read (This occurs when PrR is asserted for at least 1 PHY clock pulse).
 *  - ULPI_RR_TXCMD. The LINK sends the TXCMD over the ULPI DATA bus until the PHY asserts STP.
 *  - ULPI_RR_WAIT1. Firts clk_ULPI pulse wait [PHY turn around].
 *  - ULPI_RR_READ.  The LINK stores the value send over the ULPI DATA bus.
 *  - ULPI_RR_WAIT2. Second clk_ULPI pulse wait [PHY turn around].
 */

`default_nettype none

`ifdef ASYNC_RESET
    `define ULPI_RR_ASYNC_RESET or negedge rst
`else
    `define ULPI_RR_ASYNC_RESET
`endif

module ULPI_REG_READ (
                      // System signals
                      input  wire rst,          // Reset signal
                      input  wire clk_ULPI,     // 60MHz ULPI clock

                      // Control signals
                      input  wire PrR,          // Perform register Read
                      output wire busy,         // Module busy

                      // Register values
                      input  wire [5:0]ADDR,    // PHY address where the value is going to be read
                      output wire [7:0]REG_VAL, // The value obtained from the PHY

                      // ULPI signals
                      input  wire DIR,          // ULPI DIR (DIRection) signal
                      input  wire NXT,          // ULPI NXT (NeXT) signal
                      input  wire [7:0]DATA_I,  // ULPI input DATA signals [PHY => LINK]
                      output wire [7:0]DATA_O,  // ULPI output DATA signals [LINK => PHY]
                      output wire STP           // ULPI STP (SToP) signal
                     );

    localparam CMD_HEADER = 2'b11; // Immediate Register Read Command
                                   // 76543210
                                   // 11xxxxxx [7:6] => CMD; [5:0] => Address

    /// ULPI_RR Regs and wires
    // Inputs

    // Control registers and wires
    reg [2:0]ULPI_RR_state_r = 3'b0; // Register that stores the current ULPI_RR state
    reg [7:0]DATA_O_buff     = 0;    // Buffer that stores the 8-bit DATA sent over the bus
    reg [7:0]REG_VAL_buff    = 0;    // Buffer that stores the 8-bit value read from the PHY

    wire [7:0]TXCMD;

    // Flags
    wire ULPI_RR_s_IDLE;  // HIGH if ULPI_RR_state_r == ULPI_RR_IDLE,  else LOW
    wire ULPI_RR_s_TXCMD; // HIGH if ULPI_RR_state_r == ULPI_RR_TXCMD, else LOW
    wire ULPI_RR_s_WAIT1; // HIGH if ULPI_RR_state_r == ULPI_RR_WAIT1, else LOW
    wire ULPI_RR_s_READ;  // HIGH if ULPI_RR_state_r == ULPI_RR_READ,  else LOW
    wire ULPI_RR_s_WAIT2; // HIGH if ULPI_RR_state_r == ULPI_RR_WAIT2, else LOW

    // Assigns
    assign ULPI_RR_s_IDLE  = (ULPI_RR_state_r == ULPI_RR_IDLE)  ? 1'b1 : 1'b0; // #FLAG
    assign ULPI_RR_s_TXCMD = (ULPI_RR_state_r == ULPI_RR_TXCMD) ? 1'b1 : 1'b0; // #FLAG
    assign ULPI_RR_s_WAIT1 = (ULPI_RR_state_r == ULPI_RR_WAIT1) ? 1'b1 : 1'b0; // #FLAG
    assign ULPI_RR_s_READ  = (ULPI_RR_state_r == ULPI_RR_READ)  ? 1'b1 : 1'b0; // #FLAG
    assign ULPI_RR_s_WAIT2 = (ULPI_RR_state_r == ULPI_RR_WAIT2) ? 1'b1 : 1'b0; // #FLAG

    assign STP     = 1'b0;            // #OUTPUT
    assign busy    = !ULPI_RR_s_IDLE; // #OUTPUT
    assign DATA_O  = DATA_O_buff;     // #OUTPUT
    assign REG_VAL = REG_VAL_buff;    // #OUTPUT

    assign TXCMD = {CMD_HEADER, ADDR}; // #CONTROL
    /// End of ULPI_RR Regs and wires

    /// ULPI_RR States (See module description at the beginning of this file to get more info)
    localparam ULPI_RR_IDLE  = 0;
    localparam ULPI_RR_TXCMD = 1;
    localparam ULPI_RR_WAIT1 = 2;
    localparam ULPI_RR_READ  = 3;
    localparam ULPI_RR_WAIT2 = 4;
    /// End of ULPI_RR States

    /// ULPI_RR controller
    // States
    always @(posedge clk_ULPI `ULPI_RR_ASYNC_RESET) begin
        if(!rst) ULPI_RR_state_r <= ULPI_RR_IDLE;
        else begin
            case(ULPI_RR_state_r)
                ULPI_RR_IDLE: begin
                    if(PrR) ULPI_RR_state_r <= ULPI_RR_TXCMD;
                    else    ULPI_RR_state_r <= ULPI_RR_IDLE;
                end
                ULPI_RR_TXCMD: begin
                    if(NXT) ULPI_RR_state_r <= ULPI_RR_WAIT1;
                    else    ULPI_RR_state_r <= ULPI_RR_TXCMD;
                end
                ULPI_RR_WAIT1: ULPI_RR_state_r <= ULPI_RR_READ;
                ULPI_RR_READ:  ULPI_RR_state_r <= ULPI_RR_WAIT2;
                ULPI_RR_WAIT2: ULPI_RR_state_r <= ULPI_RR_IDLE;
                default: ULPI_RR_state_r <= ULPI_RR_IDLE;
            endcase
        end
    end

    // Register value output controller
    always @(posedge clk_ULPI `ULPI_RR_ASYNC_RESET) begin
        if(!rst)                REG_VAL_buff <= 0;
        else if(ULPI_RR_s_READ) REG_VAL_buff <= DATA_I;
    end

    // DATA Output controller
    always @(negedge clk_ULPI `ULPI_RR_ASYNC_RESET) begin
        if(!rst)                 DATA_O_buff <= 0;
        else if(ULPI_RR_s_TXCMD) DATA_O_buff <= TXCMD;
        else                     DATA_O_buff <= 0;
    end
    /// End of ULPI_RR controller

endmodule