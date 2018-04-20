;	2018/04/20
;	PIC12F675 Timer0

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
		H04W_TEMP		;
		CNT1			;TIME
		CNT2			;TIME
		CNT3			;TIME
		CNT4			;TIME
		ENDC			;

;----------
		ORG		0			;
		GOTO		INIT			;
		
		ORG		4			;
		GOTO		H04			;
		
;----------
H04		
		MOVLW		D'230'			;TMR0?初?
		MOVWF		TMR0			;TMR0?初?
		MOVWF		H04W_TEMP		;
		BCF		INTCON,GIE		;0 = 禁止所有中断
		;BCF		INTCON,INTF		;0 = 禁止 GP2/INT 外部中断
		;BCF		INTCON,T0IE		;0 = 禁止 TMR0 溢出中断
		BCF		INTCON,T0IF		;1 = TMR0 寄存器已?溢出清零 （必?用?件清零）

		BSF		GPIO,0			;
		NOP
		BCF		GPIO,0			;

		BSF		INTCON,GIE		;1 = 使能所有未屏蔽的中断
		MOVF		H04W_TEMP,w		;
		RETFIE					;
	
		
;----------
INIT
		BSF		STATUS,RP0		;BANK1 選択
		CALL		H'3FF'			;校准内部振?器
		MOVWF		OSCCAL			;校准内部振?器
		MOVLW		B'00011100'		;GIPO4,3入力端子
		MOVWF		TRISIO			;校准内部振?器
		CLRF		ANSEL			;数字 I/O
		BCF		OPTION_REG,T0CS		;TMR0 ??源??位
		BCF		OPTION_REG,PSA		;0 = 将?分?器分配? TIMER0 模?
		BCF		OPTION_REG,T0SE		;1 = GP2/T0CKI 引脚的下降沿?增

		BCF		OPTION_REG,PS2		;PS2:PS0：?分?器的分?比??位	
		BCF		OPTION_REG,PS1		;PS2:PS0：?分?器的分?比??位
		BCF		OPTION_REG,PS0		;PS2:PS0：?分?器的分?比??位
							;000		1 : 2
							;001		1 : 4
							;010		1 : 8
							;011		1 : 16
							;100		1 : 32
							;101		1 : 64
							;110		1 : 128
							;111		1 : 256

		BCF		STATUS,RP0		;BANK0 選択
		MOVLW		B'00000111'		;比較OFF
		MOVWF		CMCON			;比較OFF
		BSF		INTCON,GIE		;1 = 使能所有未屏蔽的中断
		BSF		INTCON,INTE		;1 = 使能 GP2/INT 外部中断
		BSF		INTCON,T0IE		;1 = 使能 TMR0 溢出中断


		MOVLW		D'230'			;TMR0?初?
		MOVWF		TMR0			;TMR0?初?

;--------Main
MAIN	NOP
		GOTO		MAIN			;
		
;--------end
EEND
		MOVLW		B'00000000'		;すべての出力ボードをクリア
		MOVWF		GPIO			;すべての出力ボードをクリア
		GOTO		EEND			;


;--------Timer
; 4MHZ 内部クロック
; 25KHz 作成
; 25KHz = 40us
; 4Mhz/4  = 1us 
; 25KHｚ T = 40 サイクル				

TIMER1		MOVLW		D'25'			;D'25' 0.1ミリ秒
		MOVWF		CNT1			;
LOOP1		NOP					;
		DECFSZ		CNT1,1			;
		GOTO		LOOP1			;
		RETURN					;

TIMER2		MOVLW		D'100'			;D'100' -> 10ミリ秒 D'50' -> 5ミリ秒
		MOVWF		CNT2
LOOP2		NOP					;
		CALL		TIMER1			;
		DECFSZ		CNT2,1			;
		GOTO		LOOP2			;
		RETURN					;
		
TIMER3		MOVLW		D'50'			;1/2秒
		MOVWF		CNT3			;
LOOP3		NOP					;
		CALL		TIMER2			;
		DECFSZ		CNT3,1			;
		GOTO		LOOP3			;
		RETURN					;

TIMER4		MOVLW		D'10'			;10秒
		MOVWF		CNT4			;
LOOP4		NOP					;
		CALL		TIMER3			;
		DECFSZ		CNT4,1			;
		GOTO		LOOP4			;
		RETURN					;

;--------
E_END							;
		END					;
