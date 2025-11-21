; =================================================================
; ARQUIVO: lib.asm
; OBJETIVO: Definir a função que o C vai chamar e usar o printf.
; =================================================================

; 1. Importar símbolos externos (funções do C)
extern printf

; 2. Exportar símbolos (para o C enxergar nossa função)
global asm_chamando_printf

section .data
    ; A mensagem que será impressa. 
    ; 10 = Quebra de linha (\n), 0 = Fim de string (null terminator)
    mensagem db "    [ASM]: Ola! Eu sou o Assembly executando um printf!", 10, 0

section .text

asm_chamando_printf:
    ; --- Prólogo (Padrão para funções 32 bits) ---
    push ebp        ; Salva o endereço base antigo
    mov ebp, esp    ; Atualiza o endereço base para o atual

    ; --- Corpo da Função ---
    ; Preparar argumento para o printf: empilhar o endereço da string
    push mensagem   
    
    ; Chamar a função da biblioteca C
    call printf
    
    ; Limpar a pilha (Convenção CDECL)
    ; Como empilhamos 1 item (4 bytes), somamos 4 ao ponteiro da pilha
    add esp, 4

    ; --- Epílogo ---
    mov esp, ebp    ; Restaura o topo da pilha
    pop ebp         ; Restaura o endereço base antigo
    ret             ; Retorna para o main.c