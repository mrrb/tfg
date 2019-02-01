M_NAME    := shift_register
M_FOLDER  := shift_register
  
TB_DIR    := ./tb
RTL_DIR   := ./rtl
SIM_DIR   := ./sim
PRE_DIR   := ./modules/$(M_FOLDER)/

all: sim gtk

sim: $(SIM_DIR)/$(M_NAME)_tb.out
	$^

$(SIM_DIR)/$(M_NAME)_tb.out: $(TB_DIR)/$(M_NAME)_tb.v $(RTL_DIR)/$(M_NAME).v
	mkdir -p $(SIM_DIR)/
	@ cd ../.. && iverilog $(patsubst %, $(PRE_DIR)/%, $^) -o $(PRE_DIR)/$(SIM_DIR)/$(M_NAME)_tb.out -I ./modules -I ./modules_simulation

gtk: $(SIM_DIR)/$(M_NAME)_tb.vcd
	gtkwave $< $(M_NAME).gtkw &

$(SIM_DIR)/$(M_NAME)_tb.vcd: $(SIM_DIR)/$(M_NAME)_tb.out
	$<

# Analysis

$(SIM_DIR)/diagram.dot: $(RTL_DIR)/$(M_NAME).v
	mkdir -p $(SIM_DIR)/
	@ cd ../.. && yosys -q -p "synth_ice40 -top $(M_NAME); show -stretch -prefix $(PRE_DIR)/$(SIM_DIR)/diagram -colors 13579 -format svg;" $(PRE_DIR)/$^

plot: $(SIM_DIR)/diagram.dot

dot_view: $(SIM_DIR)/diagram.dot
	xdot $(SIM_DIR)/diagram.dot

#

clean:
	rm -fdr $(SIM_DIR)

.PHONY: all sim gtk plot dot_view clean