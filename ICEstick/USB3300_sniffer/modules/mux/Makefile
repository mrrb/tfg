M_NAME  := mux

M_MOD   := ''

TB_DIR  := ./tb
RTL_DIR := ./rtl
SIM_DIR := ./sim

all: sim gtk

sim: $(SIM_DIR)/$(M_NAME)$(M_MOD)_tb.out
	$^

$(SIM_DIR)/$(M_NAME)$(M_MOD)_tb.out: $(TB_DIR)/$(M_NAME)$(M_MOD)_tb.v $(RTL_DIR)/$(M_NAME).v
	mkdir -p $(SIM_DIR)/
	iverilog $^ -o $(SIM_DIR)/$(M_NAME)$(M_MOD)_tb.out

gtk: $(SIM_DIR)/$(M_NAME)$(M_MOD)_tb.vcd
	gtkwave $< &

$(SIM_DIR)/$(M_NAME)$(M_MOD)_tb.vcd: $(SIM_DIR)/$(M_NAME)$(M_MOD)_tb.out
	$<

clean:
	rm -fdr ./$(SIM_DIR) *.vcf

