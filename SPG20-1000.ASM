;	Test
;	PIC12F675 ステッピングモータ回転する
;	GP0,GP1,GP2,GP4 出力設定
;	GP3,GP5 入力設定、回転を修正する
;	GP3正回転、GP5逆回転、1クリック、1ステップになります。
;	GP3、GP5同時に押すと、回転が始まります。
;	回転の設定はプログラムで事前に設定されます。
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
		STEP_CNT		;
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
		
		;CALL		DRV1			;波形ドライブ
		;CALL		DRV2			;フルステップ
		CALL		DRV3			;フルステップ
		
		MOVLW		D'7'			;
		MOVWF		MOTER_PWR		;モータ1ステップの通電時間
		
		MOVLW		D'90'			;4分の1, 90x4=360 利用のモーターの１回転ステップ数を割る4;
		MOVWF		MOTOR_STEP		;
		
		MOVLW		D'7'			;右回転SPEED,POWER_OFF時間が長くなると遅くなります
		MOVWF		R_PWR_OFF		;
		
		MOVLW		D'7'			;左回転SPEED,POWER_OFF時間が長くなると遅くなります
		MOVWF		L_PWR_OFF		;
		
		MOVLW		D'1';			;通電後の回転回数
		MOVWF		STEP_CNT		;
		
;--------Main
MAIN								;メイン
		CALL 		R				;右回転
		CALL		TIMER3			;遅延
	;	CALL 		L				;左回転
	;	CALL		TIMER3			;遅延
		DECFSZ		STEP_CNT,1		;回転カウントを-1
		GOTO 		MAIN			;0出なければMainへ

		GOTO 		EEND			;0になった場合は終了
		
;--------end
EEND
		MOVLW		B'00000000'		;すべての出力ボードをクリア
		MOVWF		GPIO			;すべての出力ボードをクリア
		NOP							;
		BTFSC		GPIO,3			;GPIO,3の状態を確認、デフォルトは0
		;CALL		R				;押された時、右回転を呼び出し
		CALL 		L_ROTATION		;
		NOP							;
		BTFSC		GPIO,5			;GPIO,53の状態を確認、デフォルトは0
		;CALL		L				;押された時、右回転を呼び出し
		CALL		R_ROTATION		;
		NOP							;
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
		MOVLW		B'00010001'		;波形ドライブ
		MOVWF		LA;				;
		MOVLW		B'00000011'		;波形ドライブ
		MOVWF		LB				;
		MOVLW		B'00000110'		;波形ドライブ
		MOVWF		LC				;
		MOVLW		B'00010100'		;波形ドライブ
		MOVWF		LD				;
		RETURN
		
;--------	
DRV2
		MOVLW		B'00000001'		;フルステップ
		MOVWF		LA;				;
		MOVLW		B'00000010'		;フルステップ
		MOVWF		LB				;
		MOVLW		B'00000100'		;フルステップ
		MOVWF		LC				;
		MOVLW		B'00010000'		;フルステップ
		MOVWF		LD				;
		RETURN

;--------
DRV3	
		MOVLW		B'00000011'		;;
		MOVWF		LA;				;
		MOVLW		B'00000110'		;;
		MOVWF		LB				;
		MOVLW		B'00010100'		;;
		MOVWF		LC				;
		MOVLW		B'00000000'		;;
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

		
		
