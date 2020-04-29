/* 
 * File:   main2.c
 * Author: E560
 *
 * Created on 2020/04/29, 2:09
 */

// CONFIG
#pragma config FOSC = INTRCIO   // Oscillator Selection bits (INTOSC oscillator: I/O function on GP4/OSC2/CLKOUT pin, I/O function on GP5/OSC1/CLKIN)
#pragma config WDTE = OFF       // Watchdog Timer Enable bit (WDT disabled)
#pragma config PWRTE = OFF      // Power-Up Timer Enable bit (PWRT disabled)
#pragma config MCLRE = OFF      // GP3/MCLR pin function select (GP3/MCLR pin function is digital I/O, MCLR internally tied to VDD)
#pragma config BOREN = OFF      // Brown-out Detect Enable bit (BOD disabled)
#pragma config CP = OFF         // Code Protection bit (Program Memory code protection is disabled)
#pragma config CPD = OFF        // Data Code Protection bit (Data memory code protection is disabled)

// #pragma config statements should precede project file includes.
// Use project enums instead of #define for ON and OFF.

#include <xc.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h> 
#include <limits.h>

unsigned long int STM0 = 0;
unsigned int STM10 = 0;

/*
 * 
 */

void interrupt ISR(void) {
    INTCONbits.GIE = 0;
    if (INTCONbits.T0IF == 1) {
        INTCONbits.T0IF = 0;
        //        TMR0 = 0;
        STM0 += 1;
        if (STM0 == 4294967295) {
            STM0 = 0;
        }
    }

    if (INTCONbits.INTF == 1) {
        INTCONbits.INTF = 0;
    }

    if (PIR1bits.TMR1IF == 1) {
        PIR1bits.TMR1IF = 0;
        //    TMR1Lbits.TMR1L = 0;
        //    TMR1Hbits.TMR1H = 0;
        STM10 += 1;
        if (STM10 == 65535) {
            STM10 = 0;
        }
    }
}

void PIC_TIMER0(void) {
    OPTION_REGbits.T0CS = 0;
    OPTION_REGbits.PSA = 0;
    OPTION_REGbits.PS2 = 1;
    OPTION_REGbits.PS1 = 1;
    OPTION_REGbits.PS0 = 1;
    INTCONbits.T0IE = 1;
    //    TMR0 = 0;
    /*
     * TMR0 = 0 12F675 4Mhz
     * 111 1:256 = 65556 (65.556 ms)
     * 110 1:128 = 32788 (32.788 ms)
     * 101 1:64 = 16404 (16.404 ms)
     * 100 1:32 = 8212 (8.212 ms)
     * 011 1:16 = 4116 (4.116 ms)
     * 010 1:8 = 2068 (2.068 ms)
     * 001 1:4 = 1044 (1.044 ms)
     * 000 1:2 = 532 (532 µs)
     * 
     * 65.556 ms * 4294967295 = 8.92231633 年
     * 65.556 ms * 65535 = 1.19339235 時間
     * 532 µs * 4294967295 = 26.4458634 日
     * 65.556 ms * 2147483647 = 4.46115816 年
     * 532 µs * 2147483647 = 13.2229317 日
     */
}

void PIC_TIMER1(void) {
    //    TMR1Lbits.TMR1L = 0;
    //    TMR1Hbits.TMR1H = 0;
    T1CONbits.TMR1GE = 0;
    T1CONbits.nT1SYNC = 1;
    T1CONbits.TMR1CS = 0;
    T1CONbits.TMR1ON = 1;
    T1CONbits.T1CKPS1 = 1;
    T1CONbits.T1CKPS0 = 1;
    /*
     * TMR1L = 0 TMR1H = 0 12F675 4Mhz
     * 11  =  1:8   = 524289 (524.289 ms)
     * 10  =  1:4   = 262145 (262.145 ms)
     * 01  =  1:2   = 131073 (131.073 ms)
     * 00  =  1:1   = 65536 (65.536 ms)
     * 524.289 ms x 65536 = 9.54438997 時間
     * 65.536 ms x 65536 1.19304647 時間;
     */

    INTCONbits.TMR0IE = 1;
    PIR1bits.TMR1IF = 0;
    PIE1bits.TMR1IE = 1;
}

void init(void) {
    //    OSCCAL = __osccal_val();
    //    OSCCAL = 0x90;
    //    OSCCALbits.CAL5 = 0;
    //    OSCCALbits.CAL4 = 0;
    //    OSCCALbits.CAL3 = 0;
    //    OSCCALbits.CAL2 = 0;
    //    OSCCALbits.CAL1 = 0;
    //    OSCCALbits.CAL0 = 0;
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

int main(void) {
    PIC_TIMER0();
    PIC_TIMER1();
    INTCONbits.GIE = 1;
    INTCONbits.PEIE = 1;
    while (1) {

    }
}

