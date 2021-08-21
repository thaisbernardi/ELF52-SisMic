        PUBLIC  __iar_program_start
        EXTERN  __vector_table

        SECTION .text:CODE:REORDER(2)
        
        ;; Keep vector table even if it's not referenced
        REQUIRE __vector_table
        
        THUMB

; System Control definitions
SYSCTL_BASE             EQU     0x400FE000
SYSCTL_RCGCGPIO         EQU     0x0608
SYSCTL_PRGPIO		EQU     0x0A08
SYSCTL_RCGCUART         EQU     0x0618
SYSCTL_PRUART           EQU     0x0A18
; System Control bit definitions
PORTA_BIT               EQU     000000000000001b ; bit  0 = Port A
PORTF_BIT               EQU     000000000100000b ; bit  5 = Port F
PORTJ_BIT               EQU     000000100000000b ; bit  8 = Port J
PORTN_BIT               EQU     001000000000000b ; bit 12 = Port N
UART0_BIT               EQU     00000001b        ; bit  0 = UART 0

; NVIC definitions
NVIC_BASE               EQU     0xE000E000
NVIC_EN1                EQU     0x0104
VIC_DIS1                EQU     0x0184
NVIC_PEND1              EQU     0x0204
NVIC_UNPEND1            EQU     0x0284
NVIC_ACTIVE1            EQU     0x0304
NVIC_PRI12              EQU     0x0430

; GPIO Port definitions
GPIO_PORTA_BASE         EQU     0x40058000
GPIO_PORTF_BASE    	EQU     0x4005D000
GPIO_PORTJ_BASE    	EQU     0x40060000
GPIO_PORTN_BASE    	EQU     0x40064000
GPIO_DIR                EQU     0x0400
GPIO_IS                 EQU     0x0404
GPIO_IBE                EQU     0x0408
GPIO_IEV                EQU     0x040C
GPIO_IM                 EQU     0x0410
GPIO_RIS                EQU     0x0414
GPIO_MIS                EQU     0x0418
GPIO_ICR                EQU     0x041C
GPIO_AFSEL              EQU     0x0420
GPIO_PUR                EQU     0x0510
GPIO_DEN                EQU     0x051C
GPIO_PCTL               EQU     0x052C

; UART definitions
UART_PORT0_BASE         EQU     0x4000C000
UART_FR                 EQU     0x0018
UART_IBRD               EQU     0x0024
UART_FBRD               EQU     0x0028
UART_LCRH               EQU     0x002C
UART_CTL                EQU     0x0030
UART_CC                 EQU     0x0FC8
;UART bit definitions
TXFE_BIT                EQU     10000000b ; TX FIFO full
RXFF_BIT                EQU     01000000b ; RX FIFO empty
BUSY_BIT                EQU     00001000b ; Busy


; PROGRAMA PRINCIPAL

__iar_program_start
        
main:   MOV R2, #(UART0_BIT)
	BL UART_enable ; habilita clock ao port 0 de UART

        MOV R2, #(PORTA_BIT)
	BL GPIO_enable ; habilita clock ao port A de GPIO
        
	LDR R0, =GPIO_PORTA_BASE
        MOV R1, #00000011b ; bits 0 e 1 como especiais
        BL GPIO_special

	MOV R1, #0xFF ; máscara das funções especiais no port A (bits 1 e 0)
        MOV R2, #0x11  ; funções especiais RX e TX no port A (UART)
        BL GPIO_select

	LDR R0, =UART_PORT0_BASE
        BL UART_config ; configura periférico UART0
        
        ; recepção e envio de dados pela UART utilizando sondagem (polling)
        ; resulta em um "eco": dados recebidos são retransmitidos pela UART
start 
        BL reset
       
firstnum
        CMP R10, #4              ;R10 (numero de algorismos já recebidos)
        IT EQ
          BEQ read_operation       ;se ja leu 4 algorismos, le operacao
          
        BL UART_read             ;R1 contem o valor lido na iteração       
        BL check_input 
        MOV R6, R1
                
        CMP R7, #1              ;R7 "bool" se a entrada é valida ou nao (tb pode indicar a operação)
        ITTTT EQ                ;se for numero, ecoa, monta o registrador com o valor
          BLEQ UART_echo        ;ecoa o valor
          BLEQ create_value     ; r6 = r3*10+r1 // R10++
          MOVEQ R3, R6          ; r3 = r6
          BEQ firstnum
          
        CMP R7, #2              ;"case" R7 >= 2 é um operando, entao acabou a 1a entrada e ja tem operando, pode ler segundo valor
        ITTT HS
          MOVHS R4, R1          ;salva operacao
          BLHS UART_echo        ;ecoa operacao
          BLHS second_num       ;le segundo numero

        CMP R7, #0              ;entrada invalida, volta a ler
        IT EQ   
          BLEQ firstnum
          
