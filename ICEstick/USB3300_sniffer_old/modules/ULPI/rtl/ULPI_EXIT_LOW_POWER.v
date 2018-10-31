/*
 This module has the instructions to exit from the low power mode of the PHY

 States:
    1. WRITE_IDLE. The module is doing nothing until the WRITE_DATA input is activated.
    2. WRITE_TXCMD. Once the write signal is asserted, the LINK has the ownership of the bus and send the TXCMD 8bit data ('10'cmd+{6bit Address}).
                    The PHY will respond activating the NXT signal indicating that TXCMD has been successfully latched.
    3. WRITE_SEND_DATA. Link drives the DATA to be stored in the register.
                        The PHY drives NXT high indicating that the data has been latched.
    4. WRITE_STP. Finally, the LINK drives HIGH STP, ending the writing of the register.

 From now on, ELP stands for Exit Low Power.
 */

`default_nettype none

module ULPI_EXIT_LOW_POWER ();

    /// ULPI_EXIT_LOW_POWER Regs and wires
    // Outputs

    // Inputs

    // Buffers

    // Control registers

    // Flags
    
    // Assigns

    /// End of ULPI_EXIT_LOW_POWER Regs and wires


    /// ULPI_EXIT_LOW_POWER States (See module description at the beginning to get more info)
    localparam ULPI_IDLE      = 0;
    localparam ULPI_REG_READ  = 1;
    localparam ULPI_REG_WRITE = 2;
    /// End of ULPI_EXIT_LOW_POWER States


    /// ULPI_EXIT_LOW_POWER controller
    always @(posedge clk) begin
        if(rst == 1'b1) begin
            // Master reset actions
        end
        else begin
            case()
                ULPI_IDLE: begin

                end
                ULPI_REG_READ: begin
                end
                ULPI_REG_WRITE: begin
                end
                default: begin
                end
            endcase
        end
    end
    /// End of ULPI_EXIT_LOW_POWER controller

endmodule