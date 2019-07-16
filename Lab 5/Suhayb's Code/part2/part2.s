.text
.global _start
.equ HEX, 0xFF200020
.equ EDGE, 0xFF20005C
_start:
	MOV R4, #0 //counter value starts at 0
	MOV R3, #0xF //value to reset all four edge bits
	LDR R2, =EDGE //get the address for edge capture
	STR R3, [R2] //reset edge capture
	BL DISPLAY //display "0" on HEX
	
loop:
	BL DO_DELAY //wait 0.25 seconds
	ADD R4, #1 //increment counter value
	BL DISPLAY //display counter value on HEX
	CMP R4, #99 //if counter has reached 99
	MOVEQ R4, #0 //then wrap around to 0
	
	LDR R2, =EDGE //get the address for edge capture
	LDR R3, [R2] //load edge capture
	ANDS R3, #0xF //if edge capture is not 0
	MOVNE R3, #0xF //then get value to reset all four edge bits
	STRNE R3, [R2] //then reset edge capture
	BLNE waitForPress //then wait for the next edge
	
	B loop //loop forever
	
DO_DELAY: 
	LDR R0, =50000000 // delay counter
SUB_LOOP: 
	SUBS R0, #1 //decrement delay counter
	BNE SUB_LOOP //repeat delay loop until counter reaches 0
	BX LR //return

waitForPress:
	LDR R3, [R2] //load edge capture
	ANDS R3, #0xF //if edge capture is equal to 0
	BEQ waitForPress //then keep waiting
	MOV R3, #0xF //else get value to reset all four edge bits
	STR R3, [R2] //reset edge capture
	BX LR //return
	

DISPLAY:    PUSH    {LR}            // save return address to main loop
            MOV     R0, R4          // pass the counter value to DIVIDE
            BL      DIVIDE          // ones digit will be in R0, tens digit in R1
            PUSH    {R1}            // save the tens digit
            BL      SEG7_CODE       // get bit code for ones digit
            MOV     R3, R0          // save bit code into HEX0
			POP     {R1}            // retrieve the tens digit
            MOV     R0, R1          // pass the tens digit as an argument
            BL      SEG7_CODE       // get bit code for tens digit
            LSL     R0, #8          // move into HEX1 position
            ORR     R3, R0          // save bit code into HEX1
			LDR     R2, =HEX        // get the address for HEX
			STR     R3, [R2]        // light up the HEX
			POP     {LR}            // restore return address to main loop
			BX      LR              // return to main loop
			
DIVIDE:     MOV    R2, #0           // initialize tens counter to 0
CONT:       CMP    R0, #10          // if the remainder is less than 10
            BLT    DIV_END          // then it is time to return
            SUB    R0, #10          // subtract 10 from argument
            ADD    R2, #1           // increment tens counter
            B      CONT             // repeat
DIV_END:    MOV    R1, R2           // quotient in R1 (remainder in R0)
            MOV    PC, LR           // return

SEG7_CODE:  MOV     R1, #BIT_CODES  // get pointer to first bit code "0"
            ADD     R1, R0          // index into the BIT_CODES "array"
            LDRB    R0, [R1]        // load the bit pattern (to be returned)
            MOV     PC, LR          // return

BIT_CODES:  .byte   0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
            .byte   0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
            .skip   2      // pad with 2 bytes to maintain word alignment