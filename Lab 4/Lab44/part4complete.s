          .text                   // executable code follows
          .global _start                  

/* Subroutine to convert the digits from 0 to 9 to be shown on a HEX display.
 *    Parameters: R0 = the decimal value of the digit to be displayed
 *    Returns: R0 = bit patterm to be written to the HEX display */

SEG7_CODE:  MOV     R1, #BIT_CODES  
            ADD     R1, R0         // index into the BIT_CODES "array"
            LDRB    R0, [R1]       // load the bit pattern (to be returned)
            MOV     PC, LR              

BIT_CODES:  .byte   0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
            .byte   0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
            .skip   2      // pad with 2 bytes to maintain word alignment

_start:   MOV     R3, #TEST_NUM   // load the data word ...
          MOV     R0, #0
          MOV 	  R5, #0
          MOV 	  R6, #0
          MOV 	  R7, #0
          BL      SUB0
          
/* Display R5 on HEX1-0, R6 on HEX3-2 and R7 on HEX5-4 */
DISPLAY:  LDR     R8, =0xFF200020 // base address of HEX3-HEX0
          MOV     R0, R5          // display R5 on HEX1-0
          BL      DIVIDE          // ones digit will be in R0; tens digit in R1
          MOV     R9, R1          // save the tens digit
          BL      SEG7_CODE       
          MOV     R4, R0          // save bit code
          MOV     R0, R9          // retrieve the tens digit, get bit code
          BL      SEG7_CODE       
          LSL     R0, #8		  //shift by 8 so because the tens value needs to access HEX1
          ORR     R4, R0		  //ORR the bit codes for the ones and the tens digit, to create a code for a 2-digit decimal number
          
          /*code for R6*/
          LDR     R8, =0xFF200020 // base address of HEX5-HEX4
          MOV 	  R0, R6
          BL 	  DIVIDE
          MOV 	  R9, R1
          BL      SEG7_CODE
          LSL 	  R0, #16			//shift by 16 to access HEX2
          ORR     R4, R0
          MOV     R0, R9
          BL      SEG7_CODE
          LSL     R0, #24			//shift by 24 to access HEX3
          ORR     R4, R0
          
          STR     R4, [R8]        // display the numbers from R6 and R5
          
          /*code for R7*/
          LDR     R8, =0xFF200030 // base address of HEX4-HEX5
          MOV 	  R0, R7
          BL 	  DIVIDE
          MOV 	  R9, R1
          BL 	  SEG7_CODE
          MOV     R4, R0
          MOV     R0, R9
          BL      SEG7_CODE
          LSL     R0, #8		 //shift by 8 to acces HEX5
          ORR     R4, R0
          
          STR     R4, [R8]        // display the number from r7
          
END:      B       END			//END OF CODE, R5, R6, R7 should be displayed on the HEXs


SUB0:     PUSH    {LR}      	//Store link since nested subroutines will be called

SUB1:     LDR     R4, [R3], #4    //load into R4, this register will always contain the orignal work

		  CMP 	  R4, #0		//If end of word sequence reached, pop the link and return to 'main'
          POPEQ   {LR}
          MOVEQ   PC, LR
          
          MOV 	  R1, R4		//R1 will go into the function, and R4 will keep the original word
          BL	  ONES				//since we need it for the next function as well
          CMP     R5, R0		//If the ouput is greater than the previous larger, replace the largest
          MOVLE   R5, R0
          MOV     R0, #0		//Reset the output register
          
          MOV 	  R1, R4		//Put the word into R1 again, rinse and repeat
          BL      ZEROS
          CMP     R6, R0
          MOVLE   R6, R0
          MOV     R0, #0
          
          MOV 	  R1, R4
          BL      ALTERNATE
          CMP     R7, R0
          MOVLE   R7, R0
          MOV     R0, #0
          
          B 	  SUB1			//Loop until no more words left
          
          
ONES:     CMP     R1, #0          // loop until the data contains no more 1's
          MOVEQ	  PC, LR
          LSR     R2, R1, #1      // perform SHIFT, followed by AND
          AND     R1, R1, R2      
          ADD     R0, #1          // count the string length so far
          B       ONES 
          
ZEROS:    CMP     R1, #4294967295        // loop until the data contains no more 0
          MOVEQ	  PC, LR
          LSR     R2, R1, #1      // perform SHIFT, followed by OR
          ADD     R2, #2147483648
          ORR     R1, R1, R2      
          ADD     R0, #1          // count the string length so far
          B       ZEROS 

ALTERNATE:PUSH    {LR}
          MOV 	  R9, #ALTERNATING
          LDR     R9, [R9]
	      EOR     R1, R1, R9
          MOV 	  R2, R1
          BL      ONES
          MOV 	  R9, R0		//store the output for later comparison
          MOV 	  R0, #0
          MOV     R1, R2		//get the original bitstream value back for the next function cal
          BL      ZEROS
          CMP     R0, R9
          MOVLE   R0, R9 		//if ONES output was bigger, replace R0 with it
          POP     {LR}			//Retreive the link and return to 'SUB1'
          MOV 	  PC, LR


DIVIDE: 	MOV R1, #0			//Code from lab 3 to convert a 2 decimal number, from hex to decimal
CONT: 		CMP R0, #10			//R0 contains remainder, R1 contains tens digit
            MOVLT PC, LR 
            SUB R0, #10
            ADD R1, #1
			B CONT				//loop until remainder is less than 10

ALTERNATING: .word 0x55555555

TEST_NUM: .word   0x48472493
		  .word   0x53463634
          .word   0x00000001
          .word   0xffffffff
          .word   0x55555555
          .word   0x00000000	//signals end of word sequence

          .end                
          

