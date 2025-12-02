# =================================================================
# MAKEFILE MASTER - PROJETO NASM
# Gerencia: Macros, Integração C+ASM, Filtro de Arquivos e Verificações
# =================================================================

# --- Ferramentas ---
NASM      = nasm
CC        = gcc
LD        = ld
CHECKER   = cppcheck

# --- Flags de Compilação e Linkagem ---
# NASM: 32 bits + Símbolos de debug (-g)
NASM_FLAGS = -f elf32 -g

# CFLAGS (Compilação C):
# -m32: Arquitetura 32 bits
# -Wall: Mostra todos os avisos
# -g: Informações de debug
# -no-pie: Desativa PIE (necessário para linkar com ASM estático)
# -fsanitize=address: Ativa o AddressSanitizer
CFLAGS     = -m32 -Wall -g -no-pie -fsanitize=address

# LDFLAGS (Linkagem C):
# -m32: Linkar em 32 bits
# -fsanitize=address: Necessário também no linker
LDFLAGS    = -m32 -fsanitize=address

# LD_RAW_FLAGS (Linkagem ASM Puro):
# Usado apenas na tarefa do Filtro
LD_RAW_FLAGS = -m elf_i386

# --- Diretórios ---
BUILD_DIR = build
SRC_MONT  = Montador
SRC_PRE   = Pre_Processador

# --- Nomes dos Executáveis e Saídas ---
EXEC_INTEGRA = $(BUILD_DIR)/integracao
EXEC_FILTRO  = $(BUILD_DIR)/filtro
OUT_MACROS   = $(BUILD_DIR)/macros_expandido.txt

# =================================================================
# REGRAS PRINCIPAIS
# =================================================================

# Target padrão: Compila tudo
all: dirs $(EXEC_INTEGRA) $(EXEC_FILTRO) $(OUT_MACROS) copiatxt
	@echo "=================================================="
	@echo "BUILD COMPLETO!"
	@echo "Executaveis gerados na pasta '$(BUILD_DIR)'"
	@echo "=================================================="

# Cria diretório de build
dirs:
	@mkdir -p $(BUILD_DIR)

# Copia o arquivo de entrada (Depende de dirs para garantir que a pasta exista)
copiatxt: | dirs
	@cp $(SRC_MONT)/entrada.txt $(BUILD_DIR)/entrada.txt 2>/dev/null || :

# =================================================================
# TAREFA 0: INSTALAÇÃO DE DEPENDÊNCIAS
# =================================================================

deps:
	@echo "--- Instalando dependencias (Requer SUDO) ---"
	sudo apt-get update
	sudo apt-get install -y libc6-dev-i386 nasm build-essential cppcheck

# =================================================================
# TAREFA 1: INTEGRAÇÃO C + NASM (main.c + lib.asm)
# =================================================================

# Linkagem usando GCC + Garantia de permissão
$(EXEC_INTEGRA): $(BUILD_DIR)/main.o $(BUILD_DIR)/lib.o
	$(CC) $(LDFLAGS) $^ -o $@


# Compilação do C (Garante que 'dirs' existe antes de compilar)
$(BUILD_DIR)/main.o: $(SRC_MONT)/main.c | dirs
	$(CC) $(CFLAGS) -c $< -o $@

# Montagem do Assembly da biblioteca
# CORREÇÃO: Adicionado '| dirs' para garantir que a pasta build exista
$(BUILD_DIR)/lib.o: $(SRC_MONT)/lib.asm | dirs
	$(NASM) $(NASM_FLAGS) $< -o $@

# =================================================================
# TAREFA 2: FILTRO DE ARQUIVOS (filtro.asm - ASM Puro)
# =================================================================

# Linkagem usando LD + Garantia de permissão
$(EXEC_FILTRO): $(BUILD_DIR)/filtro.o
	$(LD) $(LD_RAW_FLAGS) $< -o $@


# Montagem do Assembly do filtro
$(BUILD_DIR)/filtro.o: $(SRC_MONT)/filtro.asm | dirs
	$(NASM) $(NASM_FLAGS) $< -o $@

# =================================================================
# TAREFA 3: PRÉ-PROCESSADOR (macros_demo.asm)
# =================================================================

# Gera apenas a expansão de macros
$(OUT_MACROS): $(SRC_PRE)/macros_demo.asm | dirs
	@echo "Gerando expansao de macros..."
	$(NASM) -E $< > $@

# =================================================================
# FERRAMENTAS E EXECUÇÃO
# =================================================================

check:
	@echo "--- Rodando Cppcheck ---"
	$(CHECKER) --enable=all --suppress=missingIncludeSystem $(SRC_MONT)/main.c

test: $(EXEC_INTEGRA)
	@echo "--- Executando Integracao (Com Asan) ---"
	./$(EXEC_INTEGRA)

run-filtro: $(EXEC_FILTRO) copiatxt
	@echo "--- Executando Filtro ---"
	@cd $(BUILD_DIR) && ./filtro
	@echo "--- Conteudo gerado em saida.txt: ---"
	@cat $(BUILD_DIR)/saida.txt
	@echo ""

view-macros: $(OUT_MACROS)
	@echo "--- Visualizando Macros Expandidas ---"
	@cat $(OUT_MACROS)

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all dirs clean check test run-filtro view-macros copiatxt deps
