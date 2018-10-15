TARGET    := main
OUT_NAME  := test

SRC_DIR   := ./src
BUILD_DIR := ./build

CC		  := clang
CFLAGS	  := -std=c11 -Wall -Wextra
CFLAGS    += `pkg-config --cflags libftdi1`
LFLAGS	  := `pkg-config --libs libftdi1`

main: $(SRC_DIR)/main.c
	mkdir -p $(BUILD_DIR)
	$(CC) $(CFLAGS) $(LFLAGS) $^ -o $(BUILD_DIR)/$(OUT_NAME)

clean:
	rm -fdr $(BUILD_DIR)

all: main

run: all
	$(BUILD_DIR)/$(OUT_NAME)

.PHONY: main clean all run