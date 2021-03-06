;----
;Amazon 購入したサーボーの動作プログラム
;Miuzei サーボモーター マイクロサーボ 9g 10個セット デジタル・サーボ (10個セット)
;newServo	ver2019/12/22  ver2020/03/30
;GPIO5		InputPIN  HIGTH (LM393 IR赤外線障害物回避センサモジュール)
;GPIO4		Servo パルス出力
;GPIO 0,1	;+ -,1  パルス調整
;GPIO 2		;GPIO 0,1 設定したパルス(角度)をEEPROMに保存する。
;GPIO 3		;EEPROM保存したパルス(角度)を実行


		LIST		P=12F675
		INCLUDE		P12F675.INC

;---
		CB			=	_CPD_OFF
		CB			&=	_CP_OFF
		CB			&=	_BODEN_ON
		CB			&=	_MCLRE_OFF
		CB			&=	_PWRTE_ON
		CB			&=	_WDT_OFF
		CB			&=	_INTRC_OSC_NOCLKOUT
		__CONFIG	CB

;---
		CBLOCK		H'20'
		CNT1						;タイマカウンター
		CNT2						;
		CNT3						;
		CNT4						;
		BASE_TMR0					;パルスサイクル基本タイマー定数 D'174'
		HIGH_PULSE					;パルス
		HIGH_PULSE_CNT					;パルスGPIOHIGHカウンター定数
		HIGH_PULSE_MAX					;最大パルス定数(サーボーの最大値)D'248'
		HIGH_PULSE_MIN					;最小パルス定数(サーボーの最小値)D'55'
		HIGH_PULSE_MAX_SET				;設定最大パルス
		HIGH_PULSE_MIN_SET				;設定最初パルス
		HIGH_PULSE_MAX_EEPROM				;EEPROM最大パルス読み取り後保存先
		HIGH_PULSE_MIN_EEPROM				;EEPROM最小パルス読み取り後保存先
		HIGH_PULSE_SPEED				;パルス設定時のサーボーの回転速度定数 D'40'
		HIGH_PULSE_SPEED_CNT				;パルス設定時のサーボーの回転速度のカウンター
		H04_WTEMP					;割り込み W 一時保存先
		KEY_CHK_CNT					;GPIO High のカウント定数 D'240'
		KEY_CHK_CNT_CNT					;GPIO High カウンター
		EEPROM_ADDR					;EEPROM書き込みアドレス
		EEPROM_DATA					;EEPROM書き込み、読み込みデータ
		ENDC

;---
		org	0x2110;
		de "12F629.BLOGSPOT.COM"
		ORG		0
		GOTO		INIT
		ORG		4
		GOTO		H04
;---
H04								;割り込み
		MOVWF		H04_WTEMP			;W 一時的に保存
		BCF		INTCON,GIE			;すべての割り込み禁止
		BTFSC		INTCON,T0IF			;タイマー割り込み 1 の場合
		GOTO		H04_T0IE			;タイマー割り込み 1 の場合 GOTO 
		BTFSC		INTCON,INTF			;GPIO2の外部割り込み 1 の場合
		GOTO		H04_INTE			;GPIO2の外部割り込み 1 の場合 GOTO 
		GOTO		H04_RETFIE			;割り込み終了
		
H04_INTE	;GP2/INT					;未使用
		BCF		INTCON,INTF
		GOTO		H04_RETFIE

H04_T0IE	;Timer0
		MOVF		BASE_TMR0,w
		MOVWF		TMR0
		BSF		GPIO,4				;GPIO4 =1
		BCF		INTCON,T0IF
		MOVF		HIGH_PULSE,w
		MOVWF		HIGH_PULSE_CNT
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		DECFSZ		HIGH_PULSE_CNT,f
		GOTO		$-7
		BCF		GPIO,4				;GPIO4 =0
		GOTO		H04_RETFIE

H04_RETFIE
		BCF		INTCON,T0IF
		BCF		INTCON,INTF
		BSF		INTCON,GIE
		MOVF		H04_WTEMP,w
		RETFIE

;---
INIT
		BSF		STATUS,RP0
		CALL		H'3FF'
		MOVWF		OSCCAL
		CLRF		ANSEL
		MOVLW		B'00101111'
		MOVWF		TRISIO

		BCF		OPTION_REG,T0CS
		BCF		OPTION_REG,PSA
		BSF		OPTION_REG,PS2
		BSF		OPTION_REG,PS1
		BSF		OPTION_REG,PS0

		BCF		STATUS,RP0
		MOVLW		B'00000111'
		MOVWF		CMCON
		CALL		TIMER2

