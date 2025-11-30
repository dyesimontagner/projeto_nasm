; =============================================================
; ARQUIVO: filtro.asm
; TAREFA: Montador 7 - Leitura, Filtro e Escrita (Syscalls)
; OBJETIVO: Lê 'entrada.txt', converte para MAIÚSCULO e salva em 'saida.txt'
; =============================================================

section .data
    ; Nomes dos arquivos (terminados em 0)
    arquivo_in  db "entrada.txt", 0
    arquivo_out db "saida.txt", 0
    
    ; Mensagens de erro/sucesso
    msg_sucesso db "Sucesso! Verifique o arquivo saida.txt", 10
    len_sucesso equ $ - msg_sucesso
    msg_erro    db "Erro ao abrir arquivos!", 10
    len_erro    equ $ - msg_erro

section .bss
    fd_in  resd 1       ; Guardar o ID (File Descriptor) do arquivo de entrada
    fd_out resd 1       ; Guardar o ID do arquivo de saída
    buffer resb 1024    ; Um buffer de 1KB para ler o arquivo em pedaços

section .text
    global _start       ; Ponto de entrada padrão para o Linker (ld)

_start:
    ; --- 1. ABRIR ARQUIVO DE ENTRADA (Syscall open) ---
    mov eax, 5          ; Syscall 5 = open
    mov ebx, arquivo_in ; Nome do arquivo
    mov ecx, 0          ; Modo 0 = Read Only (O_RDONLY)
    mov edx, 0777       ; Permissões (ignoradas na leitura, mas boa prática)
    int 0x80            ; Chama o Kernel
    
    cmp eax, 0          ; Se EAX < 0, deu erro
    jl erro_abertura
    mov [fd_in], eax    ; Salva o File Descriptor

    ; --- 2. CRIAR ARQUIVO DE SAÍDA (Syscall creat) ---
    mov eax, 8          ; Syscall 8 = creat (cria ou trunca arquivo)
    mov ebx, arquivo_out
    mov ecx, 0o644      ; Permissões (rw-r--r--)
    int 0x80
    
    cmp eax, 0
    jl erro_abertura
    mov [fd_out], eax   ; Salva o File Descriptor

loop_leitura:
    ; --- 3. LER DO ARQUIVO (Syscall read) ---
    mov eax, 3          ; Syscall 3 = read
    mov ebx, [fd_in]    ; De qual arquivo?
    mov ecx, buffer     ; Para onde vai os dados?
    mov edx, 1024       ; Quantos bytes tentar ler?
    int 0x80

    ; Verifica resultado da leitura
    cmp eax, 0
    je fim_processo     ; Se leu 0 bytes, chegou no fim do arquivo (EOF)
    jl erro_abertura    ; Se menor que 0, erro

    ; Salva quantos bytes lemos para usar na escrita depois
    push eax            ; Salva contagem na pilha

    ; --- 4. FILTRO: CONVERTER PARA MAIÚSCULO ---
    ; EAX contém o número de bytes lidos. Vamos usar ECX como ponteiro.
    mov ecx, eax        ; Contador do loop (bytes lidos)
    mov esi, buffer     ; Ponteiro para o início do buffer

processar_byte:
    mov al, [esi]       ; Pega o caractere atual
    
    ; Lógica: Se for entre 'a' (97) e 'z' (122), subtrai 32
    cmp al, 'a'
    jl proximo_char     ; Se menor que 'a', ignora
    cmp al, 'z'
    jg proximo_char     ; Se maior que 'z', ignora
    
    sub al, 32          ; Converte para maiúsculo (a->A)
    mov [esi], al       ; Devolve para o buffer

proximo_char:
    inc esi             ; Avança ponteiro
    loop processar_byte ; Decrementa ECX e repete se não for zero

    ; --- 5. ESCREVER NO ARQUIVO (Syscall write) ---
    pop edx             ; Recupera quantos bytes lemos (estava na pilha)
    mov eax, 4          ; Syscall 4 = write
    mov ebx, [fd_out]   ; Para qual arquivo?
    mov ecx, buffer     ; Onde estão os dados?
                        ; EDX já está configurado com o tamanho correto
    int 0x80

    jmp loop_leitura    ; Volta para ler o próximo bloco

fim_processo:
    ; --- 6. FECHAR ARQUIVOS (Syscall close) ---
    mov eax, 6
    mov ebx, [fd_in]
    int 0x80
    
    mov eax, 6
    mov ebx, [fd_out]
    int 0x80

    ; Imprimir mensagem de sucesso
    mov eax, 4
    mov ebx, 1          ; 1 = stdout (tela)
    mov ecx, msg_sucesso
    mov edx, len_sucesso
    int 0x80
    jmp sair

erro_abertura:
    ; Imprimir mensagem de erro
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_erro
    mov edx, len_erro
    int 0x80

sair:
    mov eax, 1          ; Syscall 1 = exit
    mov ebx, 0          ; Código de retorno 0
    int 0x80


