/*
 This module has the instructions set that let read data from the PHY registers

 States:
    1. READ_IDLE. This module is doing nothing until the READ_DATA input is activated.
    2. READ_TXCMD. Once the READ signal is asserted, the LINK has the ownership of the bus and send the TXCMD 8bit data ('11'cmd+{6bit Address}).
                   The PHY will respond activating the NXT signal indicating that TXCMD has been successfully latched.
    3. READ_WAIT. The PHY takes control over the ULPI bus (making the DIR input HIGH).
                  Because of that, we hace to wait 1 clk pulse for the "TURN AROUND" to finish.
    4. READ_SAVE_DATA. After that, we just need to read the value sent over the bus and wait for the PHY to return the ownership to the LINK (DIR goes back to a low value).

 */

`default_nettype none

module ULPI_REG_READ (
                      // System signals
                      input  wire clk, // Clock input signal
                      input  wire rst, // Master reset signal
                      // ULPI controller signals
                      input  wire READ_DATA, // Signal to initiate a register READ
                      input  wire [5:0]ADDR, // Input that transmit the 6 bit address where we want to READ the DATA
                      output wire [7:0]DATA, // Output 
                      output wire BUSY,      // Output signal activated whenever is a READ operationn in progress
                      // ULPI pins
                      input  wire DIR,
                      output wire STP,
                      input  wire NXT,
                      input  wire [7:0]ULPI_DATA_IN,
                      output wire [7:0]ULPI_DATA_OUT
                     );

    // CMD used to perform a register read 11xxxxxx
    parameter [1:0]REG_READ_CMD = 2'b11;


    /// ULPI_REG_READ Regs and wires
    // Outputs
    reg [7:0]DATA_r = 8'b0;

    // Inputs
    // #NONE

    // Buffers
    reg [7:0]ULPI_DATA_OUT_r = 8'b0;

    // Control registers
    reg [1:0]READ_state_r = 3'b0; // Register to store the current state of the ULPI_REG_READ module

    // Flags
    wire READ_s_IDLE;      // 1 if READ_state_r == READ_IDLE, else 0
    wire READ_s_TXCMD;     // 1 if READ_state_r == READ_TXCMD, else 0
    wire READ_s_WAIT;      // 1 if READ_state_r == READ_WAIT1, else 0
    wire READ_s_SAVE_DATA; // 1 if READ_state_r == READ_SAVE_DATA, else 0

    // Assigns
    assign READ_s_IDLE      = (READ_state_r == READ_IDLE)      ? 1'b1 : 1'b0; // #FLAG
    assign READ_s_TXCMD     = (READ_state_r == READ_TXCMD)     ? 1'b1 : 1'b0; // #FLAG
    assign READ_s_WAIT      = (READ_state_r == READ_WAIT)      ? 1'b1 : 1'b0; // #FLAG
    assign READ_s_SAVE_DATA = (READ_state_r == READ_SAVE_DATA) ? 1'b1 : 1'b0; // #FLAG
    assign DATA             = DATA_r;          // #OUTPUT
    assign BUSY             = !READ_s_IDLE;    // #OUTPUT
    assign ULPI_DATA_OUT    = ULPI_DATA_OUT_r; // #OUTPUT
    /// End of ULPI_REG_READ Regs and wires


    /// ULPI_REG_READ States (See module description at the beginning to get more info)
    localparam READ_IDLE      = 2'b00;
    localparam READ_TXCMD     = 2'b01;
    localparam READ_WAIT      = 2'b10;
    localparam READ_SAVE_DATA = 2'b11;
    /// End of ULPI_REG_READ States


    /// ULPI_REG_READ controller
    // States and actions
    // #FIGURE_NUMBER READ_state_machine
    always @(posedge clk) begin
        if(rst == 1'b1) begin
            // When a reset occurs, the default state is loaded, and the registers are purged
            READ_state_r <= READ_IDLE;
            DATA_r <= 8'b0;
            ULPI_DATA_OUT_r <= 8'b0;
        end
        else begin
            case(READ_state_r)
                READ_IDLE: begin
                    ULPI_DATA_OUT_r <= 8'b0;
                    if(READ_DATA == 1'b1) begin
                        // The READ process start whenever the READ_DATA signal is activated, otherwise, we do nothing
                        READ_state_r <= READ_TXCMD;

                        // The TXCMD is loaded in the ULPI OUTPUT buffer
                        ULPI_DATA_OUT_r <= {REG_READ_CMD, ADDR};
                    end
                    else begin
                        READ_state_r <= READ_IDLE;
                    end
                end
                READ_TXCMD: begin
                    if(NXT == 1'b1) begin
                        // We wait for an assertion of the NXT input
                        READ_state_r <= READ_WAIT;
                    end
                    else begin
                        READ_state_r <= READ_TXCMD;
                    end
                end
                READ_WAIT: begin
                    // We wait 1 clock pulse for the "Turn around" to occur
                    // Also, the PHY has now the ownership of the bus
                    READ_state_r <= READ_SAVE_DATA;
                    ULPI_DATA_OUT_r <= 8'b0;
                end
                READ_SAVE_DATA: begin
                    if(DIR == 1'b0) begin
                        // We wait until the PHY free the bus to go back to the IDLE state (DIR goes from HIGH to LOW)
                        READ_state_r <= READ_IDLE;
                    end
                    else begin
                        READ_state_r <= READ_SAVE_DATA;

                        // We save the value of the ULPI register before the last "Turn Around"
                        DATA_r <= ULPI_DATA_IN;
                    end
                end
                default: begin
                    READ_state_r <= READ_IDLE;
                end
            endcase
        end
    end
    /// End of ULPI_REG_READ controller

endmodule