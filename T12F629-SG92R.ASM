;	2018/04/21
;	PIC12F675 Timer0
;	RoHS
;	マイクロサーボ　SG92R
;	[SG92R]
;	通販コード　M-08914
;	発売日　2015/01/20
;	メーカーカテゴリ　Tower Pro Pte Ltd
;	ＴｏｗｅｒＰｒｏのサーボです。
;
;	◆主な仕様
;		ＰＷＭサイクル：２０ｍＳ
;		制御パルス：０．５ｍｓ〜２．４ｍｓ
;		制御角：±約９０°（１８０°）
;		配線：茶＝ＧＮＤ、赤＝電源［＋］、橙＝制御信号　［ＪＲタイプ］
;		トルク：２．５ｋｇｆ・ｃｍ
;		動作速度：０．１秒／６０度
;		動作電圧：４．８Ｖ

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
		INT_FLAG					;割り込みプラク Timer0、GP2/INT 外部中断
		STEP_TEMP					;
		
		H04W_TEMP					;
		CNT1						;TIME
		CNT2						;TIME
		CNT3						;TIME
		CNT4						;TIME
		CNT5						;TIME
		ENDC						;

;----------
		ORG			0				;
		GOTO		INIT			;
		
		ORG			4				;
		GOTO		H04				;
		
;----------
H04		
		MOVWF		H04W_TEMP		;
		BCF			INTCON,GIE		;0 = 禁止所有中断

									;`判斷中斷類型
		BTFSC		INTCON,T0IF		;1 = TMR0 寄存器已?溢出 （必?用?件清零）
		GOTO		H04_TIMER		;

		BTFSC		INTCON,INTF		;1 = ?生 GP2/INT 外部中断 （必?用?件清零）
		GOTO		H04_GPIO2		;
		GOTO		H04_END			;

H04_TIMER							;
		BCF			INTCON,T0IE		;0 = 禁止 TMR0 溢出中断
		BSF			GPIO,0			;
		MOVLW		D'176'			; 20000us
		MOVWF		TMR0			;
		BCF			INTCON,T0IF		;TMR0 クリア
		BCF			INT_FLAG,0		;TIMERフラグ クリア
		BSF			INTCON,T0IE		;0 = 禁止 TMR0 溢出中断
		BCF			GPIO,0			;
		BSF			INTCON,T0IE		;1 = 使能 TMR0 溢出中断
		GOTO		H04_END			;

H04_GPIO2							;
		BCF			INTCON,INTE		;0 = 禁止 GP2/INT 外部中断
		BCF			INTCON,INTF		;1 = ?生 GP2/INT 外部中断 （必?用?件清零）
		BCF			INT_FLAG,1		;
		BSF			INTCON,INTE		;1 = 使能 GP2/INT 外部中断	
		GOTO		H04_END			;

H04_END
		BSF			INTCON,INTE		;1 = 使能 GP2/INT 外部中断
		BSF			INTCON,T0IE		;1 = 使能 TMR0 溢出中断
		BSF			INTCON,PEIE		;1 = 使能所有未屏蔽的外?中断
		BSF			INTCON,GIE		;1 = 使能所有未屏蔽的中断
		MOVF		H04W_TEMP,w		;
		RETFIE						;
			
;----------
INIT
		BSF			STATUS,RP0		;BANK1 選択
		CALL		H'3FF'			;校准内部振?器
		MOVWF		OSCCAL			;校准内部振?器
		MOVLW		B'00000100'		;入力端子
		MOVWF		TRISIO			;校准内部振?器
		CLRF		ANSEL			;数字 I/O

		BCF			OPTION_REG,T0CS		;0 = ??内部指令周期?? （CLKOUT）
		BCF			OPTION_REG,PSA		;0 = 将?分?器分配? TIMER0 模?
		BSF			OPTION_REG,INTEDG	;1 = GP2/INT 引脚上?平的上升沿触?中断

		BSF			OPTION_REG,PS2		;PS2:PS0：?分?器的分?比??位	
		BSF			OPTION_REG,PS1		;PS2:PS0：?分?器的分?比??位
		BSF			OPTION_REG,PS0		;PS2:PS0：?分?器的分?比??位
							;000		1 : 2
							;001		1 : 4 
							;010		1 : 8
							;011		1 : 16
							;100		1 : 32
							;101		1 : 64
							;110		1 : 128
							;111		1 : 256

		BCF			STATUS,RP0		;BANK0 選択
		MOVLW		B'00000111'		;比較OFF
		MOVWF		CMCON			;比較OFF

		BSF			INTCON,GIE		;1 = 使能所有未屏蔽的中断
		BSF			INTCON,PEIE		;1 = 使能所有未屏蔽的外?中断
		BSF			INTCON,INTE		;1 = 使能 GP2/INT 外部中断
		;BSF			INTCON,T0IE		;1 = 使能 TMR0 溢出中断

		MOVLW		D'176'			; 20000us
		MOVWF		TMR0			;


;・ＰＷＭサイクル：２０ｍＳ
; 20MS = 20000us = 1us * 20000; 4000
;・制御パルス：０．５ｍｓ〜２．４ｍｓ
; 0.5ms = 500us
; 2.4ms = 2400us

;--------Main
MAIN	
		CALL		ONE_STEP		;
		CALL		TIMER4			;
		BSF			INT_FLAG,1		;

DAKI
		BTFSC		INT_FLAG,1		;
		GOTO		$ - 1			;
		CALL		ONE_STEP		;
		BSF			INT_FLAG,1		;
		CALL		TIMER2			;
		GOTO		DAKI			;



;-----------------SG92R----------------------
ONE_STEP
		BSF			INTCON,T0IE		;1 = 使能 TMR0 溢出中断
		MOVLW		D'22'			;
		MOVWF		STEP_TEMP		;PWM發生長度
ONE1
		BSF			GPIO,1			;
		CALL		TIMER1			;
		CALL		TIMER1			;
		CALL		TIMER1			;
		CALL		TIMER1			;
		CALL		TIMER1			;
		BCF			GPIO,1			;
		BSF			INT_FLAG,0		;設置TimerFLAG為1 
		BTFSC		INT_FLAG,0		;等待Tiemr中斷?生後TimerFLAG變為0
		GOTO		$ - 1			;
		DECFSZ		STEP_TEMP,f		;・PWM發生長度
		GOTO		ONE1			;

		MOVLW		D'22'			;
		MOVWF		STEP_TEMP		;
ONE2
		BSF			GPIO,1			;
		CALL		T5				;
		CALL		T5				;
		CALL		T5				;
		CALL		T5				;
		CALL		TIMER1			;
		CALL		TIMER1			;
		CALL		TIMER1			;
		CALL		TIMER1			;

		BCF			GPIO,1			;
		BSF			INT_FLAG,0	;
		BTFSC		INT_FLAG,0	;
		GOTO		$ - 1			;
		DECFSZ		STEP_TEMP,f		;
		GOTO		ONE2			;

		BCF			INTCON,T0IE		;0 = 禁止 TMR0 溢出中断
		RETURN						;

;--------end
EEND
		MOVLW		B'00000000'		;すべての出力ボードをクリア
		MOVWF		GPIO			;すべての出力ボードをクリア
		SLEEP
		GOTO		EEND			;


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
