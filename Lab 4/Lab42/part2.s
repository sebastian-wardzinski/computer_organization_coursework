         .text                   // executable code follows
          .global _start                  

_start:   MOV     R3, #TEST_NUM   // load the data word ...
          MOV     R0, #0
          MOV 	  R5, #0
          BL      SUB0

END:      B       END  

SUB0:     PUSH    {LR}      

SUB1:     LDR     R1, [R3], #4    // into R1
		  CMP 	  R1, #0
          POPEQ   {LR}
          MOVEQ   PC, LR
          BL	  ONES

          CMP     R5, R0
          MOVLE   R5, R0
          MOV     R0, #0          // R0 will hold next result
          B 	  SUB1
          
ONES:     CMP     R1, #0          // loop until the data contains no more 1's
          MOVEQ	  PC, LR
          LSR     R2, R1, #1      // perform SHIFT, followed by AND
          AND     R1, R1, R2      
          ADD     R0, #1          // count the string length so far
          B       ONES 

TEST_NUM: .word   0x56786578
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
