/*
 *
 * ULPI_REG_WRITE module
 * This module lets the FPGA write a register inside a ULPI capable PHY device (usb3300 in this case)
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
 *  - ULPI_RW_IDLE.  The module is waiting to do a register write (This occurs when PrW is asserted for at least 1 PHY clock pulse). 
 *  - ULPI_RW_TXCMD. The LINK sends the TXCMD over the ULPI DATA bus until the PHY asserts NXT.
 *  - ULPI_RW_DATA.  The link sends the DATA over the ULPI DATA bus.
 *  - ULPI_RW_STOP.  The STP signal is activated, indicating the end of the transition.
 */

`default_nettype none

`ifdef ASYNC_RESET
    `define ULPI_RW_ASYNC_RESET or negedge rst
`else
    `define ULPI_RW_ASYNC_RESET
`endif

module ULPI_REG_WRITE (
                       // System signals
                       input  wire rst,          // Reset signal
                       input  wire clk_ULPI,     // 60MHz ULPI clock

                       // Control signals
                       input  wire PrW,          // Perform register Write
                       output wire busy,         // Module busy

                       // Register values
                       input  wire [5:0]ADDR,    // PHY address where the value will be stored
                       input  wire [7:0]REG_VAL, // Value that is going to be stored in the PHY register

                       // ULPI signals
                       input  wire DIR,          // ULPI DIR (DIRection) signal
                       input  wire NXT,          // ULPI NXT (NeXT) signal
                       input  wire [7:0]DATA_I,  // ULPI input DATA signals [PHY => LINK]
                       output wire [7:0]DATA_O,  // ULPI output DATA signals [LINK => PHY]
                       output wire STP           // ULPI STP (SToP) signal
                      );

    localparam CMD_HEADER = 2'b10; // Immediate Register Write Command
                                   // 76543210
                                   // 10xxxxxx [7:6] => CMD; [5:0] => Address

    /// ULPI_RW Regs and wires
    // Inputs
    // [2, output change on NEGEDGE]
    reg [5:0]ADDR_r = 0;
    always @(posedge clk_ULPI `ULPI_RW_ASYNC_RESET) begin
        if(!rst) ADDR_r <= 0;
        else if(PrW) ADDR_r <= ADDR;
    end

    reg [7:0]REG_VAL_r = 0;
    always @(posedge clk_ULPI `ULPI_RW_ASYNC_RESET) begin
        if(!rst) REG_VAL_r <= 0;
        else if(PrW) REG_VAL_r <= REG_VAL;
    end

    reg NXT_r = 0;
    always @(negedge clk_ULPI `ULPI_RW_ASYNC_RESET) begin
        if(!rst) NXT_r <= 0;
        else if(!ULPI_RW_s_IDLE) NXT_r <= NXT;
        else NXT_r <= 0;
    end

    // Control registers and wires
    reg [1:0]ULPI_RW_state_r = 2'b0; // Register that stores the current ULPI_RW state
    reg [7:0]DATA_O_buff     = 0;    // Buffer that stores the 8-bit DATA sent over the bus
    reg STP_buff             = 0;    // Buffer fot the STP output control signal

    // Flags
    wire ULPI_RW_s_IDLE;  // HIGH if ULPI_RW_state_r == ULPI_RW_IDLE,  else LOW
    wire ULPI_RW_s_TXCMD; // HIGH if ULPI_RW_state_r == ULPI_RW_TXCMD, else LOW
    wire ULPI_RW_s_DATA;  // HIGH if ULPI_RW_state_r == ULPI_RW_DATA,  else LOW
    wire ULPI_RW_s_STOP;  // HIGH if ULPI_RW_state_r == ULPI_RW_STOP,  else LOW

    // Assigns
    assign ULPI_RW_s_IDLE  = (ULPI_RW_state_r == ULPI_RW_IDLE)  ? 1'b1 : 1'b0; // #FLAG
    assign ULPI_RW_s_TXCMD = (ULPI_RW_state_r == ULPI_RW_TXCMD) ? 1'b1 : 1'b0; // #FLAG
    assign ULPI_RW_s_DATA  = (ULPI_RW_state_r == ULPI_RW_DATA)  ? 1'b1 : 1'b0; // #FLAG
    assign ULPI_RW_s_STOP  = (ULPI_RW_state_r == ULPI_RW_STOP)  ? 1'b1 : 1'b0; // #FLAG

    assign DATA_O = DATA_O_buff;     // #OUTPUT
    assign busy   = !ULPI_RW_s_IDLE; // #OUTPUT
    assign STP    = STP_buff;        // #OUTPUT
    /// End of ULPI_RW Regs and wires

    /// ULPI_RW States (See module description at the beginning of this file to get more info)
    localparam ULPI_RW_IDLE  = 0;
    localparam ULPI_RW_TXCMD = 1;
    localparam ULPI_RW_DATA  = 2;
    localparam ULPI_RW_STOP  = 3;
    /// End of ULPI_RW States

    /// ULPI_RW controller
    // States
    always @(posedge clk_ULPI `ULPI_RW_ASYNC_RESET) begin
        if(!rst) ULPI_RW_state_r <= ULPI_RW_IDLE;
        else begin
            case(ULPI_RW_state_r)
                ULPI_RW_IDLE: begin
                    if(PrW) ULPI_RW_state_r <= ULPI_RW_TXCMD;
                    else    ULPI_RW_state_r <= ULPI_RW_IDLE;
                end
                ULPI_RW_TXCMD: begin
                    if(NXT_r) ULPI_RW_state_r <= ULPI_RW_DATA;
                    else      ULPI_RW_state_r <= ULPI_RW_TXCMD;
                end
                ULPI_RW_DATA: begin
                    if(NXT_r) ULPI_RW_state_r <= ULPI_RW_STOP;
                    else      ULPI_RW_state_r <= ULPI_RW_DATA;
                end
                ULPI_RW_STOP: begin
                    ULPI_RW_state_r <= ULPI_RW_IDLE;
                end
                default: ULPI_RW_state_r <= ULPI_RW_IDLE;
            endcase
        end
    end

    // Outputs [1, output change on POSEDGE]
    // always @(posedge clk_ULPI `ULPI_RW_ASYNC_RESET) begin
    //     if(!rst) DATA_O_buff <= 0;
    //     else begin
    //         case(ULPI_RW_state_r)
    //             ULPI_RW_IDLE: begin
    //                 if(PrW) DATA_O_buff <= {CMD_HEADER, ADDR};
    //                 else    DATA_O_buff <= 0;
    //             end
    //             ULPI_RW_TXCMD: begin
    //                 if(NXT_r) DATA_O_buff <= REG_VAL_r;
    //                 else      DATA_O_buff <= DATA_O_buff;
    //             end
    //             ULPI_RW_DATA: begin
    //                 if(NXT_r) DATA_O_buff <= 0;
    //                 else      DATA_O_buff <= DATA_O_buff;
    //             end
    //             ULPI_RW_STOP: begin
    //                 DATA_O_buff <= 0;
    //             end
    //             default: DATA_O_buff <= 0;
    //         endcase
    //     end
    // end

    // always @(posedge clk_ULPI `ULPI_RW_ASYNC_RESET) begin
    //     if(!rst) STP_buff <= 1'b0;
    //     else begin
    //         case(ULPI_RW_state_r)
    //             ULPI_RW_IDLE: begin
    //                 STP_buff <= 1'b0;
    //             end
    //             ULPI_RW_TXCMD: begin
    //                 STP_buff <= 1'b0;
    //             end
    //             ULPI_RW_DATA: begin
    //                 if(NXT_r) STP_buff <= 1'b1;
    //                 else      STP_buff <= 1'b0;
    //             end
    //             ULPI_RW_STOP: begin
    //                 STP_buff <= 1'b0;
    //             end
    //             default: STP_buff <= 1'b0;
    //         endcase
    //     end
    // end

    // Outputs [2, output change on NEGEDGE]
    always @(negedge clk_ULPI `ULPI_RW_ASYNC_RESET) begin
        if(!rst)                 DATA_O_buff <= 0;
        else if(ULPI_RW_s_TXCMD) DATA_O_buff <= {CMD_HEADER, ADDR_r};
        else if(ULPI_RW_s_DATA)  DATA_O_buff <= REG_VAL_r;
        else                     DATA_O_buff <= 0;
    end

    always @(negedge clk_ULPI `ULPI_RW_ASYNC_RESET) begin
        if(!rst)                STP_buff <= 1'b0;
        else if(ULPI_RW_s_STOP) STP_buff <= 1'b1;
        else                    STP_buff <= 1'b0;
    end
    /// End of ULPI_RW controller

endmodule