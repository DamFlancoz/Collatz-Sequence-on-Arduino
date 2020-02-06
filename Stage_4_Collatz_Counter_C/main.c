/*
 * A4.c
 *
 * Created: 2019-12-04 4:35:28 PM
 * Author : daman
 */ 

#include <avr/io.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "CSC230.h"

#define  ADC_BTN_RIGHT 0x032
#define  ADC_BTN_UP 0x0C3
#define  ADC_BTN_DOWN 0x17C
#define  ADC_BTN_LEFT 0x22B
#define  ADC_BTN_SELECT 0x316

void update_cursor_pos();
void update_value_under_cursor();
void swap_speed();
void reset_seq();
int next_v();

const int row1_offsets[] = {3,4,5,6,14};
volatile int row1_offset = 2;
volatile char screen[2][17] = {"Damandeep Bawa  ", "CSC230 Fall 2019"}; 
volatile char button = '\0';
volatile char toggle_c = '0';

int main(void)
{
	// Init
    static char prev_button = '\0';
	
    lcd_init();
    
    //ADC Set up
    ADCSRA = 0x87;
    ADMUX = 0x40;
    
    // Set up Timer 1 (20hz)
    TCCR1A = 0;
    TCCR1B = 0b001;
    TCNT1 = 13568;
    TIMSK1 = 1<<TOIE1;
	
	// Set up Timer 2
	TCCR2A = 0;
	TCCR2B = 0b100;
	TCNT2 = 255-200;
	TIMSK2 = 1<<TOIE2;
    
    // Set up Timer 3 (1s), at 0 it won't work
    TCCR3A = 0;
    TCCR3B = 0b011; // 64
    TCNT3 = 0xFFFF - 15626;
    TIMSK3 = 1<<TOIE3;

    sei();
	
    // update screen
    lcd_xy(0,0);
    lcd_puts((void*) screen[0]);
    lcd_xy(0,1);
    lcd_puts((void*) screen[1]);
	
	_delay_ms(1000);	
	
	strncpy((char*) screen[0], " n=000*   SPD:0 ", 17);
	strncpy((char*) screen[1], "cnt:000 v:000000", 17);
    
    for(;;){

		if (prev_button != button){
			update_cursor_pos();
			update_value_under_cursor();
			swap_speed();
		}
		
		prev_button = button;
	    
	    // update screen
	    lcd_xy(0,0);
	    lcd_puts((char*) screen[0]);
		lcd_xy(0,1);
		lcd_puts((char*) screen[1]);
    }
}

/* Checks button and updates cursor position according to left or right 
 * press.
 */
void update_cursor_pos(){
	screen[0][row1_offsets[row1_offset]] = toggle_c;
	switch(button){
		case 'R':
			if(row1_offset < 4) row1_offset += 1;
			break;
		case 'L':
			if(row1_offset > 0) row1_offset -= 1;
			break;
	}
	toggle_c = screen[0][row1_offsets[row1_offset]];
}

/* Handles up and down button presses. Changes value under cursor or calls 
 * reset_seq if cursor is on asterisk.
 */
void update_value_under_cursor(){
	screen[0][row1_offsets[row1_offset]] = toggle_c;
	
	char *c = (char*) &screen[0][row1_offsets[row1_offset]];
	switch(button){
		case 'U':
			if (row1_offset == 3) reset_seq();
			else if(*c == '9') *c = '0';
			else (*c)++;
			break;
		case 'D':
			if (row1_offset == 3) reset_seq();
			else if(*c == '0') *c = '9';
			else (*c)--;
			break;
	}
	
	toggle_c = screen[0][row1_offsets[row1_offset]];
}

/* Handles speed saving to memory and call back. */
void swap_speed(){
	static char saved_speed = '0';
	
	if (button == 'S'){
		if (row1_offset == 4) screen[0][14] = toggle_c;
		
		saved_speed ^= screen[0][14]; // swap 
		screen[0][14] ^= saved_speed;
		saved_speed ^= screen[0][14];
	}
	
}

/* Resets count to 0 and puts in user selected n value. */
void reset_seq(){
	strncpy((char*) screen[1], "cnt:000 v:000000", 17);
	screen[1][13] = screen[0][3];
	screen[1][14] = screen[0][4];
	screen[1][15] = screen[0][5];
}

