FNAME := top

TB_DIR    := ./tb
RTL_DIR   := ./rtl
SIM_DIR   := ./sim
BUILD_DIR := ./build

all: sim sint

sim: $(SIM_DIR)/$(FNAME)_tb.out
	$^

$(SIM_DIR)/$(FNAME)_tb.out: $(TB_DIR)/$(FNAME)_tb.v $(RTL_DIR)/$(FNAME).v
	mkdir -p $(SIM_DIR)/
	iverilog $^ -o $(SIM_DIR)/$(FNAME)_tb.out

gtk: $(SIM_DIR)/$(FNAME)_tb.vcd
	gtkwave $< &

$(SIM_DIR)/$(FNAME)_tb.vcd: $(SIM_DIR)/$(FNAME)_tb.out
	$<

sint: $(BUILD_DIR)/$(FNAME).bin

$(BUILD_DIR)/$(FNAME).bin: $(RTL_DIR)/$(FNAME).v $(RTL_DIR)/$(FNAME).pcf
	mkdir -p $(BUILD_DIR)/
	yosys -p "synth_ice40 -blif $(BUILD_DIR)/$(FNAME).blif" $<
	arachne-pnr -d 1k -p $(RTL_DIR)/$(FNAME).pcf $(BUILD_DIR)/$(FNAME).blif -o $(BUILD_DIR)/$(FNAME).txt
	icepack $(BUILD_DIR)/$(FNAME).txt $(BUILD_DIR)/$(FNAME).bin

prog: sint
	iceprog $(BUILD_DIR)/$(FNAME).bin

clean:
	rm -fdr ./$(SIM_DIR) *.vcd ./$(BUILD_DIR)
