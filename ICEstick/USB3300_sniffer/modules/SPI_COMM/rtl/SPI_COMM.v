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

    /// MOSI shift register init
    /// End of MOSI shift register init

    /// SPI_COMM Regs and wires
    // Outputs

    // Inputs

    // Buffers

    // Control registers

    // Flags

    // Assigns

    /// End of SPI_COMM Regs and wires


    /// SPI_COMM States (See module description at the beginning to get more info)

    /// End of SPI_COMM States


    /// SPI_COMM controller
    // States and actions
    // #FIGURE_NUMBER SPI_state_machine
    always @(posedge clk) begin
        if(rst == 1'b1) begin
            // When a reset occurs, the default state is loaded, and the registers are purged

        end
        else begin
            case(READ_state_r)
                READ_IDLE: begin
                   
                end
                default: begin
                end
            endcase
        end
    end
    /// End of SPI_COMM controller
    

endmodule