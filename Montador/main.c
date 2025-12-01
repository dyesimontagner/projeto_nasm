/* ARQUIVO: main.c
   TAREFA: Montador NASM - Integração C e NASM (Versão Melhorada)
   OBJETIVO: Interagir com usuário e chamar funções Assembly
*/

#include <stdio.h>
#include <stdlib.h> // p/ atoi()

// Declaração das funções Assembly
extern int somar(int a, int b);
extern void asm_chamando_printf(int resultado);

void limpar_buffer() {
    int c;
    while ((c = getchar()) != '\n' && c != EOF);
}

int main(int argc, char *argv[]) {
    int num1, num2;

    printf("=========================================\n");
    printf("  INTEGRACAO C <--> ASSEMBLY NASM\n");
    printf("=========================================\n");

    // Cenário 1: Usuário passou argumentos na linha de comando
    if (argc == 3) {
        printf("[C] Argumentos detectados via linha de comando.\n");
        num1 = atoi(argv[1]); // Converte string para int
        num2 = atoi(argv[2]);
    } 
    // Cenário 2: Modo Interativo
    else {
        printf("[C] Nenhum argumento passado. Modo interativo.\n");
        printf("[C] Digite o primeiro numero inteiro: ");
        while (scanf("%d", &num1) != 1) {
            printf("[C] Entrada invalida! Digite um numero: ");
            limpar_buffer();
        }

        printf("[C] Digite o segundo numero inteiro: ");
        while (scanf("%d", &num2) != 1) {
            printf("[C] Entrada invalida! Digite um numero: ");
            limpar_buffer();
        }
    }

    printf("-----------------------------------------\n");
    printf("[C] Enviando %d e %d para a funcao 'somar' em ASM...\n", num1, num2);
    
    // Chama a função Assembly
    int resultado = somar(num1, num2);

    // O retorno volta para o C, mas agora mandamos o ASM imprimir
    printf("[C] O Assembly retornou: %d. Agora o ASM vai imprimir:\n", resultado);
    printf("-----------------------------------------\n");
    
    // Chama Assembly que chama C de volta
    asm_chamando_printf(resultado);

    printf("-----------------------------------------\n");
    printf("[C] Execucao finalizada com sucesso.\n");
    
    return 0;
}