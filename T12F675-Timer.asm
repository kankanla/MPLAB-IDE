;	2018/04/20
;	PIC12F675 Timer0

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
		H04W_TEMP		;
		CNT1			;TIME
		CNT2			;TIME
		CNT3			;TIME
		CNT4			;TIME
		ENDC			;

;----------
		ORG			0				;
		GOTO		INIT			;
		
		ORG			4				;
		GOTO		H04				;
		
;----------
H04		
		MOVLW		D'230'			;TMR0?‰?
		MOVWF		TMR0			;TMR0?‰?
		MOVWF		H04W_TEMP		;
		BCF			INTCON,GIE		;0 = ‹ÖŽ~Š—L’†’f
		;BCF			INTCON,INTF		;0 = ‹ÖŽ~ GP2/INT ŠO•”’†’f
		;BCF			INTCON,T0IE		;0 = ‹ÖŽ~ TMR0 ˆìo’†’f
		BCF			INTCON,T0IF		;1 = TMR0 Šñ‘¶Ší›ß?ˆìo´—ë i•K?—p?Œ´—ëj

		BSF			GPIO,0			;
		NOP
		BCF			GPIO,0			;

		BSF			INTCON,GIE		;1 = Žg”\Š—L–¢› •Á“I’†’f
		MOVF		H04W_TEMP,w		;
		RETFIE						;
	
		
;----------
INIT
		BSF			STATUS,RP0		;BANK1 ‘I‘ð
		CALL		H'3FF'			;Zy“à•”U?Ší
		MOVWF		OSCCAL			;Zy“à•”U?Ší
		MOVLW		B'00011100'		;GIPO4,3“ü—Í’[Žq
		MOVWF		TRISIO			;Zy“à•”U?Ší
		CLRF		ANSEL			;”Žš I/O
		BCF			OPTION_REG,T0CS	;TMR0 ??Œ¹??ˆÊ
		BCF			OPTION_REG,PSA	;0 = «?•ª?Ší•ª”z? TIMER0 –Í?
		BCF			OPTION_REG,T0SE	;1 = GP2/T0CKI ˆø‹r“I‰º~‰ˆ?ú

		BCF			OPTION_REG,PS2	;PS2:PS0F?•ª?Ší“I•ª?”ä??ˆÊ	
		BCF			OPTION_REG,PS1	;PS2:PS0F?•ª?Ší“I•ª?”ä??ˆÊ
		BCF			OPTION_REG,PS0	;PS2:PS0F?•ª?Ší“I•ª?”ä??ˆÊ
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
		BSF			INTCON,INTE		;1 = Žg”\ GP2/INT ŠO•”’†’f
		BSF			INTCON,T0IE		;1 = Žg”\ TMR0 ˆìo’†’f


		MOVLW		D'230'			;TMR0?‰?
		MOVWF		TMR0			;TMR0?‰?

;--------Main
MAIN	NOP
		GOTO		MAIN			;



		
;--------end
EEND
		MOVLW		B'00000000'		;‚·‚×‚Ä‚Ìo—Íƒ{[ƒh‚ðƒNƒŠƒA
		MOVWF		GPIO			;‚·‚×‚Ä‚Ìo—Íƒ{[ƒh‚ðƒNƒŠƒA
		GOTO		EEND			;


;--------Timer
; 4MHZ “à•”ƒNƒƒbƒN
; 25KHz ì¬
; 25KHz = 40us
; 4Mhz/4  = 1us 
; 25KH‚š T = 40 ƒTƒCƒNƒ‹				

TIMER1	MOVLW		D'25'			;D'25' 0.1ƒ~ƒŠ•b
		MOVWF		CNT1			;
LOOP1	NOP							;
		DECFSZ		CNT1,1			;
		GOTO		LOOP1			;
		RETURN						;

TIMER2	MOVLW		D'100'			;D'100' -> 10ƒ~ƒŠ•b D'50' -> 5ƒ~ƒŠ•b
		MOVWF		CNT2
LOOP2	NOP							;
		CALL		TIMER1			;
		DECFSZ		CNT2,1			;
		GOTO		LOOP2			;
		RETURN						;
		
TIMER3	MOVLW		D'50'			;1/2•b
		MOVWF		CNT3			;
LOOP3	NOP							;
		CALL		TIMER2			;
		DECFSZ		CNT3,1			;
		GOTO		LOOP3			;
		RETURN						;

TIMER4	MOVLW		D'10'			;10•b
		MOVWF		CNT4			;
LOOP4	NOP							;
		CALL		TIMER3			;
		DECFSZ		CNT4,1			;
		GOTO		LOOP4			;
		RETURN						;

;--------
E_END								;
		END							;