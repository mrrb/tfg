/*
 *
 * SPI_COMM module
 * This module controls the SPI communication with a SPI Master. It handles the OSI level 2 (frame).
 * 
 * 
 */

/*
 *
 * Configs:
 * 1.A. Invert SCLK for [CPOL = 1]
 * 1.B. Not invert SCLK for [CPOL = 0]
 * 
 * 2.A. When SS goes from HIGH to LOW, the data is loaded into the shift register, and then, is shifted every faling edge of SCLK [CPHA = 0]
 * 2.B. The data is loaded and shifted every rising edge [CPHA = 1]
 * 
 */

`default_nettype none
`include "./modules/shift_register.vh" // Shift register module
`include "./modules/clk_pulse.vh"      // Clock pulse module

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
                 input  wire  [7:0]STA,      // Status code to send to the Master
                 input  wire  [7:0]DATA_in,  // Data to send to the Master
                 output wire  [7:0]CMD,      // Command received from the Master
                 output wire [15:0]ADDR,     // Address where the DATA must be read/write
                 output wire  [7:0]DATA_out, // Data received from the Master
                 output wire  [7:0]RAW_out,  // Raw data from the Master

                 // Control signals
                 input  wire err_in,  // Error in the SPI transaction (catched by the SPI main controller)
                 output wire err_out, // Error in the last SPI transaction (catched by SPI_COMM)
                 output wire EoB,     // End of Byte control signal
                 output wire busy     // When there is a transfer in progress this signal will be High
                );

    /// Shift register pulse module init
    wire shift_pulse;
    clk_pulse shift_clk (clk, SCLK, shift_pulse);
    /// End of Shift register pulse module init

    /// Shift register common signals
    reg  force_shift_r  = 1'b0; // Register that forces a shift/load in the shifts registers
    reg  shift_enable_r = 1'b0; // Register that controls the status of the shift registers
    wire clk_shift; assign clk_shift = shift_pulse || force_shift_r;
    /// End of Shift register common signals

    /// MOSI shift register init
    wire MOSI_bit_out;
    wire [7:0]MOSI_data;
    shift_register shift_MOSI (.clk(clk_shift), .enable(shift_enable_r), .bit_in(MOSI), .bit_out(MOSI_bit_out),
                               .DATA_out(MOSI_data), .DATA_in(8'b0), .PARALLEL_EN(1'b0));
    /// End of MOSI shift register init

    /// MISO shift register init
    wire MISO_bit_out;
    wire [7:0]MISO_out;
    wire [7:0]MISO_data; assign MISO_data = SET_r ? DATA_in : STA;
    wire MISO_shift_par; assign MISO_shift_par = SPI_s_LOAD;
    shift_register shift_MISO (.clk(!clk_shift), .enable(shift_enable_r || SPI_s_LOAD), .bit_in(1'b0), .bit_out(MISO_bit_out),
                               .DATA_out(MISO_out), .DATA_in(MISO_data), .PARALLEL_EN(MISO_shift_par));
    /// End of MISO shift register init

    /// SPI_COMM Regs and wires
    // Outputs
    reg  [7:0]CMD_r      =  8'b0;
    reg [15:0]ADDR_r     = 16'b0;
    reg  [7:0]DATA_out_r =  8'b0;
    reg  [7:0]RAW_out_r  =  8'b0;
    reg err_r = 1'b0;

    // Inputs
    // #NONE

    // Buffers

    // Control registers
    reg [2:0]SPI_state_r = 3'b0; // Register to store the current state of the SPI_COMM module
    reg [3:0]SPI_ctrl_r  = 4'b0; // Register to store the number of the next bit to be readed in each frame data packet
    reg [1:0]TR_count_r  = 2'b0; // Register that stores the remaining number of packets to read

    reg SET_r = 1'b0; // 
    reg [1:0]MODE_r = 2'b0;
    reg CONT_r  = 1'b0;
    reg WRITE_r = 1'b0;

    // Flags
    wire SPI_s_IDLE;  // 1 if SPI_state_r == SPI_IDLE,  else 0
    wire SPI_s_LOAD;  // 1 if SPI_state_r == SPI_LOAD,  else 0
    wire SPI_s_TRANS; // 1 if SPI_state_r == SPI_TRANS, else 0
    wire SPI_s_SAVE;  // 1 if SPI_state_r == SPI_SAVE,  else 0
    wire SPI_s_BACK;  // 1 if SPI_state_r == SPI_BACK,  else 0
    wire SPI_s_RST;   // 1 if SPI_state_r == SPI_RST,   else 0

    wire error;       // When an error occur (either from this module or from the main controller), this signal will be HIGH

    // Assigns
    assign SPI_s_IDLE  = (SPI_state_r == SPI_IDLE)  ? 1'b1 : 1'b0; // #FLAG
    assign SPI_s_LOAD  = (SPI_state_r == SPI_LOAD)  ? 1'b1 : 1'b0; // #FLAG
    assign SPI_s_TRANS = (SPI_state_r == SPI_TRANS) ? 1'b1 : 1'b0; // #FLAG
    assign SPI_s_SAVE  = (SPI_state_r == SPI_SAVE)  ? 1'b1 : 1'b0; // #FLAG
    assign SPI_s_BACK  = (SPI_state_r == SPI_BACK)  ? 1'b1 : 1'b0; // #FLAG
    assign SPI_s_RST   = (SPI_state_r == SPI_RST)   ? 1'b1 : 1'b0; // #FLAG

    assign MISO        = !SPI_s_IDLE ? MISO_out[0] : 1'b0; // #OUTPUT
    assign CMD         = CMD_r;             // #OUTPUT
    assign ADDR        = ADDR_r;            // #OUTPUT
    assign DATA_out    = DATA_out_r;        // #OUTPUT
    assign RAW_out     = RAW_out_r;         // #OUTPUT
    assign err_out     = err_r;             // #OUTPUT
    assign EoB         = SPI_s_BACK;        // #OUTPUT
    assign busy        = !SPI_s_IDLE;       // #OUTPUT

    assign error       = err_in || err_out; // #CONTROL
    /// End of SPI_COMM Regs and wires


    /// SPI_COMM States (See module description at the beginning to get more info)
    localparam SPI_IDLE  = 0;
    localparam SPI_LOAD  = 1;
    localparam SPI_TRANS = 2;
    localparam SPI_SAVE  = 3;
    localparam SPI_BACK  = 4;
    localparam SPI_RST   = 5;
    /// End of SPI_COMM States


    /// SPI_COMM controller
    // #FIGURE_NUMBER SPI_state_machine
    // Transactions
    always @(posedge clk) begin
        if(rst == 1'b1) begin
            SPI_state_r <= SPI_RST;
        end
        else begin
            case(SPI_state_r)
                SPI_IDLE: begin
                    // The controller is waiting for the SPI master to start a transmission
                    if(!SS) SPI_state_r <= SPI_LOAD;
                    else    SPI_state_r <= SPI_IDLE;
                end
                SPI_LOAD: begin
                    // The Data that is going to be sent is loaded into the shift register
                    if(!error) SPI_state_r <= SPI_TRANS;
                    else        SPI_state_r <= SPI_RST;
                end
                SPI_TRANS: begin
                    // Each bit of the packet is sent/read
                    if(error) 
                        SPI_state_r <= SPI_RST;
                    else if(SPI_ctrl_r == 4'b1000)
                        SPI_state_r <= SPI_SAVE;
                    else
                        SPI_state_r <= SPI_TRANS;
                end
                SPI_SAVE: begin
                    // Depending on the packet/frame type, the byte is stored/processed accordingly
                    if(!error) SPI_state_r <= SPI_BACK;
                    else        SPI_state_r <= SPI_RST;
                end
                SPI_BACK: begin
                    // If there aren't any more packets to send/read, the controller goes back to the default state
                    // Otherwise, the controller goes back to the SPI_LOAD state to read/send another byte
                    if(error)
                        SPI_state_r <= SPI_RST;
                    else if(!(TR_count_r == 2'b0))
                        SPI_state_r <= SPI_LOAD;
                    else
                        SPI_state_r <= SPI_RST;
                end
                SPI_RST: begin
                    // All the control registers are purged before another transmission
                    if(!error && SS) SPI_state_r <= SPI_IDLE;
                    else             SPI_state_r <= SPI_RST;
                end
                default: begin
                    SPI_state_r <= SPI_RST;
                end
            endcase
        end
    end

    // Actions
    always @(posedge clk) begin
        if(rst == 1'b1) begin

        end
        else begin
            case(SPI_state_r)
                SPI_IDLE: begin
                    SPI_ctrl_r <= 4'b0;
                    TR_count_r <= 1'b1;
                end
                SPI_LOAD: begin
                    shift_enable_r <= 1'b1;
                    force_shift_r <= 1'b1;
                end
                SPI_TRANS: begin
                    force_shift_r <= 1'b0;

                    if(SS) err_r <= 1'b1;
                end
                SPI_SAVE: begin
                    RAW_out_r <= MOSI_data;
                    if(!SET_r) begin
                        CMD_r <= MOSI_data;
                        MODE_r <= MOSI_data[1:0];
                        CONT_r <= MOSI_data[2];
                        WRITE_r <= MOSI_data[3];

                        TR_count_r <= TR_count_r + MOSI_data[1:0] - 1;
                    end
                    else if(MODE_r == 2'b01) begin
                        DATA_out_r <= MOSI_data;
                        if(CONT_r) TR_count_r <= 2'b01;
                        else TR_count_r <= TR_count_r - 1;
                    end
                    else if(MODE_r == 2'b10) begin
                        if(TR_count_r == 2'b01) begin
                            ADDR_r[7:0] <= MOSI_data;
                            if(CONT_r) TR_count_r <= 2'b10;
                            else TR_count_r <= TR_count_r - 1;
                        end
                        else if(TR_count_r == 2'b10) begin
                            ADDR_r[15:8] <= MOSI_data;
                            TR_count_r <= TR_count_r - 1;
                        end
                    end
                    else if(MODE_r == 2'b11) begin
                        if(TR_count_r == 2'b01) begin
                            DATA_out_r <= MOSI_data;
                            if(CONT_r) TR_count_r <= 2'b10;
                            else TR_count_r <= TR_count_r - 1;
                        end
                        else if(TR_count_r == 2'b10) begin
                            ADDR_r[7:0] <= MOSI_data;
                            TR_count_r <= TR_count_r - 1;
                        end
                        else if(TR_count_r == 2'b11) begin
                            ADDR_r[15:8] <= MOSI_data;
                            TR_count_r <= TR_count_r - 1;
                        end
                    end
                end
                SPI_BACK: begin

                end
                SPI_RST: begin
                    TR_count_r <= 2'b0;
                    SPI_ctrl_r <= 4'b0;
                    shift_enable_r <= 1'b0;
                end
                default: begin
                    
                end
            endcase
        end
    end

    // Every time a bit is readed, the counter is incremented by one
    always @(negedge shift_pulse) if(!SPI_s_IDLE) SPI_ctrl_r <= SPI_ctrl_r + 1'b1;
    /// End of SPI_COMM controller

 endmodule