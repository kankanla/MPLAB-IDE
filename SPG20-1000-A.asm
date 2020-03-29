;	2018/3/24
;	SPG20-1362 STEPPING MOTOR
;	????????????GPIO5????????????????GPIO5??????????????
;	PIC12F675 ?????????????
;	GP0,GP1,GP2,GP4 ????
;	GP3,GP5 ????
;---------

		LIST		P=12F675
		INCLUDE		P12F675.INC
;---------
;	CONFIG 		??
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
		MOTER_PWR		;????
		MOTER_PWR_TEMP		;
		R_PWR_OFF		;R_PWR_OFF	
		L_PWR_OFF		;L_PWR_OFF
		FSR_TEMP		;
		PWR_OFF_TEMP		;
		STEP_CNT		;?????????
		STEP_ALL		;????
		MOTOR_STEP		;
		CNTNFA			;
		CNTNFB			;
		L0			;
		LA			;
		LB			;
		LC			;		
		LD			;
		ENDC

;----------
		ORG		H'0'
		GOTO INIT
		
;----------
INIT
		BSF		STATUS,RP0		;BANK1 ??
		MOVLW		B'00101000'		;GIPO5,3????
		MOVWF		TRISIO			;GIPO5,3????
		CLRF		ANSEL			;???????????????

		BCF		STATUS,RP0		;BANK0 ??
		MOVLW		B'00000111'		;??OFF
		MOVWF		CMCON			;??OFF
		BCF		INTCON,PEIE		;?????????????
		
		CALL		DRV1			;??????
		;CALL		DRV2			;??????
		
		MOVLW		D'14'			;7-14
		MOVWF		MOTER_PWR		;???1?????????
		
		MOVLW		D'90'			;4??1, 90x4=360 ???????????????????4;
		MOVWF		MOTOR_STEP		;
		
		MOVLW		D'2'			;???SPEED,POWER_OFF??????????????
		MOVWF		R_PWR_OFF		;
		
		MOVLW		D'2'			;???SPEED,POWER_OFF??????????????
		MOVWF		L_PWR_OFF		;
		
		MOVLW		D'100';			;????????
		MOVWF		STEP_ALL		;
		MOVWF		STEP_CNT		;
		
;--------Main
MAIN							;???
		MOVF		STEP_ALL,w		;
		MOVWF		STEP_CNT		;
		CLRF		GPIO			;GPIO???
		BTFSS		GPIO,5			;???????
		GOTO		$ - 1			;
START
		CALL 		R			;???
	;	CALL		TIMER3			;??
	;	CALL 		L			;???
	;	CALL		TIMER3			;??
		BTFSC		GPIO,5			;????
		CALL		TEMP_STOP		;
		DECFSZ		STEP_CNT,1		;???????-1
		GOTO 		START			;0?????Main?
		GOTO 		MAIN			;0?????????

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
R							;?????
		MOVF		MOTOR_STEP,0		;
		MOVWF		CNTNFA;			;
R_LOOP
		CALL		R_ROTATION		;?4????
		DECFSZ		CNTNFA,1		;
		GOTO		R_LOOP			;
		RETURN					;
		
L							;?????
		MOVF		MOTOR_STEP,0		;
		MOVWF		CNTNFB;			;
L_LOOP
		CALL		L_ROTATION		;?4????
		DECFSZ		CNTNFB,1		;
		GOTO		L_LOOP			;
		RETURN

;--------
L_ROTATION						;?4????
		MOVLW		LA			;LA??????????
		MOVWF		FSR			;FSR??????????
L_INDF_LOOP
		MOVF		INDF,0			;INDF?????????
		MOVWF		GPIO			;????????
		MOVWF		FSR_TEMP		;
		MOVF		MOTER_PWR,0		;
		MOVWF		MOTER_PWR_TEMP		;
		CALL		M_PWR			;
		MOVF		L_PWR_OFF,0		;
		MOVWF		PWR_OFF_TEMP		;
		CALL		CLRGPIO			;
		MOVF		FSR_TEMP,0		;
		SUBWF		LD,0			;
		BTFSC		STATUS,Z		;
		RETURN
		
		INCF		FSR,1			;
		GOTO		L_INDF_LOOP		;

;--------			
R_ROTATION						;?4????
		MOVLW		LD			;
		MOVWF		FSR			;
R_INDF_LOOP
		MOVF		INDF,0			;
		MOVWF		GPIO			;
		MOVWF		FSR_TEMP		;
		MOVF		MOTER_PWR,0		;
		MOVWF		MOTER_PWR_TEMP		;
		CALL		M_PWR			;
		MOVF		R_PWR_OFF,0		;
		MOVWF		PWR_OFF_TEMP		;
		CALL		CLRGPIO			;
		MOVF		FSR_TEMP,0		;
		SUBWF		LA,0			;
		BTFSC		STATUS,Z		;
		RETURN
		
		DECF		FSR,1			;
		GOTO		R_INDF_LOOP		;

;--------
DRV1
		MOVLW		B'00010001'		;??????
		MOVWF		LA;			;
		MOVLW		B'00000011'		;??????
		MOVWF		LB			;
		MOVLW		B'00000110'		;??????
		MOVWF		LC			;
		MOVLW		B'00010100'		;??????
		MOVFW		LD			;
		RETURN
		
;--------	
DRV2
		MOVLW		B'00000001'		;??????
		MOVWF		LA;			;
		MOVLW		B'00000010'		;??????
		MOVWF		LB			;
		MOVLW		B'00000100'		;??????
		MOVWF		LC			;
		MOVLW		B'00010000'		;??????
		MOVWF		LD			;
		RETURN


;--------
CLRGPIO	NOP
		CLRF		GPIO			;
		CALL		TIMER1			;
		DECFSZ		PWR_OFF_TEMP,1	;
		GOTO		CLRGPIO			;
		RETURN

M_PWR		;MOVF		MOTER_PWR,0		;D'10' ~ D'30';
		;MOVWF		MOTER_PWR_TEMP
MLOOP1	NOP
		CALL		TIMER1
		DECFSZ		MOTER_PWR_TEMP,1	;
		GOTO		MLOOP1
		RETURN

;--------Timer
;      4Mhz 1????=0.00000025S = 0.00025mS = 0.25?S
;      4Mhz 1????=1?S
TIMER1	MOVLW		D'25'				;D'25' 0.1??? (101Cycles,101.000000uSecs)
		MOVWF		CNT1			;
LOOP1	NOP						;
		DECFSZ		CNT1,1			;
		GOTO		LOOP1			;
		RETURN					;

TIMER2	MOVLW		D'92'				;D'92' -> 10??? (10029Cycles,10.029000mSecs)
		MOVWF		CNT2
LOOP2							;
		CALL		TIMER1			;
		DECFSZ		CNT2,1			;
		GOTO		LOOP2			;
		RETURN					;
		
TIMER3	MOVLW		D'51'				;D'51' -> 0.5? (507196Cycles,507.196000mSecs) 
		MOVWF		CNT3			;
LOOP3	NOP						;
		CALL		TIMER2			;
		DECFSZ		CNT3,1			;
		GOTO		LOOP3			;
		RETURN					;

TIMER4	MOVLW		D'10'				;1D'10' -> 5? (5072041Cycles,5.072041Secs)
		MOVWF		CNT4			;
LOOP4	NOP						;
		CALL		TIMER3			;
		DECFSZ		CNT4,1			;
		GOTO		LOOP4			;
		RETURN					;


;--------
		END					;