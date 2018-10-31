/// USB3300_parser Regs and wires
// Buffers
reg [2:0]main_STA_FPGA_request_r = 3'b0;
reg [2:0]main_STA_FPGA_status_r  = 3'b0;
reg [1:0]main_STA_error_code_r   = 2'b0;

// Control registers
// reg []main_state_r = 'b0;

// Flags
wire [7:0]main_STA = {main_STA_FPGA_request_r, main_STA_FPGA_status_r, main_STA_error_code_r};
wire main_rst;

// Assigns
assign main_rst = 1'b1;
/// End of USB3300_parser Regs and wires

/// USB3300_parser States
localparam MAIN_IDLE = 0;
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