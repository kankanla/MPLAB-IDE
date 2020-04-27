/*
 * File:   main.c
 * Author: E560
 * UVC 起動 遅延スタートタイマー,xx分x最大6回,常オン
 *
 * Created on 2020/03/06, 22:31
 */

// CONFIG
#pragma config FOSC = INTRCIO   // Oscillator Selection bits (INTOSC oscillator: I/O function on GP4/OSC2/CLKOUT pin, I/O function on GP5/OSC1/CLKIN)
#pragma config WDTE = OFF       // Watchdog Timer Enable bit (WDT disabled)
#pragma config PWRTE = OFF      // Power-Up Timer Enable bit (PWRT disabled)
#pragma config MCLRE = OFF      // GP3/MCLR pin function select (GP3/MCLR pin function is digital I/O, MCLR internally tied to VDD)
#pragma config BOREN = OFF      // Brown-out Detect Enable bit (BOD disabled)
#pragma config CP = OFF         // Code Protection bit (Program Memory code protection is disabled)
#pragma config CPD = OFF        // Data Code Protection bit (Data memory code protection is disabled)

#include <xc.h>
//#include<stdio.h>

/*
 * UVC Timer    XX分 x6回，常オン 
 * GP5  OUT     LED1    時間表示用，警告音
 * GP0  OUT     LED2    時間表示用
 * GP1  OUT     LED3    時間表示用
 * GP2  INPUT   INT     割り込み マイクロ波レーダーセンサーRCWL-0516など
 * GP3  INPUT   INPUT   時間設定キー,長押し停止
 * GP4  OUT     LED,    リレー起動用 
 */

//OSCCAL = __osccal_val();
#define _XTAL_FREQ 4000000
//#define _XTAL_FREQ 4Mhz
//asm("OSCCAL equ 090h");

/*
 * FLAG = 0 GP3 INPUT 時間設定
 * FLAG = 1 時間設定後，タイマスタート猶予時間
 * FLAG = 2 タイマ実行中
 * FLAG = 3
 */
unsigned char FLAG = 0; //現在の状態 デフォルト0
unsigned char TCONT = 0; //タイマ回数/時間設定 デフォルト 0
unsigned int CONT_TEMP = 0; //カウンターのTemp デフォルト0

void interrupt isr(void) {
    INTCONbits.GIE = 0;
    if (FLAG == 0) {
        /*
         * Timer0 の設定時間内でGP3のInput回数設定
         * この時間をすぎると設定できなくなる．
         */
        if (INTCONbits.T0IF == 1) {
            INTCONbits.T0IE = 0;
            INTCONbits.T0IF = 0;
            CONT_TEMP += 1;
            if (CONT_TEMP > 254) {
                FLAG = 1;
                CONT_TEMP = 0;
                INTCONbits.T0IE = 0;
            } else {
                TMR0 = 180;
                INTCONbits.T0IE = 1;
            }
        }
    }

    if (FLAG == 2) {
        INTCONbits.T0IE = 0;
        /*
         * タイマ実行中
         * GP2割り込みが発生する場合GP4出力を一回無効にする．
         */
        if (INTCONbits.INTF == 1) {
            GPIObits.GP4 = 0;
            GPIObits.GP2 = 0;
            INTCONbits.INTF = 0;
        }
        if (PIR1bits.TMR1IF == 1) {
            PIR1bits.TMR1IF = 0;
            TMR1Lbits.TMR1L = 0;
            TMR1Hbits.TMR1H = 0;
            //1000 Target halted. Stopwatch cycle count = 524344286 (524.344286 s)
            //1717 Target halted. Stopwatch cycle count = 900298883 (900.298883 s)
            //TCONT = 1 Target halted. Stopwatch cycle count = 900780098 (900.780098 s)
            //1分 ==101
            //7分 ==707
            //15分 ==1515
            if (TCONT == 0) {
                /*
                 * タイマ停止
                 */
                INTCONbits.INTE = 0;
                FLAG = 0;
                GPIObits.GP4 = 0;
                PIE1bits.TMR1IE = 0; //Timer1終了
            } else if (TCONT == 7) {
                /*
                 * タイマない，常オン
                 */
                FLAG = 2;
                if (CONT_TEMP > 202) {
                    CONT_TEMP = 0;
                    TCONT = 7;
                    GPIObits.GP4 = 1;
                }
                CONT_TEMP += 1;
                PIE1bits.TMR1IE = 1; //Timer1続き
            } else {
                /*
                 * タイマ続き，カウント-1
                 */
                FLAG = 2;
                if (CONT_TEMP > 707) {
                    CONT_TEMP = 0;
                    TCONT -= 1;
                    GPIObits.GP4 = 1;
                }
                CONT_TEMP += 1;
                PIE1bits.TMR1IE = 1; //Timer1続き
            }
        }
    }
    //    if (FLAG == 3) {
    //    }
    INTCONbits.GIE = 1;
}

/*
 * 初期化設定
 */
void INIT(void) {
    //    OSCCAL = __osccal_val();
    //    OSCCAL = 0x90;
    OSCCALbits.CAL5 = 0;
    OSCCALbits.CAL4 = 0;
    OSCCALbits.CAL3 = 0;
    OSCCALbits.CAL2 = 0;
    OSCCALbits.CAL1 = 0;
    OSCCALbits.CAL0 = 0;
    OPTION_REGbits.nGPPU = 1;
    OPTION_REGbits.T0CS = 0;
    OPTION_REGbits.INTEDG = 1;
    INTCONbits.INTE = 0;
    INTCONbits.GPIE = 0;
    CMCONbits.CM2 = 1;
    CMCONbits.CM1 = 1;
    CMCONbits.CM0 = 1;
    TRISIO = 0b00001100;
    GPIO = 0;
    ANSEL = 0;
}

