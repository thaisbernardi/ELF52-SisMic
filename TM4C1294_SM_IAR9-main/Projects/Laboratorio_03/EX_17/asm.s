        PUBLIC  __iar_program_start
        PUBLIC  __vector_table

        SECTION .text:CODE:REORDER(2)
        
        ;; Keep vector table even if it's not referenced
        REQUIRE __vector_table
        
        THUMB

SYSCTL_RCGCGPIO_R       EQU     0x400FE608
SYSCTL_PRGPIO_R		EQU     0x400FEA08
PORTN_F_BIT             EQU     1000000100000b ; bit 12 = Port F e N
PORTN_BIT               EQU     1000000000000b ; 

GPIO_PORTN_DATA_R    	EQU     0x40064000
GPIO_PORTN_DIR_R     	EQU     0x40064400
GPIO_PORTN_DEN_R     	EQU     0x4006451C

GPIO_PORTF_DATA_R    	EQU     0x4005D000
GPIO_PORTF_DIR_R     	EQU     0x4005D400
GPIO_PORTF_DEN_R     	EQU     0x4005D51C

        
//main    MOV R2, #PORTN_F_BIT
//	LDR R0, =SYSCTL_RCGCGPIO_R
//	LDR R1, [R0] ; leitura do estado anterior
//	ORR R1, R2 ; habilita port N
//	STR R1, [R0] ; escrita do novo estado
//
//      LDR R0, =SYSCTL_PRGPIO_R
//wait	LDR R2, [R0] ; leitura do estado atual
//	TEQ R1, R2 ; clock do port N habilitado?
//	BNE wait ; caso negativo, aguarda
//
//      MOV R2, #00000010b ; bit 0
//        
//	LDR R0, =GPIO_PORTN_DIR_R
//	LDR R1, [R0] ; leitura do estado anterior
//	ORR R1, R2 ; bit de saída
//	STR R1, [R0] ; escrita do novo estado
//
//	LDR R0, =GPIO_PORTN_DEN_R
//	LDR R1, [R0] ; leitura do estado anterior
//	ORR R1, R2 ; habilita função digital
//	STR R1, [R0] ; escrita do novo estado

//        MOV R1, #000000001b ; estado inicial
// 	LDR R0, = GPIO_PORTN_DATA_R
//loop	STR R1, [R0, R2, LSL #2] ; aciona LED com estado atual
//        MOVT R3, #0x000F ; constante de atraso 
//delay   CBZ R3, theend ; 1 clock
//        SUB R3, R3, #1 ; 1 clock
//        B delay ; 3 clocks
//theend  EOR R1, R1, R2 ; troca o estado
//        B loop

delay   MOVT R3, #0x000F ; constante de atraso 
        CBZ R3, ret ; 1 clock
        SUB R3, R3, #1 ; 1 clock
        B delay ; 3 clocks
ret     BX LR

inicia  MOV R2, #PORTN_F_BIT
	LDR R0, =SYSCTL_RCGCGPIO_R
	LDR R1, [R0] ; leitura do estado anterior
	ORR R1, R2 ; habilita port F e N
	STR R1, [R0] ; escrita do novo estado

        LDR R0, =SYSCTL_PRGPIO_R
wait	LDR R2, [R0] ; leitura do estado atual
	TEQ R1, R2 ; clock do port F e N habilitado?
	BNE wait ; caso negativo, aguarda

        BX LR
////        
conf    MOV R2, #00000001b ; bit 0 (D2) e 1 (D1) 
        LDR R0, =GPIO_PORTN_DIR_R
	LDR R1, [R0] ; leitura do estado anterior
	ORR R1, R2 ; bit de saída
	STR R1, [R0] ; escrita do novo estado

	LDR R0, =GPIO_PORTN_DEN_R
	LDR R1, [R0] ; leitura do estado anterior
	ORR R1, R2 ; habilita função digital
	STR R1, [R0] ; escrita do novo estado

        MOV R2, #00000001b ;
        LDR R0, =GPIO_PORTF_DIR_R
	LDR R1, [R0] ; leitura do estado anterior
	ORR R1, R2 ; bit de saída
	STR R1, [R0] ; escrita do novo estado

	LDR R0, =GPIO_PORTF_DEN_R
	LDR R1, [R0] ; leitura do estado anterior
	ORR R1, R2 ; habilita função digital
	STR R1, [R0] ; escrita do novo estado

        BX LR
auxN    LDR R0, = GPIO_PORTN_DATA_R
        STR R1, [R0, R2, LSL #2]
        BL delay
        EOR R1, R1, R2
        BX LR
//
auxF    LDR R4, = GPIO_PORTF_DATA_R
        STR R5, [R4, R6, LSL #2]
        BL delay
        EOR R5, R5, R6
        BX LR
//        
//contN   MOV R2, #00000001b ; LED 0 
//        MOV R1, R2
//        B auxN
//        MOV R2, #00000010b ; LED 1 
//        MOV R1, R2
//        B auxN
//        MOV R2, #00000011b ; LED 1 
//        MOV R1, R2
//        B auxN
//        BX LR
//        
//        
//cont    B contN
//        MOV R6, #00010000b ; LED 2 
//        MOV R5, R5
//        B auxF
//        MOV R6, #00000001b ; LED 3 
//        MOV R5, R5
//        B auxF
//        MOV R6, #00010001b ; LED 2 e 3 
//        MOV R5, R5
//        B auxF
//        BX LR        
//        

__iar_program_start

main    BL inicia
        BL conf
        ;BL auxN
loop    MOV R6, #00000001b
        MOV R5, #000000001b ; estado inicial
        BL auxF
        B loop

        ;; Forward declaration of sections.
        SECTION CSTACK:DATA:NOROOT(3)
        SECTION .intvec:CODE:NOROOT(2)
        
        DATA

__vector_table
        DCD     sfe(CSTACK)
        DCD     __iar_program_start

        DCD     NMI_Handler
        DCD     HardFault_Handler
        DCD     MemManage_Handler
        DCD     BusFault_Handler
        DCD     UsageFault_Handler
        DCD     0
        DCD     0
        DCD     0
        DCD     0
        DCD     SVC_Handler
        DCD     DebugMon_Handler
        DCD     0
        DCD     PendSV_Handler
        DCD     SysTick_Handler

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Default interrupt handlers.
;;

        PUBWEAK NMI_Handler
        PUBWEAK HardFault_Handler
        PUBWEAK MemManage_Handler
        PUBWEAK BusFault_Handler
        PUBWEAK UsageFault_Handler
        PUBWEAK SVC_Handler
        PUBWEAK DebugMon_Handler
        PUBWEAK PendSV_Handler
        PUBWEAK SysTick_Handler

        SECTION .text:CODE:REORDER:NOROOT(1)
        THUMB

NMI_Handler
HardFault_Handler
MemManage_Handler
BusFault_Handler
UsageFault_Handler
SVC_Handler
DebugMon_Handler
PendSV_Handler
SysTick_Handler
Default_Handler
__default_handler
        CALL_GRAPH_ROOT __default_handler, "interrupt"
        NOCALL __default_handler
        B __default_handler

        END
