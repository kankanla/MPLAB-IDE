;	
;	2018/03/21 Coilgun railgun
;	�R�C���K���i�p: Coilgun�j�͓d���΂̃R�C�����g���Ēe�ۂƂȂ镨�̂������E���˂��鑕�u�ł���B
;	GPIO,0�C1�C2,4 �o��		
;	GPIO 3�A5���� 5�X�C�b�`,3���g�p
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
		H04_TEMP		;
		CNT1			;TIME
		CNT2			;TIME
		CNT3			;TIME
		CNT4			;TIME
		ENDC			;

;----------
		ORG			0				;
		GOTO		INIT			;
		
		ORG			4				;
		GOTO		H04				;
		
;----------
H04		
		MOVWF		H04_TEMP		;
		MOVF		H04_TEMP,w		;
		RETFIE						;
		
;----------
INIT
		BSF			STATUS,RP0		;BANK1 �I��
		CALL		H'3FF'			;
		MOVWF		OSCCAL			;
		MOVLW		B'00101000'		;GIPO5,3���͒[�q
		MOVWF		TRISIO			;
		CLRF		ANSEL			;�A�i���O���N���A�A�f�W�^������
		BCF			OPTION_REG,7	;
		
		BCF			STATUS,RP0		;BANK0 �I��
		MOVLW		B'00000111'		;��rOFF
		MOVWF		CMCON			;��rOFF
		CLRF		GPIO			;

;--------Main
MAIN
		CALL		TIMER4
		NOP							;���ˑҋ@
		BTFSS		GPIO,5			;���˃{�^�������AGPIO5 1�ɂȂ�A���̃R�}���h���X�L�b�v
		GOTO		MAIN			;
		
		BSF			GPIO,0			;�R�C��GPIO,0
		CALL		TIMER2			;
		BCF			GPIO,0			;
		CALL		TIMER1			;

		BSF			GPIO,1			;�R�C��GPIO,1
		CALL		TIMER2			;
		BCF			GPIO,1			;
		CALL		TIMER1			;

		BSF			GPIO,2			;�R�C��GPIO,2
		CALL		TIMER2			;
		BCF			GPIO,2			;
		CALL		TIMER1			;

		BSF			GPIO,4			;�R�C��GPIO,4
		CALL		TIMER2
		BCF			GPIO,4			;
		CALL		TIMER1			;

		BTFSC		GPIO,5			;���˃{�^���𗣂���Main�ɖ߂�
		GOTO		$ - 1			;
		GOTO		MAIN			;

;--------end
EEND
		MOVLW		B'00000000'		;���ׂĂ̏o�̓{�[�h���N���A
		MOVWF		GPIO			;���ׂĂ̏o�̓{�[�h���N���A
		GOTO		EEND			;

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
E_END								;
		END							;