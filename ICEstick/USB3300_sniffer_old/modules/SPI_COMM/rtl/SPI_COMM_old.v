/*
 *
 * SPI_COMM module
 * This module controls the SPI communication with a SPI Master. It handles the OSI level 2 (frame).
 * 
 * 
 */

`default_nettype none

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
                input  wire [7:0]DATA_in,  // Data to send to the computer
                output wire [7:0]DATA_out, // Data received from the computer

                // Control signals
                input  wire err_in,        // Error in the SPI transaction (catched by the SPI main controller)
                output wire err_out,       // Error in the last SPI transaction (catched by SPI_COMM)
                output wire EoB,           // End of Byte control signal
                output wire busy,          // When there is a transfer in progress this signal will be High

                // Frame info signals
                output wire [4:0]CMD,      // Command => data_out[4:0]
                output wire [7:0]INFO_out, // INFO packet in long format transmissions
                output wire sec_CMD,       // The frame has a secondary packet
                output wire read,          // The PC request the FPGA to send data
                output wire format         // The frame is a secondary transmission (long format)
               );

    /// Shift register pulse module init
    wire shift_pulse;
    clk_pulse shift_clk (clk, SCLK, shift_pulse);
    /// End of Shift register pulse module init

    /// Shift register common signals
    reg  force_shift_r    = 1'b0; // Register that forces a shift/load in the shifts registers
    reg  shift_enable_r   = 1'b0; // Register that controls the status of the shift registers
    wire clk_shift; assign clk_shift = shift_pulse || force_shift_r;
    /// End of Shift register common signal

    /// MOSI shift register init
    wire MOSI_bit_out;
    wire [7:0]MOSI_data;
    shift_register shift_MOSI (.clk(clk_shift), .enable(shift_enable_r), .bit_in(MOSI), .bit_out(MOSI_bit_out), .DATA_out(MOSI_data), .DATA_in(8'b0), .PARALLEL_EN(1'b0));
    /// End of MOSI shift register init

    /// MISO shift register init
    wire MISO_shift_par; reg MISO_shift_par_r = 1'b0; assign MISO_shift_par = MISO_shift_par_r;
    wire [7:0]MISO_out;
    wire MISO_bit_out;
    shift_register shift_MISO (.clk(clk_shift), .enable(shift_enable_r), .bit_in(1'b0), .bit_out(MISO_bit_out), .DATA_out(MISO_out), .DATA_in(DATA_in), .PARALLEL_EN(MISO_shift_par));
    /// End of MISO shift register init

    /// SPI_COMM Regs and wires
    // Outputs
    reg [7:0]DATA_out_r = 8'b0;
    reg err_r           = 1'b0;
    reg [4:0]CMD_r      = 5'b0;
    reg [7:0]INFO_r     = 7'b0;

    // Inputs
    // #NONE

    // Buffers
    reg [7:0]DATA_in_buff_r = 8'b0; // Buffer where the DATA that is going to be send is stored

    // Control registers
    reg [2:0]SPI_state_r = 3'b0; // Register to store the current state of the SPI_COMM module
    reg [3:0]SPI_ctrl_r  = 4'b0; // Register to store the number of the next bit to be readed in each frame data packet
    reg [4:0]TR_count_r  = 5'b0; // Register that stores the remaining number of packets to read (32 bytes max.)

    reg SET_A_r = 1'b0; // Register that controls which format has the frame
    reg SET_B_r = 1'b0; // Register that controls if we are reading/writing data

    reg format_r  = 1'b0; // If the format of the message is "Long" this register will stored a '1', elsewise, a '0' ("short format")
    reg read_r    = 1'b0; // If there is a READ command, this register will stored a '1', elsewise, a '0' (WRITE)
    reg sec_CMD_r = 1'b0; // If the command will have a secondary CMD, this register will stored a '1', elsewise, a '0'.

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
    assign DATA_out    = DATA_out_r;        // #OUTPUT
    assign err_out     = err_r;             // #OUTPUT
    assign EoB         = SPI_s_BACK;        // #OUTPUT
    assign busy        = !SPI_s_IDLE;       // #OUTPUT
    assign CMD         = CMD_r;             // #OUTPUT
    assign INFO_out    = INFO_r;            // #OUTPUT
    assign sec_CMD     = sec_CMD_r;         // #OUTPUT
    assign read        = read_r;            // #OUTPUT
    assign format      = format_r;          // #OUTPUT

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
                    if(end_tr) SPI_state_r <= SPI_RST;
                    else       SPI_state_r <= SPI_TRANS;
                end
                SPI_TRANS: begin
                    // Each bit of the packet is sent/read
                    if(end_tr)                      SPI_state_r <= SPI_RST;
                    else if(SPI_ctrl_r == 4'b1000)  SPI_state_r <= SPI_SAVE;
                    else                            SPI_state_r <= SPI_TRANS;
                end
                SPI_SAVE: begin
                    // Depending on the packet/frame type, the byte is stored/processed accordingly
                    if(end_tr) SPI_state_r <= SPI_RST;
                    else       SPI_state_r <= SPI_BACK;
                end
                SPI_BACK: begin
                    // If there aren't any more packets to send/read, the controller goes back to the default state
                    // Otherwise, the controller goes back to the SPI_LOAD state to read/send another byte
                    if(end_tr) SPI_state_r <= SPI_RST;
                    else if(!(TR_count_r == 4'b0))
                        SPI_state_r <= SPI_LOAD;
                    else if(sec_CMD_r && SS)
                        SPI_state_r <= SPI_IDLE;
                    else if(sec_CMD_r && !SS)
                        SPI_state_r <= SPI_BACK;
                    else
                        SPI_state_r <= SPI_RST;
                end
                SPI_RST: begin
                    // All the control registers are purged before another transmission
                    if(SS && !error) SPI_state_r <= SPI_IDLE;
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

                end
                SPI_LOAD: begin

                end
                SPI_TRANS: begin

                end
                SPI_SAVE: begin

                end
                SPI_BACK: begin

                end
                SPI_RST: begin

                end
                default: begin
                    
                end
            endcase
        end
    end

    // Every time a bit is readed, the counter is incremented by one
    always @(negedge shift_pulse) SPI_ctrl_r <= SPI_ctrl_r + 1'b1;
    /// End of SPI_COMM controller

endmodule