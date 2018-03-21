;	
;	2018/03/21 Coilgun railgun
;	コイルガン（英: Coilgun）は電磁石のコイルを使って弾丸となる物体を加速・発射する装置である。
;	GPIO,0，1，2,4 出力		
;	GPIO 3、5入力 5スイッチ,3未使用
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
		H04_TEMP		;
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
		MOVWF		H04_TEMP		;
		MOVF		H04_TEMP,w		;
		RETFIE						;
		
;----------
INIT
		BSF			STATUS,RP0		;BANK1 選択
		CALL		H'3FF'			;
		MOVWF		OSCCAL			;
		MOVLW		B'00101000'		;GIPO5,3入力端子
		MOVWF		TRISIO			;
		CLRF		ANSEL			;アナログをクリア、デジタル入力
		BCF			OPTION_REG,7	;
		
		BCF			STATUS,RP0		;BANK0 選択
		MOVLW		B'00000111'		;比較OFF
		MOVWF		CMCON			;比較OFF
		CLRF		GPIO			;

;--------Main
MAIN
		CALL		TIMER4
		NOP							;発射待機
		BTFSS		GPIO,5			;発射ボタン押す、GPIO5 1になり、次のコマンドをスキップ
		GOTO		MAIN			;
		
		BSF			GPIO,0			;コイルGPIO,0
		CALL		TIMER2			;
		BCF			GPIO,0			;
		CALL		TIMER1			;

		BSF			GPIO,1			;コイルGPIO,1
		CALL		TIMER2			;
		BCF			GPIO,1			;
		CALL		TIMER1			;

		BSF			GPIO,2			;コイルGPIO,2
		CALL		TIMER2			;
		BCF			GPIO,2			;
		CALL		TIMER1			;

		BSF			GPIO,4			;コイルGPIO,4
		CALL		TIMER2
		BCF			GPIO,4			;
		CALL		TIMER1			;

		BTFSC		GPIO,5			;発射ボタンを離すとMainに戻る
		GOTO		$ - 1			;
		GOTO		MAIN			;

;--------end
EEND
		MOVLW		B'00000000'		;すべての出力ボードをクリア
		MOVWF		GPIO			;すべての出力ボードをクリア
		GOTO		EEND			;

;--------Timer
;      4Mhz 1クロック=0.00000025S = 0.00025mS = 0.25μS
;      4Mhz 1サイクル=1μS
TIMER1	MOVLW		D'25'			;D'25' 0.1ミリ秒 (101Cycles,101.000000uSecs)
		MOVWF		CNT1			;
LOOP1	NOP							;
		DECFSZ		CNT1,1			;
		GOTO		LOOP1			;
		RETURN						;

TIMER2	MOVLW		D'92'			;D'92' -> 10ミリ秒 (10029Cycles,10.029000mSecs)
		MOVWF		CNT2
LOOP2							;
		CALL		TIMER1			;
		DECFSZ		CNT2,1			;
		GOTO		LOOP2			;
		RETURN						;
		
TIMER3	MOVLW		D'51'			;D'51' -> 0.5秒 (507196Cycles,507.196000mSecs) 
		MOVWF		CNT3			;
LOOP3	NOP							;
		CALL		TIMER2			;
		DECFSZ		CNT3,1			;
		GOTO		LOOP3			;
		RETURN						;

TIMER4	MOVLW		D'10'			;1D'10' -> 5秒 (5072041Cycles,5.072041Secs)
		MOVWF		CNT4			;
LOOP4	NOP							;
		CALL		TIMER3			;
		DECFSZ		CNT4,1			;
		GOTO		LOOP4			;
		RETURN						;

;--------
E_END								;
		END							;