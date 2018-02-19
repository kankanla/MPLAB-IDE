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
		BSF			STATUS,RP0		;
		MOVLW		B'00101000'		;
		MOVWF		TRISIO			;
		CLRF		ANSEL			;

		BCF			STATUS,RP0
		MOVLW		B'00000111'		;
		MOVWF		CMCON			;
		BCF			INTCON,PEIE		;

		MOVLW		B'00010001'		;波形ドライブ
	;	MOVLW		B'00000001'		;フルステップ
		MOVWF		LA;				;

		MOVLW		B'00000011'		;波形ドライブ
	;	MOVLW		B'00000010'		;フルステップ
		MOVWF		LB				;

		MOVLW		B'00000110'		;波形ドライブ
	;	MOVLW		B'00000100'		;フルステップ
		MOVWF		LC				;

		MOVLW		B'00010100'		;波形ドライブ
	;	MOVLW		B'00010000'		;フルステップ
		MOVWF		LD				;

		MOVLW		D'12'			;
		MOVWF		MOTER_PWR		;通電時間

		MOVLW		D'90'			; 90x4=360 利用のモーターの１回転ステップ数を割る4;
		MOVWF		MOTOR_STEP		;

		MOVLW		D'45'			;右回転SPEED
		MOVWF		R_PWR_OFF			;

		MOVLW		D'15'			;左回転SPEED
		MOVWF		L_PWR_OFF			;

		MOVLW		D'9';			;回転数
		MOVWF		STEP_CNT		;

;--------Main
MAIN
		CALL 		R				;
		CALL 		L				;
		DECFSZ		STEP_CNT,1		;
		GOTO 		MAIN			;
		GOTO 		EEND			;

;--------end
EEND
		MOVLW		B'00000000'		;
		MOVWF		GPIO			;
		NOP							;
		GOTO		EEND			;

;--------Main2
R
		MOVF		MOTOR_STEP,0	;
		MOVWF		CNTNFA;			;
R_LOOP
		CALL		R_ROTATION		;
		DECFSZ		CNTNFA,1		;
		GOTO		R_LOOP			;
		RETURN						;
		
L
		MOVF		MOTOR_STEP,0	;
		MOVWF		CNTNFB;			;
L_LOOP
		CALL		L_ROTATION		;
		DECFSZ		CNTNFB,1		;
		GOTO		L_LOOP			;
		RETURN

;--------StepA
L_ROTATION
		MOVF		LA,0			;
		MOVWF		GPIO			;
		MOVF		MOTER_PWR,0		;
		MOVWF		MOTER_PWR_TEMP	;
		CALL		M_PWR			;

		MOVF		L_PWR_OFF,0		;
		MOVWF		PWR_OFF_TEMP	;
		CALL		CLRGPIO			;

		MOVF		LB,0			;
		MOVWF		GPIO			;
		MOVF		MOTER_PWR,0		;
		MOVWF		MOTER_PWR_TEMP	;
		CALL		M_PWR			;
		MOVF		L_PWR_OFF,0		;
		MOVWF		PWR_OFF_TEMP	;
		CALL		CLRGPIO			;
	
		MOVF		LC,0			;
		MOVWF		GPIO			;
		MOVF		MOTER_PWR,0		;
		MOVWF		MOTER_PWR_TEMP	;
		CALL		M_PWR			;
		MOVF		L_PWR_OFF,0		;
		MOVWF		PWR_OFF_TEMP	;
		CALL		CLRGPIO			;

		
		MOVF		LD,0			;
		MOVWF		GPIO			;
		MOVF		MOTER_PWR,0		;
		MOVWF		MOTER_PWR_TEMP	;
		CALL		M_PWR			;
		MOVF		L_PWR_OFF,0		;
		MOVWF		PWR_OFF_TEMP	;
		CALL		CLRGPIO			;
		RETURN

;--------StepB
R_ROTATION
		MOVF		LD,0			;
		MOVWF		GPIO			;
		MOVF		MOTER_PWR,0		;
		MOVWF		MOTER_PWR_TEMP	;
		CALL		M_PWR			;
		MOVF		R_PWR_OFF,0		;
		MOVWF		PWR_OFF_TEMP	;
		CALL		CLRGPIO			;

		MOVF		LC,0			;
		MOVWF		GPIO			;
		MOVF		MOTER_PWR,0		;
		MOVWF		MOTER_PWR_TEMP	;
		CALL		M_PWR			;
		MOVF		R_PWR_OFF,0		;
		MOVWF		PWR_OFF_TEMP	;
		CALL		CLRGPIO			;

		MOVF		LB,0			;
		MOVWF		GPIO			;
		MOVF		MOTER_PWR,0		;
		MOVWF		MOTER_PWR_TEMP	;
		CALL		M_PWR			;
		MOVF		R_PWR_OFF,0		;
		MOVWF		PWR_OFF_TEMP	;
		CALL		CLRGPIO			;

		MOVF		LA,0			;
		MOVWF		GPIO			;
		MOVF		MOTER_PWR,0		;
		MOVWF		MOTER_PWR_TEMP	;
		CALL		M_PWR			;
		MOVF		R_PWR_OFF,0		;
		MOVWF		PWR_OFF_TEMP	;
		CALL		CLRGPIO			;
		RETURN

;--------Timer
TIMER1	MOVLW		D'25'			;0.1ミリ秒
		MOVWF		CNT1
LOOP1	NOP
		DECFSZ		CNT1,1
		GOTO		LOOP1
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

