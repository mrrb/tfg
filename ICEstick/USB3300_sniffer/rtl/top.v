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

`ifdef ASYNC_RESET
    `define TOP_ASYNC_RESET or negedge rst
`else
    `define TOP_ASYNC_RESET
`endif

`include "./rtl/bauds.vh"

`include "./modules/UART.vh"
`include "./modules/ULPI.vh"
`include "./modules/ULPI_WRAPPER.vh"
`include "./modules/clk_div.vh"

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
                         output wire [4:0]IO_LEDs,   // 4 (red) + 1 (green) LED's on the ICEstick board
                         output wire [7:0]IO_bank1,  // Bank 0 I/O (bottom right connector [from top to bottom, ])
                         output wire [1:0]IO_bank2   // Remaining free I/O's of the Bank 2 connector (bottom left)
                        );
/// reset
    /// Reset signal
    wire rst;
    assign rst = 1'b1;
    // assign ULPI_RST = !rst;
    /// End of Reset signal
///


/// Timers
    /// Timers
    // #MODULE_INIT Timers
    wire clk_div_ice, clk_div_ice_pulse;
    clk_div       #(.DIVIDER(24))
    clk_div_ice_m  (
                    // Clock signals
                    .clk_in(clk_ice),              // [Input]
                    .clk_out(clk_div_ice),         // [Output]
                    .clk_pulse(clk_div_ice_pulse), // [Output]

                    // Control signals
                    .enable(1'b1)                  // [Input]
                   );

    wire clk_div_ULPI, clk_div_ULPI_pulse;
    clk_div        #(.DIVIDER(24))
    clk_div_ULPI_m  (
                     // Clock signals
                     .clk_in(clk_ULPI),              // [Input]
                     .clk_out(clk_div_ULPI),         // [Output]
                     .clk_pulse(clk_div_ULPI_pulse), // [Output]

                     // Control signals
                     .enable(1'b1)                   // [Input]
                    );
    /// End of Timers
///


/// Assings
    /// IO_LEDs assigns
    assign IO_LEDs[0] = clk_div_ice;  // Middle LED
    assign IO_LEDs[1] = clk_div_ULPI; // TOP LED (near FPGA ic)
    assign IO_LEDs[2] = ULPI_DIR;     // RIGHT LED
    // assign IO_LEDs[3] = ULPI_STP;     // BOTTOM LED (near PMOD connector)
    // assign IO_LEDs[4] = ULPI_NXT;     // LEFT LED
    assign IO_LEDs[3] = 0;
    assign IO_LEDs[4] = 0;

    /// IO_bank1 assigns


    /// IO_bank2 assigns


///


/// Test assigns

    assign IO_bank1 = 0;
    assign IO_bank2 = 0;
    // assign IO_bank1[0] = UART_Tx;
    // assign IO_bank1[1] = UART_Rx;
    // assign IO_bank1[2] = UART_Tx_clk;
    // assign IO_bank1[3] = UART_Rx_clk;
    // assign IO_bank1[4] = ULPI_DIR;

    // assign IO_bank1 = UART_DATA_out;

    // assign UART_DATA_in = UTMI_data_in_o;
    // assign UART_send    = !UART_Rx_EMPTY;
    // assign UART_NxT     = !UART_Rx_EMPTY;

    // assign UART_DATA_in = ULPI_DATA_out;
    assign UART_DATA_in = ULPI_RxCMD;
    // assign UART_DATA_in = UTMI_data_in_o;
    // assign UART_DATA_in = {1'b0, 1'b0, UTMI_rxvalid_o, UTMI_rxactive_o, UTMI_rxerror_o, 1'b0, 1'b1, 1'b1};

    // assign UART_DATA_in = UART_DATA_out;
    assign UART_send    = !UART_Rx_EMPTY;
    assign UART_NxT     = !UART_Rx_EMPTY;
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

    UART #(.BAUDS(`B921600))
    UART  (
           // System signals
           .rst(rst),               // [Input]
           .clk(clk_ULPI),           // [Input]

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

/// ULPI INOUT
    /// ULPI tristate controller
    wire [7:0] ULPI_DATA_in, ULPI_DATA_out;

    // Yosys has only limited support for tri-state logic, so the tristate ULPI DATA bus must me manually initialized.
    genvar i = 0;
    generate
        for(i=0; i<8; i=i+1) begin : IO_TRI_DATA_GEN
            SB_IO      #(
                        .PIN_TYPE(6'b1010_01), // Input and Output Pin Function Tables. ICE Technology Library. Page 88.
                                                // [5:2] => PIN_OUTPUT_TRISTATE
                                                // [1:0] => PIN_INPUT
                        .PULLUP(1'b0)          // No pull-up
                        )
            IO_TRI_DATA (
                        .PACKAGE_PIN(ULPI_DATA[i]), // Physical tristate I/O wire
                        .OUTPUT_ENABLE(!ULPI_DIR),  // Control signal
                        .D_OUT_0(ULPI_DATA_out[i]), // 
                        .D_IN_0(ULPI_DATA_in[i])    // 
                        );
        end
    endgenerate

    // Tristate slector (NOT COMPATIBLE WITH YOSYS!!)
    // assign ULPI_DATA_in = ULPI_DATA;
    // assign ULPI_DATA = (ULPI_DIR) ? 8'bz : ULPI_DATA_out; // When the PHY has the ownership of the bus, the FPGA must have the inputs in a HIGH impedance mode
    //                                                       //   so there will not have any conflicts.
    /// End of ULPI tristaet controller
///

/// ULPI
    /// ULPI init
    // #MODULE_INIT ULPI
    wire ULPI_PrW, ULPI_PrR;
    wire [2:0] ULPI_status;

    wire [5:0] ULPI_ADDR;
    wire [7:0] ULPI_REG_VAL_W, ULPI_REG_VAL_R;

    wire [7:0] ULPI_RxCMD;
    wire [1:0] ULPI_RxLineState, ULPI_RxVbusState;
    wire ULPI_RxActive, ULPI_RxError, ULPI_RxHostDisconnect, ULPI_RxID;

    wire ULPI_DATA_re, ULPI_INFO_re, ULPI_DATA_buff_full, ULPI_DATA_buff_empty, ULPI_INFO_buff_full, ULPI_INFO_buff_empty;
    wire  [7:0] ULPI_USB_DATA;
    wire [15:0] ULPI_USB_INFO_DATA;

    ULPI ULPI (
               // System signals
               .rst(rst),                                // [Input]
               .clk_ice(clk_ice),                        // [Input]
               .clk_ULPI(clk_ULPI),                      // [Input]
               
               // Control signals
               .PrW(ULPI_PrW),                           // [Input]
               .PrR(ULPI_PrR),                           // [Input]
               .status(ULPI_status),                     // [Output]
               
               // Register signals
               .ADDR(ULPI_ADDR),                         // [Input]
               .REG_VAL_W(ULPI_REG_VAL_W),               // [Input]
               .REG_VAL_R(ULPI_REG_VAL_R),               // [Output]
               
               // Rx states
               .RxCMD(ULPI_RxCMD),                       // [Output]
               .RxLineState(ULPI_RxLineState),           // [Output]
               .RxVbusState(ULPI_RxVbusState),           // [Output]
               .RxActive(ULPI_RxActive),                 // [Output]
               .RxError(ULPI_RxError),                   // [Output]
               .RxHostDisconnect(ULPI_RxHostDisconnect), // [Output]
               .RxID(ULPI_RxID),                         // [Output]
               
               // Buffer control
               .DATA_re(ULPI_DATA_re),                   // [Input]
               .INFO_re(ULPI_INFO_re),                   // [Input]
               .USB_DATA(ULPI_USB_DATA),                 // [Output]
               .USB_INFO_DATA(ULPI_USB_INFO_DATA),       // [Output]
               .DATA_buff_full(ULPI_DATA_buff_full),     // [Output]
               .DATA_buff_empty(ULPI_DATA_buff_empty),   // [Output]
               .INFO_buff_full(ULPI_INFO_buff_full),     // [Output]
               .INFO_buff_empty(ULPI_INFO_buff_empty),   // [Output]
               
               // ULPI signals
               .DIR(ULPI_DIR),                           // [Input]
               .NXT(ULPI_NXT),                           // [Input]
               .DATA_in(ULPI_DATA_in),                   // [Input]
               .DATA_out(ULPI_DATA_out),                 // [Output]
               .STP(ULPI_STP),                           // [Output]
               .U_RST(ULPI_RST)                          // [Output]
              );
    /// End of ULPI init
///


// /// ULPI WRAPPER
//     /// ULPI WRAPPER
//     wire UTMI_txvalid_i, UTMI_txready_o; // NOT-USED -> Only for DATA transmission
//     wire UTMI_rxvalid_o, UTMI_rxactive_o, UTMI_rxerror_o;
//     wire [7:0] UTMI_data_in_o, UTMI_data_out_i;
//     wire [1:0] UTMI_xcvrselect_i, UTMI_op_mode_i, UTMI_linestate_o;
//     wire UTMI_termselect_i, UTMI_dppulldown_i, UTMI_dmpulldown_i;
//     ULPI_WRAPPER ULPI_WRAPPER_m (
//                                  // ULPI Interface (PHY)
//                                  .ulpi_clk60_i(clk_ULPI),               // [Input]
//                                  .ulpi_rst_i(!rst),                     // [Input]
//                                  .ulpi_data_out_i(ULPI_DATA_in),        // [Input]
//                                  .ulpi_data_in_o(ULPI_DATA_out),        // [Output]
//                                  .ulpi_dir_i(ULPI_DIR),                 // [Input]
//                                  .ulpi_nxt_i(ULPI_NXT),                 // [Input]
//                                  .ulpi_stp_o(ULPI_STP),                 // [Output]

//                                  // UTMI Interface (SIE)
//                                  .utmi_txvalid_i(UTMI_txvalid_i),       // [Input]
//                                  .utmi_txready_o(UTMI_txready_o),       // [Output]
//                                  .utmi_rxvalid_o(UTMI_rxvalid_o),       // [Output]
//                                  .utmi_rxactive_o(UTMI_rxactive_o),     // [Output]
//                                  .utmi_rxerror_o(UTMI_rxerror_o),       // [Output]
//                                  .utmi_data_in_o(UTMI_data_in_o),       // [Output]
//                                  .utmi_data_out_i(UTMI_data_out_i),     // [Input]
//                                  .utmi_xcvrselect_i(UTMI_xcvrselect_i), // [Input]
//                                  .utmi_op_mode_i(UTMI_op_mode_i),       // [Input]
//                                  .utmi_linestate_o(UTMI_linestate_o),   // [Output]
//                                  .utmi_termselect_i(UTMI_termselect_i), // [Input]
//                                  .utmi_dppulldown_i(UTMI_dppulldown_i), // [Input]
//                                  .utmi_dmpulldown_i(UTMI_dmpulldown_i)  // [Input]
//                                 );
//     /// End of ULPI WRAPPER
// ///


// /// UTMI assigns
//     /// UTMI assigns
//     assign UTMI_op_mode_i = 2'b01; // UTMI non-driving mode so the PHY uses tristate inputs
//     /// End of UTMI assigns
// ///


/// Controllers
    /// Controllers
    // TOP Regs and wires
    // Outputs
    // Control registers and wires
    reg TOP_state_r = 0;

    // Flags
    wire TOP_s_START; // HIGH if TOP_state_r == TOP_START, else LOW
    wire TOP_s_IDLE;  // HIGH if TOP_state_r == TOP_IDLE,  else LOW
    
    // Assigns
    assign TOP_s_START = (TOP_state_r == TOP_START) ? 1'b1 : 1'b0; // #FLAG
    assign TOP_s_IDLE  = (TOP_state_r == TOP_IDLE)  ? 1'b1 : 1'b0; // #FLAG

    // End of TOP Regs and wires

    // TOP States (See module description at the beginning of this file to get more info)
    localparam TOP_START = 0;
    localparam TOP_IDLE = 1;
    // End of TOP States

    // TOP controller
    always @(posedge clk_ULPI `TOP_ASYNC_RESET) begin
        if(!rst) TOP_state_r <= TOP_START;
        else begin
            case(TOP_state_r)
                TOP_START: begin

                end
                TOP_IDLE: begin

                end
                default: TOP_state_r <= TOP_START;
            endcase
        end
    end
    // End of TOP controller
    /// End of Controllers
///

endmodule