;		BaseTimer 20000uS D'174'=21005, D'177'=20237
		MOVLW		D'174'			;174
		MOVWF		BASE_TMR0;
		MOVWF		TMR0;

		MOVLW		D'240'
		MOVWF		KEY_CHK_CNT
		
;		MOVL		D'55'		498uS
;		MOVL		D'100'		903uS
;		MOVL		D'167'		1506uS  167
;		MOVL		D'233'		2100uS  
		MOVLW		D'248'
		MOVWF		HIGH_PULSE
		MOVLW		D'55'
		MOVWF		HIGH_PULSE_MIN
		MOVWF		HIGH_PULSE_MIN_SET
		MOVLW		D'248'
		MOVWF		HIGH_PULSE_MAX
		MOVWF		HIGH_PULSE_MAX_SET
		MOVLW		D'40'
		MOVWF		HIGH_PULSE_SPEED
		
		BCF		INTCON,INTE
		BSF		INTCON,T0IE
		BCF		INTCON,T0IF	
		BSF		INTCON,GIE
		CLRF		GPIO;

;---
MAIN
		NOP
MAIN_LOOP
		BTFSC		GPIO,0
		CALL		KEY_CHK_P0
		BTFSC		GPIO,1
		CALL		KEY_CHK_P1
		BTFSC		GPIO,2
		CALL		SERVO_SAVE
		BTFSC		GPIO,3				;実行信号
		CALL		SERVO_ONESTEP_EEPROM
		BTFSS		GPIO,5				;実行信号
		CALL		SERVO_ONESTEP_EEPROM
		GOTO		MAIN_LOOP

KEY_CHK_P0							;GPIO,0
		MOVF		KEY_CHK_CNT,w
		MOVWF		KEY_CHK_CNT_CNT
		BTFSS		GPIO,0
		RETURN
		DECFSZ		KEY_CHK_CNT_CNT,f
		GOTO		$-3;
		
		CALL		SET_HIGH_PULSE_SPEED		;間隔時間(スピート)
		INCF		HIGH_PULSE,f			;+1
		MOVF		HIGH_PULSE_MAX,w
		SUBWF		HIGH_PULSE,w			;HIGH_PULSE - HIGH_PULSE_MAX 大小比較 > 0  C=1
		BTFSS		STATUS,C			;BTFSS STATUS,C
		GOTO		$+3				;C=0
		MOVF		HIGH_PULSE_MAX,w		;C=1
		MOVWF		HIGH_PULSE
		MOVF		HIGH_PULSE,w
		MOVWF		HIGH_PULSE_MAX_SET
		RETURN
		
KEY_CHK_P1							;GPIO,1
		MOVF		KEY_CHK_CNT,w
		MOVWF		KEY_CHK_CNT_CNT
		BTFSS		GPIO,1
		RETURN
		DECFSZ		KEY_CHK_CNT_CNT,f
		GOTO		$-3;

		CALL		SET_HIGH_PULSE_SPEED		;間隔時間(スピート)
		DECF		HIGH_PULSE,f			;-1
		MOVF		HIGH_PULSE_MIN,w
		SUBWF		HIGH_PULSE,w			;HIGH_PULSE - HIGH_PULSE_MIN 大小比較 < 0 負 C=0
		BTFSC		STATUS,C			;BTFSC STATUS,C
		GOTO		$+3				;C=1
		MOVF		HIGH_PULSE_MIN,w		;C=0
		MOVWF		HIGH_PULSE
		MOVF		HIGH_PULSE,w
		MOVWF		HIGH_PULSE_MIN_SET
		RETURN

MAIN_END
		GOTO		PEND
		
;---
;		EEPROM_ADDR					;
;		EEPROM_DATA					;
EEPROM								;EEPROM ファンクション
EEPROM_WREN							;EEPROM 書き込み
		BCF		INTCON,GIE
		BSF		STATUS,RP0			;バンク1に切り替え
		MOVF		EEPROM_ADDR,w
		MOVWF		EEADR
		MOVF		EEPROM_DATA,w			;書き込みデータ
		MOVWF		EEDATA
		BSF		EECON1,WREN			;書き込み許可
		MOVLW		0X55				;書き込み手順
		MOVWF		EECON2
		MOVLW		0XAA
		MOVWF		EECON2
		BSF		EECON1,WR			;書き込み;書き込み完了のチェック
		BTFSC		EECON1,WR
		GOTO		$-1
		BCF		STATUS,RP0			;書き込み完了後、バイク0に戻る
		BSF		INTCON,GIE
		RETURN

