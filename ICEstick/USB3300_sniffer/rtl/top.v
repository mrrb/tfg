/*
 * 
 * This is the top file for the USB3300 sniffer, where all the controllers and modules are loaded
 * 
 * Modules initialization:
 *  - PLL. Module that generates the Master clock (≅100.5MHz).
 *  - UART. Module that manages the serial communication between the FPGA and the processing unit (a computer in this case).
 * 
 */

`default_nettype none

`include "./rtl/bauds.vh"

`include "./modules/UART.vh"
`include "./modules/clk_div.vh"

 module USB3300_sniffer (
                         // System signals
                         input  wire clk_ice,        // 12MHz clock located in the ICEstick board

                        //  // ULPI signals
                        //  input  wire ULPI_DIR,       // ULPI DIRECTION
                        //  input  wire ULPI_NXT,       // ULPI NEXT
                        //  inout  wire [7:0]ULPI_DATA, // ULPI 8-bit parallel data
                        //  output wire ULPI_STP,       // ULPI STOP
                        //  output wire ULPI_RST,       // USB3300 RESET pin

                         // UART signals
                         input  wire UART_Rx,        // Serial Read
                         output wire UART_Tx,        // Serial Write

                         // I/O
                         input  wire IO_btn,
                         output wire [2:0]IO_test,
                         output wire [4:0]IO_LEDs
                        );

    /// Testing signals and controllers
    wire t_rst;
    assign t_rst = 1'b1;

    reg [7:0]t_UART_DATA_in  = 8'b0;
    reg [2:0]t_UART_in_count = 3'b0;

    always @(posedge clk_test) begin
    // t_UART_DATA_in <= "a";
        t_UART_in_count <= t_UART_in_count + 1'b1;
    end

    // always @(*) begin
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

    wire clk_test;
    wire clk_test_pulse;

    clk_div #(.DIVIDER(19))
    clk_div  (
              .clk_in(clk_ice), .clk_out(clk_test), .clk_pulse(clk_test_pulse), // Clock signals
              .enable(IO_btn) // Control signals
             );

    assign IO_LEDs[0] = clk_test;
    assign IO_LEDs[1] = IO_btn;
    assign IO_LEDs[2] = UART_TiP;
    assign IO_LEDs[3] = UART_Tx;
    assign IO_LEDs[4] = t_UART_in_count[2];

    assign IO_test[0] = UART_Tx;
    assign IO_test[1] = UART_Rx;
    assign IO_test[2] = UART_Tx_clk;
    // assign IO_test[1] = UART_Tx_clk;
    // assign IO_test[1] = UART_Rx_clk;
    /// End of Testing signals and controllers

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

/// Add UART RAM Tx/Rx
/// Why does not work the always loop with clk_shift??
    /// UART init
    // #MODULE_INIT UART

    wire [7:0]UART_DATA_out;
    wire UART_TiP;
    wire UART_NrD;
    wire UART_Rx_clk;
    wire UART_Tx_clk;

    UART #(.BAUDS(`B115200))
    UART  (
           // System signals
           .rst(t_rst), // [Input]
           .clk(clk_ice), // [Input]

           // UART signals
           .Rx(UART_Rx), // [Input]
           .Tx(UART_Tx), // [Output]
           .clk_Rx(UART_Rx_clk), // [Output]
           .clk_Tx(UART_Tx_clk), // [Output]

           // Data signals
        //    .I_DATA(UART_DATA_out), // [Input]
           .I_DATA(t_UART_DATA_in), // [Input]
           .O_DATA(UART_DATA_out), // [Output]

           // Control signals
           .send_data(UART_NrD), // [Input]
        //    .send_data(clk_test_pulse), // [Input]
           .TiP(UART_TiP), // [Output]
           .NrD(UART_NrD)  // [Output]
          );
    /// End of UART init



endmodule