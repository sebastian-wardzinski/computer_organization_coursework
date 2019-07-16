.text
.global _start
.equ HEX, 0xFF200020
.equ KEY, 0xFF200050
_start:
	LDR R4, =HEX //address of HEX displays
	BL zero //hex should show "0" at the beginning
	
poll:
	LDR R1, =KEY //get address of KEY values
	LDR R1, [R1] //load KEY values
	ANDS R1, #0xF //check if any key is pressed
	BEQ poll //if no keys are pressed, pol again
	
	PUSH {R1} //keys have been pressed, save the KEY values
	BL waitForRelease //wait until all keys are released
	
	POP {R1} //retrieve the KEY values
	
	LDR R2, [R4] //get the current HEX display
	CMP R2, #0 //check if HEX is blank
	MOVEQ R0, #DISPLAY_CODE //if blank, then return to pointer to the beginning of the display code array
	LDREQB R3, [R0] //get "0" code
	STREQ R3, [R4] //set HEX to "0"
	BEQ poll //poll again
	
	ANDS R2, R1, #0b0001 //if KEY0 is pressed
	BLNE zero //then set HEX to "0"
	ANDS R2, R1, #0b0010 //check if KEY1 is pressed
	BLNE increment //then increment the displayed number
	ANDS R2, R1, #0b0100 //check if KEY2 is pressed
	BLNE decrement //then make the HEX blank
	ANDS R2, R1, #0b1000 //check for KEY3 being pressed
	BLNE blank //then make the HEX blank
	B poll //poll again
	
waitForRelease:
	LDR R1, =KEY //get address of KEY values
	LDR R1, [R1] //load the KEY values
	ANDS R1, #0xF //if any key is pressed
	BNE waitForRelease //then keep waiting
	BXEQ LR //else return

zero:
	MOV R0, #DISPLAY_CODE //pointer to the first display code, which is "0"
	LDRB R3, [R0] //load "0"
	STR R3, [R4] //set HEX to "0"
	BX LR //return

increment:
	LDRB R3, [R0] //get the display code
	CMP R3, #0b01100111 //if the current code is "9"
	MOVEQ R0, #DISPLAY_CODE //then move the pointer back to "0"
	ADDNE R0, #1 //else move the pointer to the next element
	LDRB R3, [R0] //load the element
	STR R3, [R4] //set the HEX
	BX LR //return

decrement:
	LDRB R3, [R0] //get the display code
	CMP R3, #0b00111111 //if the current code is "0"
	MOVEQ R0, #DISPLAY_CODE //then move the pointer back to "0"
	SUBNE R0, #1 //else move the pointer to the next element
	LDRB R3, [R0] //load the element
	STR R3, [R4] //set the HEX
	BX LR //return

blank:
	MOV R3, #0x0//0 means diplay is blank
	STR R3, [R4] //set HEX to blank
	BX LR //return

DISPLAY_CODE:  .byte   0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
               .byte   0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
               .skip   2      // pad with 2 bytes to maintain word alignment