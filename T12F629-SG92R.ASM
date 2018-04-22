;	2018/04/21
;	PIC12F675 Timer0
;	RoHS
;	�}�C�N���T�[�{�@SG92R
;	[SG92R]
;	�ʔ̃R�[�h�@M-08914
;	�������@2015/01/20
;	���[�J�[�J�e�S���@Tower Pro Pte Ltd
;	�s���������o�����̃T�[�{�ł��B
;
;	����Ȏd�l
;		�o�v�l�T�C�N���F�Q�O���r
;		����p���X�F�O�D�T�����`�Q�D�S����
;		����p�F�}��X�O���i�P�W�O���j
;		�z���F�����f�m�c�A�ԁ��d���m�{�n�A�򁁐���M���@�m�i�q�^�C�v�n
;		�g���N�F�Q�D�T�������E����
;		���쑬�x�F�O�D�P�b�^�U�O�x
;		����d���F�S�D�W�u

;---------
		LIST		P=12F675
		INCLUDE		P12F675.INC
;---------
;	CONFIG 		�ݒ�
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
		INT_FLAG					;���荞�݃v���N Timer0�AGP2/INT �O�����f
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
		BCF			INTCON,GIE		;0 = �֎~���L���f

									;`���В��Зތ^
		BTFSC		INTCON,T0IF		;1 = TMR0 �񑶊��?��o �i�K?�p?������j
		GOTO		H04_TIMER		;

		BTFSC		INTCON,INTF		;1 = ?�� GP2/INT �O�����f �i�K?�p?������j
		GOTO		H04_GPIO2		;
		GOTO		H04_END			;

H04_TIMER							;
		BCF			INTCON,T0IE		;0 = �֎~ TMR0 ��o���f
		BSF			GPIO,0			;
		MOVLW		D'176'			; 20000us
		MOVWF		TMR0			;
		BCF			INTCON,T0IF		;TMR0 �N���A
		BCF			INT_FLAG,0		;TIMER�t���O �N���A
		BSF			INTCON,T0IE		;0 = �֎~ TMR0 ��o���f
		BCF			GPIO,0			;
		BSF			INTCON,T0IE		;1 = �g�\ TMR0 ��o���f
		GOTO		H04_END			;

H04_GPIO2							;
		BCF			INTCON,INTE		;0 = �֎~ GP2/INT �O�����f
		BCF			INTCON,INTF		;1 = ?�� GP2/INT �O�����f �i�K?�p?������j
		BCF			INT_FLAG,1		;
		BSF			INTCON,INTE		;1 = �g�\ GP2/INT �O�����f	
		GOTO		H04_END			;

H04_END
		BSF			INTCON,INTE		;1 = �g�\ GP2/INT �O�����f
		BSF			INTCON,T0IE		;1 = �g�\ TMR0 ��o���f
		BSF			INTCON,PEIE		;1 = �g�\���L�������I�O?���f
		BSF			INTCON,GIE		;1 = �g�\���L�������I���f
		MOVF		H04W_TEMP,w		;
		RETFIE						;
			
;----------
INIT
		BSF			STATUS,RP0		;BANK1 �I��
		CALL		H'3FF'			;�Z�y�����U?��
		MOVWF		OSCCAL			;�Z�y�����U?��
		MOVLW		B'00000100'		;���͒[�q
		MOVWF		TRISIO			;�Z�y�����U?��
		CLRF		ANSEL			;���� I/O

		BCF			OPTION_REG,T0CS		;0 = ??�����w�ߎ���?? �iCLKOUT�j
		BCF			OPTION_REG,PSA		;0 = ��?��?�핪�z? TIMER0 ��?
		BSF			OPTION_REG,INTEDG	;1 = GP2/INT ���r��?���I�㏡���G?���f

		BSF			OPTION_REG,PS2		;PS2:PS0�F?��?��I��?��??��	
		BSF			OPTION_REG,PS1		;PS2:PS0�F?��?��I��?��??��
		BSF			OPTION_REG,PS0		;PS2:PS0�F?��?��I��?��??��
							;000		1 : 2
							;001		1 : 4 
							;010		1 : 8
							;011		1 : 16
							;100		1 : 32
							;101		1 : 64
							;110		1 : 128
							;111		1 : 256

		BCF			STATUS,RP0		;BANK0 �I��
		MOVLW		B'00000111'		;��rOFF
		MOVWF		CMCON			;��rOFF

		BSF			INTCON,GIE		;1 = �g�\���L�������I���f
		BSF			INTCON,PEIE		;1 = �g�\���L�������I�O?���f
		BSF			INTCON,INTE		;1 = �g�\ GP2/INT �O�����f
		;BSF			INTCON,T0IE		;1 = �g�\ TMR0 ��o���f

		MOVLW		D'176'			; 20000us
		MOVWF		TMR0			;


;�E�o�v�l�T�C�N���F�Q�O���r
; 20MS = 20000us = 1us * 20000; 4000
;�E����p���X�F�O�D�T�����`�Q�D�S����
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
		BSF			INTCON,T0IE		;1 = �g�\ TMR0 ��o���f
		MOVLW		D'22'			;
		MOVWF		STEP_TEMP		;PWMᢐ����x
ONE1
		BSF			GPIO,1			;
		CALL		TIMER1			;
		CALL		TIMER1			;
		CALL		TIMER1			;
		CALL		TIMER1			;
		CALL		TIMER1			;
		BCF			GPIO,1			;
		BSF			INT_FLAG,0		;�ݒuTimerFLAG��1 
		BTFSC		INT_FLAG,0		;����Tiemr����?����TimerFLAG�̈�0
		GOTO		$ - 1			;
		DECFSZ		STEP_TEMP,f		;�EPWMᢐ����x
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

		BCF			INTCON,T0IE		;0 = �֎~ TMR0 ��o���f
		RETURN						;

;--------end
EEND
		MOVLW		B'00000000'		;���ׂĂ̏o�̓{�[�h���N���A
		MOVWF		GPIO			;���ׂĂ̏o�̓{�[�h���N���A
		SLEEP
		GOTO		EEND			;


;--------Timer
; 4MHZ �����N���b�N
; 25KHz �쐬
; 25KHz = 40us
; 4Mhz/4  = 1us 
; 25KH�� T = 40 �T�C�N��				

TIMER1		MOVLW		D'25'			;D'25' 0.1�~���b
			MOVWF		CNT1			;
LOOP1		NOP							;
			DECFSZ		CNT1,1			;
			GOTO		LOOP1			;
			RETURN						;

T5			MOVLW		D'4'			;D'5' -> 0.5�~���b
			MOVWF		CNT5
LOOPT5		NOP							;
			CALL		TIMER1			;
			DECFSZ		CNT5,1			;
			GOTO		LOOPT5			;
			RETURN						;


TIMER2		MOVLW		D'100'			;D'100' -> 10�~���b D'50' -> 5�~���b
			MOVWF		CNT2
LOOP2		NOP							;
			CALL		TIMER1			;
			DECFSZ		CNT2,1			;
			GOTO		LOOP2			;
			RETURN						;
		
TIMER3		MOVLW		D'50'			;1/2�b
			MOVWF		CNT3			;
LOOP3		NOP							;
			CALL		TIMER2			;
			DECFSZ		CNT3,1			;
			GOTO		LOOP3			;
			RETURN						;

TIMER4		MOVLW		D'10'			;10�b
			MOVWF		CNT4			;
LOOP4		NOP							;
			CALL		TIMER3			;
			DECFSZ		CNT4,1			;
			GOTO		LOOP4			;
			RETURN						;

;--------
E_END									;
			END							;