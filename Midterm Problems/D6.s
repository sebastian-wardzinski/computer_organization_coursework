.global _start

_start:	MOV R5, #N
		LDR R5, [R5]
        MOV R6, #MEMLOC
        CMP R5, #0
        BEQ END
        
        MOV R0, #0
        STR R0, [R6], #4
        SUBS R5, #1
        CMP R5, #0
        BEQ END
        
        MOV R1, #1
        STR R1, [R6], #4
        SUBS R5, #1
        CMP R5, #2
        BLE END
        
LOOP:	ADD R2, R1, R0
		STR R2, [R6], #4
        MOV R0, R1
        MOV R1, R2
        SUB R5, #1
        CMP R5, #0
        BEQ END
        B 	LOOP

END: 	B 	END

N: 		.word 50
MEMLOC: .word 
        
	
	