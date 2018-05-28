;	2018/05/21
;	A/D 変換、電圧の値でLEDを点灯する

;---------
		LIST		P=12F675
		INCLUDE		P12F675.INC
;---------
;	CONFIG 		設定
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
		CNT1	 					;TIME
		CNT2						;TIME
		CNT3						;TIME
		CNT4						;TIME
		CNT5						;TIME
		LED
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
		BSF			STATUS,RP0		;BANK1 選択
		CALL		H'3FF'			;校准内部振?器
		MOVWF		OSCCAL			;校准内部振?器

		MOVLW		B'00010000'		;Input Port GPIO,3 AN3
		MOVWF		TRISIO			;

		MOVLW		B'01011000'		;
		MOVWF		ANSEL			;

		BCF			STATUS,RP0		;
		MOVLW		B'00000111'		;CMCON Off
		MOVWF		CMCON			;
		
;--------Main
MAIN	

TEST
		CALL		ADCON			;
		CALL		TIMER3			;
		GOTO		TEST			;


;--------end
EEND
		MOVLW		B'00000000'		;すべての出力ボードをクリア
		MOVWF		GPIO			;すべての出力ボードをクリア
		SLEEP
		GOTO		EEND			;


;---------A/DWork
ADCON
		BCF			STATUS,RP0		;Bank1 
		MOVLW		B'00001100'		;ADFM = 0 , VCFG = 0 VDD , CHS1:CHS0 AN3 , GO = 0 , ADON = 0
		MOVWF		ADCON0			;
		BSF			ADCON0,ADON		;
		CALL		TIMER1			;
		BSF			ADCON0,GO		;

		BTFSC		ADCON0,GO		;
		GOTO		$ - 1			;

		BCF			ADCON,ADON		;
		MOVF		ADRESH,w		;
		CLRF		LED				;
		CALL		EEPROM			;
		CALL		EEPROML			;

		; 3.4v H'54'
		; 2.8v H'72'
		; 1.6v H'AF'
		; 0.6v H'DF'
		;MOVLW		H'2'			;
		;MOVWF		ADRESH			;

		MOVF		ADRESH,w		;
		SUBLW		H'FF'			;
		BTFSS		STATUS,C		;
		GOTO		$ + 3			;
		MOVLW		B'00100011'		; 4v -5v
		MOVWF		LED				;

		MOVF		ADRESH,w		;
		SUBLW		H'CC'			;
		BTFSS		STATUS,C		;
		GOTO		$ + 3			;
		MOVLW		B'00100001'		; 3v -4v
		MOVWF		LED				;

		MOVF		ADRESH,w		;
		SUBLW		H'99'			;
		BTFSS		STATUS,C		;
		GOTO		$ + 3			;
		MOVLW		B'00000111'		; 2v -3v
		MOVWF		LED				;

		MOVF		ADRESH,w		;
		SUBLW		H'66'			;
		BTFSS		STATUS,C		;
		GOTO		$ + 3			;
		MOVLW		B'00000011'		; 1v -2v
		MOVWF		LED				;	

		MOVF		ADRESH,w		;
		SUBLW		H'33'			;
		BTFSS		STATUS,C		;
		GOTO		$ + 3			;
		MOVLW		B'00000001'		; 0v -1v
		MOVWF		LED				;
		NOP

		MOVF		LED,w			;
		MOVWF		GPIO			;
		BCF			STATUS,RP0		;
		CALL		TIMER3			;
		RETURN						;


;----------EEPROM
EEPROM
		BSF			STATUS,RP0		;
		MOVLW		H'00'			;
		MOVWF		EEADR			;
		BCF			STATUS,RP0		;
		MOVF		ADRESH,w		;
		BSF			STATUS,RP0		;
		MOVWF		EEDATA			;
		BSF			EECON1,WREN		;
		BCF			INTCON,GIE		;
		MOVLW		H'55'			;
		MOVWF		EECON2			;
		MOVLW		H'AA'			;
		MOVWF		EECON2			;
		BSF			EECON1,WR		;
		BSF			INTCON,GIE		;
		BTFSC		EECON1,WR		;
		GOTO		$ - 1			;
		BCF			EECON1,WREN		;
		BCF			STATUS,RP0		;
		RETURN						;


;----------EEPROM
EEPROML
		BSF			STATUS,RP0		;
		MOVLW		H'01'			;
		MOVWF		EEADR			;
		MOVF		ADRESL,w		;
		MOVWF		EEDATA			;
		BSF			EECON1,WREN		;
		BCF			INTCON,GIE		;
		MOVLW		H'55'			;
		MOVWF		EECON2			;
		MOVLW		H'AA'			;
		MOVWF		EECON2			;
		BSF			EECON1,WR		;
		BSF			INTCON,GIE		;
		BTFSC		EECON1,WR		;
		GOTO		$ - 1			;
		BCF			EECON1,WREN		;
		BCF			STATUS,RP0		;
		RETURN						;



;--------Timer
; 4MHZ 内部クロック
; 25KHz 作成
; 25KHz = 40us
; 4Mhz/4  = 1us 
; 25KHｚ T = 40 サイクル				

TIMER1		MOVLW		D'25'			;D'25' 0.1ミリ秒
			MOVWF		CNT1			;
LOOP1		NOP							;
			DECFSZ		CNT1,1			;
			GOTO		LOOP1			;
			RETURN						;

T5			MOVLW		D'4'			;D'5' -> 0.5ミリ秒
			MOVWF		CNT5
LOOPT5		NOP							;
			CALL		TIMER1			;
			DECFSZ		CNT5,1			;
			GOTO		LOOPT5			;
			RETURN						;


TIMER2		MOVLW		D'100'			;D'100' -> 10ミリ秒 D'50' -> 5ミリ秒
			MOVWF		CNT2
LOOP2		NOP							;
			CALL		TIMER1			;
			DECFSZ		CNT2,1			;
			GOTO		LOOP2			;
			RETURN						;
		
TIMER3		MOVLW		D'50'			;1/2秒
			MOVWF		CNT3			;
LOOP3		NOP							;
			CALL		TIMER2			;
			DECFSZ		CNT3,1			;
			GOTO		LOOP3			;
			RETURN						;

TIMER4		MOVLW		D'10'			;10秒
			MOVWF		CNT4			;
LOOP4		NOP							;
			CALL		TIMER3			;
			DECFSZ		CNT4,1			;
			GOTO		LOOP4			;
			RETURN						;

;--------
E_END									;
			END							;
