/*
 * 
 * This is the top file for the USB3300 sniffer, where all the controllers and modules are loaded
 * 
 * Modules initialization:
 *  - PLL. Module that generates the Master clock (≅100.5MHz).
 *  - UART. Module that manages the serial communication between the FPGA and the processing unit (a computer in this case).
 *  - ULPI.
 * 
 */

`default_nettype none

`define ASYNC_RESET

`include "./rtl/bauds.vh"

`include "./modules/UART.vh"
`include "./modules/ULPI.vh"
`include "./modules/clk_div.vh"
`include "./modules/FIFO_BRAM_SYNC.vh"

 module USB3300_sniffer (
                         // System signals
                         input  wire clk_ice,        // 12MHz clock located in the ICEstick board
                         input  wire clk_ULPI,       // 60MHz clock from the usb3300 module

                         // ULPI signals
                         input  wire ULPI_DIR,       // ULPI DIRECTION
                         input  wire ULPI_NXT,       // ULPI NEXT
                         inout  wire [7:0]ULPI_DATA, // ULPI 8-bit parallel data
                         output wire ULPI_STP,       // ULPI STOP
                         output wire ULPI_RST,       // USB3300 RESET pin

                         // UART signals
                         input  wire UART_Rx,        // Serial Read
                         output wire UART_Tx,        // Serial Write

                         // I/O
                         output wire [7:0]IO_bank1,  // Bank 0 I/O (bottom right connector [from top to bottom, ])
                         output wire [1:0]IO_bank2,  // Remaining free I/O's of the Bank 2 connector (bottom left)
                         output wire [4:0]IO_LEDs    // 4 (red) + 1 (green) LED's on the ICEstick board
                        );
/// reset
    /// Reset signal
    wire rst;
    assign rst = 1'b1;
    // assign ULPI_RST = !rst;
    /// End of Reset signal
///


/// old
    // /// Testing signals and controllers
    // reg t_rst_r = 1'b0;
    // wire t_rst; assign t_rst = t_rst_r;

    // // assign IO_test2 = UART_DATA_out;

    // reg [7:0]t_UART_DATA_in  = 8'b0;
    // reg [2:0]t_UART_in_count = 3'b0;

    // always @(negedge clk_ice)
    //     if(!t_rst_r)
    //         t_rst_r <= 1'b1;

    // always @(posedge clk_test) begin
    // // t_UART_DATA_in <= "a";
    //     t_UART_in_count <= t_UART_in_count + 1'b1;
    // end

    // always @(posedge clk_ice) begin
    //     case(t_UART_in_count)
    //         3'd0: t_UART_DATA_in <= "H";
    //         3'd1: t_UART_DATA_in <= "e";
    //         3'd2: t_UART_DATA_in <= "l";
    //         3'd3: t_UART_DATA_in <= "l";
    //         3'd4: t_UART_DATA_in <= "o";
    //         3'd5: t_UART_DATA_in <= "!";
    //         3'd6: t_UART_DATA_in <= "!";
    //         3'd7: t_UART_DATA_in <= "\n";
    //         default: t_UART_DATA_in <= " ";
    //     endcase
    // end

    // wire clk_test;
    // wire clk_test_pulse;

    // clk_div #(.DIVIDER(19))
    // clk_div  (
    //           .clk_in(clk_ice), .clk_out(clk_test), .clk_pulse(clk_test_pulse), // Clock signals
    //           .enable(IO_btn) // Control signals
    //          );

    // assign IO_LEDs[0] = clk_test;
    // assign IO_LEDs[1] = IO_btn;
    // assign IO_LEDs[2] = UART_TiP;
    // assign IO_LEDs[3] = UART_Tx;
    // assign IO_LEDs[4] = t_UART_in_count[2];

    // assign IO_test[0] = UART_Tx;
    // assign IO_test[1] = UART_Rx;
    // assign IO_test[2] = UART_Tx_clk;
    // assign IO_test[3] = t_rst;
    // // assign IO_test[1] = UART_Tx_clk;
    // // assign IO_test[1] = UART_Rx_clk;
    // /// End of Testing signals and controllers
///


/// Test timer
    // Timer
    wire clk_test, clk_test_pulse;
    clk_div #(.DIVIDER(23))
    clk_div  (
              .clk_in(clk_ice), .clk_out(clk_test), .clk_pulse(clk_test_pulse), // Clock signals
              .enable(1'b1) // Control signals
             );
///


/// Test assigns
    assign IO_LEDs[0] = clk_test;
    assign IO_LEDs[1] = rst;

    assign IO_bank1[0] = UART_Tx;
    assign IO_bank1[1] = UART_Rx;
    assign IO_bank1[2] = UART_Tx_clk;
    assign IO_bank1[3] = UART_Rx_clk;
    assign IO_bank1[4] = clk_ctrl;

    // assign IO_bank1 = UART_DATA_out;

    assign UART_DATA_in = UART_DATA_out;
    assign UART_send    = !UART_Rx_EMPTY;
    assign UART_NxT     = !UART_Rx_EMPTY;
///


/// Test init
    /// Test init
    reg ctrl = 0;
    always @(posedge clk_ice) begin
        ctrl <= !ctrl;
    end
    /// End of Test init
///

/// PLL
    /// PLL init
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

    wire clk_ctrl;   // Generated Master clock (≅100.5MHz)
    wire pll_locked; // Locked control signal

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
		            .REFERENCECLK(clk_ice),   // [Input]
		            .PLLOUTCORE(clk_ctrl)     // [Output]
		           );
    /// End of PLL init
///


/// UART
    /// UART init
    // #MODULE_INIT UART
    wire [7:0]UART_DATA_in;
    wire [7:0]UART_DATA_out;
    wire UART_send;
    wire UART_TiP, UART_NrD;         // 
    wire UART_NxT;
    wire UART_Tx_FULL;                // Tx buffer status signals
    wire UART_Rx_FULL, UART_Rx_EMPTY; // Rx buffer status signals
    wire UART_Rx_clk, UART_Tx_clk;    // UART Rx/Tx clocks

    UART #(.BAUDS(`B115200))
    UART  (
           // System signals
           .rst(rst),               // [Input]
           .clk(clk_ice),           // [Input]

           // UART signals
           .Rx(UART_Rx),            // [Input]
           .Tx(UART_Tx),            // [Output]
           .clk_Rx(UART_Rx_clk),    // [Output]
           .clk_Tx(UART_Tx_clk),    // [Output]

           // Data signals
           .I_DATA(UART_DATA_in),   // [Input]
           .O_DATA(UART_DATA_out),  // [Output]

           // Control signals
           .send_data(UART_send),   // [Input]
           .NxT(UART_NxT),          // [Input]
           .TiP(UART_TiP),          // [Output]
           .NrD(UART_NrD),          // [Output]
           .Tx_FULL(UART_Tx_FULL),  // [Output]
           .Rx_FULL(UART_Rx_FULL),  // [Output]
           .Rx_EMPTY(UART_Rx_EMPTY) // [Output]
          );
    /// End of UART init
///


/// ULPI
    /// ULPI init
    // #MODULE_INIT ULPI
    wire ULPI_PrW; assign ULPI_PrW = 1'b1;
    wire [5:0]ULPI_ADDR;
    wire [7:0]ULPI_REG_VAL_W, ULPI_REG_VAL_R;
    ULPI ULPI (
               // System signals
               .rst(rst),
               .clk_ice(clk_ice),
               .clk_ULPI(clk_ULPI),

               // Control signals
               .PrW(ULPI_PrW),

               //Register signals
               .ADDR(ULPI_ADDR),
               .REG_VAL_W(ULPI_REG_VAL_W),
               .REG_VAL_R(ULPI_REG_VAL_R),

               // ULPI signals
               .DIR(ULPI_DIR),
               .NXT(ULPI_NXT),
               .DATA(ULPI_DATA),
               .STP(ULPI_STP),
               .U_RST(ULPI_RST)
              );
    /// End of ULPI init
///

    /// Controllers

    /// End of Controllers

endmodule