# projeto_nasm

Este documento orienta a execução do projeto, descrevendo as tarefas escolhidas, como rodar o código usando o `Makefile` e os conceitos teóricos necessários para a apresentação.

---
## 0. Dependências obrigatórias

Instale tudo com:

```bash
sudo apt update
sudo apt install nasm gcc gcc-multilib make -y
```

### **nasm**

Montador utilizado para compilar os arquivos `.asm` no formato `elf32`.

### **gcc + gcc-multilib**

O código em C é compilado com `-m32`, então é obrigatório ter suporte a 32 bits.
Sem o `gcc-multilib`, surgem erros como:

* `crt1.o: No such file`
* `file in wrong format`
* incompatibilidade de bibliotecas 32 bits.

### **make**

Responsável por executar o `Makefile` que organiza toda a compilação do projeto.


## 1. Tarefas selecionadas

De acordo com a lista de exercícios, este projeto implementa as seguintes tarefas:

### Tarefa 4 – Pré-processador (Macros multilinhas)

> Construa um programa NASM que exemplifique o uso de todas as macros multilinhas vistas em sala de aula e as execute. Mostre como são expandidas.

Implementação em:
- Pasta: `Pre_Processador`
- Arquivo: `macros_demo.asm`

### Tarefa 2 – Montador NASM + C (Integração com biblioteca nativa)

> Construa um programa em C que chama um programa em NASM para exemplificar o uso de bibliotecas nativas do C (por exemplo, a stdio).

Implementação em:
- Pasta: `Montador`
- Arquivos: `main.c`, `lib.asm`

### Tarefa 7 – Filtro de arquivos em NASM

> Construa um programa em NASM para ler um arquivo, aplicar um filtro qualquer nele e gravar o arquivo resultante, usando os serviços do S.O.

Implementação em:
- Pasta: `Montador`
- Arquivo: `filtro.asm`  
- Arquivo de entrada esperado: `Montador/entrada.txt`  
- Arquivo de saída gerado: `build/saida.txt` (executando o filtro)

---

## 2. Preparação do ambiente

O projeto é todo em **32 bits**, tanto o C quanto o Assembly. Em distribuições 64 bits é preciso instalar as bibliotecas de compatibilidade.

No Ubuntu/WSL:

```bash
sudo apt update
sudo apt install nasm gcc gcc-multilib -y
```

Sem o `gcc-multilib`, os comandos com `-m32` falham (erros de headers e libs 32 bits).

---

## 3. Organização do projeto

Estrutura relevante:

```text
.
├── Makefile
├── Montador
│   ├── main.c
│   ├── lib.asm
│   ├── filtro.asm        (Tarefa 7)
│   └── entrada.txt       (arquivo de entrada do filtro)
└── Pre_Processador
    └── macros_demo.asm   (Tarefa 4)
```

A pasta `build/` é criada automaticamente pelo `Makefile` e guarda:

* Objetos compilados (`*.o`)
* Executáveis:

  * `build/integracao`   → Tarefa 2 (C + NASM)
  * `build/filtro`       → Tarefa 7 (NASM puro)
* Saídas auxiliares:

  * `build/macros_expandido.txt` → expansão das macros (Tarefa 4)
  * `build/entrada.txt` e `build/saida.txt` para o filtro

---

## 4. Como usar o Makefile

### Comando principal

```bash
make
```

O que ele faz:

* Cria `build/`
* Compila:

  * `Montador/main.c` → `build/main.o`
  * `Montador/lib.asm` → `build/lib.o`
* Linka a integração C+ASM → `build/integracao`
* Monta o filtro (Tarefa 7) → `build/filtro` (se `Montador/filtro.asm` existir)
* Gera a expansão das macros → `build/macros_expandido.txt`
* Copia `Montador/entrada.txt` → `build/entrada.txt` (usado pelo filtro)

### Outros alvos úteis

* **Rodar integração C+ASM (Tarefa 2):**

  ```bash
  make test
  ```

  Isso compila (se necessário) e executa `./build/integracao`
  com **AddressSanitizer** ativado (detecta acessos inválidos à memória).

* **Rodar o filtro de arquivos (Tarefa 7):**

  ```bash
  make run-filtro
  ```

  O Makefile:

  * Garante que `build/filtro` está compilado

  * Copia `Montador/entrada.txt` para `build/entrada.txt`

  * Entra na pasta `build/` e executa `./filtro`

  * Após a execução, mostra o conteúdo de `build/saida.txt` no terminal


* **Ver a expansão das macros (Tarefa 4):**

  ```bash
  make view-macros
  ```

  Isso garante que `build/macros_expandido.txt` foi gerado e imprime o conteúdo na tela.

  O arquivo é gerado internamente por:

  ```bash
  nasm -E Pre_Processador/macros_demo.asm > build/macros_expandido.txt
  ```

