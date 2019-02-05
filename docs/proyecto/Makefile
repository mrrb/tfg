SRC_DIR   := memoria
BUILD_DIR := out

TEX_NAME := TFG

###
OUT_NAME := ./$(SRC_DIR)/$(BUILD_DIR)/$(TEX_NAME).pdf
TEX_MAIN := ./$(TEX_NAME).tex
###

all: $(OUT_NAME)

$(OUT_NAME):
	@cd $(SRC_DIR) && \
	mkdir -p $(BUILD_DIR) && \
	latexmk -pdf -time -synctex=1 -shell-escape -outdir=./$(BUILD_DIR) $(TEX_MAIN) 

view: $(OUT_NAME)
	@echo "Opening $(OUT_NAME)"
	@xdg-open $(OUT_NAME)

clean:
	rm -fdr ./$(SRC_DIR)/$(BUILD_DIR)

.PHOYNY: all clean view