EEPROM_DR							;EEPROM 読み込み
		BCF		INTCON,GIE
		BSF		STATUS,RP0
		MOVF		EEPROM_ADDR,w
		MOVWF		EEADR
		BSF		EECON1,RD
		MOVF		EEDATA,w
		MOVWF		EEPROM_DATA	
		BCF		STATUS,RP0
		BSF		INTCON,GIE
		RETURN
		
;---
;SERVO_SAVE
;		HIGH_PULSE_MAX_EEPROM	;			H'01'
;		HIGH_PULSE_MIN_EEPROM	;			H'00'
SERVO_SAVE
		MOVF		HIGH_PULSE_MIN_SET,w	
		MOVWF		EEPROM_DATA
		MOVLW		H'00'
		MOVWF		EEPROM_ADDR
		CALL		EEPROM
		
		MOVF		HIGH_PULSE_MAX_SET,w
		MOVWF		EEPROM_DATA
		MOVLW		H'01'
		MOVWF		EEPROM_ADDR
		CALL		EEPROM
		CALL		SERVO_ONESTEP_EEPROM_CHK
		RETURN
		
;---
SERVO_ONESTEP_EEPROM						;
		MOVF		KEY_CHK_CNT,w			;キーカウントチェック、ノイズの対処方法
		MOVWF		KEY_CHK_CNT_CNT
		BTFSS		GPIO,3
		BTFSC		GPIO,5
		RETURN
		DECFSZ		KEY_CHK_CNT_CNT,f
		GOTO		$-4;
SERVO_ONESTEP_EEPROM_CHK					;パルス保存後に一回実行する
		MOVLW		H'00'				;MINI_EEPROM
		MOVWF		EEPROM_ADDR			;EEPROM読み取りアドレス
		CALL		EEPROM_DR			;EEPROM読み取りファンクションへ
		MOVF		EEPROM_DATA,w			;EEPROM読み取り後のデータ
		MOVWF		HIGH_PULSE_MIN_EEPROM		;
		
		MOVLW		H'01'				;MAX_EEPROM
		MOVWF		EEPROM_ADDR
		CALL		EEPROM_DR
		MOVF		EEPROM_DATA,w
		MOVWF		HIGH_PULSE_MAX_EEPROM
		
		MOVF		HIGH_PULSE_MIN_EEPROM,w		;
		MOVWF		HIGH_PULSE			;
		CALL		TIMER3
		MOVF		HIGH_PULSE_MAX_EEPROM,w		;
		MOVWF		HIGH_PULSE			;
		CALL		TIMER3
		RETURN
		
;---
SERVO_ONESTEP_RUN						;未使用
		GOTO		$+8
		MOVF		KEY_CHK_CNT,w
		MOVWF		KEY_CHK_CNT_CNT
		BTFSS		GPIO,3
		BTFSC		GPIO,5
		RETURN
		DECFSZ		KEY_CHK_CNT_CNT,f
		GOTO		$-4;

		MOVF		HIGH_PULSE_MIN,w
		MOVWF		HIGH_PULSE
		CALL		TIMER3
		MOVF		HIGH_PULSE_MAX,w
		MOVWF		HIGH_PULSE
		CALL		TIMER3
		RETURN

;---
SERVO_TEST							;未使用
		MOVF		HIGH_PULSE_MAX,w
		MOVWF		HIGH_PULSE
		CALL		TIMER3
		MOVF		HIGH_PULSE_MIN,w
		MOVWF		HIGH_PULSE
		CALL		TIMER3
		MOVLW		D'167'
		MOVWF		HIGH_PULSE
		CALL		TIMER3
		RETURN

;---
SET_HIGH_PULSE_SPEED						;間隔(スピート)
		MOVF		HIGH_PULSE_SPEED,w
		MOVWF		HIGH_PULSE_SPEED_CNT		
		CALL		TIMER1
		DECFSZ		HIGH_PULSE_SPEED_CNT,f
		GOTO		$-2
		RETURN

;---								;一般用タイマー
TIMER1
		MOVLW		D'25'
		MOVWF		CNT1
		NOP
		DECFSZ		CNT1,f
		GOTO		$-2
		RETURN

TIMER2
		MOVLW		D'100'
		MOVWF		CNT2
		NOP
		CALL		TIMER1
		DECFSZ		CNT2,f
		GOTO		$-3
		RETURN

TIMER3
		MOVLW		D'50'		;0.5s
		MOVWF		CNT3
		NOP
		CALL		TIMER2
		DECFSZ		CNT3,f
		GOTO		$-3
		RETURN

TIMER4
		MOVLW		D'10'		;10s
		MOVWF		CNT4
		NOP
		CALL		TIMER3
		DECFSZ		CNT4,f
		GOTO		$-3
		RETURN	

;---
PEND
		END