void showLED(void) {
    /*
     * TCONT値によって，LED表示．
     */
    switch (TCONT) {
        case 0:
            GPIObits.GP5 = 0;
            GPIObits.GP0 = 0;
            GPIObits.GP1 = 0;
            break;
        case 1:
            GPIObits.GP5 = 1;
            GPIObits.GP0 = 0;
            GPIObits.GP1 = 0;
            break;
        case 2:
            GPIObits.GP5 = 0;
            GPIObits.GP0 = 1;
            GPIObits.GP1 = 0;
            break;
        case 3:
            GPIObits.GP5 = 1;
            GPIObits.GP0 = 1;
            GPIObits.GP1 = 0;
            break;
        case 4:
            GPIObits.GP5 = 0;
            GPIObits.GP0 = 0;
            GPIObits.GP1 = 1;
            break;
        case 5:
            GPIObits.GP5 = 1;
            GPIObits.GP0 = 0;
            GPIObits.GP1 = 1;
            break;
        case 6:
            GPIObits.GP5 = 0;
            GPIObits.GP0 = 1;
            GPIObits.GP1 = 1;
            break;
        case 7:
            GPIObits.GP5 = 1;
            GPIObits.GP0 = 1;
            GPIObits.GP1 = 1;
            break;
    }
}

void beep(void) {
    GPIObits.GP5 = ~GPIObits.GP5;
    for (unsigned char i = 0; i < 8; i++) {
    }
    GPIObits.GP5 = ~GPIObits.GP5;
    for (unsigned char i = 0; i < 8; i++) {
    }
}

void GP3stop(void) {
    while (GP3 == 1) {
        FLAG = 0;
        TCONT = 0;
        showLED();
        PIE1bits.TMR1IE = 0;
        INTCONbits.INTE = 0;
        INTCONbits.PEIE = 0;
        INTCONbits.GIE = 0;
        GPIObits.GP4 = 0;
    }
}

/*
 *時間設定スイッチ機能、一定期間内で押してTCONTカウント数を設定、約4秒内
 */
void pinchk(void) {
    OPTION_REGbits.PSA = 0;
    OPTION_REGbits.PS2 = 1;
    OPTION_REGbits.PS1 = 1;
    OPTION_REGbits.PS0 = 1;
    INTCONbits.T0IE = 1;
    INTCONbits.GIE = 1;
    TMR0 = 180;
    while (FLAG == 0) {
        showLED();
        while (GPIObits.GP3 == 1) {
            for (unsigned char i = 0; i < 254; i++) {
                if (GPIObits.GP3 != 1) {
                    break;
                }
                if (i == 250) {
                    TCONT += 1;
                    if (TCONT > 7) {
                        TCONT = 1;
                    }
                    beep();
                    showLED();
                }
            }
            while (GPIObits.GP3 == 1);
        }
    }
}

void Timer_1(void) {
    /*
     * タイマ1設定     
     */
    TMR1Lbits.TMR1L = 0;
    TMR1Hbits.TMR1H = 1;
    T1CONbits.TMR1GE = 0;
    T1CONbits.T1CKPS1 = 1;
    T1CONbits.T1CKPS0 = 1;
    T1CONbits.T1OSCEN = 0;
    T1CONbits.nT1SYNC = 1;
    T1CONbits.TMR1CS = 0;
    T1CONbits.TMR1ON = 1;
    GPIObits.GP4 = 0;

    __delay_ms(100);

    //約x秒カウント待つ時間,警告音鳴らす
    CONT_TEMP = 0;
    while (CONT_TEMP < 50) {
        while (TMR1H != 0) {
        }
        TMR1H = 180;
        CONT_TEMP += 1;
        beep();
        //タイマー停止
        if (GP3 == 1) {
            GP3stop();
            break;
        }
    }

    /*
     * タイマ1スタート
     */
    FLAG = 2;
    CONT_TEMP = 0;
    TMR1Lbits.TMR1L = 0;
    TMR1Hbits.TMR1H = 0;
    if (TCONT != 0) {
        GPIObits.GP4 = 1;
        GPIObits.GP2 = 0;
    }
    PIE1bits.TMR1IE = 1;
    INTCONbits.INTE = 1;
    INTCONbits.PEIE = 1;
    INTCONbits.GIE = 1;
}

/*
 * FLAG = 0 GP3  INPUT 時間設定できる
 * FLAG = 1 時間設定後，タイマスタート猶予時間
 * FLAG = 2 タイマ実行中
 * FLAG = 3
 */

void main(void) {
    INIT();
    showLED();
    while (1) {
        showLED();
        switch (FLAG) {
            case 0:
                if (GPIObits.GP3 == 1) {
                    pinchk();
                }
                break;
            case 1:
                Timer_1();
                break;
            case 2:
                beep();
                beep();
                GP3stop(); //タイマー停止
                __delay_ms(1000);
                NOP();
                break;
            case 3:
                NOP();
                break;
        }
    }
    return;
}