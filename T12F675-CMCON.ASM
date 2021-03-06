;	2018/05/30
;	CMCON CIN+ > CIN- ΜκAGPIO2_·ιB CIN+ < CIN-ΜΖ«AGPIO2Α·ι

;---------
		LIST		P=12F675
		INCLUDE		P12F675.INC
;---------
;	CONFIG 		έθ
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
		CNT1	 					;TIME
		CNT2						;TIME
		CNT3						;TIME
		CNT4						;TIME
		CNT5						;TIME
		ENDC						;

;----------
		ORG			0				;
		GOTO		INIT			;
		
		ORG			4				;
		GOTO		H04				;
		
;----------
H04		
		RETFIE						;
			
;----------
INIT
		BSF			STATUS,RP0		;BANK1 Iπ

		CALL		H'3FF'			;ZyΰU?ν
		MOVWF		OSCCAL			;ZyΰU?ν

		MOVLW		B'00000011'		;Input Port GPIO,3 AN3
		MOVWF		TRISIO			;

		MOVLW		B'01011011'		;
		MOVWF		ANSEL			;

		BCF			STATUS,RP0		;

		;MOVLW		B'00000010'		;CM2:CM0 = 010
		MOVLW		B'00000001'		;CM2:CM0 = 001
		MOVWF		CMCON			;
		CLRF		GPIO			;



;--------Main
;CM2:CM0 = 001
MAIN
		NOP
		GOTO		MAIN			;

;CM2:CM0 = 010
MAIN1
		BTFSS		CMCON,COUT		;
		GOTO		MAIN1			;
		BSF			GPIO,2			;

MAIN2
		BTFSC		CMCON,COUT		;
		GOTO		MAIN2
		BCF			GPIO,2			;
		GOTO		MAIN1			;


;--------end
EEND
		SLEEP
		GOTO		EEND			;




;--------Timer
; 4MHZ ΰNbN
; 25KHz μ¬
; 25KHz = 40us
; 4Mhz/4  = 1us 
; 25KH T = 40 TCN				

TIMER1		MOVLW		D'25'			;D'25' 0.1~b
			MOVWF		CNT1			;
LOOP1		NOP							;
			DECFSZ		CNT1,1			;
			GOTO		LOOP1			;
			RETURN						;

T5			MOVLW		D'4'			;D'5' -> 0.5~b
			MOVWF		CNT5
LOOPT5		NOP							;
			CALL		TIMER1			;
			DECFSZ		CNT5,1			;
			GOTO		LOOPT5			;
			RETURN						;


TIMER2		MOVLW		D'100'			;D'100' -> 10~b D'50' -> 5~b
			MOVWF		CNT2
LOOP2		NOP							;
			CALL		TIMER1			;
			DECFSZ		CNT2,1			;
			GOTO		LOOP2			;
			RETURN						;
		
TIMER3		MOVLW		D'50'			;1/2b
			MOVWF		CNT3			;
LOOP3		NOP							;
			CALL		TIMER2			;
			DECFSZ		CNT3,1			;
			GOTO		LOOP3			;
			RETURN						;

TIMER4		MOVLW		D'10'			;10b
			MOVWF		CNT4			;
LOOP4		NOP							;
			CALL		TIMER3			;
			DECFSZ		CNT4,1			;
			GOTO		LOOP4			;
			RETURN						; 

;--------
E_END									;
			END							;
