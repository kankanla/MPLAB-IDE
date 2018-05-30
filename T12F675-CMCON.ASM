;	2018/05/30
;	CMCON CIN+ > CIN- ÇÃèÍçáÅAGPIO2ì_ìîÇ∑ÇÈÅB CIN+ < CIN-ÇÃÇ∆Ç´ÅAGPIO2è¡ìîÇ∑ÇÈ

;---------
		LIST		P=12F675
		INCLUDE		P12F675.INC
;---------
;	CONFIG 		ê›íË
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
		BSF			STATUS,RP0		;BANK1 ëIë

		CALL		H'3FF'			;çZèyì‡ïîêU?äÌ
		MOVWF		OSCCAL			;çZèyì‡ïîêU?äÌ

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
; 4MHZ ì‡ïîÉNÉçÉbÉN
; 25KHz çÏê¨
; 25KHz = 40us
; 4Mhz/4  = 1us 
; 25KHÇö T = 40 ÉTÉCÉNÉã				

TIMER1		MOVLW		D'25'			;D'25' 0.1É~Éäïb
			MOVWF		CNT1			;
LOOP1		NOP							;
			DECFSZ		CNT1,1			;
			GOTO		LOOP1			;
			RETURN						;

T5			MOVLW		D'4'			;D'5' -> 0.5É~Éäïb
			MOVWF		CNT5
LOOPT5		NOP							;
			CALL		TIMER1			;
			DECFSZ		CNT5,1			;
			GOTO		LOOPT5			;
			RETURN						;


TIMER2		MOVLW		D'100'			;D'100' -> 10É~Éäïb D'50' -> 5É~Éäïb
			MOVWF		CNT2
LOOP2		NOP							;
			CALL		TIMER1			;
			DECFSZ		CNT2,1			;
			GOTO		LOOP2			;
			RETURN						;
		
TIMER3		MOVLW		D'50'			;1/2ïb
			MOVWF		CNT3			;
LOOP3		NOP							;
			CALL		TIMER2			;
			DECFSZ		CNT3,1			;
			GOTO		LOOP3			;
			RETURN						;

TIMER4		MOVLW		D'10'			;10ïb
			MOVWF		CNT4			;
LOOP4		NOP							;
			CALL		TIMER3			;
			DECFSZ		CNT4,1			;
			GOTO		LOOP4			;
			RETURN						; 

;--------
E_END									;
			END							;
