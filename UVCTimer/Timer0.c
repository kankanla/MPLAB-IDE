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

unsigned long int STM = 0;
unsigned long int TTM = 0;

/*
 * 
 */

void interrupt ISR(void) {
    INTCONbits.GIE = 0;
    if (INTCONbits.T0IF == 1) {
        INTCONbits.T0IF = 0;
        TMR0 = 0;
        STM += 1;
    }
    INTCONbits.GIE = 1;
}

void Stimer(void) {
    OPTION_REGbits.T0CS = 0;
    OPTION_REGbits.PSA = 0;
    OPTION_REGbits.PS2 = 1;
    OPTION_REGbits.PS1 = 1;
    OPTION_REGbits.PS0 = 1;
    INTCONbits.T0IE = 1;
    INTCONbits.GIE = 1;
    TMR0 = 0;
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

void init(void) {

}

int main(void) {
    Stimer();
    while (1) {
        TTM += 1;
    }
}

