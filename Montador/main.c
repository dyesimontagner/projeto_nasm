/* ARQUIVO: main.c
   TAREFA: Montador NASM - Integração C e NASM
   OBJETIVO: Chamar uma função Assembly que usa stdio.h
*/

#include <stdio.h>

// 'extern': Avisa o C que essa função existe em outro arquivo (no .asm)
// 'void': Ela não retorna valor.
extern int somar(int a, int b);
extern void asm_chamando_printf(int resultado);

int main() {
    int x = 100;
    int y = 5;

    printf("[C] Somando %d + %d usando Assembly...\n", x, y);
    int resultado = somar(x, y);

    printf("[C] Chamando asm_chamando_printf(resultado)...\n");
    asm_chamando_printf(resultado);

    printf("[C] Terminei.\n");
    return 0;
}