.text
.global _start

HEX_ADDRESS:	.word 0xFF200020
EDGECAPTURE:  	.word 0xFF20005C

_start:		LDR R9, HEX_ADDRESS
			LDR R10, EDGECAPTURE
            MOV R5, #0xf
            STR R5, [R10]
            MOV R5, #0
            
HEX:		BL 	DO_DELAY
			ADD R5, #1
            CMP R5, #0x64
            MOVEQ R5, #0
            MOV R0, R5
            
            BL DIVIDE		//r0 ones digit, r1 tens digit
            MOV R6, R0
            MOV R7, R1
            
            MOV R0, R6
            BL SEG7_CODE	//r0 input/ouput, r1 changed
            MOV R6, R0  
            MOV R0, R7
            BL SEG7_CODE
            LSL R0, #8
            ORR R6, R0
            STR R6, [R9]
            
            MOV R8, #0
            LDRB R8, [R10]
            CMP R8, #0x0
            MOVNE R8, #0xf
            STRNE R8, [R10]
            BNE COUNT_OFF
            B 	HEX

DO_DELAY:	LDR R0, =80000000
SUB_LOOP:	SUBS R0, R0, #1
			BNE SUB_LOOP
            MOV PC, LR
            
COUNT_OFF:	LDRB R8, [R10]
			CMP R8, #0x0
            MOVNE R8, #0xf
            STRNE R8, [R10]
            BNE HEX
            B	COUNT_OFF
            
DIVIDE: 	MOV R1, #0		
CONT: 		CMP R0, #10			
            MOVLT PC, LR 
            SUB R0, #10
            ADD R1, #1
			B CONT	
            
SEG7_CODE:  MOV     R1, #BIT_CODES  
            ADD     R1, R0         // index into the BIT_CODES "array"
            LDRB    R0, [R1]       // load the bit pattern (to be returned)
            MOV     PC, LR     
            
BIT_CODES:  .byte   0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
            .byte   0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
            .skip   2
            
 