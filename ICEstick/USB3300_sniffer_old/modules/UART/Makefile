M_NAME    := UART
T_NAME	  := top
  
TB_DIR    := ./tb
RTL_DIR   := ./rtl
SIM_DIR   := ./sim
PRE_DIR   := ./modules/$(M_NAME)/
BUILD_DIR := ./build

all: sim gtk

sim: $(SIM_DIR)/$(M_NAME)_tb.out
	$^

$(SIM_DIR)/$(M_NAME)_tb.out: $(TB_DIR)/$(M_NAME)_tb.v $(RTL_DIR)/$(M_NAME).v
	mkdir -p $(SIM_DIR)/
	cd ../.. && iverilog $(patsubst %, $(PRE_DIR)/%, $^) -o $(PRE_DIR)/$(SIM_DIR)/$(M_NAME)_tb.out -I ./modules

gtk: $(SIM_DIR)/$(M_NAME)_tb.vcd
	gtkwave $< &

$(SIM_DIR)/$(M_NAME)_tb.vcd: $(SIM_DIR)/$(M_NAME)_tb.out
	$<

sint: $(BUILD_DIR)/$(T_NAME).bin

$(BUILD_DIR)/$(T_NAME).bin: $(RTL_DIR)/$(T_NAME).v $(RTL_DIR)/$(T_NAME).pcf
	mkdir -p $(BUILD_DIR)/
	cd ../.. && yosys -p "synth_ice40 -blif $(PRE_DIR)/$(BUILD_DIR)/$(T_NAME).blif" $(PRE_DIR)/$(RTL_DIR)/$(T_NAME).v
	arachne-pnr -d 1k -p $(RTL_DIR)/$(T_NAME).pcf $(BUILD_DIR)/$(T_NAME).blif -o $(BUILD_DIR)/$(T_NAME).txt
	icepack $(BUILD_DIR)/$(T_NAME).txt $(BUILD_DIR)/$(T_NAME).bin

prog: sint
	iceprog $(BUILD_DIR)/$(T_NAME).bin

clean:
	rm -fdr ./$(SIM_DIR) *.vcd ./$(BUILD_DIR)

