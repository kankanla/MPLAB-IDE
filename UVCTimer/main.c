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
 * UVC Timer    15分 x7 
 * GP0  OUT     LED1    時間表示用
 * GP1  OUT     LED2    時間表示用
 * GP2  OUT     LED3    時間表示用
 * GP3  INPUT   INPUT   時間設定キー 
 * GP4  OUT     LED,    リレー起動用
 * GP5  OUT     Beep    警告音
 */

//OSCCAL = __osccal_val();
#define _XTAL_FREQ 4000000
asm("OSCCAL equ 090h");

/*
 * FLAG = 0 GP3  INPUT 時間設定できる
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
            TMR1Lbits.TMR1L = 0;
            TMR1Hbits.TMR1H = 0;
            //1000 Target halted. Stopwatch cycle count = 524344286 (524.344286 s)
            //1717 Target halted. Stopwatch cycle count = 900298883 (900.298883 s)
            //TCONT = 1 Target halted. Stopwatch cycle count = 900780098 (900.780098 s)
            //TCONT = 2 Target halted. Stopwatch cycle count = 1801560140 (1801.56014 s)
            if (CONT_TEMP > 1717 && TCONT == 1) {
                FLAG = 0;
                GPIObits.GP4 = 0;
                CONT_TEMP = 0;
                PIR1bits.TMR1IF = 0;
                PIE1bits.TMR1IE = 0; //Timer1終了
            } else {
                FLAG = 2;
                GPIObits.GP4 = 1;
                if (CONT_TEMP > 1717) {
                    CONT_TEMP = 0;
                    TCONT -= 1;
                }
                CONT_TEMP += 1;
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
    GPIO = 0;
    //    GPIObits.GP0 = 0;
    //    GPIObits.GP1 = 0;
    //    GPIObits.GP2 = 0;
    //    GPIObits.GP4 = 0;
    //    GPIObits.GP5 = 0;
    return;
}

void showLED(void) {
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
}

void beep(void) {
    GPIObits.GP5 = 1;
    NOP();
    NOP();
    NOP();
    NOP();
    GPIObits.GP5 = 0;
    NOP();
    NOP();
    NOP();
    NOP();
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
            if (TCONT > 7) {
                TCONT = 7;
            }
            showLED();
            while (GPIObits.GP3 == 1);
        }
        NOP();
    }
    NOP();
    return;
}

void Timer_1(void) {
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

    for (char i = 0; i < 2; i++) {
        __delay_ms(10);
    }

    //約4秒カウント待つ時間
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
                Timer_1();
                break;
            case 2:
                GPIObits.GP0 = 0;
                GPIObits.GP1 = 0;
                GPIObits.GP2 = 0;
                beep();
                showLED();
                NOP();
                break;
            case 3:
                NOP();
                break;
        }
    }
    return;
}