read_operation

        BL UART_read             ;R1 contem o valor lido na iteração       
        BL check_input   
        
        CMP R7, #2              ;"case" R7 < 2 não é valor valido
        IT LO
          BLO read_operation      ;volta a ler
        
        CMP R7, #5              ;"case" R7 > 5 não é valor valido
        IT HI
          BHI read_operation      ;volta a ler
             
        MOV R4, R1              ;se passou as verificações, é operação valida, salva
        BL UART_echo            ;ecoa, e vai ler o 2o numero
        
second_num
      CMP R10, #4              ;R10 (numero de algorismos já recebidos)
        IT EQ
          BEQ read_equal               ;se ja leu 4 algorismos, resolve
          
        BL UART_read             ;R1 contem o valor lido na iteração       
        BL check_input  
        MOV R6, R1
                
        CMP R7, #1              ;R7 "bool" se a entrada é valida ou nao (tb pode indicar a operação)
        ITTT EQ                ;se for numero, ecoa, monta o registrador com o valor
          BLEQ UART_echo
          BLEQ create_value     ; r6 = r5*10+r1 // R10++
          MOVEQ R5, R6          ; r4 = r6

        CMP R7, #6              ;"case" R7 = 4 operando = entao pode resolver
        ITT EQ
          BLEQ UART_echo        ;ecoa operacao
          BLEQ solve            ;BRANCH RESOLVER

read_equal
        BL UART_read             ;R1 contem o valor lido na iteração       
        BL check_input   
        
        CMP R7, #6              ;"case" R7 != 4 nao é operador =
        IT NE
          BNE read_operation      ;volta a ler

solve   
        CMP R4, #2
        IT EQ
          ADDEQ R1, R3, R5
          
        CMP R4, #3
        IT EQ
          SUBEQ R1, R3, R5
          
        CMP R4, #4
        IT EQ
          MULEQ R1, R3, R5
          
        CMP R4, #5
        IT EQ
          UDIVEQ R1, R3, R5
       
       
        BL return_number ;
          
        B start


; SUB-ROTINAS
return_number
        ADD R1, R1, #0  ;"pass"
        BX LR


;r3, r6, r9 cria_valor_com_3_algarismos(r1, r6)
create_value
        PUSH {R7, R8}
        
        MOV R8, #0x30
        SUB R1, R1, R8
        
        MOV R7, #10
        MUL R6, R6, R7
        
        ADD R6, R6, R1
        
        ADD R10, R10, #1          ;R9 numero de algorismos recebidos
        
        POP {R7, R8}
        BX LR

;----------
;r7 valida_se_num_valido(r1)
check_input
        MOV R7, #1
        
        CMP R1, #0x30
        IT LO
          MOVLO R7, #0 ;false

        CMP R1, #0x39
        IT HI
          MOVHI R7, #0 ;false

        CMP R1, #0x2B   ;+
        IT EQ
          MOVEQ R7, #2 ;false

        CMP R1, #0x2D   ;-
        IT EQ
          MOVEQ R7, #3 ;operation

        CMP R1, #0x2A   ;*
        IT EQ
          MOVEQ R7, #4 ;false

        CMP R1, #0x2F   ;/
        IT EQ
          MOVEQ R7, #5 ;operation
          
        CMP R1, #0x3D   ;=
        IT EQ
          MOVEQ R7, #6 ;operation
  
        BX LR

;-------------------
;ecoa_valor_na_uart(r0, r1)
UART_echo 
           
