; macros_demo.asm - macros multilinhas das aulas

; --------------- MACROS ----------------

%macro prologue 0
    push ebp
    mov  ebp, esp
%endmacro

%macro prologue_frame 1
    push ebp
    mov  ebp, esp
    sub  esp, %1
%endmacro

%macro epilogue 0
    mov  esp, ebp
    pop  ebp
    ret
%endmacro

%macro prologo 0
    push ebp
    mov  ebp, esp
    push ebx
    push esi
    push edi
%endmacro

%macro epilogo 0
    pop  edi
    pop  esi
    pop  ebx
    mov  esp, ebp
    pop  ebp
    ret
%endmacro

%macro silly 2
    %2: db %1
%endmacro

%macro retz 0
    jnz %%skip
    ret
%%skip:
%endmacro

; ATENÇÃO: estas macros usam int 0x21 (DOS), não vão rodar em Linux,
; mas servem para mostrar a EXPANSÃO das macros, que é o objetivo do exercício.

%macro writefile 2+
    jmp %%endstr
%%str: db %2
%%endstr:
    mov dx, %%str
    mov cx, %%endstr - %%str
    mov bx, %1
    mov ah, 0x40
    int 0x21
%endmacro

%macro die 0-1 "Painful program death has occurred."
    writefile 2, %1
    mov ax, 0x4C01
    int 0x21
%endmacro

%macro multipush 1-*
%rep %0
    push %1
    %rotate 1
%endrep
%endmacro

%macro multipop 1-*
%rep %0
    %rotate -1
    pop %1
%endrep
%endmacro

%macro keytab_entry 2
    keypos%1 equ $ - keytab
    db %2
%endmacro

; retcc exatamente como nos slides: usa o CC invertido (%-1)
%macro retcc 1
    j%-1 %%skip
    ret
%%skip:
%endmacro


; --------------- DADOS ----------------

section .data

silly 'A', letraA
silly 'Z', letraZ

keytab:
    keytab_entry F1,     129
    keytab_entry F2,     130
    keytab_entry Return, 13

filehandle dw 1


; --------------- CODIGO ----------------

section .text
global main

main:
    ; exemplo de prólogo completo com salvamento de registradores
    prologo

    mov eax, 20

    ; exemplo de chamada de função com frame na pilha
    call func_exemplo_frame

    ; exemplos de multipush / multipop
    mov ebx, 1
    mov ecx, 2
    mov edx, 3
    multipush eax, ebx, ecx, edx
    multipop  eax, ebx, ecx, edx

    ; exemplo de retz: retorna se eax != 20
    cmp eax, 20
    je .ok
    retz
.ok:

    ; exemplo de retcc: "retorna se zero"
    mov eax, 0
    cmp eax, 0
    retcc z

    ; --------------- Exemplos de writefile e die ---------------
    ; writefile: igual ao slide (handle 2, string, 13,10)
    writefile 2, "Exemplo da macro writefile", 13, 10

    ; die: chamada com UM parâmetro, como definido (0-1)
    die "Erro fatal via macro die"

    ; (na prática, depois de die o programa terminaria)
    epilogo


func_exemplo_frame:
    ; exemplo de prologue_frame + epilogue
    prologue_frame 16
    mov dword [ebp-4], 1234
    epilogue
