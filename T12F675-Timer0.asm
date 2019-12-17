;	2018/05/30
;	PIC CMCON
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
		MOVLW		D'181'			;
		MOVWF		TMR0			;

		MOVLW		D'1'			
		MOVWF		H04_TEMP		;
		DECFSZ		H04_TEMP,f
		GOTO		$-1

		BTFSS		GPIO,0			;
		BSF			GPIO,0
		BCF			GPIO,0


H04_END

		BSF			INTCON,1
		MOVF		H04W_TEMP,w		;
		RETFIE						;
			
;----------
INIT
		BSF			STATUS,RP0		;BANK1 ëIë
		CALL		H'3FF'			;çZèyì‡ïîêU?äÌ
		MOVWF		OSCCAL			;

		MOVLW		B'00001000'		;
		MOVWF		TRISIO			;

		MOVLW		B'00000000'		;
		MOVWF		ANSEL			;

		BCF			OPTION_REG,T0CS	;
		BCF			OPTION_REG,PSA	;
		BSF			OPTION_REG,2	;
		BSF			OPTION_REG,1	;
		BSF			OPTION_REG,0	;
		BSF			OPTION_REG,T0SE	;
		

		BCF			STATUS,RP0		;
		MOVLW		B'00000111'		;
		MOVWF		CMCON			;

		MOVLW		D'181'			;
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
		END