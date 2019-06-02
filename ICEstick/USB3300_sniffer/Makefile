M_NAME    := top
Y_NAME    := USB3300_sniffer
  
TB_DIR    := ./tb
RTL_DIR   := ./rtl
SIM_DIR   := ./sim
PRE_DIR   := ./
BUILD_DIR := ./build

FREQ_MIN  := 71

all: prog

# Simulation
sim: $(SIM_DIR)/$(M_NAME)_tb.out
	$^

$(SIM_DIR)/$(M_NAME)_tb.out: $(TB_DIR)/$(M_NAME)_tb.v $(RTL_DIR)/$(M_NAME).v
	mkdir -p $(SIM_DIR)/
	iverilog $(patsubst %, %, $^) -o $(SIM_DIR)/$(M_NAME)_tb.out -I ./modules_simulation -I ./modules

gtk: $(SIM_DIR)/$(M_NAME)_tb.vcd
	gtkwave $< $(M_NAME).gtkw &

$(SIM_DIR)/$(M_NAME)_tb.vcd: $(SIM_DIR)/$(M_NAME)_tb.out
	$<


# FPGA Logic synthesis & programming

$(BUILD_DIR)/$(M_NAME).blif: $(RTL_DIR)/$(M_NAME).v
	mkdir -p $(BUILD_DIR)/
	# -retime -abc2 /// -relut -noabc -noflatten -vpr
	yosys -p "synth_ice40 -top $(Y_NAME) -blif $(BUILD_DIR)/$(M_NAME).blif -json $(BUILD_DIR)/$(M_NAME).json -edif $(BUILD_DIR)/$(M_NAME).edif; \
			  write_verilog -attr2comment $(BUILD_DIR)/$(M_NAME)_yosys.v; \
			  write_table $(BUILD_DIR)/$(M_NAME)_table.csv;" \
		  $< -d -l $(BUILD_DIR)/yosys.log

$(BUILD_DIR)/$(M_NAME).json: $(BUILD_DIR)/$(M_NAME).blif

$(BUILD_DIR)/$(M_NAME).asc: $(BUILD_DIR)/$(M_NAME).blif $(RTL_DIR)/$(M_NAME).pcf
	# --freq $(FREQ_MIN) // --no-tmdriv // --tmfuzz
	nextpnr-ice40 --save $(BUILD_DIR)/$(M_NAME).proj \
				  --pcf  $(RTL_DIR)/$(M_NAME).pcf \
				  --asc  $(BUILD_DIR)/$(M_NAME).asc \
				  --json $(BUILD_DIR)/$(M_NAME).json \
				  --hx1k --package tq144 --freq $(FREQ_MIN)

$(BUILD_DIR)/$(M_NAME).bin: $(BUILD_DIR)/$(M_NAME).asc
	icepack $(BUILD_DIR)/$(M_NAME).asc $(BUILD_DIR)/$(M_NAME).bin

$(BUILD_DIR)/$(M_NAME)_yosys.v: synt

arachne: $(BUILD_DIR)/$(M_NAME).blif
	arachne-pnr -d 1k -P tq144 -p $(RTL_DIR)/$(M_NAME).pcf $(BUILD_DIR)/$(M_NAME).blif -o $(BUILD_DIR)/$(M_NAME).asc

synt: $(BUILD_DIR)/$(M_NAME).json

pnr:  $(BUILD_DIR)/$(M_NAME).asc

pack: $(BUILD_DIR)/$(M_NAME).bin

pnr_gui: $(BUILD_DIR)/$(M_NAME).json $(RTL_DIR)/$(M_NAME).pcf
	nextpnr-ice40 --json $(BUILD_DIR)/$(M_NAME).json \
				  --pcf $(RTL_DIR)/$(M_NAME).pcf \
				  --asc $(BUILD_DIR)/$(M_NAME).asc \
				  --hx1k --package tq144 --gui

prog: $(BUILD_DIR)/$(M_NAME).bin
	iceprog $(BUILD_DIR)/$(M_NAME).bin


# Analysis

timing: $(BUILD_DIR)/$(M_NAME).asc $(RTL_DIR)/$(M_NAME).pcf
	icetime -p $(RTL_DIR)/$(M_NAME).pcf   \
			-o $(BUILD_DIR)/timing_report \
			$(BUILD_DIR)/$(M_NAME).asc    \
			-t -d hx1k -P tq144 -c $(FREQ_MIN)

$(BUILD_DIR)/diagram.dot: $(RTL_DIR)/$(M_NAME).v
	mkdir -p $(BUILD_DIR)/
	yosys -q -p "synth_ice40 -top $(Y_NAME); show -stretch -prefix $(BUILD_DIR)/diagram -colors 13579 -format svg;" $^

plot: $(BUILD_DIR)/diagram.dot

dot_view: $(BUILD_DIR)/diagram.dot
	xdot $(BUILD_DIR)/diagram.dot

# 

clean:
	rm -fdr ./$(SIM_DIR) ./$(BUILD_DIR)

.PHONY: all sim gtk synt pnr pack pnr_gui prog timing plot clean dot_view