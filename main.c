/*
 * File:   main.c
 * PIC 12F1822
 * 32 MHz 
 * 0.03125us
 * Created on 2020/03/06, 23:25
 */

// CONFIG1
#pragma config FOSC = INTOSC    // Oscillator Selection (INTOSC oscillator: I/O function on CLKIN pin)
#pragma config WDTE = OFF       // Watchdog Timer Enable (WDT disabled)
#pragma config PWRTE = ON       // Power-up Timer Enable (PWRT enabled)
#pragma config MCLRE = ON      // MCLR Pin Function Select (MCLR/VPP pin function is digital input)
#pragma config CP = OFF         // Flash Program Memory Code Protection (Program memory code protection is disabled)
#pragma config CPD = OFF        // Data Memory Code Protection (Data memory code protection is disabled)
#pragma config BOREN = ON       // Brown-out Reset Enable (Brown-out Reset enabled)
#pragma config CLKOUTEN = OFF   // Clock Out Enable (CLKOUT function is disabled. I/O or oscillator function on the CLKOUT pin)
#pragma config IESO = OFF       // Internal/External Switchover (Internal/External Switchover mode is disabled)
#pragma config FCMEN = OFF      // Fail-Safe Clock Monitor Enable (Fail-Safe Clock Monitor is disabled)

// CONFIG2
#pragma config WRT = OFF        // Flash Memory Self-Write Protection (Write protection off)
#pragma config PLLEN = OFF      // PLL Enable (4x PLL disabled)
#pragma config STVREN = ON      // Stack Overflow/Underflow Reset Enable (Stack Overflow or Underflow will cause a Reset)
#pragma config BORV = HI        // Brown-out Reset Voltage Selection (Brown-out Reset Voltage (Vbor), high trip point selected.)
#pragma config LVP = OFF        // Low-Voltage Programming Enable (High-voltage on MCLR/VPP must be used for programming)

#include <xc.h>
#include<stdio.h>
#define _XTAL_FREQ 32000000
__EEPROM_DATA('t', 'b', 2, 3, 4, 5, 6, 7);

void SET_INIT();
void TMR1_INIT();
void T0(void);
void T1(void);
void EEPROMWRITE(unsigned char adr, unsigned char data);
unsigned char EEPROMREAD(unsigned char addr);

void interrupt T1_isr(void) {
    //TMR1H = 255; //40
    //TMR1L = 160; //40
    //TMR1H = 255; //20
    //TMR1L = 239; //20
    if (TMR1IF == 1) {
        PORTAbits.RA2 = ~PORTAbits.RA2;
        TMR1H = 255;
        TMR1L = 254; //240
        TMR1IF = 0;
    }
}

void main(void) {
    SET_INIT();
    TMR1_INIT();
    __delay_ms(1);
    PORTAbits.RA2 = 0;
    TMR1H = 255;
    TMR1L = 240;
    T1GCONbits.TMR1GE = 1;
    PIE1bits.TMR1IE = 1;

    while (1) {
        NOP();
        NOP();
        NOP();
        NOP();
        NOP();
        NOP();
        NOP();
        NOP();
        NOP();
    }
}

void T0(void) {
    PORTAbits.RA2 = 1;
    PORTAbits.RA2 = 0;
    return;
}

void T1(void) {
    PORTAbits.RA2 = 1;
    PORTAbits.RA2 = 0;
    return;
}

void TMR1_INIT() {
    T1CONbits.TMR1CS = 1;
    T1CONbits.TMR1ON = 1;
    //    T1GCONbits.TMR1GE = 1;
    //    PIE1bits.TMR1IE = 1;
    return;
}

void SET_INIT() {
    OSCCONbits.SPLLEN = 1; //4xPPL ??
    OSCCONbits.IRCF3 = 1;
    OSCCONbits.IRCF2 = 1;
    OSCCONbits.IRCF1 = 1;
    OSCCONbits.IRCF0 = 0;
    OSCCONbits.SCS1 = 1;
    OSCCONbits.SCS0 = 0;
    ANSELAbits.ANSA4 = 0;
    ANSELAbits.ANSA2 = 0;
    ANSELAbits.ANSA1 = 0;
    ANSELAbits.ANSA0 = 0;
    TRISAbits.TRISA0 = 0;
    TRISAbits.TRISA1 = 0;
    TRISAbits.TRISA2 = 0;
    TRISAbits.TRISA3 = 1;
    TRISAbits.TRISA4 = 0;
    TRISAbits.TRISA5 = 0;
    INTCONbits.PEIE = 1;
    INTCONbits.GIE = 1;
    return;
}

void EEPROMWRITE(unsigned char add, unsigned char data) {
    EEADRLbits.EEADRL = add;
    EEDATLbits.EEDATL = data;
    EECON1bits.CFGS = 0;
    EECON1bits.EEPGD = 0;
    EECON1bits.WREN = 1;
    INTCONbits.GIE = 0;
    EECON2bits.EECON2 = 0x55;
    EECON2bits.EECON2 = 0xaa;
    EECON1bits.WR = 1;
    while (EECON1bits.WR == 1);
    INTCONbits.GIE = 1;
    EECON1bits.WREN = 0;
    return;
}

unsigned char EEPROMREAD(unsigned char addr) {
    EEADRL = addr;
    INTCONbits.GIE = 0;
    EECON1bits.RD = 1;
    while (EECON1bits.RD == 1);
    return EEDATA;
}

