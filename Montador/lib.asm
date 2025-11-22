; =================================================================
; ARQUIVO: lib.asm
; OBJETIVO: Implementar funções Assembly chamadas pelo C:
;   - int somar(int a, int b)
;   - void asm_chamando_printf(int resultado)
; =================================================================

extern printf

global somar
global asm_chamando_printf

section .data
    msg_fmt db "    [ASM]: O resultado da soma é: %d", 10, 0

section .text

; =================================================================
; int somar(int a, int b)
; CDECL:
;   a = [ebp + 8]
;   b = [ebp + 12]
; Retorno em EAX
; =================================================================
somar:
    push ebp
    mov  ebp, esp

    mov eax, [ebp + 8]     ; eax = a
    mov edx, [ebp + 12]    ; edx = b (uso edx para não clobber ebx)
    add eax, edx           ; eax = a + b  (valor de retorno)

    mov esp, ebp
    pop ebp
    ret


; =================================================================
; void asm_chamando_printf(int resultado)
; CDECL:
;   resultado = [ebp + 8]
; Esta função chama printf("%d")
; =================================================================
asm_chamando_printf:
    push ebp
    mov  ebp, esp

    mov eax, [ebp + 8]     ; pega o inteiro enviado pelo C

    push eax               ; segundo argumento: o valor
    push msg_fmt           ; primeiro argumento: string de formato
    call printf
    add esp, 8             ; limpa a pilha

    mov esp, ebp
    pop ebp
    ret


; NÃO NECESSITA DE PILHA EXECUTÁVEL
section .note.GNU-stack noalloc noexec nowrite progbits 
