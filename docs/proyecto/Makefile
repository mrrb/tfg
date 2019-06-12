SRC_DIR   := memoria
BUILD_DIR := out
FIG_DIR   := fig

TEX_NAME := TFG
DOT_FOLDERS := maquinas_estados

###
OUT_NAME := ./$(SRC_DIR)/$(BUILD_DIR)/$(TEX_NAME).pdf
TEX_MAIN := ./$(TEX_NAME).tex

DOT_FOLDERS := $(addprefix $(SRC_DIR)/$(FIG_DIR)/, $(DOT_FOLDERS))
###

all: pdf

$(OUT_NAME):
	@cd $(SRC_DIR) && \
	mkdir -p $(BUILD_DIR) && \
	latexmk -bibtex -lualatex -time -synctex=1 -outdir=./$(BUILD_DIR) -shell-escape $(TEX_MAIN)

preview: dot_eps
	@cd $(SRC_DIR) && \
	mkdir -p $(BUILD_DIR) && \
	latexmk -bibtex -pvc -view=pdf -lualatex -time -synctex=1 -outdir=./$(BUILD_DIR) -shell-escape $(TEX_MAIN)
	# latexmk -pdf -pvc -view=pdf -f -new-viewer -time -synctex=1 -outdir=./$(BUILD_DIR) -shell-escape $(TEX_MAIN)

pdf: $(OUT_NAME)

dot_eps:
	$(foreach i, $(DOT_FOLDERS), \
		$(foreach j, $(shell find ./$(i)/ -name '*.dot'), \
			dot $(j) -Teps -o $(basename $(j)).eps; \
		) \
	)

view: $(OUT_NAME)
	@echo "Opening $(OUT_NAME)"
	@xdg-open $(OUT_NAME)

clean:
	rm -fdr ./$(SRC_DIR)/$(BUILD_DIR)

.PHOYNY: all clean view preview dot_eps pdf