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
    prologo

    mov eax, 20

    call func_exemplo_frame

    mov ebx, 1
    mov ecx, 2
    mov edx, 3
    multipush eax, ebx, ecx, edx
    multipop  eax, ebx, ecx, edx

    cmp eax, 20
    je .ok
    retz
.ok:

    mov eax, 0
    cmp eax, 0
    retcc z

    epilogo


func_exemplo_frame:
    prologue_frame 16
    mov dword [ebp-4], 1234
    epilogue
