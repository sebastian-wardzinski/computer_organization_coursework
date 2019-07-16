/* Program that converts a binary number to decimal */
           .text               // executable code follows
           .global _start
_start:
            MOV    R6, #N
            MOV    R5, #Digits  // R5 points to the decimal digits storage location
            LDR    R6, [R6]     // R4 holds N
            MOV    R0, R6       // parameter for DIVIDE goes in R0
     		MOV    R4, #Devisor
            LDR	   R4, [R4]  		 
            BL     DIVIDE
            STRB   R3, [R5, #3] // Thousands digit
			STRB   R2, [R5, #2] // Hundreds digit
            STRB   R1, [R5, #1] // Tens digit is now in R1
            STRB   R0, [R5]     // Ones digit is in R0
END:        B      END

/* Subroutine to perform the integer division R0 / 10.
 * Returns: quotient in R1, and remainder in R0
*/
DIVIDE:     MOV    R1, #0	//Initialize all digits to zero
			MOV    R2, #0
            MOV    R3, #0
          
CONT:       CMP    R0, R4	//Is digit less than divisor?
            BLT    DIV_SEC	//Next digit
            SUB    R0, R4	//Repeated subtraction
            ADD    R1, #1
            B      CONT		//LOOP
            
DIV_SEC:    CMP    R1, R4	//Is digit less than divisor?
			BLT    DIV_TRD	//Next digit
			SUB    R1, R4	//Repeated subtraction
            ADD    R2, #1
            B	   DIV_SEC	//LOOP

DIV_TRD:	CMP    R2, R4	//Is digit less than divisor?
			MOVLT  PC, LR 	//Go back to main, we have all digits
            SUB    R2, R4	//Repeated subtraction
            ADD    R3, #1
            B 	   DIV_TRD	//LOOP

N:          .word  4645         // the decimal number to be converted
Digits:     .space 4          // storage space for the decimal digits
Devisor: 	.word 10
            .end
