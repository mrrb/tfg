/*
 * 
 * ULPI_REG_WRITE module
 * This module has the instructions set that let write data into the PHY registers
 * 
 * States:
 *    1. WRITE_IDLE. The module is doing nothing until the WRITE_DATA input is activated.
 *    2. WRITE_TXCMD. Once the write signal is asserted, the LINK has the ownership of the bus and send the TXCMD 8bit data ('10'cmd+{6bit Address}).
 *                    The PHY will respond activating the NXT signal indicating that TXCMD has been successfully latched.
 *    3. WRITE_SEND_DATA. Link drives the DATA to be stored in the register.
 *                        The PHY drives NXT high indicating that the data has been latched.
 *    4. WRITE_STP. Finally, the LINK drives HIGH STP, ending the writing of the register.
 * 
 */

`default_nettype none

module ULPI_REG_WRITE (
                      // System signals
                      input  wire clk, // Clock input signal
                      input  wire rst, // Master reset signal

                      // ULPI controller signals
                      input  wire WRITE_DATA, // Signal to initiate a register write
                      input  wire [5:0]ADDR,  // Input that transmit the 6 bit address where we want to write the DATA
                      input  wire [7:0]DATA,  // Input that transmit the 8 bit DATA to be written in the ULPI register
                      output wire BUSY,       // Output signal activated whenever is a Write operationn in progress
                      //output wire QUICK_EXIT, // In case the PHY take control over the BUS in the first 

                      // ULPI pins
                      input  wire DIR,               // ULPI DIR signal
                      output wire STP,               // ULPI STP signal
                      input  wire NXT,               // ULPI NXT signal
                      input  wire [7:0]ULPI_DATA_IN, // ULPI DATA input
                      output wire [7:0]ULPI_DATA_OUT // ULPI DATA output
                      );

    // CMD used to perform a register write 10xxxxxx
    parameter [1:0]REG_WRITE_CMD = 2'b10;


    /// ULPI_REG_WRITE Regs and wires
    // Outputs
    reg STP_r = 1'b0;

    // Inputs
    // #NONE

    // Buffers
    reg [7:0]DATA_buf_r = 8'b0;      // Buffer for the ULPI controller DATA input
    reg [7:0]ULPI_DATA_buf_r = 8'b0; // Buffer for the ULPI DATA output

    // Control registers
    reg [1:0]WRITE_state_r = 2'b0;   // Register to store the current state of the ULPI_REG_WRITE module

    // Flags
    wire WRITE_s_IDLE;      // 1 if WRITE_state_r == WRITE_IDLE, else 0
    wire WRITE_s_TXCMD;     // 1 if WRITE_state_r == WRITE_TXCMD, else 0
    wire WRITE_s_SEND_DATA; // 1 if WRITE_state_r == WRITE_SEND_DATA, else 0
    wire WRITE_s_STP;       // 1 if WRITE_state_r == WRITE_STP, else 0
    
    // Assigns
    assign WRITE_s_IDLE      = (WRITE_state_r == WRITE_IDLE)      ? 1'b1 : 1'b0; // #FLAG
    assign WRITE_s_TXCMD     = (WRITE_state_r == WRITE_TXCMD)     ? 1'b1 : 1'b0; // #FLAG
    assign WRITE_s_SEND_DATA = (WRITE_state_r == WRITE_SEND_DATA) ? 1'b1 : 1'b0; // #FLAG
    assign WRITE_s_STP       = (WRITE_state_r == WRITE_STP)       ? 1'b1 : 1'b0; // #FLAG

    assign BUSY              = !WRITE_s_IDLE;   // #OUTPUT
    assign ULPI_DATA_OUT     = ULPI_DATA_buf_r; // #OUTPUT
    assign STP               = STP_r;           // #OUTPUT
    /// End of ULPI_REG_WRITE Regs and wires


    /// ULPI_REG_WRITE States (See module description at the beginning to get more info)
    localparam WRITE_IDLE      = 2'b00;
    localparam WRITE_TXCMD     = 2'b01;
    localparam WRITE_SEND_DATA = 2'b10;
    localparam WRITE_STP       = 2'b11;
    /// End of ULPI_REG_WRITE States


    /// ULPI_REG_WRITE controller
    // States and actions
    // #FIGURE_NUMBER WRITE_state_machine
    always @(posedge clk) begin
        if(rst == 1'b1) begin
            // When a reset occurs, the default state is loaded, and the registers are purged
            WRITE_state_r <= WRITE_IDLE;
            STP_r <= 1'b0;
            ULPI_DATA_buf_r <= 8'b0;
        end
        else begin
            case(WRITE_state_r)
                WRITE_IDLE: begin
                    STP_r <= 1'b0;
                    // The state change once the Write signal (WRITE_DATA) is activated, elsewise, we do nothing
                    if(WRITE_DATA == 1'b1) begin
                        WRITE_state_r <= WRITE_TXCMD;

                        // The value of the DATA input may vary during the write process, so we store its initial value
                        DATA_buf_r      <= DATA;
                        ULPI_DATA_buf_r <= {REG_WRITE_CMD, ADDR};
                    end
                    else begin
                        WRITE_state_r <= WRITE_IDLE;
                        ULPI_DATA_buf_r <= 8'b0; // Default DATA output
                    end
                end
                WRITE_TXCMD: begin                   
                    // We wait until the PHY assert the NXT signal
                    if(NXT == 1'b1) begin
                        WRITE_state_r <= WRITE_SEND_DATA;

                        // Once TXCMD has been accepted, we send the new register value
                        ULPI_DATA_buf_r <= DATA_buf_r;
                    end
                    else WRITE_state_r <= WRITE_TXCMD;
                end
                WRITE_SEND_DATA: begin
                    // We wait again for an activated NXT signal
                    if(NXT == 1'b1) begin
                        WRITE_state_r <= WRITE_STP;
                    
                        // The STP signal is activated, ending the register write
                        STP_r <= 1'b1;
                        ULPI_DATA_buf_r <= 8'b0;
                    end
                    else WRITE_state_r <= WRITE_SEND_DATA;
                end
                WRITE_STP: begin
                    // The WRITE routine is done, so we go back to the IDLE state
                    WRITE_state_r <= WRITE_IDLE;
                    
                    // The STP pin is changed to a LOW level and the DATA output return to the initial state
                    STP_r <= 1'b0;
                    ULPI_DATA_buf_r <= 8'b0;
                end
                default: begin
                    // Just in case a not possible state value occurs, we go back to the inital state
                    WRITE_state_r <= WRITE_IDLE;
                    ULPI_DATA_buf_r <= 8'b0;
                    STP_r <= 1'b0;
                end
            endcase
        end
    end
    /// End of ULPI_REG_WRITE controller

endmodule