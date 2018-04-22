;	2018/04/21
;	PIC12F675 Timer0
;	RoHS
;	ƒ}ƒCƒNƒƒT[ƒ{@SG92R
;	[SG92R]
;	’Ê”ÌƒR[ƒh@M-08914
;	”­”„“ú@2015/01/20
;	ƒ[ƒJ[ƒJƒeƒSƒŠ@Tower Pro Pte Ltd
;	‚s‚‚—‚…‚’‚o‚’‚‚ÌƒT[ƒ{‚Å‚·B
;
;	ŸŽå‚ÈŽd—l
;		‚o‚v‚lƒTƒCƒNƒ‹F‚Q‚O‚‚r
;		§Œäƒpƒ‹ƒXF‚OD‚T‚‚“`‚QD‚S‚‚“
;		§ŒäŠpF}–ñ‚X‚O‹i‚P‚W‚O‹j
;		”züF’ƒ‚f‚m‚cAÔ“dŒ¹m{nAžò§ŒäM†@m‚i‚qƒ^ƒCƒvn
;		ƒgƒ‹ƒNF‚QD‚T‚‹‚‡‚†E‚ƒ‚
;		“®ì‘¬“xF‚OD‚P•b^‚U‚O“x
;		“®ì“dˆ³F‚SD‚W‚u

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
		INT_FLAG					;Š„‚èž‚Ýƒvƒ‰ƒN Timer0AGP2/INT ŠO•”’†’f
		STEP_TEMP					;
		
		H04W_TEMP					;
		CNT1						;TIME
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
		MOVWF		H04W_TEMP		;
		BCF			INTCON,GIE		;0 = ‹ÖŽ~Š—L’†’f

									;`”»Ð’†Ð—ÞŒ^
		BTFSC		INTCON,T0IF		;1 = TMR0 Šñ‘¶Ší›ß?ˆìo i•K?—p?Œ´—ëj
		GOTO		H04_TIMER		;

		BTFSC		INTCON,INTF		;1 = ?¶ GP2/INT ŠO•”’†’f i•K?—p?Œ´—ëj
		GOTO		H04_GPIO2		;
		GOTO		H04_END			;

H04_TIMER							;
		BCF			INTCON,T0IE		;0 = ‹ÖŽ~ TMR0 ˆìo’†’f
		BSF			GPIO,0			;
		MOVLW		D'176'			; 20000us
		MOVWF		TMR0			;
		BCF			INTCON,T0IF		;TMR0 ƒNƒŠƒA
		BCF			INT_FLAG,0		;TIMERƒtƒ‰ƒO ƒNƒŠƒA
		BSF			INTCON,T0IE		;0 = ‹ÖŽ~ TMR0 ˆìo’†’f
		BCF			GPIO,0			;
		BSF			INTCON,T0IE		;1 = Žg”\ TMR0 ˆìo’†’f
		GOTO		H04_END			;

H04_GPIO2							;
		BCF			INTCON,INTE		;0 = ‹ÖŽ~ GP2/INT ŠO•”’†’f
		BCF			INTCON,INTF		;1 = ?¶ GP2/INT ŠO•”’†’f i•K?—p?Œ´—ëj
		BCF			INT_FLAG,1		;
		BSF			INTCON,INTE		;1 = Žg”\ GP2/INT ŠO•”’†’f	
		GOTO		H04_END			;

H04_END
		BSF			INTCON,INTE		;1 = Žg”\ GP2/INT ŠO•”’†’f
		BSF			INTCON,T0IE		;1 = Žg”\ TMR0 ˆìo’†’f
		BSF			INTCON,PEIE		;1 = Žg”\Š—L–¢› •Á“IŠO?’†’f
		BSF			INTCON,GIE		;1 = Žg”\Š—L–¢› •Á“I’†’f
		MOVF		H04W_TEMP,w		;
		RETFIE						;
			
;----------
INIT
		BSF			STATUS,RP0		;BANK1 ‘I‘ð
		CALL		H'3FF'			;Zy“à•”U?Ší
		MOVWF		OSCCAL			;Zy“à•”U?Ší
		MOVLW		B'00000100'		;“ü—Í’[Žq
		MOVWF		TRISIO			;Zy“à•”U?Ší
		CLRF		ANSEL			;”Žš I/O

		BCF			OPTION_REG,T0CS		;0 = ??“à•”Žw—ßŽüŠú?? iCLKOUTj
		BCF			OPTION_REG,PSA		;0 = «?•ª?Ší•ª”z? TIMER0 –Í?
		BSF			OPTION_REG,INTEDG	;1 = GP2/INT ˆø‹rã?•½“Iã¡‰ˆG?’†’f

		BSF			OPTION_REG,PS2		;PS2:PS0F?•ª?Ší“I•ª?”ä??ˆÊ	
		BSF			OPTION_REG,PS1		;PS2:PS0F?•ª?Ší“I•ª?”ä??ˆÊ
		BSF			OPTION_REG,PS0		;PS2:PS0F?•ª?Ší“I•ª?”ä??ˆÊ
							;000		1 : 2
							;001		1 : 4 
							;010		1 : 8
							;011		1 : 16
							;100		1 : 32
							;101		1 : 64
							;110		1 : 128
							;111		1 : 256

		BCF			STATUS,RP0		;BANK0 ‘I‘ð
		MOVLW		B'00000111'		;”äŠrOFF
		MOVWF		CMCON			;”äŠrOFF

		BSF			INTCON,GIE		;1 = Žg”\Š—L–¢› •Á“I’†’f
		BSF			INTCON,PEIE		;1 = Žg”\Š—L–¢› •Á“IŠO?’†’f
		BSF			INTCON,INTE		;1 = Žg”\ GP2/INT ŠO•”’†’f
		;BSF			INTCON,T0IE		;1 = Žg”\ TMR0 ˆìo’†’f

		MOVLW		D'176'			; 20000us
		MOVWF		TMR0			;


;E‚o‚v‚lƒTƒCƒNƒ‹F‚Q‚O‚‚r
; 20MS = 20000us = 1us * 20000; 4000
;E§Œäƒpƒ‹ƒXF‚OD‚T‚‚“`‚QD‚S‚‚“
; 0.5ms = 500us
; 2.4ms = 2400us

;--------Main
MAIN	
		CALL		ONE_STEP		;
		CALL		TIMER4			;
		BSF			INT_FLAG,1		;

DAKI
		BTFSC		INT_FLAG,1		;
		GOTO		$ - 1			;
		CALL		ONE_STEP		;
		BSF			INT_FLAG,1		;
		CALL		TIMER2			;
		GOTO		DAKI			;



;-----------------SG92R----------------------
ONE_STEP
		BSF			INTCON,T0IE		;1 = Žg”\ TMR0 ˆìo’†’f
		MOVLW		D'22'			;
		MOVWF		STEP_TEMP		;PWMá¢¶’·“x
ONE1
		BSF			GPIO,1			;
		CALL		TIMER1			;
		CALL		TIMER1			;
		CALL		TIMER1			;
		CALL		TIMER1			;
		CALL		TIMER1			;
		BCF			GPIO,1			;
		BSF			INT_FLAG,0		;Ý’uTimerFLAGˆ×1 
		BTFSC		INT_FLAG,0		;“™‘ÒTiemr’†Ð?¶ŒãTimerFLAGÌˆ×0
		GOTO		$ - 1			;
		DECFSZ		STEP_TEMP,f		;EPWMá¢¶’·“x
		GOTO		ONE1			;

		MOVLW		D'22'			;
		MOVWF		STEP_TEMP		;
ONE2
		BSF			GPIO,1			;
		CALL		T5				;
		CALL		T5				;
		CALL		T5				;
		CALL		T5				;
		CALL		TIMER1			;
		CALL		TIMER1			;
		CALL		TIMER1			;
		CALL		TIMER1			;

		BCF			GPIO,1			;
		BSF			INT_FLAG,0	;
		BTFSC		INT_FLAG,0	;
		GOTO		$ - 1			;
		DECFSZ		STEP_TEMP,f		;
		GOTO		ONE2			;

		BCF			INTCON,T0IE		;0 = ‹ÖŽ~ TMR0 ˆìo’†’f
		RETURN						;

;--------end
EEND
		MOVLW		B'00000000'		;‚·‚×‚Ä‚Ìo—Íƒ{[ƒh‚ðƒNƒŠƒA
		MOVWF		GPIO			;‚·‚×‚Ä‚Ìo—Íƒ{[ƒh‚ðƒNƒŠƒA
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
