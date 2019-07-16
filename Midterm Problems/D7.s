.global _start

_start: MOV R0, #WORD
		MOV R1, #0
LOOP:	LDRB R1, [R0]
        CMP R1, #0x20
        BEQ END
        SUB R1, #32
        STRB R1, [R0]
        ADD R0, #1
        B 	LOOP
        
END: 	B 	END

WORD:  .byte 97, 110, 99, 32
        
	