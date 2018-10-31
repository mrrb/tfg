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

`include "./modules/UART.vh"         // Include UART module
`include "./modules/SPI_COMM.vh"     // Include SPI_COMM module
`include "./modules/REG_BANK.vh"     // Include REG_BANK module
`include "./modules/ULPI/rtl/ULPI.v" // Include Full ULPI module

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
    wire pll_locked;   // Locked control signal

    SB_PLL40_CORE #(
		            .FEEDBACK_PATH("SIMPLE"),
		            .DIVR(4'b0000),		      // DIVR =  0
		            .DIVF(7'b1000010),	      // DIVF = 66
		            .DIVQ(3'b011),		      // DIVQ =  3
		            .FILTER_RANGE(3'b001)	  // FILTER_RANGE = 1
	               )
           pll_gen (
		            .LOCK(pll_locked),        // [Output]
		            .RESETB(1'b1),            // [Input]
		            .BYPASS(1'b0),            // [Input]
		            .REFERENCECLK(clk_int),   // [Input]
		            .PLLOUTCORE(clk_ctrl)     // [Output]
		           );
    /// End of Main clock generator from PLL


    /// Controller memory init
    // #MODULE_INIT memory
    /*
     * The ICE40HX has 16 RAM module of 4k each.
     * 
     * RAM modules assignments:
     *  - Module 0    => System memory. Main memory used by the entire system.
     *  - Module 1-12 => USB memory. Memory where all the USB packages are stored. Only a module is allowed to be activated simultaneously.
     *  - Module 13   => Reserved.
     *  - Module 14   => Reserved.
     *  - Module 15   => ULPI memory.
     *
     */
    wire [15:0]mem_r_selector_w; // Memory module selector [READ]. Each bit of this wire enables its corresponding module to perform a READ cycle.
    wire [15:0]mem_w_selector_w; // Memory module selector [WRITE]. Each bit of this wire enables its corresponding module to perform a WRITE cycle.
    wire mem_r_clk_en_w;         // Memory clock enable [READ]. This wire enables the clock input globally in READ cycles.
    wire mem_w_clk_en_w;         // Memory clock enable [WRITE]. This wire enables the clock input globally in WRITE cycles.

    wire [7:0]mem_SYS_r_DATA_w;  // Data OUTPUT from the System memory. [Module 0].
    wire [7:0]mem_USB_r_DATA_w;  // Data OUTPUT from the USB memory.    [Modules 1-12].
    wire [7:0]mem_ULPI_r_DATA_w; // Data OUTPUT from the ULPI memory.   [Module 15].
    wire [7:0]mem_SYS_w_DATA_w;  // Data INPUT to the System memory.    [Module 0].
    wire [7:0]mem_USB_w_DATA_w;  // Data INPUT to the USB memory.       [Modules 1-12].
    wire [7:0]mem_ULPI_w_DATA_w; // Data INPUT to the ULPI memory.      [Module 15].

    wire [8:0]mem_SYS_r_ADDR_w;  // Address where the System memory has to be READ.  [Module 0]
    wire [8:0]mem_USB_r_ADDR_w;  // Address where the USB memory has to be READ.     [Module 1-12]
    wire [8:0]mem_ULPI_r_ADDR_w; // Address where the ULPI memory has to be READ.    [Module 15]
    wire [8:0]mem_SYS_w_ADDR_w;  // Address where the System memory has to be WRITE. [Module 0]
    wire [8:0]mem_USB_w_ADDR_w;  // Address where the USB memory has to be WRITE.    [Module 1-12]
    wire [8:0]mem_ULPI_w_ADDR_w; // Address where the ULPI memory has to be WRITE.   [Module 15]

    `include "./rtl/ram_init/sys.v"  // System memory init file. 
    `include "./rtl/ram_init/USB.v"  // USB memory init file.
    `include "./rtl/ram_init/ULPI.v" // ULPI memory init file.
    /// End of Controller memory init


    /// UART module init
    // #MODULE_INIT UART
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
    wire  [7:0]SPI_STA_w;
    wire  [7:0]SPI_DATA_in_w;
    wire  [7:0]SPI_CMD_w;
    wire [15:0]SPI_ADDR_w;
    wire  [7:0]SPI_DATA_out_w;
    wire  [7:0]SPI_RAW_w;

    wire SPI_err_in_w;
    wire SPI_err_out_w;
    wire SPI_EoB_w;
    wire SPI_EoP_w;
    wire SPI_busy_w;

    SPI_COMM spi(
                 // System signals
                 .clk(clk_ctrl),  // [Input]
                 .rst(1'b1),      // [Input]

                 // SPI interface signals
                 .SCLK(SPI_SCK),  // [Input]
                 .SS(SPI_SS),     // [Input]
                 .MOSI(SPI_MOSI), // [Input]
                 .MISO(SPI_MISO), // [Output]

                 // Data signals
                 .STA(SPI_STA_w),           // [Input]
                 .DATA_in(SPI_DATA_in_w),   // [Input]
                 .CMD(SPI_CMD_w),           // [Output]
                 .ADDR(SPI_ADDR_w),         // [Output]
                 .DATA_out(SPI_DATA_out_w), // [Output]
                 .RAW_out(SPI_RAW_w),       // [Output]

                 // Control signals
                 .err_in(SPI_err_in_w),   // [Input]
                 .err_out(SPI_err_out_w), // [Output]
                 .EoB(SPI_EoB_w),         // [Output]
                 .EoP(SPI_EoP_w),         // [Output]
                 .busy(SPI_busy_w)        // [Output]
                );
    /// End of SPI module init


    /// ULPI module init
    // #MODULE_INIT ULPI
    wire [7:0]ULPI_DATA_w;
    assign ULPI_DATA = ULPI_DIR ? {8{1'bz}} : ULPI_DATA_w;

    wire [7:0]ULPI_DATA_out;
    wire ULPI_busy;
    ULPI ulpi (
               .clk_ext(clk_ctrl),
               .clk_int(clk_ext),
               .rst(1'b0),
               .WD(1'b0),
               .RD(1'b0),
               .TD(1'b0),
               .LP(1'b0),
               .ADDR(8'b0),
               .REG_DATA_IN(8'b0),
               .REG_DATA_OUT(ULPI_DATA_out),
               .BUSY(ULPI_busy),
               .DIR(ULPI_DIR),
               .STP(ULPI_STP),
               .NXT(ULPI_NXT),
               .ULPI_DATA_IN(ULPI_DATA_w),
               .ULPI_DATA_OUT(ULPI_DATA)
              );
    /// End of ULPI module init


    /// USB3300_parser main controller
    `include "./rtl/controllers/main_controller.v"
    /// End of USB3300_parser main controller


    /// SPI main controller
    // `include "./rtl/controllers/SPI_controller.v"
    /// End of SPI main controller

endmodule