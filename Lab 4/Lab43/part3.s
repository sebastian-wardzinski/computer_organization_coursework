       .text                   // executable code follows
          .global _start                  

_start:   MOV     R3, #TEST_NUM   // load the data word ...
          MOV     R0, #0
          MOV 	  R5, #0
          MOV 	  R6, #0
          MOV 	  R7, #0
          BL      SUB0

END:      B       END  

SUB0:     PUSH    {LR}      

SUB1:     LDR     R4, [R3], #4    // into R1

		  CMP 	  R4, #0
          POPEQ   {LR}
          MOVEQ   PC, LR
          
          MOV 	  R1, R4
          BL	  ONES
          CMP     R5, R0
          MOVLE   R5, R0
          MOV     R0, #0
          
          MOV 	  R1, R4
          BL      ZEROS
          CMP     R6, R0
          MOVLE   R6, R0
          MOV     R0, #0
          
          MOV 	  R1, R4
          BL      ALTERNATE
          CMP     R7, R0
          MOVLE   R7, R0
          MOV     R0, #0
          
          B 	  SUB1
          
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
		  LSR     R2, R1, #1
	      EOR     R1, R1, R2
          BL      ONES
          POP     {LR}
          MOV 	  PC, LR

TEST_NUM: .word   0x55555555
		  .word   0x34645634
          .word   0x00000000
          .word   0xdddddddd
          .word   0xaaaaaaaa
          .word   0x88888888
          .word   0x66666666
          .word   0x33333333
          .word   0x11111111
          .word   0x00000000

          .end                            
