# Makefile para projeto NASM + C
# Uso: `make` (gera o executável), `make run`, `make clean`
# Variáveis podem ser sobrescritas na linha de comando, por exemplo:
#  make NASM_FMT=win32 CFLAGS='-m32 -O2'

NASM = nasm
CC   = gcc
NASM_FMT ?= elf32
CFLAGS ?= -m32 -Wall -g
LDFLAGS ?= -m32

BUILD_DIR = build
SRC_C     = Montador/main.c
ASM_SRC   = Montador/lib.asm
OBJ_C     = $(BUILD_DIR)/main.o
OBJ_ASM   = $(BUILD_DIR)/lib.o
BIN       = montador_program

.PHONY: all dirs clean run help

all: $(BIN)

dirs:
	@mkdir -p $(BUILD_DIR)

$(OBJ_ASM): $(ASM_SRC) | dirs
	$(NASM) -f $(NASM_FMT) $< -o $@

$(OBJ_C): $(SRC_C) | dirs
	$(CC) $(CFLAGS) -c $< -o $@

$(BIN): $(OBJ_ASM) $(OBJ_C)
	$(CC) $(LDFLAGS) $^ -o $@

run: $(BIN)
	./$(BIN)

clean:
	rm -rf $(BUILD_DIR) $(BIN)

help:
	@echo "Targets: all (default), run, clean"
	@echo "Override variables: NASM_FMT, CFLAGS, LDFLAGS, CC, NASM"

