M_NAME    := SB_PLL40_CORE
M_FOLDER  := SB_PLL40_CORE
  
TB_DIR    := ./tb
RTL_DIR   := ./rtl
SIM_DIR   := ./sim
PRE_DIR   := ./modules_simulation/$(M_FOLDER)

all: sim gtk

sim: $(SIM_DIR)/$(M_NAME)_tb.out
	$^

$(SIM_DIR)/$(M_NAME)_tb.out: $(TB_DIR)/$(M_NAME)_tb.v $(RTL_DIR)/$(M_NAME).v
	mkdir -p $(SIM_DIR)/
	cd ../.. && iverilog $(patsubst %, $(PRE_DIR)/%, $^) -o $(PRE_DIR)/$(SIM_DIR)/$(M_NAME)_tb.out

gtk: $(SIM_DIR)/$(M_NAME)_tb.vcd
	gtkwave $< $(M_NAME).gtkw &

$(SIM_DIR)/$(M_NAME)_tb.vcd: $(SIM_DIR)/$(M_NAME)_tb.out
	$<

clean:
	rm -fdr $(SIM_DIR)

.PHONY: all sim gtk clean

