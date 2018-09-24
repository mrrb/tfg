/*
 *
 *
 *
 */

module SPI_COMM(
                // System signals
                input  wire clk, // Master clock signal
                input  wire rst, // Reset signal

                // SPI interface signals
                input  wire SCLK, // SPI Clock signal
                input  wire SS,   // Slave Select
                input  wire MOSI, // Master-Out Slave-In
                output wire MISO, // Master-IN  Slave-Out

                // Data signals
                input  wire STA,              // USB analyzer status info
                input  wire [7:0]DATA_in,     // Data to send to the computer
                input  wire data_out_latched, // The data sent to the FPGA controller module has been latched
                input  wire [7:0]INFO_read,   // 8bit Information sent whenever a long format READ [see commands.info and SPI-paper.pdf] occurs
                output wire [7:0]DATA_out,    // Data received from the computer
                output wire [7:0]INFO_write,  // 8bit Information received whenever a long format WRITE [see commands.info and SPI-paper.pdf] occurs
                output wire data_in_latched,  // The data received from the FPGA controller module has been latched
                output wire err               // Error in the last SPI transaction
               );

    /// SPI_COMM Regs and wires
    // Outputs

    // Inputs

    // Buffers

    // Control registers

    // Flags

    // Assigns

    /// End of SPI_COMM Regs and wires


    /// SPI_COMM States (See module description at the beginning to get more info)
    localparam READ_IDLE      = 2'b00;
    localparam READ_TXCMD     = 2'b01;
    localparam READ_WAIT      = 2'b10;
    localparam READ_SAVE_DATA = 2'b11;
    /// End of SPI_COMM States


    /// SPI_COMM controller
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
    /// End of SPI_COMM controller
    

endmodule