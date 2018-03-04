;	Test
;	外部クロックによりファンの回転速度を変更するプログラム
;	GPIO0，1，2 出力		
;	GPIO3,4,入力		B'00011000'
;	GPIO5,外部RCクロック
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
		CB		&=	_EXTRC_OSC_NOCLKOUT
		__CONFIG	CB
		
;----------
		CBLOCK	H'20'		;EQU
		SPEED			;SPEED
		SPEED_TEMP		;SPEED_TEMP
		STEP_ALL		;ALL_STEP
		STEP_ALL_TEMP	;
		STEP_ON			;STEP_ON
		STEP_ON_TEMP	;
		CNT1			;TIME
		CNT2			;TIME
		CNT3			;TIME
		CNT4			;TIME
		ENDC

;----------
		ORG			H'0'			;
		GOTO		INIT			;
		
		ORG			H'04'			;
		GOTO		H04				;
		
;----------
H04

		
;----------
INIT
		BSF			STATUS,RP0		;BANK1 選択
		MOVLW		B'00011000'		;GIPO4,3入力端子
		MOVWF		TRISIO			;
		CLRF		ANSEL			;アナログをクリア、デジタル入力

		BCF			STATUS,RP0		;BANK0 選択
		MOVLW		B'00000111'		;比較OFF
		MOVWF		CMCON			;比較OFF
		BCF			INTCON,PEIE		;すべての外部割り込みを禁止
		
		MOVLW		D'30'			;
		MOVWF		STEP_ALL		;
		MOVLW		D'16'			;
		MOVWF		STEP_ON			;
		
		
;--------Main
MAIN								;メイン
		MOVF		STEP_ALL,0		;
		MOVWF		STEP_ALL_TEMP	;
		MOVF		STEP_ON,0		;
		MOVWF		STEP_ON_TEMP	;
		
		
MAIN_T1
		MOVLW		B'00000000'		;
		NOP							;
		NOP
		MOVF		STEP_ON_TEMP,1	;
		BTFSS		STATUS,Z		;
		DECFSZ		STEP_ON_TEMP,1	;
		MOVLW		B'00000100'		;
		BTFSS		STATUS,Z		;
		MOVWF		GPIO			;
		CALL		TIMER2			;
		
		DECFSZ		STEP_ALL_TEMP,1	;
		GOTO		MAIN_T1			;
		GOTO		MAIN			;
		
		GOTO 		EEND			;
		
;-------TP_ON
TP_ON	
		DECF		STEP_ALL_TEMP	;
		DECF		STEP_ON_TEMP	;
		MOVLW		B'00000100'		;
		MOVWF		GPIO			;
		RETURN
		
;--------end
EEND
		MOVLW		B'00000000'		;すべての出力ボードをクリア
		MOVWF		GPIO			;すべての出力ボードをクリア
		GOTO		EEND			;





;--------Timer
TIMER1	MOVLW		D'25'			;0.1ミリ秒
		MOVWF		CNT1
LOOP1	NOP
		DECFSZ		CNT1,1
		GOTO		LOOP1
		RETURN

TIMER2	MOVLW		D'100'			;D'100' -> 10ミリ秒 D'50' -> 5ミリ秒
		MOVWF		CNT2
LOOP2	NOP
		CALL		TIMER1
		DECFSZ		CNT2,1
		GOTO		LOOP2
		RETURN
		
TIMER3	MOVLW		D'50'			;1/2秒
		MOVWF		CNT3
LOOP3	NOP
		CALL		TIMER2
		DECFSZ		CNT3,1
		GOTO		LOOP3
		RETURN

TIMER4	MOVLW		D'10'			;10秒
		MOVWF		CNT4
LOOP4	NOP
		CALL		TIMER3
		DECFSZ		CNT4,1
		GOTO		LOOP4
		RETURN

;--------
		END							;

		
		