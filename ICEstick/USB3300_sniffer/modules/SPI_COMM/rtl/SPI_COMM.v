/*
 *
 * SPI_COMM module
 * This module controls the SPI communication with a SPI Master. It handles the OSI level 2 (frame).
 * 
 * 
 */

`default_nettype none
`include "./modules/shift_register.vh" // Shift register module

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

    /// Shift register init
    reg shift_bit_in_r = 1'b0;
    reg force_clk_r    = 1'b0;
    reg shift_enable_r = 1'b0;
    reg shift_par_r    = 1'b0;

    wire shift_clk_w;
    wire shift_bit_out_w;
    wire [7:0]shift_DATA_in_w;
    wire [7:0]shift_DATA_out_w;

    shift_register shift_MOSI (.clk(shift_clk_w),         .enable(shift_enable_r),
                               .bit_in(shift_bit_in_r),   .bit_out(shift_bit_out_w),
                               .DATA_in(shift_DATA_in_w), .DATA_out(shift_DATA_out_w),
                               .PARALLEL_EN(shift_par_r));
    /// End of Shift register init

    /// SPI_COMM Regs and wires
    // Outputs
    reg  [7:0]CMD_r      =  8'b0;
    reg [15:0]ADDR_r     = 16'b0;
    reg  [7:0]DATA_out_r =  8'b0;
    reg  [7:0]RAW_out_r  =  8'b0;

    reg  err_r = 1'b0;
    reg  EoB_r = 1'b0;

    // Inputs
    // #NONE

    // Buffers

    // Control registers
    reg [1:0]SPI_state_r = 2'b0; // Register to store the current state of the SPI_COMM module
    reg [3:0]SPI_count_r = 4'b0; // Register to store the number of the next bit to be readed in each frame data packet
    reg [1:0]TR_count_r  = 2'b0; // Register that stores the remaining number of packets to read

    reg [1:0]MODE_r = 2'b0;
    reg CONT_r      = 1'b0;
    reg WRITE_r     = 1'b0;

    // Flags
    wire SPI_s_IDLE;  // 1 if SPI_state_r == SPI_IDLE,  else 0
    wire SPI_s_TRANS; // 1 if SPI_state_r == SPI_TRANS, else 0
    wire SPI_s_RST;   // 1 if SPI_state_r == SPI_RST,   else 0

    wire error;

    // Assigns
    assign SPI_s_IDLE  = (SPI_state_r == SPI_IDLE)  ? 1'b1 : 1'b0; // #FLAG
    assign SPI_s_TRANS = (SPI_state_r == SPI_TRANS) ? 1'b1 : 1'b0; // #FLAG
    assign SPI_s_RST   = (SPI_state_r == SPI_RST)   ? 1'b1 : 1'b0; // #FLAG

    assign shift_clk_w     = !SCLK || force_clk_r;        // #SHIFT_REGISTER
    assign shift_DATA_in_w = SPI_s_IDLE ? STA  : DATA_in; // #SHIFT_REGISTER
    // assign shift_par_w     = SPI_s_IDLE ? 1'b1 : 1'b0;    // #SHIFT_REGISTER

    assign MISO     = !SPI_s_IDLE ? shift_DATA_out_w[0] : 1'b0; // #OUTPUT
    assign CMD      = CMD_r;       // #OUTPUT
    assign ADDR     = ADDR_r;      // #OUTPUT
    assign DATA_out = DATA_out_r;  // #OUTPUT
    assign RAW_out  = RAW_out_r;   // #OUTPUT
    assign err_out  = err_r;       // #OUTPUT
    assign EoB      = EoB_r;       // #OUTPUT
    assign busy     = !SPI_s_IDLE; // #OUTPUT

    assign error = err_in || err_out; // #CONTROL
    /// End of SPI_COMM Regs and wires


    /// SPI frame modes
    localparam SPI_f_MODE_0 = 2'b00;
    localparam SPI_f_MODE_1 = 2'b01;
    localparam SPI_f_MODE_2 = 2'b10;
    localparam SPI_f_MODE_3 = 2'b11;

    localparam SPI_f_SINGLE = 1'b0;
    localparam SPI_f_CONT   = 1'b1;

    localparam SPI_f_READ   = 1'b0;
    localparam SPI_f_WRITE  = 1'b1;
    /// End of SPI frame modes


    /// SPI_COMM States (See module description at the beginning to get more info)
    localparam SPI_IDLE  = 0;
    localparam SPI_TRANS = 1;
    localparam SPI_RST   = 2;
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
                    if(!SS) SPI_state_r <= SPI_TRANS;
                    else    SPI_state_r <= SPI_IDLE;
                end
                SPI_TRANS: begin
                    if(error)
                        SPI_state_r <= SPI_RST;
                    else if(SPI_count_r != 4'b1000)
                        SPI_state_r <= SPI_TRANS;
                    else if(SPI_count_r == 4'b1000) begin
                        if(TR_count_r != 2'b0) SPI_state_r <= SPI_TRANS;
                        else begin
                            if(CONT_r)
                                SPI_state_r <= SPI_TRANS;
                            else
                                SPI_state_r <= SPI_RST;
                        end
                    end
                    else
                        SPI_state_r <= SPI_RST;
                end
                SPI_RST: begin
                    if(!error && SS) SPI_state_r <= SPI_IDLE;
                    else SPI_state_r <= SPI_RST;
                end
                default: SPI_state_r <= SPI_RST;
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
                    if(!SS) begin
                        shift_enable_r <= 1'b1;
                        force_clk_r <= 1'b1;
                        shift_par_r <= 1'b1;
                    end
                end
                SPI_TRANS: begin
                    force_clk_r <= 1'b0;
                    shift_par_r <= 1'b0;
                    if(SPI_count_r == 4'b1000) begin
                        EoB_r <= 1'b1;
                        if(MODE_r == SPI_f_MODE_0) begin
                            CMD_r   <= shift_DATA_out_w;
                            MODE_r  <= shift_DATA_out_w[1:0];
                            CONT_r  <= shift_DATA_out_w[2];
                            WRITE_r <= shift_DATA_out_w[3];

                            TR_count_r <= TR_count_r - 1'b1 + shift_DATA_out_w[1:0];
                        end
                        else if(MODE_r == SPI_f_MODE_1) begin
                            if(CONT_r) TR_count_r <= 2'b01;
                            else       TR_count_r <= TR_count_r - 1'b1;
                        end
                        else if(MODE_r == SPI_f_MODE_2) begin
                            if(TR_count_r == 2'b10) begin
                                ADDR_r[15:8] = shift_DATA_out_w;
                                TR_count_r <= TR_count_r - 1'b1;
                            end
                            else if(TR_count_r == 2'b01) begin
                                ADDR_r[7:0] = shift_DATA_out_w;
                                if(CONT_r) TR_count_r <= 2'b10;
                                else       TR_count_r <= TR_count_r - 1'b1;
                            end
                        end
                        else if(MODE_r == SPI_f_MODE_3) begin
                            if(TR_count_r == 2'b11) begin
                                ADDR_r[15:8] = shift_DATA_out_w;
                                TR_count_r <= TR_count_r - 1'b1;
                            end
                            else if(TR_count_r == 2'b10) begin
                                ADDR_r[7:0] = shift_DATA_out_w;
                                TR_count_r <= TR_count_r - 1'b1;
                            end
                            else if(TR_count_r == 2'b01) begin
                                ADDR_r[7:0] = shift_DATA_out_w;
                                if(CONT_r) TR_count_r <= 2'b11;
                                else       TR_count_r <= TR_count_r - 1'b1;
                            end
                        end
                    end
                    else begin
                        EoB_r <= 1'b0;
                    end
                end
                SPI_RST: begin
                    shift_enable_r <= 1'b0;
                    SPI_count_r    <= 4'b0;
                    force_clk_r <= 1'b0;
                    shift_par_r <= 1'b0;

                    MODE_r  <= 2'b0;
                    CONT_r  <= 1'b0;
                    WRITE_r <= 1'b0;

                    EoB_r <= 1'b0;

                    SPI_count_r <= 4'b0;
                    TR_count_r  <= 2'b0;
                end
                default: begin
                end
            endcase
        end
    end

    // SCLK posedge loop
    always @(posedge SCLK) begin
        if(!SS) shift_bit_in_r <= MOSI;
        if(!SS) SPI_count_r <= SPI_count_r + 1'b1;
    end
    // End of SCLK posedge loop

    // SCLK negedge loop
    always @(negedge SCLK) begin
    end
    // End of SCLK negedge loop
    /// End of SPI_COMM controller

endmodule