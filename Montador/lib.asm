; =================================================================
; ARQUIVO: lib.asm
; OBJETIVO: Definir a função que o C vai chamar e usar o printf.
; =================================================================

extern printf          
global asm_chamando_printf

section .data
    ; Mensagem para o printf
    msg db "    [ASM]: Ola! Eu sou o Assembly executando um printf!", 10, 0

section .text

asm_chamando_printf:
    ; --- Prologo ---
    push ebp
    mov ebp, esp

    ; --- Corpo ---
    push msg        ; Empilha o endereço da mensagem
    call printf     ; Chama o C
    add esp, 4      ; Limpa a pilha

    ; --- Epilogo ---
    mov esp, ebp
    pop ebp
    ret

; Essa linha abaixo avisa o Linux que não precisamos de pilha executável
section .note.GNU-stack noalloc noexec nowrite progbits