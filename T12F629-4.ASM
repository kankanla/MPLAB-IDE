;	2018/03/10
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
		CB		&=	_INTRC_OSC_NOCLKOUT  ;_EXTRC_OSC_NOCLKOUT
		__CONFIG	CB
		
;----------
		CBLOCK	H'20'
		STEP_ALL		;ALL_STEP
		STEP_ON			;STEP_ON
		STEP_OFF		;		
		STEP_ON_CONT	;
		STEP_OFF_CONT	;
		KHZ25			;
		H04W_TEMP		;
		H04W_LED		;
		CNT1			;TIME
		CNT2			;TIME
		CNT3			;TIME
		CNT4			;TIME
		ENDC			;

;----------
		ORG			0		;
		GOTO		INIT			;
		
		ORG			4			;
		GOTO		H04				;
		
;----------
H04		
		MOVWF		H04W_TEMP
		BCF			INTCON,GIE		;
		BCF			INTCON,INTF		;	
		;-----------------------
		INCF		STEP_ON,f		;ONを+1	
		MOVF		STEP_ON,w		;現在のON値を読み取り
		SUBWF		STEP_ALL,w		;全体のステップを減算します。
		BTFSC		STATUS,Z		;結果は0の場合、ON==ALLの場合
		CLRF		STEP_ON			;ONをクリアする
		MOVF		STEP_ON,w		;
		BTFSC		STATUS,Z		;
		SLEEP
		
		
		
		MOVF		STEP_ON,w		;
		SUBWF		STEP_ALL,w		;
		MOVWF		STEP_OFF		;

			
		MOVF		STEP_ON,w		;
		MOVWF		STEP_ON_CONT	;
		MOVWF		H04W_LED		;
		MOVF		STEP_OFF,w		;
		BTFSC		STATUS,Z		;
		INCF		STEP_OFF,f		;
		MOVF		STEP_OFF,w		;
		MOVWF		STEP_OFF_CONT	;
		BCF			GPIO,0			;
		MOVF		H04W_LED,w		;
		BTFSC		STATUS,Z		;
		GOTO		H4_EEND			;		

H4_LED	
		BSF			GPIO,1			;
		CALL		TIMER2			;
		BCF			GPIO,1			;
		CALL		TIMER2			;
		DECFSZ		H04W_LED,f		;
		GOTO		H4_LED			;

H4_EEND
		BSF			INTCON,GIE		;
		MOVF		H04W_TEMP,w		;		
		

		;-----------------------
		RETFIE		;
		
		
;----------
INIT
		BSF			STATUS,RP0		;BANK1 選択
		CALL		H'3FF'			;
		MOVWF		OSCCAL			;
		MOVLW		B'00011100'		;GIPO4,3入力端子
		MOVWF		TRISIO			;
		CLRF		ANSEL			;アナログをクリア、デジタル入力
		BCF			OPTION_REG,6	;
		
		BCF			STATUS,RP0		;BANK0 選択
		MOVLW		B'00000111'		;比較OFF
		MOVWF		CMCON			;比較OFF
		BSF			INTCON,GIE		;PEIE：外?中断使能位
		BSF			INTCON,INTE		;INTE：GP2/INT 外部中断使能位

		
		MOVLW		D'11'			;
		MOVWF		STEP_ALL		;
		MOVLW		D'1'			;
		MOVWF		STEP_ON			;
		MOVWF		STEP_ON_CONT	;
		SUBWF		STEP_ALL,w		;
		MOVWF		STEP_OFF		;
		MOVWF		STEP_OFF_CONT	;
		CLRF		GPIO			;

;--------Main
MAIN
T1_ON
		DECFSZ		STEP_ON_CONT,f	;
		GOTO		T1_ON			;
		BCF			GPIO,0			;	
		MOVF		STEP_ON,w		;
		MOVWF		STEP_ON_CONT	;
		GOTO		T1_OFF			;
	
T1_OFF
		DECFSZ		STEP_OFF_CONT,f	;
		GOTO		T1_OFF			;
		BSF			GPIO,0			;
		MOVF		STEP_OFF,w		;
		MOVWF		STEP_OFF_CONT	;
		GOTO		T1_ON			;
		





;--------T1;
MAIN_ON
		BSF			GPIO,2			;
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
		BTFSC		GPIO,3			;
		CALL		SET_STEP		;
		DECFSZ		STEP_OFF_CONT	;
		GOTO		MAIN_OFF		;
		MOVF		STEP_OFF,w		;
		MOVWF		STEP_OFF_CONT	;
		GOTO		MAIN_ON			;

		
;--------SET_STEP
SET_STEP
	
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

;--------25Khz
;4Mhz 1C = 0.25us
;1c = 1us
;25kHz  1s/25000= 0.00004s = 0.04ms = 40us

KHZ25_T	MOVLW		D'19'			;D'25' 0.1ミリ秒
		MOVWF		KHZ25
KHZ25_LOOP
		DECFSZ		KHZ25,1
		GOTO		KHZ25_LOOP
		RETURN


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