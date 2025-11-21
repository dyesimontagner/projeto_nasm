; =================================================================
; ARQUIVO: macros_demo.asm
; TAREFA: Pré-processador (Opção 4) - Macros Multilinhas
; =================================================================

; --- Definição de Macros ---

; Macro 1: Prologo
; Salva o ponteiro base (ebp) e cria um novo stack frame.
%macro prologo 0
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi
%endmacro

; Macro 2: Epilogo
; Restaura os registradores na ordem inversa e limpa o stack frame.
%macro epilogo 0
    pop edi
    pop esi
    pop ebx
    mov esp, ebp
    pop ebp
    ret
%endmacro

; Macro 3: Calculadora Simples (Dobrar valor)
; Recebe um registrador como parâmetro (%1) e multiplica por 2
%macro dobrar_valor 1
    shl %1, 1       ; Shift Left equivale a multiplicar por 2
%endmacro

; --- Código Principal ---
section .text
global main

main:
    ; 1. Chamando a macro 'prologo'
    ; O pré-processador vai substituir isso pelas instruções de push
    prologo

    ; 2. Lógica simples para teste
    mov eax, 10     ; Coloca 10 no acumulador
    
    ; 3. Chamando a macro com parâmetro
    dobrar_valor eax  ; O pré-processador vai gerar: shl eax, 1
                      ; Resultado: EAX vira 20

    ; 4. Chamando a macro 'epilogo'
    epilogo


