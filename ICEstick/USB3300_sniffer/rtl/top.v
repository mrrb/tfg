/*
 * 
 * This is the main file for the USB3300 sniffer
 * 
 * Modules initialization:
 *  - Controller main clock init with integrated PLL. [#MODULE_INIT PLL]
 *  - Controller memory bank init. [#MODULE_INIT Bank1]
 *  - [#MODULE_INIT Mem]
 *  - UART interface module init. [#MODULE_INIT UART]
 *  - SPI interface module init. [#MODULE_INIT SPI]
 *  - 
 * 
 */

`default_nettype none

`include "./rtl/ULPI_REG_ADDR.vh" // USB3300 register addresses definitions
`include "./rtl/CTRL_REG_ADDR.vh" // Main controller register addresses definitions

`include "./modules/ULPI/rtl/ULPI.v" // ULPI module
`include "./modules/UART/rtl/UART.v" // UART module
`include "./modules/SPI_COMM/rtl/SPI_COMM.v" // SPI module
`include "./modules/REG_BANK/rtl/REG_BANK.v" // SPI module
`include "./modules/clk_div_gen/rtl/clk_div_gen.v" // Clock divider module
`include "./modules/mux/rtl/mux.v" // Multiplexer module 
`include "./modules/shift_register/rtl/shift_register.v" // Shift register module 
`include "./modules/clk_pulse/rtl/clk_pulse.v" // Clock pulses

module USB3300_parser (
                       // Clocks
                       input  wire clk_int, // FPGA 12MHz clock
                       input  wire clk_ext, // USB3300 60MHz clock

                       // USB3300/ULPI pins
                       input  wire ULPI_DIR, // ULPI DIR input
                       input  wire ULPI_NXT, // ULPI NXT input
                       output wire ULPI_STP, // ULPI STP output
                       output wire ULPI_RST, // USB3300 RST pin
                       inout  wire [7:0]ULPI_DATA, // ULPI Data inout

                       // SPI pins
                       input  wire SPI_SCK,  // SPI reference clock
                       input  wire SPI_SS,   // SPI Slave Select pin
                       input  wire SPI_MOSI, // SPI input  'Master Out Slave In'
                       output wire SPI_MISO, // SPI output 'Master In  Slave Out'

                       // UART pins
                       input  wire UART_RX, // UART serial data input
                       output wire UART_TX  // UART serial data output
                      );

    /// Main clock generator from PLL
    // #MODULE_INIT PLL
    /*
     * PLL configuration
     *
     * This configuration was generated automatically
     * using the icepll tool from the IceStorm project.
     * Use at your own risk.
     *
     * Given input frequency:        12.000 MHz
     * Requested output frequency:  100.000 MHz
     * Achieved output frequency:   100.500 MHz
     */
    wire clk_ctrl; // Master controller clock signal [clk ≅100MHz output]
    wire locked;   // Locked control signal
    SB_PLL40_CORE #(
		            .FEEDBACK_PATH("SIMPLE"),
		            .DIVR(4'b0000),		    // DIVR =  0
		            .DIVF(7'b1000010),	    // DIVF = 66
		            .DIVQ(3'b011),		    // DIVQ =  3
		            .FILTER_RANGE(3'b001)	    // FILTER_RANGE = 1
	               )
               uut (
		            .LOCK(locked),          // [Input]
		            .RESETB(1'b1),          // [Input]
		            .BYPASS(1'b0),          // [Input]
		            .REFERENCECLK(clk_int), // [Input]
		            .PLLOUTCORE(clk_ctrl)   // [Output]
		           );
    /// End of Main clock generator from PLL


    /// Main controller register bank init
    // #MODULE_INIT Bank1
    wire BANK1_WD;
    wire [5:0]BANK1_ADDR;
    wire [7:0]BANK1_DATA_in;
    wire [7:0]BANK1_DATA_out;
    REG_BANK #(
               .ADDR_BITS(6),
               .DATA_BITS(8)
              )
        bank1 (
               .clk(clk_ctrl),       // [Input]
               .WD(BANK1_WD),        // [Input]
               .ADDR(BANK1_ADDR),    // [Input]
               .DATA_in(BANK1_ADDR), // [Input]
               .DATA_out(BANK1_ADDR) // [Output]
              );
    /// End of Main controller register bank init
    

    /// Main memory init
    // #MODULE_INIT Mem
    /// End of Main memory init


    /// UART module init
    // #MODULE_INIT UART
    // Inputs
    // Outputs
    wire UART_DATA_out;
    wire UART_DATA_in;
    wire UART_send;
    wire UART_TiP;
    wire UART_NrD;
    wire UART_baud;
    UART #(
           .BAUD_DIVIDER(7) // We use a 12MHz clock to get 115200 baud, so we must use 7th order divider (see ./tools/get_divider.py).
          )
    uart  (
           .clk(clk_int), // [Input] 12MHz internal clock
           .Rx(UART_RX),  // [Input]
           .I_DATA(UART_DATA_in), // [Input]
           .send_data(UART_send), // [Input]
           .Tx(UART_TX),   // [Output]
           .TiP(UART_TiP), // [Output]
           .NrD(UART_NrD), // [Output]
           .O_DATA(UART_DATA_out), // [Output]
           .clk_baud(UART_baud)    // [Output]
          );
    /// End of UART module init


    /// SPI module init
    // #MODULE_INIT SPI
    wire [7:0]SPI_DATA_out;
    wire SPI_err_out;
    wire SPI_err_in;
    wire SPI_EoB;
    wire SPI_busy;
    wire SPI_CMD;
    wire SPI_INFO_out;
    wire SPI_sec_CMD;
    wire SPI_read;
    wire SPI_format;

    SPI_COMM spi(
                 // System signals
                 .clk(clk_ctrl),          // [Input]
                 .rst(0'b0),              // [Input]

                 // SPI interface signals
                 .SCLK(SPI_SCK),          // [Input]
                 .SS(SPI_SS),             // [Input]
                 .MOSI(SPI_MOSI),         // [Input]
                 .MISO(SPI_MISO),         // [Output]

                 // Data signals
                 .DATA_in(SPI_data_in_r),   // [Input]
                 .DATA_out(SPI_DATA_out), // [Output]

                 // Control signals
                 .err_in(SPI_err_in),     // [Input]
                 .err_out(SPI_err_out),   // [Output]
                 .EoB(SPI_EoB),           // [Output]
                 .busy(SPI_busy),         // [Output]

                 // Frame info signals
                 .CMD(SPI_CMD),           // [Output]
                 .INFO_out(SPI_INFO_out), // [Output]
                 .sec_CMD(SPI_sec_CMD),   // [Output]
                 .read(SPI_read),         // [Output]
                 .format(SPI_format)      // [Output]
                );
    /// End of SPI module init


    /// ULPI module init
    // #MODULE_INIT ULPI
    wire [7:0]ULPI_DATA_out;
    wire ULPI_busy;
    ULPI ulpi (
               .clk_ext(clk_ctrl),
               .clk_int(clk_ext),
               .rst(0'b0),
               .WD(0'b0),
               .RD(0'b0),
               .TD(0'b0),
               .LP(0'b0),
               .ADDR(8'b0),
               .REG_DATA_IN(8'b0),
               .REG_DATA_OUT(ULPI_DATA_out),
               .BUSY(ULPI_busy),
               .DIR(ULPI_DIR),
               .STP(ULPI_STP),
               .NXT(ULPI_NXT),
               .ULPI_DATA(ULPI_DATA)
              );
    /// End of ULPI module init


    /// USB3300_parser main controller
        /// USB3300_parser Regs and wires
        // Buffers
        reg [2:0]main_STA_FPGA_request_r = 3'b0;
        reg [2:0]main_STA_FPGA_status_r  = 3'b0;
        reg [1:0]main_STA_error_code_r   = 2'b0;

        // Control registers
        // #NONE

        // Flags
        wire [7:0]main_STA = {main_STA_FPGA_request_r, main_STA_FPGA_status_r, main_STA_error_code_r};
        wire main_rst;
        
        // Assigns
        // #NONE
        /// End of USB3300_parser Regs and wires

        /// USB3300_parser States (See module description at the beginning to get more info)
        /// End of USB3300_parser States

        /// USB3300_parser controller
        // #FIGURE_NUMBER main_SPI_state_machine
        // States
        // always @(posedge clk_ctrl) begin
        //     if(main_rst) begin
        //     end
        //     else begin
        //         case()
        //             default: begin
        //             end
        //         endcase
        //     end
        // end
        // // Actions
        // always @(posedge clk_ctrl) begin
        //     if(main_rst) begin
        //     end
        //     else begin
        //         case()
        //             default: begin
        //             end
        //         endcase
        //     end
        // end
        /// End of USB3300_parser controller
    /// End of USB3300_parser main controller


    /// SPI main controller

        /// main_SPI Regs and wires
        // Buffers
        reg [7:0]SPI_data_in_r = 8'b0;

        // Control registers
        reg [2:0]SPI_state_r = 3'b0; // Register to store the current state of the SPI controller
        reg SPI_err_in_r     = 1'b0;
        reg [1:0]SPI_mode_next_r    = 2'b0;
        reg [1:0]SPI_mode_current_r = 2'b0;
        reg [1:0]SPI_mode_l_next_r  = 2'b0;
        reg [4:0]SPI_B_count_r = 5'b0; // SPI Byte count
        reg SPI_F_end_r = 1'b0; // SPI end of Frame
        reg [4:0]SPI_info_len_r = 5'b0;
        reg [2:0]SPI_info_extra_r = 3'b0;
        reg SPI_SET_mode_2_r = 1'b0;
        reg SPI_SET_mode_3_r = 1'b0;
        reg SPI_pre_done = 1'b0;

        // Flags
        wire SPI_err;
        
        // Assigns
        assign SPI_err = SPI_err_out || SPI_err_in;
        /// End of main_SPI Regs and wires

        /// main_SPI States (See module description at the beginning to get more info)
        localparam SPI_IDLE      = 0;
        localparam SPI_LOAD      = 1;
        localparam SPI_TR        = 2;
        localparam SPI_CHK       = 3;
        localparam SPI_BACK      = 4;
        localparam SPI_PRE_READ  = 5;
        localparam SPI_PRE_WRITE = 6;
        localparam SPI_RST       = 7;
        /// End of main_SPI States

        /// main_SPI controller
        // #FIGURE_NUMBER main_SPI_state_machine
        // States
        always @(posedge clk_ctrl) begin
            if(main_rst) begin
                SPI_state_r <= SPI_RST;
            end
            else begin
                case(SPI_state_r)
                    SPI_IDLE: begin
                        if(!SPI_busy) SPI_state_r <= SPI_LOAD;
                        else          SPI_state_r <= SPI_IDLE;
                    end
                    SPI_LOAD: begin
                        SPI_state_r <= SPI_TR;
                    end
                    SPI_TR: begin
                        if(SPI_err)      SPI_state_r <= SPI_RST;
                        else if(SPI_EoB) SPI_state_r <= SPI_CHK;
                        else             SPI_state_r <= SPI_TR;
                    end
                    SPI_CHK: begin
                        if(SPI_err) SPI_state_r <= SPI_RST;
                        else        SPI_state_r <= SPI_BACK;                    
                    end
                    SPI_BACK: begin
                        if(SPI_err) SPI_state_r <= SPI_RST;
                        else if(SPI_F_end_r && SPI_sec_CMD) begin
                            if(SPI_read) SPI_state_r <= SPI_PRE_READ;
                            else         SPI_state_r <= SPI_PRE_WRITE;
                        end
                        else if(!SPI_F_end_r) SPI_state_r <= SPI_TR;
                        else                  SPI_state_r <= SPI_RST;
                    end
                    SPI_PRE_READ: begin
                        if(SPI_err)      SPI_state_r <= SPI_RST;
                        if(SPI_pre_done) SPI_state_r <= SPI_IDLE;
                        else             SPI_state_r <= SPI_PRE_READ;
                    end
                    SPI_PRE_WRITE: begin
                        if(SPI_err)      SPI_state_r <= SPI_RST;
                        if(SPI_pre_done) SPI_state_r <= SPI_IDLE;
                        else             SPI_state_r <= SPI_PRE_WRITE;
                    end
                    SPI_RST: begin
                        if(!SPI_busy && !SPI_err) SPI_state_r <= SPI_IDLE;
                        else                      SPI_state_r <= SPI_RST;
                    end
                    default: begin
                        SPI_state_r <= SPI_RST; 
                    end
                endcase
            end
        end
        // Actions
        always @(posedge clk_ctrl) begin
            if(main_rst) begin
            end
            else begin
                case(SPI_state_r)
                    SPI_IDLE: begin
                        SPI_data_in_r <= main_STA;
                        SPI_F_end_r   <= 1'b0;
                    end
                    SPI_LOAD: begin
                        SPI_mode_next_r    <= 2'b0;
                        SPI_mode_current_r <= 2'b0;
                        SPI_mode_l_next_r  <= SPI_mode_next_r;

                        SPI_B_count_r <= 5'b0;
                    end
                    SPI_TR: begin

                    end
                    SPI_CHK: begin
                        SPI_B_count_r <= SPI_B_count_r + 1'b1;

                        if(SPI_mode_current_r == 2'b0) begin
                            if(!SPI_read && !SPI_format) begin
                                SPI_mode_current_r <= 2'b01;
                                if(SPI_sec_CMD) SPI_mode_next_r <= 2'b10;
                                else            SPI_mode_next_r <= 2'b00;
                            end
                            else if(!SPI_read && SPI_format) begin
                                SPI_mode_current_r <= 2'b10;
                                if(SPI_sec_CMD) SPI_mode_next_r <= 2'b10;
                                else            SPI_mode_next_r <= 2'b00;
                            end
                            else if(SPI_read && SPI_format) begin
                                SPI_mode_current_r <= 2'b11;
                                if(SPI_sec_CMD) SPI_mode_next_r <= 2'b11;
                                else            SPI_mode_next_r <= 2'b00;
                            end
                            else SPI_err_in <= 1'b1;

                            if(SPI_mode_l_next_r != SPI_mode_current_r) SPI_err_in <= 1'b1;
                        end
                        else if(SPI_mode_current_r == 2'b01 && SPI_B_count_r == 5'b1) begin
                            /*
                             * SAVE BYTE
                             */
                            SPI_F_end_r   <= 1'b1;
                        end
                        else if(SPI_mode_current_r == 2'b10 && SPI_B_count_r == 5'b1) begin
                            SPI_info_len_r <= SPI_INFO_out[4:0];
                            SPI_info_extra_r <= SPI_INFO_out[7:5];
                            SPI_SET_mode_2_r <= 1'b1;
                        end
                        else if(SPI_mode_current_r == 2'b10 && SPI_B_count_r <= (SPI_info_len_r+1'b1) && SPI_SET_mode_2_r) begin
                            /*
                             * SAVE BYTE
                             */
                            if(SPI_B_count_r == (SPI_info_len_r+1'b1)) SPI_F_end_r = 1'b1;
                        end
                        else if(SPI_mode_current_r == 2'b11 && SPI_B_count_r == 5'b1) begin
                            SPI_data_in_r <= {SPI_info_extra_r, SPI_info_len_r};
                            SPI_SET_mode_3_r <= 1'b1;
                        end
                        else if(SPI_mode_current_r == 2'b11 && SPI_B_count_r <= (SPI_info_len_r+1'b1) && SPI_SET_mode_3_r) begin
                            /*
                             * NEXT BYTE
                             */
                            if(SPI_B_count_r == (SPI_info_len_r+1'b1)) SPI_F_end_r = 1'b1;
                        end
                        else SPI_err_in <= 1'b1;
                    end
                    SPI_BACK: begin
                        
                    end
                    SPI_PRE_READ: begin
                        
                    end
                    SPI_PRE_WRITE: begin
                        
                    end
                    SPI_RST: begin
                        SPI_err_in <= 1'b0;
                        SPI_mode_next_r    <= 2'b0;
                        SPI_mode_current_r <= 2'b0;
                        SPI_mode_l_next_r  <= 2'b0;
                        SPI_info_len_r     <= 5'b0;
                        SPI_info_extra_r   <= 3'b0;
                        SPI_SET_mode_2_r   <= 1'b0;
                        SPI_SET_mode_3_r   <= 1'b0;
                    end
                    default: begin
                        
                    end
                endcase
            end
        end
        /// End of main_SPI controller

    /// End of SPI main controller

endmodule