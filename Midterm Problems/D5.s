.text
.global _start

_start:	MOV R1, #X
        MOV R2, #Y
        MOV R5, #LARGER
        MOV R0, #N
		STR R0, [R0]
	
LOOP: 	LDR R3, [R1], #4
        LDR R4, [R2], #4
		CMP R3, R4
        STRGE R4, R5
        STRLT R3, R5
        SUB R0, #1
        CMP R0, #0
        BEQ LOOP
    
END:    B END

Y:	.byte 0x32, 0x23, 0x12, 0x22, 0x02
X:	.byte 0x43, 0x80, 0x54, 0x52, 0x08
N: 	.byte 0x05

LARGER: .byte

.end