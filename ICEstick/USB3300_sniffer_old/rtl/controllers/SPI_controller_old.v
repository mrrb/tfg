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