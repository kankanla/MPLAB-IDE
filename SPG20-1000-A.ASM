;	2018/3/24
;	SPG20-1362 STEPPING MOTOR
;	�w���]������]���܂��BGPIO5�������Ƃ��ɉ�]���J�E���g����AGPIO5�������Ƃ��Ɉꎞ��~���܂��B
;	PIC12F675 �X�e�b�s���O���[�^��]����
;	GP0,GP1,GP2,GP4 �o�͐ݒ�
;	GP3,GP5 ���͐ݒ�
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
		MOTER_PWR		;�ʓd����
		MOTER_PWR_TEMP	;
		R_PWR_OFF		;R_PWR_OFF	
		L_PWR_OFF		;L_PWR_OFF
		FSR_TEMP		;
		PWR_OFF_TEMP	;
		STEP_CNT		;��]�񐔃J�E���g�p
		STEP_ALL		;��]��
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
		BSF			STATUS,RP0		;BANK1 �I��
		MOVLW		B'00101000'		;GIPO5,3���͒[�q
		MOVWF		TRISIO			;GIPO5,3���͒[�q
		CLRF		ANSEL			;�A�i���O���N���A�A�f�W�^������

		BCF			STATUS,RP0		;BANK0 �I��
		MOVLW		B'00000111'		;��rOFF
		MOVWF		CMCON			;��rOFF
		BCF			INTCON,PEIE		;���ׂĂ̊O�����荞�݂��֎~
		
		CALL		DRV1			;�t���X�e�b�v
		;CALL		DRV2			;�g�`�h���C�u
		
		MOVLW		D'14'			;7-14
		MOVWF		MOTER_PWR		;���[�^1�X�e�b�v�̒ʓd����
		
		MOVLW		D'90'			;4����1, 90x4=360 ���p�̃��[�^�[�̂P��]�X�e�b�v��������4;
		MOVWF		MOTOR_STEP		;
		
		MOVLW		D'2'			;�E��]SPEED,POWER_OFF���Ԃ������Ȃ�ƒx���Ȃ�܂�
		MOVWF		R_PWR_OFF		;
		
		MOVLW		D'2'			;����]SPEED,POWER_OFF���Ԃ������Ȃ�ƒx���Ȃ�܂�
		MOVWF		L_PWR_OFF		;
		
		MOVLW		D'100';			;�ʓd��̉�]��
		MOVWF		STEP_ALL		;
		MOVWF		STEP_CNT		;
		
;--------Main
MAIN								;���C��
		MOVF		STEP_ALL,w		;
		MOVWF		STEP_CNT		;
		CLRF		GPIO			;GPIO�N���A
		BTFSS		GPIO,5			;�X�^�[�g�{�^��
		GOTO		$ - 1			;
START
		CALL 		R				;�E��]
	;	CALL		TIMER3			;�x��
	;	CALL 		L				;����]
	;	CALL		TIMER3			;�x��
		BTFSC		GPIO,5			;�ꎞ��~
		CALL		TEMP_STOP		;
		DECFSZ		STEP_CNT,1		;��]�J�E���g��-1
		GOTO 		START			;0�o�Ȃ����Main��
		GOTO 		MAIN			;0�ɂȂ����ꍇ�͏I��

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
R									;�E�����]
		MOVF		MOTOR_STEP,0	;
		MOVWF		CNTNFA;			;
R_LOOP
		CALL		R_ROTATION		;�E4�X�e�b�v
		DECFSZ		CNTNFA,1		;
		GOTO		R_LOOP			;
		RETURN						;
		
L									;�������]
		MOVF		MOTOR_STEP,0	;
		MOVWF		CNTNFB;			;
L_LOOP
		CALL		L_ROTATION		;��4�X�e�b�v
		DECFSZ		CNTNFB,1		;
		GOTO		L_LOOP			;
		RETURN

;--------
L_ROTATION							;��4�X�e�b�v
		MOVLW		LA				;LA�̃A�h���X��ǂݎ��
		MOVWF		FSR				;FSR�ɃA�h���X�Ə�������
L_INDF_LOOP
		MOVF		INDF,0			;INDF���W�X�^��ǂݎ��
		MOVWF		GPIO			;��]�f�[�^���o��
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
R_ROTATION							;��4�X�e�b�v
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
		MOVLW		B'00010001'		;�t���X�e�b�v
		MOVWF		LA;				;
		MOVLW		B'00000011'		;�t���X�e�b�v
		MOVWF		LB				;
		MOVLW		B'00000110'		;�t���X�e�b�v
		MOVWF		LC				;
		MOVLW		B'00010100'		;�t���X�e�b�v
		MOVWF		LD				;
		RETURN
		
;--------	
DRV2
		MOVLW		B'00000001'		;�g�`�h���C�u
		MOVWF		LA;				;
		MOVLW		B'00000010'		;�g�`�h���C�u
		MOVWF		LB				;
		MOVLW		B'00000100'		;�g�`�h���C�u
		MOVWF		LC				;
		MOVLW		B'00010000'		;�g�`�h���C�u
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
;      4Mhz 1�N���b�N=0.00000025S = 0.00025mS = 0.25��S
;      4Mhz 1�T�C�N��=1��S
TIMER1	MOVLW		D'25'			;D'25' 0.1�~���b (101Cycles,101.000000uSecs)
		MOVWF		CNT1			;
LOOP1	NOP							;
		DECFSZ		CNT1,1			;
		GOTO		LOOP1			;
		RETURN						;

TIMER2	MOVLW		D'92'			;D'92' -> 10�~���b (10029Cycles,10.029000mSecs)
		MOVWF		CNT2
LOOP2							;
		CALL		TIMER1			;
		DECFSZ		CNT2,1			;
		GOTO		LOOP2			;
		RETURN						;
		
TIMER3	MOVLW		D'51'			;D'51' -> 0.5�b (507196Cycles,507.196000mSecs) 
		MOVWF		CNT3			;
LOOP3	NOP							;
		CALL		TIMER2			;
		DECFSZ		CNT3,1			;
		GOTO		LOOP3			;
		RETURN						;

TIMER4	MOVLW		D'10'			;1D'10' -> 5�b (5072041Cycles,5.072041Secs)
		MOVWF		CNT4			;
LOOP4	NOP							;
		CALL		TIMER3			;
		DECFSZ		CNT4,1			;
		GOTO		LOOP4			;
		RETURN						;


;--------
		END							;