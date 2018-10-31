/// main_SPI Regs and wires
// Buffers

// Control registers
reg main_SPI_state_r = 

// Flags

// Assigns

/// End of main_SPI Regs and wires

/// main_SPI States (See module description at the beginning to get more info)
/// End of main_SPI States

/// main_SPI controller
// #FIGURE_NUMBER main_SPI_state_machine
// States
always @(posedge clk_ctrl) begin
    if(!main_rst) begin
        SPI_state_r <= SPI_RST;
    end
    else begin
        case()
            : begin
            end
            default: begin
            end
        endcase
    end
end
// Actions
always @(posedge clk_ctrl) begin
    if(!main_rst) begin
    end
    else begin
        case()
            : begin
            end
            default: begin
            end
        endcase
    end
end
/// End of main_SPI controller