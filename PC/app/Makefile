CC := clang
# CC := gcc

CFLAGS := -std=c17
CFLAGS += -Wall -Wextra -Wundef -std=gnu17
CFLAGS += `pkg-config --cflags libserialport jansson`

LFLAGS := -lm
LFLAGS += `pkg-config --libs libserialport jansson`
LFLAGS += -lpthread

BUILD_DIR := ./build
SRC_DIR   := ./src

MAIN_OUT_NAME := FPGA-usb-capture
TEST_OUT_NAME := test.run

SRC_NAMES     = serial_ctrl menu thread_functions
MAIN_SRC_NAME = main
TEST_SRC_NAME = test

D_TEST := 0


###
ifeq ($(D_TEST), 0)
	OUT_NAME := $(MAIN_OUT_NAME)
	SRC_MAIN := $(MAIN_SRC_NAME)
else ifeq ($(D_TEST), 1)
	OUT_NAME := $(TEST_OUT_NAME)
	SRC_MAIN := $(TEST_SRC_NAME)
else
	OUT_NAME := $(MAIN_OUT_NAME)
	SRC_MAIN := $(MAIN_SRC_NAME)
endif
###

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

install: build
	cp ./build/$(OUT_NAME) /usr/bin/$(OUT_NAME)

uninstall:
	rm -f /usr/bin/$(OUT_NAME)

clean:
	rm -fdr $(BUILD_DIR)/
	rm -f $(SRC_DIR)/*.o

###

.PHONY: all build clean run install uninstall
# .SILENT: