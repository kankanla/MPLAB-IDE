;	2018/04/20
;	PIC12F675 Timer0

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
		H04W_TEMP		;
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
		MOVLW		D'230'			;TMR0?��?
		MOVWF		TMR0			;TMR0?��?
		MOVWF		H04W_TEMP		;
		BCF			INTCON,GIE		;0 = �֎~���L���f
		;BCF			INTCON,INTF		;0 = �֎~ GP2/INT �O�����f
		;BCF			INTCON,T0IE		;0 = �֎~ TMR0 ��o���f
		BCF			INTCON,T0IF		;1 = TMR0 �񑶊��?��o���� �i�K?�p?������j

		BSF			GPIO,0			;
		NOP
		BCF			GPIO,0			;

		BSF			INTCON,GIE		;1 = �g�\���L�������I���f
		MOVF		H04W_TEMP,w		;
		RETFIE						;
	
		
;----------
INIT
		BSF			STATUS,RP0		;BANK1 �I��
		CALL		H'3FF'			;�Z�y�����U?��
		MOVWF		OSCCAL			;�Z�y�����U?��
		MOVLW		B'00011100'		;GIPO4,3���͒[�q
		MOVWF		TRISIO			;�Z�y�����U?��
		CLRF		ANSEL			;���� I/O
		BCF			OPTION_REG,T0CS	;TMR0 ??��??��
		BCF			OPTION_REG,PSA	;0 = ��?��?�핪�z? TIMER0 ��?
		BCF			OPTION_REG,T0SE	;1 = GP2/T0CKI ���r�I���~��?��

		BCF			OPTION_REG,PS2	;PS2:PS0�F?��?��I��?��??��	
		BCF			OPTION_REG,PS1	;PS2:PS0�F?��?��I��?��??��
		BCF			OPTION_REG,PS0	;PS2:PS0�F?��?��I��?��??��
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
		BSF			INTCON,INTE		;1 = �g�\ GP2/INT �O�����f
		BSF			INTCON,T0IE		;1 = �g�\ TMR0 ��o���f


		MOVLW		D'230'			;TMR0?��?
		MOVWF		TMR0			;TMR0?��?

;--------Main
MAIN	NOP
		GOTO		MAIN			;



		
;--------end
EEND
		MOVLW		B'00000000'		;���ׂĂ̏o�̓{�[�h���N���A
		MOVWF		GPIO			;���ׂĂ̏o�̓{�[�h���N���A
		GOTO		EEND			;


;--------Timer
; 4MHZ �����N���b�N
; 25KHz �쐬
; 25KHz = 40us
; 4Mhz/4  = 1us 
; 25KH�� T = 40 �T�C�N��				

TIMER1	MOVLW		D'25'			;D'25' 0.1�~���b
		MOVWF		CNT1			;
LOOP1	NOP							;
		DECFSZ		CNT1,1			;
		GOTO		LOOP1			;
		RETURN						;

TIMER2	MOVLW		D'100'			;D'100' -> 10�~���b D'50' -> 5�~���b
		MOVWF		CNT2
LOOP2	NOP							;
		CALL		TIMER1			;
		DECFSZ		CNT2,1			;
		GOTO		LOOP2			;
		RETURN						;
		
TIMER3	MOVLW		D'50'			;1/2�b
		MOVWF		CNT3			;
LOOP3	NOP							;
		CALL		TIMER2			;
		DECFSZ		CNT3,1			;
		GOTO		LOOP3			;
		RETURN						;

TIMER4	MOVLW		D'10'			;10�b
		MOVWF		CNT4			;
LOOP4	NOP							;
		CALL		TIMER3			;
		DECFSZ		CNT4,1			;
		GOTO		LOOP4			;
		RETURN						;

;--------
E_END								;
		END							;