* **Limpar tudo (recompilar do zero depois):**

  ```bash
  make clean
  ```

  Remove a pasta `build/` inteira.

---

## 5. Detalhes por tarefa

### 5.1 Tarefa 4 — Pré-processador (Macros multilinhas)

**Arquivo:** `Pre_Processador/macros_demo.asm`
**Objetivo:** demonstrar o uso de **todas as macros multilinhas vistas em aula** e mostrar como o NASM as expande.

No arquivo de exemplo são usadas macros como:

* `prologo` / `epilogo`, `prologue_frame` / `epilogue`:
  encapsulam o padrão de criação/remoção de frame na pilha.
* `silly`: gera rótulos de dados (`letraA`, `letraZ`) a partir de parâmetros.
* `multipush` / `multipop`: usam `%rep` e `%rotate` para empilhar/desempilhar vários registradores com uma única chamada.
* `keytab_entry`: constrói uma tabela de teclas com `equ` e `db`.
* `retz` e `retcc`: macros de controle de fluxo que expandem para `jnz`, `jz` etc.
* `writefile` e `die`: exemplos de macros que usam serviços do DOS via `int 0x21` (aqui o foco é a **expansão**, não a execução real no Linux).

#### Como ver a expansão

Opção 1 — usando o Makefile:

```bash
make view-macros
```

Opção 2 — manualmente:

```bash
nasm -E Pre_Processador/macros_demo.asm > build/macros_expandido.txt
```

No arquivo gerado você verá:

* Linhas com `%line` (para mapear linhas originais);
* As instruções reais de assembly, **já com as macros substituídas por código concreto**.

Isso mostra que as macros foram tratadas na fase de pré-processamento.

---

### 5.2 Tarefa 2 — Integração C + NASM (stdio)

**Arquivos:**

* `Montador/main.c`
* `Montador/lib.asm`

**Ideia:**

* `main.c` é o ponto de entrada em C.
* Ele mostra mensagens na tela, chama uma função escrita em Assembly.
* A função em `lib.asm` usa **biblioteca padrão do C (`printf`)** para imprimir algo e retorna.

Fluxo típico:

1. `main` imprime algo como:

   ```c
   printf("[C]: Inicio do programa em C.\n");
   ```
2. Chama uma função `asm_chamando_printf()` definida em `lib.asm`.
3. O Assembly:

   * prepara os argumentos,
   * chama `printf` como uma função externa (`extern printf`),
   * retorna para o C.
4. `main` imprime uma mensagem final.

#### Como compilar e executar com o Makefile

```bash
make        # compila tudo
make test   # executa build/integracao
```

Internamente o Makefile faz:

* Compila C:

  ```bash
  gcc -m32 -Wall -g -no-pie -fsanitize=address -c Montador/main.c -o build/main.o
  ```
* Monta o Assembly:

  ```bash
  nasm -f elf32 -g Montador/lib.asm -o build/lib.o
  ```
* Linka ambos:

  ```bash
  gcc -m32 -fsanitize=address build/main.o build/lib.o -o build/integracao
  ```

Você também pode rodar manualmente:

```bash
./build/integracao
```

---

### 5.3 Tarefa 7 — Filtro de arquivos em NASM

**Arquivo:** `Montador/filtro.asm`
**Arquivos auxiliares:**

* Entrada: `Montador/entrada.txt`
* Saída: gerada em `build/saida.txt`

**Objetivo:**

* Ler um arquivo de texto.
* Aplicar um filtro qualquer (por exemplo: deixar só letras maiúsculas, remover vogais, substituir caracteres, etc.).
* Gravar o resultado em outro arquivo.
* Tudo isso usando serviços do sistema operacional (no nosso caso, Linux 32 bits).

Em termos de sistema:

* Entrada usada em runtime: `build/entrada.txt`
  (cópia automática de `Montador/entrada.txt` via `copiatxt` no Makefile)
* Saída (esperada): `build/saida.txt`

#### Como compilar e executar

Depois de implementar `filtro.asm`:

```bash
make run-filtro
```

O Makefile:

1. Monta `Montador/filtro.asm` → `build/filtro.o`
2. Linka com `ld -m elf_i386` → `build/filtro`
3. Copia `Montador/entrada.txt` → `build/entrada.txt`
4. Executa `./build/filtro`
5. Mostra na tela o conteúdo de `build/saida.txt`



---

## 6. Resumo

```bash
# Compilar tudo (integração, filtro, macros)
make

# Rodar integração C + ASM (Tarefa 2)
make test

# Rodar filtro de arquivos (Tarefa 7)
make run-filtro

# Ver a expansão das macros (Tarefa 4)
make view-macros

# Limpar build/
make clean
```

Com isso, o README fica alinhado ao `Makefile` e às três atividades (2, 4 e 7) que você mencionou.


