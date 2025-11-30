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
# -no-pie: Desativa Position Independent Executable (necessário para linkar com ASM estático)
# -fsanitize=address: Ativa o AddressSanitizer para detectar vazamentos/corrupção
CFLAGS     = -m32 -Wall -g -no-pie -fsanitize=address

# LDFLAGS (Linkagem C):
# -m32: Linkar em 32 bits
# -fsanitize=address: Necessário também no linker para o ASan funcionar
LDFLAGS    = -m32 -fsanitize=address

# LD_RAW_FLAGS (Linkagem ASM Puro):
# Usado apenas na tarefa do Filtro (que usa _start e syscalls diretas)
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

# Target padrão: Compila tudo e prepara o ambiente
all: dirs $(EXEC_INTEGRA) $(EXEC_FILTRO) $(OUT_MACROS) copiatxt
	@echo "=================================================="
	@echo "BUILD COMPLETO!"
	@echo "Executaveis gerados na pasta '$(BUILD_DIR)'"
	@echo "=================================================="

# Cria diretório de build
dirs:
	@mkdir -p $(BUILD_DIR)

# Copia o arquivo de entrada para a pasta build (para o filtro funcionar)
copiatxt:
	@cp $(SRC_MONT)/entrada.txt $(BUILD_DIR)/entrada.txt 2>/dev/null || :

# =================================================================
# TAREFA 1: INTEGRAÇÃO C + NASM (main.c + lib.asm)
# =================================================================

# Linkagem usando GCC (necessário para C e ASan)
$(EXEC_INTEGRA): $(BUILD_DIR)/main.o $(BUILD_DIR)/lib.o
	$(CC) $(LDFLAGS) $^ -o $@

# Compilação do C
$(BUILD_DIR)/main.o: $(SRC_MONT)/main.c
	$(CC) $(CFLAGS) -c $< -o $@

# Montagem do Assembly da biblioteca
$(BUILD_DIR)/lib.o: $(SRC_MONT)/lib.asm
	$(NASM) $(NASM_FLAGS) $< -o $@

# =================================================================
# TAREFA 2: FILTRO DE ARQUIVOS (filtro.asm - ASM Puro)
# =================================================================

# Linkagem usando LD (pois usa _start e syscalls, sem C runtime)
$(EXEC_FILTRO): $(BUILD_DIR)/filtro.o
	$(LD) $(LD_RAW_FLAGS) $< -o $@

# Montagem do Assembly do filtro
$(BUILD_DIR)/filtro.o: $(SRC_MONT)/filtro.asm
	$(NASM) $(NASM_FLAGS) $< -o $@

# =================================================================
# TAREFA 3: PRÉ-PROCESSADOR (macros_demo.asm)
# =================================================================

# Gera apenas a expansão de macros (-E)
$(OUT_MACROS): $(SRC_PRE)/macros_demo.asm
	@echo "Gerando expansao de macros..."
	$(NASM) -E $< > $@

# =================================================================
# FERRAMENTAS E EXECUÇÃO
# =================================================================

# Roda análise estática no código C
check:
	@echo "--- Rodando Cppcheck ---"
	$(CHECKER) --enable=all --suppress=missingIncludeSystem $(SRC_MONT)/main.c

# Roda o teste de Integração (ASan ativo detectará erros aqui)
test: $(EXEC_INTEGRA)
	@echo "--- Executando Integracao (Com Asan) ---"
	./$(EXEC_INTEGRA)

# Roda o Filtro de Arquivos
run-filtro: $(EXEC_FILTRO) copiatxt
	@echo "--- Executando Filtro ---"
	@cd $(BUILD_DIR) && ./filtro
	@echo "--- Conteudo gerado em saida.txt: ---"
	@cat $(BUILD_DIR)/saida.txt
	@echo ""

# Visualiza as macros expandidas
view-macros: $(OUT_MACROS)
	@echo "--- Visualizando Macros Expandidas ---"
	@cat $(OUT_MACROS)

# Limpa os arquivos gerados
clean:
	rm -rf $(BUILD_DIR)

# Declara que estes targets não são arquivos
.PHONY: all dirs clean check test run-filtro view-macros copiatxt