/* Updates v on screen. returns 1 if v is changed and 0 otherwise. */
int next_v(){
	char buff[7] = "000000";
	buff[0] = screen[1][10];
	buff[1] = screen[1][11];
	buff[2] = screen[1][12];
	buff[3] = screen[1][13];
	buff[4] = screen[1][14];
	buff[5] = screen[1][15];
	
	int v = (int) strtol(buff, NULL, 10);

	if (v==1) return 0;

	v = (v%2) ? 3*v+1 : v/2;
	sprintf(buff, "%06d", v);

	screen[1][10] = buff[0];
	screen[1][11] = buff[1];
	screen[1][12] = buff[2];
	screen[1][13] = buff[3];
	screen[1][14] = buff[4];
	screen[1][15] = buff[5];
	
	return 1;	 
}

/* Get button value from ADC. */ 
unsigned short poll_adc(){
	unsigned short adc_result = 0; //16 bits
	
	ADCSRA |= 0x40;
	while((ADCSRA & 0x40) == 0x40); //Busy-wait
	
	unsigned short result_low = ADCL;
	unsigned short result_high = ADCH;
	
	adc_result = (result_high<<8)|result_low;
	return adc_result;
}

/* Checks and updates button value. */
ISR(TIMER1_OVF_vect){
	static int overflow = 0;
	if (overflow==12) {
		int adc_result = poll_adc();
		
		if (adc_result < ADC_BTN_RIGHT){
			button = 'R';
		} else if (adc_result < ADC_BTN_UP){
			button = 'U';
		} else if (adc_result < ADC_BTN_DOWN){
			button = 'D';
		} else if (adc_result < ADC_BTN_LEFT){
			button = 'L';
		} else if (adc_result < ADC_BTN_SELECT){
			button = 'S';
		} else button = '\0';
		
		TCNT1 = 13568;
		overflow = 0;

	} else overflow++;
}

/* Blinks cursor. */
ISR(TIMER2_OVF_vect){
	static int overflow = 0;
	if (overflow==488) {
		
		// Toggle char
		screen[0][row1_offsets[row1_offset]] ^= toggle_c ^ ' ';
		
		TCNT2 = 255-200;
		overflow = 0;

	} else overflow++;
}

/* Updates count and collatz value on screen */
ISR(TIMER3_OVF_vect){
	static int T3_TARGET_OVF = 0;
	static int T3_OVF_CNT = 0;
	
	if (T3_OVF_CNT < T3_TARGET_OVF){
		T3_OVF_CNT++;
		return;
	}
	
	T3_OVF_CNT = 0;

	// check speed here
	switch(screen[0][14]){
		case '0':
			return;
			break;

		case '1':
			T3_TARGET_OVF = 0;
			TCNT3 = 0xFFFF - 15625;
			break;
			
		case '2':
			T3_TARGET_OVF = 0;
			TCNT3 = 0xFFFF - 31250;
			break;
		
		case '3':
			T3_TARGET_OVF = 0;
			TCNT3 = 0xFFFF - 62500;
			break;
		
		case '4':
			T3_TARGET_OVF = 0;
			TCNT3 = 0xFFFF - 31250;
			break;
		
		case '5':
			T3_TARGET_OVF = 3;
			TCNT3 = 0xFFFF - 53395;
			break;
		
		case '6':
			T3_TARGET_OVF = 5;
			TCNT3 = 0xFFFF - 47325;
			break;
		
		case '7':
			T3_TARGET_OVF = 7;
			TCNT3 = 0xFFFF - 41255;
			break;
		
		case '8':
			T3_TARGET_OVF = 9;
			TCNT3 = 0xFFFF - 35185;
			break;
		
		case '9':
			T3_TARGET_OVF = 11;
			TCNT3 = 0xFFFF - 29115;
			break;
	}
	
	if (next_v()){
		char buff[4] = "000";
		buff[0] = screen[1][4];
		buff[1] = screen[1][5];
		buff[2] = screen[1][6];
	
		int i = atoi(buff);
		i++;
	
		sprintf(buff,"%03d",i);
	
		screen[1][4] = buff[0];
		screen[1][5] = buff[1];
		screen[1][6] = buff[2];	
	}

}