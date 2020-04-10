/*
 * File:   main.c
 * Author: E560
 * UVC 起動 遅延スタートタイマー,15,15,15
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
 * UVC Timer    15,+15,+30 分
 * GP0  OUT     LED1    時間表示用
 * GP1  OUT     LED2    時間表示用
 * GP2  OUT     LED3    時間表示用
 * GP3  INPUT   INPUT   時間設定キー 4x15，起動後人体センサー判断
 * GP4  OUT     LED,    リレー起動用
 * GP5  OUT     Beep    警告音
 */

//OSCCAL = __osccal_val();
//#define _XTAL_FREQ 4000000
asm("OSCCAL equ 090h");

/*
 * FLAG = 0 GP3  INPUT 時間設定できる
 * FLAG = 1 時間設定後，タイマスタート猶予時間
 * FLAG = 2 タイマ実行中
 * FLAG = 3
 */
char FLAG = 1; //現在の状態
char TCONT = 3; //タイマ回数/時間設定
int CONT_TEMP = 0; //カウンターのTemp;

void interrupt isr(void) {
    INTCONbits.GIE = 0;
    if (FLAG == 0) {
        if (INTCONbits.T0IF == 1) {
            INTCONbits.T0IE = 0;
            INTCONbits.T0IF = 0;
            ++CONT_TEMP;
            if (CONT_TEMP > 254) {
                FLAG = 1;
                CONT_TEMP = 0;
            } else {
                TMR0 = 1;
                INTCONbits.T0IE = 1;
            }
        }
    }
    //    if (FLAG == 1) {
    //    }
    if (FLAG == 2) {
        if (PIR1bits.TMR1IF == 1) {
            //1000 Target halted. Stopwatch cycle count = 524344286 (524.344286 s)
            //1718 Target halted. Stopwatch cycle count = 900823228 (900.823228 s)
            //1717 Target halted. Stopwatch cycle count = 900298883 (900.298883 s)
            if (CONT_TEMP > 1717) {
                GPIObits.GP4 = 0;
                FLAG = 0;
                CONT_TEMP = 0;
                TMR1Lbits.TMR1L = 0;
                TMR1Hbits.TMR1H = 0;
                PIR1bits.TMR1IF = 0;
                PIE1bits.TMR1IE = 0; //Timer1終了
            } else {
                GPIObits.GP4 = 1;
                FLAG = 2;
                CONT_TEMP = CONT_TEMP;
                TMR1Lbits.TMR1L = 0;
                TMR1Hbits.TMR1H = 0;
                PIR1bits.TMR1IF = 0;
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
    ANSEL = 0;
    CMCON = 0;
    TRISIO = 0b00001000;
    return;
}

/*
 *時間設定スイッチ機能、一定期間内で押してTCONTカウント数を設定、約4秒内
 */
void pinchk(void) {
    OPTION_REGbits.T0CS = 0;
    OPTION_REGbits.PSA = 0;
    OPTION_REGbits.PS2 = 1;
    OPTION_REGbits.PS1 = 1;
    OPTION_REGbits.PS0 = 1;
    INTCONbits.T0IE = 1;
    INTCONbits.GIE = 1;
    TMR0 = 0;
    while (FLAG == 0) {
        if (GPIObits.GP3 == 1) {
            TCONT = TCONT + 1;
            NOP();
            if (TCONT == 0) {
                GPIObits.GP0 = 0;
                GPIObits.GP1 = 0;
                GPIObits.GP2 = 0;
            }
            if (TCONT == 1) {
                GPIObits.GP0 = 1;
                GPIObits.GP1 = 0;
                GPIObits.GP2 = 0;
            }
            if (TCONT == 2) {
                GPIObits.GP0 = 0;
                GPIObits.GP1 = 1;
                GPIObits.GP2 = 0;
            }
            if (TCONT == 3) {
                GPIObits.GP0 = 1;
                GPIObits.GP1 = 1;
                GPIObits.GP2 = 0;
            }
            if (TCONT == 4) {
                GPIObits.GP0 = 0;
                GPIObits.GP1 = 0;
                GPIObits.GP2 = 1;
            }
            if (TCONT == 5) {
                GPIObits.GP0 = 1;
                GPIObits.GP1 = 0;
                GPIObits.GP2 = 1;
            }
            if (TCONT == 6) {
                GPIObits.GP0 = 0;
                GPIObits.GP1 = 1;
                GPIObits.GP2 = 1;
            }
            if (TCONT == 7) {
                GPIObits.GP0 = 1;
                GPIObits.GP1 = 1;
                GPIObits.GP2 = 1;
            }
            if (TCONT > 7) {
                NOP();
            }
            while (GPIObits.GP3 == 1);
        }
        NOP();
    }
    NOP();
    return;
}

void Timer_1(char a) {
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
    //    for (char i = 0; i < 2; i++) {
    //        __delay_ms(1000);
    //    }

    CONT_TEMP = 0;
    while (CONT_TEMP < 20) {
        while (TMR1H != 0) {
            NOP();
        }
        TMR1H = 1;
        CONT_TEMP += 1;
    }

    FLAG = 2;
    CONT_TEMP = 0;
    TMR1Lbits.TMR1L = 0;
    TMR1Hbits.TMR1H = 0;
    GPIObits.GP4 = 1;
    PIE1bits.TMR1IE = 1;
    INTCONbits.PEIE = 1;
    INTCONbits.GIE = 1;
    return;
}

/*
 * FLAG = 0 GP3  INPUT 時間設定できる
 * FLAG = 1 時間設定後，タイマスタート猶予時間
 * FLAG = 2 タイマ実行中
 * FLAG = 3
 */

void main(void) {
    INIT();
    while (1) {
        switch (FLAG) {
            case 0:
                if (GPIObits.GP3 == 1)
                    pinchk();
                break;
            case 1:
                Timer_1(3);
                break;
            case 2:
                NOP();
                break;
            case 3:
                NOP();
                break;
        }
    }
    return;
}