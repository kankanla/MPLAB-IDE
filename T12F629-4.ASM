;	2018/03/10
;	�O���N���b�N�ɂ��t�@���̉�]���x��ύX����v���O����
;	GPIO0�C1�C2 �o��		
;	GPIO3,4,����		B'00011000'
;	GPIO5,�O��RC�N���b�N
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
		STEP_ALL		;ALL_STEP
		STEP_ON			;STEP_ON
		STEP_OFF		;		
		STEP_ON_CONT	;
		STEP_OFF_CONT	;
		KHZ25			;
		H04W_TEMP		;
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
		MOVF		STEP_ON,w		;���݂�ON�l��ǂݎ��
		SUBWF		STEP_ALL,w		;�S�̂̃X�e�b�v�����Z���܂��B
		BTFSC		STATUS,Z		;���ʂ�0�̏ꍇ�AON==ALL�̏ꍇ
		CLRF		STEP_ON			;ON���N���A����
		MOVF		STEP_ON,w		;
		BTFSC		STATUS,Z		;
		SLEEP
		INCF		STEP_ON,f		;ON��+1	
		
		
		MOVF		STEP_ON,w		;
		SUBWF		STEP_ALL,w		;
		MOVWF		STEP_OFF		;

			
		MOVF		STEP_ON,w		;
		MOVWF		STEP_ON_CONT	;
		MOVF		STEP_OFF,w		;
		MOVWF		STEP_OFF_CONT	;
		
		BSF			INTCON,GIE		;
		MOVF		H04W_TEMP,w		;		
		

		;-----------------------
		RETFIE		;
		
		
;----------
INIT
		BSF			STATUS,RP0		;BANK1 �I��
		CALL		H'3FF'			;
		MOVWF		OSCCAL			;
		MOVLW		B'00011100'		;GIPO4,3���͒[�q
		MOVWF		TRISIO			;
		CLRF		ANSEL			;�A�i���O���N���A�A�f�W�^������
		BCF			OPTION_REG,1	;
		
		BCF			STATUS,RP0		;BANK0 �I��
		MOVLW		B'00000111'		;��rOFF
		MOVWF		CMCON			;��rOFF
		BSF			INTCON,GIE		;PEIE�F�O?���f�g�\��
		BSF			INTCON,INTE		;INTE�FGP2/INT �O�����f�g�\��

		
		MOVLW		D'10'			;
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
		DECFSZ		STEP_ON_CONT	;
		GOTO		T1_ON			;
		BCF			GPIO,0			;	
		MOVF		STEP_ON,w		;
		MOVWF		STEP_ON_CONT	;
		GOTO		T1_OFF			;
	
T1_OFF
		DECFSZ		STEP_OFF_CONT	;
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
	
		MOVF		STEP_ON,w		;���݂�ON�l��ǂݎ��
		SUBWF		STEP_ALL,w		;�S�̂̃X�e�b�v�����Z���܂��B
		BTFSC		STATUS,Z		;���ʂ�0�̏ꍇ�AON==ALL�̏ꍇ
		CLRF		STEP_ON			;ON���N���A����
		INCF		STEP_ON,f		;ON��+1
		
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
		MOVLW		B'00000000'		;���ׂĂ̏o�̓{�[�h���N���A
		MOVWF		GPIO			;���ׂĂ̏o�̓{�[�h���N���A
		GOTO		EEND			;

;--------25Khz
;4Mhz 1C = 0.25us
;1c = 1us
;25kHz  1s/25000= 0.00004s = 0.04ms = 40us

KHZ25_T	MOVLW		D'19'			;D'25' 0.1�~���b
		MOVWF		KHZ25
KHZ25_LOOP
		DECFSZ		KHZ25,1
		GOTO		KHZ25_LOOP
		RETURN


;--------Timer
TIMER1	MOVLW		D'25'			;D'25' 0.1�~���b
		MOVWF		CNT1
LOOP1	NOP
		DECFSZ		CNT1,1
		GOTO		LOOP1
		RETURN

TIMER2	MOVLW		D'100'			;D'100' -> 10�~���b D'50' -> 5�~���b
		MOVWF		CNT2
LOOP2	NOP
		CALL		TIMER1
		DECFSZ		CNT2,1
		GOTO		LOOP2
		RETURN
		
TIMER3	MOVLW		D'50'			;1/2�b
		MOVWF		CNT3
LOOP3	NOP
		CALL		TIMER2
		DECFSZ		CNT3,1
		GOTO		LOOP3
		RETURN

TIMER4	MOVLW		D'10'			;10�b
		MOVWF		CNT4
LOOP4	NOP
		CALL		TIMER3
		DECFSZ		CNT4,1
		GOTO		LOOP4
		RETURN

;--------
		END							;