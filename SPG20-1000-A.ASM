;	2018/3/24
;	SPG20-1362 STEPPING MOTOR
;	指定回転数を回転します。GPIO5押したときに回転をカウントする、GPIO5押したときに一時停止します。
;	PIC12F675 ステッピングモータ回転する
;	GP0,GP1,GP2,GP4 出力設定
;	GP3,GP5 入力設定
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
;		CB		&=	_INTRC_OSC_CLKOUT 
;		CB		&=	_INTRC_OSC
		CB		&=	_INTRC_OSC_NOCLKOUT
		__CONFIG	CB
		
;----------
		CBLOCK	H'20'
		CNT1			;TIME
		CNT2			;TIME
		CNT3			;TIME
		CNT4			;TIME
		MOTER_PWR		;通電時間
		MOTER_PWR_TEMP	;
		R_PWR_OFF		;R_PWR_OFF	
		L_PWR_OFF		;L_PWR_OFF
		FSR_TEMP		;
		PWR_OFF_TEMP	;
		STEP_CNT		;回転回数カウント用
		STEP_ALL		;回転回数
		MOTOR_STEP		;
		CNTNFA			;
		CNTNFB			;
		L0				;
		LA				;
		LB				;
		LC				;		
		LD				;
		ENDC

;----------
		ORG		H'0'
		GOTO INIT
		
;----------
INIT
		BSF			STATUS,RP0		;BANK1 選択
		MOVLW		B'00101000'		;GIPO5,3入力端子
		MOVWF		TRISIO			;GIPO5,3入力端子
		CLRF		ANSEL			;アナログをクリア、デジタル入力

		BCF			STATUS,RP0		;BANK0 選択
		MOVLW		B'00000111'		;比較OFF
		MOVWF		CMCON			;比較OFF
		BCF			INTCON,PEIE		;すべての外部割り込みを禁止
		
		CALL		DRV1			;フルステップ
		;CALL		DRV2			;波形ドライブ
		
		MOVLW		D'14'			;7-14
		MOVWF		MOTER_PWR		;モータ1ステップの通電時間
		
		MOVLW		D'90'			;4分の1, 90x4=360 利用のモーターの１回転ステップ数を割る4;
		MOVWF		MOTOR_STEP		;
		
		MOVLW		D'2'			;右回転SPEED,POWER_OFF時間が長くなると遅くなります
		MOVWF		R_PWR_OFF		;
		
		MOVLW		D'2'			;左回転SPEED,POWER_OFF時間が長くなると遅くなります
		MOVWF		L_PWR_OFF		;
		
		MOVLW		D'100';			;通電後の回転回数
		MOVWF		STEP_ALL		;
		MOVWF		STEP_CNT		;
		
;--------Main
MAIN								;メイン
		MOVF		STEP_ALL,w		;
		MOVWF		STEP_CNT		;
		CLRF		GPIO			;GPIOクリア
		BTFSS		GPIO,5			;スタートボタン
		GOTO		$ - 1			;
START
		CALL 		R				;右回転
	;	CALL		TIMER3			;遅延
	;	CALL 		L				;左回転
	;	CALL		TIMER3			;遅延
		BTFSC		GPIO,5			;一時停止
		CALL		TEMP_STOP		;
		DECFSZ		STEP_CNT,1		;回転カウントを-1
		GOTO 		START			;0出なければMainへ
		GOTO 		MAIN			;0になった場合は終了

TEMP_STOP
		BTFSC		GPIO,5			;
		GOTO		$ - 1			;
		BTFSS		GPIO,5			;
		GOTO		$ - 1 			;
		RETURN		


;--------end
EEND
		GOTO		EEND			;
		
		
;--------Main2
R									;右一周回転
		MOVF		MOTOR_STEP,0	;
		MOVWF		CNTNFA;			;
R_LOOP
		CALL		R_ROTATION		;右4ステップ
		DECFSZ		CNTNFA,1		;
		GOTO		R_LOOP			;
		RETURN						;
		
L									;左一周回転
		MOVF		MOTOR_STEP,0	;
		MOVWF		CNTNFB;			;
L_LOOP
		CALL		L_ROTATION		;左4ステップ
		DECFSZ		CNTNFB,1		;
		GOTO		L_LOOP			;
		RETURN

;--------
L_ROTATION							;左4ステップ
		MOVLW		LA				;LAのアドレスを読み取り
		MOVWF		FSR				;FSRにアドレスと書き込み
L_INDF_LOOP
		MOVF		INDF,0			;INDFレジスタを読み取り
		MOVWF		GPIO			;回転データを出力
		MOVWF		FSR_TEMP		;
		MOVF		MOTER_PWR,0		;
		MOVWF		MOTER_PWR_TEMP	;
		CALL		M_PWR			;
		MOVF		L_PWR_OFF,0		;
		MOVWF		PWR_OFF_TEMP	;
		CALL		CLRGPIO			;
		MOVF		FSR_TEMP,0		;
		SUBWF		LD,0			;
		BTFSC		STATUS,Z		;
		RETURN
		
		INCF		FSR,1			;
		GOTO		L_INDF_LOOP		;

;--------			
R_ROTATION							;左4ステップ
		MOVLW		LD				;
		MOVWF		FSR				;
R_INDF_LOOP
		MOVF		INDF,0			;
		MOVWF		GPIO			;
		MOVWF		FSR_TEMP		;
		MOVF		MOTER_PWR,0		;
		MOVWF		MOTER_PWR_TEMP	;
		CALL		M_PWR			;
		MOVF		R_PWR_OFF,0		;
		MOVWF		PWR_OFF_TEMP	;
		CALL		CLRGPIO			;
		MOVF		FSR_TEMP,0		;
		SUBWF		LA,0			;
		BTFSC		STATUS,Z		;
		RETURN
		
		DECF		FSR,1			;
		GOTO		R_INDF_LOOP		;

;--------
DRV1
		MOVLW		B'00010001'		;フルステップ
		MOVWF		LA;				;
		MOVLW		B'00000011'		;フルステップ
		MOVWF		LB				;
		MOVLW		B'00000110'		;フルステップ
		MOVWF		LC				;
		MOVLW		B'00010100'		;フルステップ
		MOVWF		LD				;
		RETURN
		
;--------	
DRV2
		MOVLW		B'00000001'		;波形ドライブ
		MOVWF		LA;				;
		MOVLW		B'00000010'		;波形ドライブ
		MOVWF		LB				;
		MOVLW		B'00000100'		;波形ドライブ
		MOVWF		LC				;
		MOVLW		B'00010000'		;波形ドライブ
		MOVWF		LD				;
		RETURN


;--------
CLRGPIO	NOP
		CLRF		GPIO			;
		CALL		TIMER1			;
		DECFSZ		PWR_OFF_TEMP,1	;
		GOTO		CLRGPIO			;
		RETURN

M_PWR	;MOVF		MOTER_PWR,0			;D'10' ~ D'30';
		;MOVWF		MOTER_PWR_TEMP
MLOOP1	NOP
		CALL		TIMER1
		DECFSZ		MOTER_PWR_TEMP,1	;
		GOTO		MLOOP1
		RETURN

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
		END							;