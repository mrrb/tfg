M_NAME    := top
Y_NAME	  := USB3300_sniffer
  
TB_DIR    := ./tb
RTL_DIR   := ./rtl
SIM_DIR   := ./sim
PRE_DIR   := ./
BUILD_DIR := ./build

all: sim sint

sim: $(SIM_DIR)/$(M_NAME)_tb.out
	$^

$(SIM_DIR)/$(M_NAME)_tb.out: $(TB_DIR)/$(M_NAME)_tb.v $(RTL_DIR)/$(M_NAME).v
	mkdir -p $(SIM_DIR)/
	iverilog $(patsubst %, %, $^) -o $(SIM_DIR)/$(M_NAME)_tb.out -I ./modules_simulation -I ./modules

gtk: $(SIM_DIR)/$(M_NAME)_tb.vcd
	gtkwave $< $(M_NAME).gtkw &

$(SIM_DIR)/$(M_NAME)_tb.vcd: $(SIM_DIR)/$(M_NAME)_tb.out
	$<

sint: $(BUILD_DIR)/$(M_NAME).bin

$(BUILD_DIR)/$(M_NAME).bin: $(RTL_DIR)/$(M_NAME).v $(RTL_DIR)/$(M_NAME).pcf
	mkdir -p $(BUILD_DIR)/
	# -retime -abc2
	yosys -p "synth_ice40 -top $(Y_NAME) -blif $(BUILD_DIR)/$(M_NAME).blif -json $(BUILD_DIR)/$(M_NAME).json -retime; \
			  write_verilog $(BUILD_DIR)/$(M_NAME)_yosys.v; \
			  write_table $(BUILD_DIR)/$(M_NAME)_table.csv;" \
		  $< -d -l $(BUILD_DIR)/yosys.log
	# --freq 100.5
	nextpnr-ice40 --save $(BUILD_DIR)/$(M_NAME).proj \
				  --json $(BUILD_DIR)/$(M_NAME).json \
				  --pcf  $(RTL_DIR)/$(M_NAME).pcf \
				  --asc  $(BUILD_DIR)/$(M_NAME).asc \
				  --hx1k --package tq144
	# arachne-pnr -d 1k -P tq144 -p $(RTL_DIR)/$(M_NAME).pcf $(BUILD_DIR)/$(M_NAME).blif -o $(BUILD_DIR)/$(M_NAME).asc
	icepack $(BUILD_DIR)/$(M_NAME).asc $(BUILD_DIR)/$(M_NAME).bin

plot: $(RTL_DIR)/$(M_NAME).v
	mkdir -p $(BUILD_DIR)/
	yosys -q -p "show -stretch -prefix $(BUILD_DIR)/diagram -colors 1133557799 -format dot;" $^

gui: sint
	nextpnr-ice40 --json $(BUILD_DIR)/$(M_NAME).json \
				  --pcf $(RTL_DIR)/$(M_NAME).pcf \
				  --asc $(BUILD_DIR)/$(M_NAME).asc \
				  --hx1k --package tq144 --gui

prog: sint
	iceprog $(BUILD_DIR)/$(M_NAME).bin

timing: sint
	icetime -t -d hx1k -p $(RTL_DIR)/top.pcf -P tq144 -c 100.5 \
			-o $(BUILD_DIR)/timing_report \
			$(BUILD_DIR)/$(M_NAME).asc

clean:
	rm -fdr ./$(SIM_DIR) ./$(BUILD_DIR)

.PHONY: all sim gtk clean sint prog timing plot gui