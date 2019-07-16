.text
.global _start

_start:	  	MOV 	R9, #HEX_ADDRESS
			LDR		R9, [R9]
            MOV		R10, #KEY_ADDRESS
            LDR		R10, [R10]
            
WAITLOOP:	LDR     R3, [R10]
			CMP 	R3, #0x1
 			BEQ     KEY0
            CMP 	R3, #0x2
            BEQ    	KEY1
            CMP 	R3, #0x4
            BEQ 	KEY2
            CMP 	R3, #0x8
            BEQ 	KEY3
            B 		WAITLOOP
            
WAIT3: 		LDR 	R3, [R10] 
			CMP 	R3, #0
            BNE		KEY0
            B 		WAIT3
        	
KEY0:		LDR     R3, [R10]
			CMP 	R3, #0
			BNE 	KEY0
            B		KEY0rel

KEY0rel:	MOV 	R0, #0
			BL 		SEG7_CODE
            STR 	R2, [R9]
            MOV		PC, #WAITLOOP
            
KEY1:		LDR     R3, [R10]
			CMP 	R3, #0
			BNE 	KEY1
            B		KEY1rel

KEY1rel:	CMP 	R0, #9
			ADDNE 	R0, #1
            MOVEQ	R0, #0
			BL      SEG7_CODE
            STR 	R2, [R9]
            MOV		PC, #WAITLOOP

KEY2:		LDR     R3, [R10]
			CMP 	R3, #0
			BNE 	KEY2
            B		KEY2rel

KEY2rel:	CMP 	R0, #0
			SUBNE 	R0, #1
            MOVEQ	R0, #9
			BL      SEG7_CODE
            STR 	R2, [R9]
            MOV		PC, #WAITLOOP

KEY3:		LDR     R3, [R10]
			CMP 	R3, #0
			BNE 	KEY3
            B		KEY3rel

KEY3rel:	MOV 	R0, #0
            STR 	R0, [R9]
            MOV		PC, #WAIT3

SEG7_CODE:  MOV     R1, #BIT_CODES  
            ADD     R1, R0         // index into the BIT_CODES "array"
            LDRB    R2, [R1]       // load the bit pattern (to be returned)
            MOV     PC, LR     

HEX_ADDRESS:	.word 0xFF200020
KEY_ADDRESS:  	.word 0xFF200050
        
BIT_CODES:  .byte   0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
            .byte   0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
            .skip   2      // pad with 2 bytes to maintain word alignment