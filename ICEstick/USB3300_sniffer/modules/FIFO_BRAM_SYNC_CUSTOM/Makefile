M_NAME    := FIFO_BRAM_SYNC_CUSTOM
M_FOLDER  := FIFO_BRAM_SYNC_CUSTOM
  
TB_DIR    := ./tb
RTL_DIR   := ./rtl
SIM_DIR   := ./sim
PRE_DIR   := ./modules/$(M_FOLDER)/

all: sim gtk

sim: $(SIM_DIR)/$(M_NAME)_tb.out
	$^

$(SIM_DIR)/$(M_NAME)_tb.out: $(TB_DIR)/$(M_NAME)_tb.v $(RTL_DIR)/$(M_NAME).v
	mkdir -p $(SIM_DIR)/
	cd ../.. && iverilog $(patsubst %, $(PRE_DIR)/%, $^) -o $(PRE_DIR)/$(SIM_DIR)/$(M_NAME)_tb.out -I ./modules -I ./modules_simulation

gtk: $(SIM_DIR)/$(M_NAME)_tb.vcd
	gtkwave $< $(M_NAME).gtkw &

$(SIM_DIR)/$(M_NAME)_tb.vcd: $(SIM_DIR)/$(M_NAME)_tb.out
	$<

clean:
	rm -fdr $(SIM_DIR)

.PHONY: all sim gtk clean

