.global _start

_start: MOV R12, #4
		MOV R9, #SUM
		MOV R6, #N
		LDR R6, [R6]
        MOV R7, #J
        LDR R7, [R7]
        MOV R3, #1
SUB1: 	MOV R5, #LIST
        MUL R2, R12, R3
        MLA R4, R12, R7, R12
        ADD R5, R2
        MOV R1, #0
        MOV R8, #0
LOOP: 	LDR R0, [R5]
		ADD R1, R0
        ADD R8, #1
        CMP R8, R6
        BGE	SUB1_PRE
        B	LOOP
SUB1_PRE:STR R1, [R9], #4
		ADD R3, #1
        CMP R3, R7
        BGT END
        B   SUB1
END: 	B 	END
        
        
        
SUM:.word	
N:	.word 	3
J: 	.word	6
LIST:.word	