; PIC12F1822 Configuration Bit Settings
; Assembly source line config statements

#include "p12f1822.inc"
    
    LIST P=12F1822
    INCLUDE P12F1822.INC

; CONFIG1
; __config 0xF9A4
    __CONFIG _CONFIG1, _FOSC_INTOSC & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_OFF & _CLKOUTEN_OFF & _IESO_ON & _FCMEN_ON
; CONFIG2
; __config 0xFFFF
    __CONFIG _CONFIG2, _WRT_OFF & _PLLEN_ON & _STVREN_ON & _BORV_LO & _LVP_ON
 
 
;CBLOCK
    CBLOCK H'20'
	CNT1
	CNT2
	CNT3
    ENDC
    
;--------
    ORG	0
    GOTO    INIT
    
    ORG 4
    GOTO    H04_ISR
    
;H04_ISR
H04_ISR   
    
;INIT
INIT
    MOVLB   1
    MOVLW   B'11110010'
    MOVWF   OSCCON
    MOVLW   B'00111000'
    MOVWF   TRISA
    
    MOVLW   B'00000000'
    MOVLB   3
    MOVWF   ANSELA
    
    MOVLW   B'00000000';
    MOVLB   0
    MOVWF   PORTA
    
   
;MAIN
MAIN
    BSF	    PORTA,RA1
    NOP
    NOP
    NOP
    BCF	    PORTA,RA1
    NOP
    NOP
    NOP
    NOP
    GOTO    MAIN
    

	
    
;PEND
    END
 
 