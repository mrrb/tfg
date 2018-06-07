M_NAME  := clk_div_gen

TB_DIR  := ./tb
RTL_DIR := ./rtl
SIM_DIR := ./sim

all: sim gtk

sim: $(SIM_DIR)/$(M_NAME)_tb.out
	$^

$(SIM_DIR)/$(M_NAME)_tb.out: $(TB_DIR)/$(M_NAME)_tb.v $(RTL_DIR)/$(M_NAME).v
	mkdir -p $(SIM_DIR)/
	iverilog $^ -o $(SIM_DIR)/$(M_NAME)_tb.out

gtk: $(SIM_DIR)/$(M_NAME)_tb.vcd

$(SIM_DIR)/$(M_NAME)_tb.vcd: $(SIM_DIR)/$(M_NAME)_tb.out
	gtkwave $@ &

clean:
	rm -fdr ./$(SIM_DIR) *.vcf

