CC := clang
# CC := gcc

CFLAGS := -std=c17
CFLAGS += -Wall -Wextra -Wundef -std=gnu17
CFLAGS += `pkg-config --cflags jansson`

LFLAGS := -lm
LFLAGS += `pkg-config --libs jansson`
# LFLAGS += -lpthread

BUILD_DIR := ./build
SRC_DIR   := ./src

OUT_NAME := json2pcap.run

SRC_NAMES = json2pcap
SRC_MAIN  = main

###
SRC_ROUTE := $(addprefix $(SRC_DIR)/, $(SRC_NAMES) $(SRC_MAIN))
SRC_OBJTS := $(addsuffix .o, $(SRC_ROUTE))
###


all: build

run: build
	@$(BUILD_DIR)/$(OUT_NAME)


$(SRC_OBJTS): %.o: %.c
	@echo Building $@
	@$(CC) -c $(CFLAGS) $^ -o $@

$(BUILD_DIR)/$(OUT_NAME): $(SRC_OBJTS)
	@mkdir -p $(BUILD_DIR)
	@$(CC) $(CFLAGS) $(LFLAGS) $^ -o $@

build: $(BUILD_DIR)/$(OUT_NAME)


clean:
	rm -fdr $(BUILD_DIR)/
	rm -f $(SRC_DIR)/*.o

###

.PHONY: all build clean run
# .SILENT: