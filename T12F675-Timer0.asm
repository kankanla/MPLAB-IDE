;	2018/05/30
;	PIC CMCON
;---------
		LIST		P=12F675
		INCLUDE		P12F675.INC
;---------
;	CONFIG 		Ý’è
		CB		=	_CPD_OFF
		CB		&=	_CP_OFF
		CB		&=	_BODEN_ON
		CB		&=	_MCLRE_OFF
		CB		&=	_PWRTE_ON
		CB		&=	_WDT_OFF
		CB		&=	_INTRC_OSC_NOCLKOUT  ;_EXTRC_OSC_NOCLKOUT
		__CONFIG	CB
		
;----------
		CBLOCK	H'20'
		H04W_TEMP					;
		CNT1						;TIME
		CNT2						;TIME
		CNT3						;TIME
		CNT4						;TIME
		CNT5						;TIME
		PLAG						;
		H04_TEMP					;
		ENDC						;

;----------
		ORG			0				;
		GOTO		INIT			;
		
		ORG			4				;
		GOTO		H04				;

;----------

H04		
		MOVWF		H04W_TEMP		;
		BCF			INTCON,1		;
		BCF			INTCON,T0IF		;

		MOVLW		D'90'			
		MOVWF		H04_TEMP		;
		DECFSZ		H04_TEMP,f
		GOTO		$-1

		BTFSS		GPIO,0			;
		BSF			GPIO,0
		BCF			GPIO,0


H04_END
		MOVF		H04W_TEMP,w		;
		RETFIE						;
			
;----------
INIT
		BSF			STATUS,RP0		;BANK1 ‘I‘ð
		CALL		H'3FF'			;Zy“à•”U?Ší
		MOVWF		OSCCAL			;

		MOVLW		B'00001000'		;
		MOVWF		TRISIO			;

		MOVLW		B'00000000'		;
		MOVWF		ANSEL			;

		BCF			OPTION_REG,T0CS	;
		BCF			OPTION_REG,PSA	;
		BCF			OPTION_REG,2	;
		BCF			OPTION_REG,1	;
		BCF			OPTION_REG,0	;
		BSF			OPTION_REG,T0SE	;
		

		BCF			STATUS,RP0		;
		MOVLW		B'00000111'		;
		MOVWF		CMCON			;

		MOVLW		D'12'			;
		MOVWF		TMR0			;



;--------Main
MAIN	
		MOVLW		B'10100000'		;
		MOVWF		INTCON			;

		NOP						;10
		GOTO		$ - H'1'	;
		

;--------end
EEND
		SLEEP
		GOTO		EEND			;









;--------Timer
; 4MHZ “à•”ƒNƒƒbƒN
; 25KHz ì¬
; 25KHz = 40us
; 4Mhz/4  = 1us 
; 25KH‚š T = 40 ƒTƒCƒNƒ‹				

TIMER1		MOVLW		D'25'			;D'25' 0.1ƒ~ƒŠ•b
			MOVWF		CNT1			;
LOOP1		NOP							;
			DECFSZ		CNT1,1			;
			GOTO		LOOP1			;
			RETURN						;

T5			MOVLW		D'4'			;D'5' -> 0.5ƒ~ƒŠ•b
			MOVWF		CNT5
LOOPT5		NOP							;
			CALL		TIMER1			;
			DECFSZ		CNT5,1			;
			GOTO		LOOPT5			;
			RETURN						;


TIMER2		MOVLW		D'100'			;D'100' -> 10ƒ~ƒŠ•b D'50' -> 5ƒ~ƒŠ•b
			MOVWF		CNT2
LOOP2		NOP							;
			CALL		TIMER1			;
			DECFSZ		CNT2,1			;
			GOTO		LOOP2			;
			RETURN						;
		
TIMER3		MOVLW		D'50'			;1/2•b
			MOVWF		CNT3			;
LOOP3		NOP							;
			CALL		TIMER2			;
			DECFSZ		CNT3,1			;
			GOTO		LOOP3			;
			RETURN						;

TIMER4		MOVLW		D'10'			;10•b
			MOVWF		CNT4			;
LOOP4		NOP							;
			CALL		TIMER3			;
			DECFSZ		CNT4,1			;
			GOTO		LOOP4			;
			RETURN						;

;--------
E_END									;
			END							;