# ELF52-SisMic_Laboratorio_01
Laboratorio 01 para disciplina de Sistemas Microcontrolados

Os valores nos registradores com a execução do código foram: 

  R0: 0x0000 0055

  R1: 0x0055 0000 (após shift lógico de 16 bits para a esquerda)

  R2: 0x0000 5500 (após shift logico de 8 bits para a direita)

  R3: 0x0000 0550 (após shift aritmetico de 4 bits para a direita)

  R4: 0x0000 0154 (após rotação de 2 bits para a direita)

  R5: 0x0000 00aa (após rotação com extensão para a direita) 

Ou seja, o valor hexadecimal puro ou das operações foi diretamente armazenado no registrador. 

Na mesma janela de visualização dos registradores, é possivel visualizar individualmente os valores dos registradores xPSR, PC, SP, LR, PRIMASK, etc, bem como cada uma de suas flags. Nenhum valor negativo foi alcançado durante a execução. 
Na janela de disassembly, pode-se observar para cada condição a posição da memória em que ela está amrazenada, seu opcode, seu mnemônico, registradores utilizados e valores. O endereço visto é o endereço para qual o PC vai apontar quando a execução for a próxima a ser executada, nessa execução indo de 0x40 a 0x54. Pelo opcode, podemos observar se a operação é de 16 ou 32 bits, quando esse é composto por 1 ou 2 valores hexadecimais, respectivamente. Neste código, todos os opcodes são de 32 bits. 

Mudando os comandos MOV para MVN, as saídas são
R0: 0xffff ffaa

R1: 0x0055 ffff 

R2: 0xffff aa00 

R3: 0x0000 055f 

R4: 0x3fff fea8 

R5: 0xe000 00ab

O comando MVN faz uma operação lógica NOT bit a bit no valor, e o armazena no registrador Rd
O valor 0x0000 0055 ou (0000000000000000 0000000001010101b), ao ser invertido bit a bit gera um valor muito grande, por ter uma sequencia de 1s no inicio. Para manter o tamanho maximo do valor no registrador, os shifts nao se comportam da mesma forma que com os comandos de MOV.
