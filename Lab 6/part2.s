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
                  .global  _start                          
_start:                                         
/* Set up stack pointers for IRQ and SVC processor modes */
				MOV 	R0, #0b10010	//IRQ mode
                MSR 	CPSR, R0	
                LDR		SP, =0x2FFFFFFC	//set IRQ stack pointer
                MOV 	R0, #0b10011 	//SVC mode
                MSR 	CPSR, R0
                LDR 	SP, =0x3FFFFFFC
                    
                  BL       CONFIG_GIC       // configure the ARM generic
                                            // interrupt controller
                  BL       CONFIG_TIMER     // configure the Interval Timer
                  BL       CONFIG_KEYS      // configure the pushbutton
                                            // KEYs port

/* Enable IRQ interrupts in the ARM processor */
               	MOV 	R0, #0xFFFFFF7F
                MRS 	R1, CPSR
                AND	 	R1, R0
                MSR 	CPSR, R1
                
               	LDR     R5, =0xFF200000  // LEDR base address
LOOP:                                          
           	    LDR    	R3, COUNT        // global variable
       	     	STR     R3, [R5]         // write to the LEDR lights
               	B       LOOP                

/* Configure the Interval Timer to create interrupts at 0.25 second intervals */
CONFIG_TIMER:     
				LDRH 	R0, PERIOD
                STRH 	R0, TIMER_PERIOD1
                LDRH 	R0, PERIOD + 4
                STRH 	R0, TIMER_PERIOD2
                MOV		R0, #0b0111		//to start, continue, and interrupt
                STR 	R0, TIMER_CONTROL
                BX      LR      
                
PERIOD: 			.word	0x017D7840
TIMER_STATUS: 		.word 	0xFF202000
TIMER_CONTROL:		.word 	0xFF202004 
TIMER_PERIOD1:		.word 	0xFF202008
TIMER_PERIOD2: 		.word 	0xFF20200c 

/* Configure the pushbutton KEYS to generate interrupts */
CONFIG_KEYS:                                    
               	MOV 	R0, #0xF
               	STR 	R1, Key_Interrupt_Mask
                BX       LR                  

/* Global variables */
                  .global  COUNT                           
COUNT:            .word    0x0              // used by timer
                  .global  RUN              // used by pushbutton KEYs
RUN:              .word    0x1              // initial value to increment
                                            // COUNT
                  .end                                        
