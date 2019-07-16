              .section .vectors, "ax"  
                B        _start              // reset vector
                B        SERVICE_UND         // undefined instruction vector
                B        SERVICE_SVC         // software interrupt vector
                B        SERVICE_ABT_INST    // aborted prefetch vector
                B        SERVICE_ABT_DATA    // aborted data vector
                .word    0                   // unused vector
                B        SERVICE_IRQ         // IRQ interrupt vector
                B        SERVICE_FIQ         // FIQ interrupt vector

                .text    
                .include "exceptions.s"
                .global  _start 
				
Key_Interrupt_Mask: 	.word 0xFF200058

_start:                                  
/* Set up stack pointers for IRQ and SVC processor modes */
				MOV 	R0, #0b10010	//IRQ mode
                MSR 	CPSR, R0	
                LDR		SP, =0x80000	//set IRQ stack pointer
                MOV 	R0, #0b10011 	//SVC mode
                MSR 	CPSR, R0
                LDR 	SP, =0x3FFFFFFC
                
                BL       CONFIG_GIC      // configure the ARM generic
                                         // interrupt controller
/* Configure the KEY pushbuttons port to generate interrupts */
                MOV 	R0, #0b1111 
				LDR 	R1, Key_Interrupt_Mask
				ORR		R1, R0
                STR 	R1, Key_Interrupt_Mask
                
/* Enable IRQ interrupts in the ARM processor */
                MOV 	R0, #0b10000000
                MRS 	R1, CPSR
                ORR	 	R1, R0
                MSR 	CPSR, R1
IDLE:                                    
                B        IDLE            // main program simply idles

/* Define the exception service routines */

SERVICE_IRQ:    PUSH     {R0-R7, LR}     
                LDR      R4, =0xFFFEC100 // GIC CPU interface base address
                LDR      R5, [R4, #0x0C] // read the ICCIAR in the CPU
                                         // interface

KEYS_HANDLER:                       
                CMP      R5, #73         // check the interrupt ID

UNEXPECTED:     BNE      UNEXPECTED      // if not recognized, stop here
                BL       KEY_ISR

EXIT_IRQ:       STR      R5, [R4, #0x10] // write to the End of Interrupt
                                         // Register (ICCEOIR)
                POP      {R0-R7, LR}     
                SUBS     PC, LR, #4      // return from exception
