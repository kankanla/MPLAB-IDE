;	Test
;	外部クロックによりファンの回転速度を変更するプログラム
;	GPIO0，1，2 出力		
;	GPIO3,4,入力		B'00011000'
;	GPIO5,外部RCクロック
;---------

		LIST		P=12F675
		INCLUDE		P12F675.INC
;---------
;CONFIG 		設定
		CB		=	_CPD_OFF
		CB		&=	_CP_OFF
		CB		&=	_BODEN_ON
		CB		&=	_MCLRE_OFF
		CB		&=	_PWRTE_ON
		CB		&=	_WDT_OFF
		CB		&=	_EXTRC_OSC_NOCLKOUT
		__CONFIG	CB
		
;----------
		CBLOCK	H'20'
		STEP_ALL		;ALL_STEP
		STEP_ON			;STEP_ON
		STEP_OFF		;		
		STEP_ON_CONT	;
		STEP_OFF_CONT	;
		CNT1			;TIME
		CNT2			;TIME
		CNT3			;TIME
		CNT4			;TIME
		ENDC			;

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
		BSF			INTCON,PEIE		;すべての外部割り込みを禁止
		
		MOVLW		D'30'			;
		MOVWF		STEP_ALL		;
		MOVLW		D'1'			;
		MOVWF		STEP_ON			;
		MOVWF		STEP_ON_CONT	;
		SUBWF		STEP_ALL,w		;
		MOVWF		STEP_OFF		;
		MOVWF		STEP_OFF_CONT	;

;--------Main
MAIN
MAIN_ON
		NOP
		NOP
		NOP
		BSF			GPIO,2			;
		CALL		TIMER2			;;;
		BTFSC		GPIO,3			;
		CALL		SET_STEP		;
		DECFSZ		STEP_ON_CONT	;
		GOTO		MAIN_ON			;
		MOVF		STEP_ON,w		;
		MOVWF		STEP_ON_CONT	;
		GOTO		MAIN_OFF		;

MAIN_OFF
		MOVF		STEP_OFF,w		;
		BTFSC		STATUS,Z		;
		GOTO		MAIN_ON			;
		BCF			GPIO,2			;
		CALL		TIMER2			;;;
		BTFSC		GPIO,3			;
		CALL		SET_STEP		;
		DECFSZ		STEP_OFF_CONT	;
		GOTO		MAIN_OFF		;
		MOVF		STEP_OFF,w		;
		MOVWF		STEP_OFF_CONT	;
		GOTO		MAIN_ON			;

		
;--------SET_STEP
SET_STEP
		BCF			GPIO,2			;
		BTFSC		GPIO,3			;
		GOTO		SET_STEP		;GPIO 1
		
		MOVF		STEP_ON,w		;現在のON値を読み取り
		SUBWF		STEP_ALL,w		;全体のステップを減算します。
		BTFSC		STATUS,Z		;結果は0の場合、ON==ALLの場合
		CLRF		STEP_ON			;ONをクリアする
		INCF		STEP_ON,f		;ONを+1
		
		MOVF		STEP_ON,w		;
		SUBWF		STEP_ALL,w		;
		MOVWF		STEP_OFF		;
		
		MOVF		STEP_ON,w		;
		MOVWF		STEP_ON_CONT	;
		MOVF		STEP_OFF,w		;
		MOVWF		STEP_OFF_CONT	;
		
		BSF			GPIO,0			;
		BSF			GPIO,1			;
		CALL		TIMER2			;
		BCF			GPIO,0			;
		BCF			GPIO,1			;
		RETURN
		
;--------end
EEND
		MOVLW		B'00000000'		;すべての出力ボードをクリア
		MOVWF		GPIO			;すべての出力ボードをクリア
		GOTO		EEND			;

;--------Timer
TIMER1	MOVLW		D'25'			;D'25' 0.1ミリ秒
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

		
		