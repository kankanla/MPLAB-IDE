PIC12F675　2CH AD変換を比較し、LEDを電灯する。
AN2に入力した電圧はAN3に設定した電圧より高く場合、LEDが
電灯します。


  LIST   P=12F675
  INCLUDE  P12F675.INC
  CB = _CPD_OFF               ;データ保護しない
  CB &= _CP_OFF               ;コード保護しない
  CB &= _BODEN_ON             ;ブラウンアウトリセット
  CB &= _MCLRE_OFF            ;GP3/MCLR デジタルI/O
  CB &= _PWRTE_ON             ;パワーアップタイマを使用する
  CB &= _WDT_OFF              ;ウォッチドッグタイマをOFF
  CB &= _INTRC_OSC_NOCLKOUT   ;内部クロックを利用、RA4ピンI/Oピン
  __CONFIG CB                 ;設定

;--------
  CBLOCK H'20'
   CONT1                      ;LED点滅カウント
   SCONT1                     ;タイマカウント
   SCONT2
   HAN3
   LAN3
   HAN2
   LAN2
   EEA                        ;EEPROM書き込み時のアドレス
   EED                        ;EEPROM書き込み時のデータ
  ENDC

;----------
  ORG  H'0'
  GOTO INIT

  ;ORG  H'04'
  ;GOTO H04

;----------
INIT                          ;デバイス初期化
  BCF  STATUS,RP0             ;0バンク選択
  MOVLW B'00000111'           ;コンパレータOFF
  MOVWF CMCON                 ;コンパレータOFF
  BCF  INTCON,PEIE            ;周辺割り込みOFF

  BSF  STATUS,RP0            ;1バンク選択
  CALL 0x3FF                 ;
  MOVWF OSCCAL
  MOVLW B'00010110'         ;RP1,2,4入力用設定
  MOVWF TRISIO              ;RP1,2,4入力用設定
  MOVLW B'00010100'         ;Fosc/8,GP2,4アナログ
  MOVWF ANSEL               ;Fosc/8,GP2,4アナログ
  BCF  STATUS,RP0           ;0バンク戻る
  CALL S1TIME

;-----------------------------------------------------------
MAIN                        ;
  BTFSC GPIO,1              ;
  GOTO ADCL                 ;

;ADH---------------------------
  MOVLW B'00001100'         ;ADFM=0,VDD電圧,AN3-GP4
  MOVWF ADCON0              ;
  CALL ADCMAIN              ;
  MOVF ADRESH,W             ;
  MOVWF HAN3                ;
  BSF  STATUS,RP0           ;
  MOVF ADRESL,W             ;
  BCF  STATUS,RP0           ;
  MOVWF LAN3                ;

  MOVLW B'00001000'    ;ADFM=0,VDD電圧,AN2-GP2
  MOVWF ADCON0
  CALL ADCMAIN
  MOVF ADRESH,W
  MOVWF HAN2      ;
  BSF  STATUS,RP0
  MOVF ADRESL,W
  BCF  STATUS,RP0
  MOVWF LAN2      ;
  CALL EPCHK

  MOVF HAN3,W     ;A
  SUBWF HAN2,W     ;B
  BTFSS STATUS,C     ;IF BF-HAN3>AW-HAN2 C=1
  GOTO HLEDON
  BCF  GPIO,5
  GOTO MAIN

HLEDON
  BSF  GPIO,5
  CALL S2TIME
  GOTO MAIN

;ADL--------------------------
ADCL
  MOVLW B'10001100'    ;ADFM=1,VDD電圧,AN3-GP4
  MOVWF ADCON0     ;
  CALL ADCMAIN
  BSF  STATUS,RP0
  MOVF ADRESL,W
  BCF  STATUS,RP0
  MOVWF LAN3      ;

  MOVLW B'10001000'    ;ADFM=1,VDD電圧,AN2-GP2
  MOVWF ADCON0
  CALL ADCMAIN
  BSF  STATUS,RP0
  MOVF ADRESL,W
  BCF  STATUS,RP0
  MOVWF LAN2      ;
  CALL EPCHK

  MOVF LAN3,W     ;A
  SUBWF LAN2,W     ;B
  BTFSS STATUS,C     ;IF BF-HAN3>AW-HAN2 C=1
  GOTO LLEDON
  BCF  GPIO,5
  GOTO MAIN

LLEDON
  BSF  GPIO,5
  ;CALL S2TIME
  GOTO MAIN

;--------------------------------------------------------------
;EEPRO CHECK
EPCHK
  MOVF HAN3,W
  MOVWF EED
  MOVLW 0X00
  MOVWF EEA
  CALL EEPROM

  MOVF LAN3,W
  MOVWF EED
  MOVLW 0X01
  MOVWF EEA
  CALL EEPROM

  MOVF HAN2,W
  MOVWF EED
  MOVLW 0X02
  MOVWF EEA
  CALL EEPROM

  MOVF LAN2,W
  MOVWF EED
  MOVLW 0X03
  MOVWF EEA
  CALL EEPROM

  RETURN

;------------------------------------------------------------
;AD開始
ADCMAIN
  BSF  ADCON0,ADON    ;ADC変換ON
  CALL ADCLK32     ;充電時間約30μs
  BSF  ADCON0,GO     ;ADC変換
ENDAC
  BTFSC ADCON0,GO     ;ADC変換完了待ち
  GOTO ENDAC     ;ADC変換完了待ち
  BCF  ADCON0,ADON    ;ADC変換OFF
  RETURN 

;充電時間
ADCLK32
  MOVLW D'17'      ;1 7x4+4=32μs
  MOVWF SCONT1     ;
ADCLK32LOOP
  NOP        ;1
  DECFSZ SCONT1,F     ;1
  GOTO ADCLK32LOOP    ;2
  RETURN       ;2
;充電時間完了
;AD完了


;--------------------------------------------------
;時間タイマ
S2TIME
  MOVLW D'11'
  MOVWF SCONT2
S2LOP
  CALL S1TIME
  DECFSZ SCONT2,F
  GOTO S2LOP
  RETURN

S1TIME              ;1000μS、1mS
    MOVLW   D'249'       ;1 249X4+4=1000
   MOVWF   SCONT1     ;1
S1LOP
    NOP           ;1
    DECFSZ  SCONT1,F      ;1
    GOTO   S1LOP      ;2
    RETURN          ;2

;--------------------------------------------------------
;EEPROM書き込み
EEPROM
  BSF  STATUS,RP0
  MOVF EEA,W     ;書き込みアドレス
    MOVWF EEADR
  MOVF EED,W     ;書き込みデータ
    MOVWF EEDATA
  BSF  EECON1,WREN    ;書き込み許可
  MOVLW 0X55      ;書き込み手順
  MOVWF EECON2
  MOVLW 0XAA
  MOVWF EECON2
  BSF  EECON1,WR     ;書き込み
RWC
    BTFSC EECON1,WR
  GOTO RWC
  BCF  STATUS,RP0    ;書き込み完了後、バイク0に戻る
  RETURN       ;戻る
;---
EEND


  END
