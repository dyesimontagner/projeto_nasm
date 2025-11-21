/* ARQUIVO: main.c
   TAREFA: Montador NASM (Opção 2) - Integração C e NASM
   OBJETIVO: Chamar uma função Assembly que usa stdio.h
*/

#include <stdio.h>

// 'extern': Avisa o C que essa função existe em outro arquivo (no .asm)
// 'void': Ela não retorna valor.
extern void asm_chamando_printf();

int main() {
    printf("[C]: Inicio do programa em C.\n");
    printf("[C]: Vou chamar a funcao escrita em Assembly agora...\n");
    printf("---------------------------------------------------\n");

    // Chamada da função Assembly
    asm_chamando_printf();

    printf("---------------------------------------------------\n");
    printf("[C]: A funcao Assembly retornou. Fim do programa.\n");
    return 0;
}