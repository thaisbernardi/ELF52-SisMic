        PUBLIC  __iar_program_start
        PUBLIC  __vector_table

        SECTION .text:CODE:REORDER(1)
        
        ;; Keep vector table even if it's not referenced
        REQUIRE __vector_table
        
        THUMB
        
__iar_program_start

main    MOV R0, #6
        MOV R1, #2
        BL Mul16b               ; Exercicio 10
        BL Fat32b               ; Exercicio 11
        B Stop

Mul16b:                         ; Exercicio 10
        PUSH {R1, R3, R4}       ;salva os valores originais
loop_m
        CMP R1, #0              ; nao executa se for multiplicar por 0
        BEQ end                 ; se R1 for zero 
        LSRS R1, R1, #1         ; logical shift right divide R1 por 2^1 
        ITT CS                  ; verificação de C = 1
          LSLCS R4, R0, R3      ; Logical shift left (multiplicação de r0 por 2^R3)
          ADDCS R2, R2, R4      ; adiciona R4 em R2 
        ADD R3, R3, #1          ; valor do expoente aumenta em 1 pra proxima iteração
        B loop_m
end
        POP {R1, R3, R4}        ;restaura valores originais
        BX LR
        
        
Fat32b:                         ; Exercicio 11
        PUSH {R1, R2}
        MOV R2, R0
        MOV R1, #0
        
loop_f 
        CMP R0, #1                ; verifica R0, se 1, retorna
        IT EQ                  
          BEQ return
        SUB R1, R2, #1            ; coloca r0 - 1 em r1
        MULS R0, R1               ; faz uma das multiplicações do fatorial

        ITT VS                    ; caso ultrapasse o limite de bits
          MOVVS R0, #-1           ; a função retorna -1 
          BVS return
        
        SUB R2, R2, #1                  
        CMP R1, #2
        IT EQ
          BEQ return 
        
        B loop_f
      
return 
        POP {R1, R2}
        BX LR
     

Stop    B Stop
        
        
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