tx_loop      ;loop para terminar o envio atual
       LDR R4, [R0, #UART_FR] ; status da UART
       TST R4, #TXFE_BIT ; transmissor vazio?
       BEQ tx_loop
       
       STR R1, [R0]
            
       BX LR

;-----
;reseta regs
reset
        MOV R1, #0
        MOV R2, #0
        MOV R3, #0
        MOV R4, #0
        MOV R5, #0
        MOV R6, #0
        MOV R10, #0
        MOV R11, #0
        BX LR
      
;-------
; r1 le_da_serial(r0)
UART_read
        LDR R2, [R0, #UART_FR]                          ; status da UART
        TST R2, #RXFF_BIT                               ; Verifica se o receptor 
        BEQ UART_read
        
        LDR R1, [R0]                                    ; Le a resial e joga em R1
        
        BX LR
  

; UART_enable: habilita clock para as UARTs selecionadas em R2
; R2 = padrão de bits de habilitação das UARTs
; Destrói: R0 e R1
UART_enable:
        LDR R0, =SYSCTL_BASE
	LDR R1, [R0, #SYSCTL_RCGCUART]
	ORR R1, R2 ; habilita UARTs selecionados
	STR R1, [R0, #SYSCTL_RCGCUART]

waitu	LDR R1, [R0, #SYSCTL_PRUART]
	TEQ R1, R2 ; clock das UARTs habilitados?
	BNE waitu

        BX LR
        
; UART_config: configura a UART desejada
; R0 = endereço base da UART desejada
; Destrói: R1
UART_config:
        LDR R1, [R0, #UART_CTL]
        BIC R1, #0x01 ; desabilita UART (bit UARTEN = 0)
        STR R1, [R0, #UART_CTL]

        ; clock = 16MHz, baud rate = 300 bps
        MOV R1, #3333
        STR R1, [R0, #UART_IBRD]
        MOV R1, #22
        STR R1, [R0, #UART_FBRD]
        
        ; 8 bits, 2 stop, even parity, FIFOs disabled, no interrupts
        MOV R1, #0x6E ;01101110b 
        STR R1, [R0, #UART_LCRH]
        
        ; clock source = system clock
        MOV R1, #0x00
        STR R1, [R0, #UART_CC]
        
        LDR R1, [R0, #UART_CTL]
        ORR R1, #0x01 ; habilita UART (bit UARTEN = 1)
        STR R1, [R0, #UART_CTL]

        BX LR


; GPIO_special: habilita funcões especiais no port de GPIO desejado
; R0 = endereço base do port desejado
; R1 = padrão de bits (1) a serem habilitados como funções especiais
; Destrói: R2
GPIO_special:
	LDR R2, [R0, #GPIO_AFSEL]
	ORR R2, R1 ; configura bits especiais
	STR R2, [R0, #GPIO_AFSEL]

	LDR R2, [R0, #GPIO_DEN]
	ORR R2, R1 ; habilita função digital
	STR R2, [R0, #GPIO_DEN]

        BX LR

; GPIO_select: seleciona funcões especiais no port de GPIO desejado
; R0 = endereço base do port desejado
; R1 = máscara de bits a serem alterados
; R2 = padrão de bits (1) a serem selecionados como funções especiais
; Destrói: R3
GPIO_select:
	LDR R3, [R0, #GPIO_PCTL]
        BIC R3, R1
	ORR R3, R2 ; seleciona bits especiais
	STR R3, [R0, #GPIO_PCTL]

        BX LR
;----------

; GPIO_enable: habilita clock para os ports de GPIO selecionados em R2
; R2 = padrão de bits de habilitação dos ports
; Destrói: R0 e R1
GPIO_enable:
        LDR R0, =SYSCTL_BASE
	LDR R1, [R0, #SYSCTL_RCGCGPIO]
	ORR R1, R2 ; habilita ports selecionados
	STR R1, [R0, #SYSCTL_RCGCGPIO]

waitg	LDR R1, [R0, #SYSCTL_PRGPIO]
	TEQ R1, R2 ; clock dos ports habilitados?
	BNE waitg

        BX LR

        SECTION .rodata:CONST(2)
        DATA
   
REPLY                   DC8     "Sistemas Microcontrolados\r\n" 
    
CR                      DC8     "\r"     ;\r  0x0d
LF                      DC8     "\n"     ;\n  0x    
MAIS                    DC8     "+"     ;+ (43d) #0x2B
MENOS                   DC8     "-"    ;- (45d) #0x2D 
MULT                    DC8     "*"    ;* (42d) #0x2A
DIV                     DC8     "/"     ;/ (47d)   #0x2F
IG			DC8	"="	  ;= (61d)   
    
        
        END