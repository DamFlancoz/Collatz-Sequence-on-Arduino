/*
 * AsmFile1.asm
 *
 *  Created: 2019-11-13 1:03:15 PM
 *   Author: daman
 *
 * Contains functions for main
 */ 

 timer3_setup:	
	; timer mode: normal	
	ldi TEMP, 0x00
	sts TCCR2A, TEMP

	; clock / 64
	ldi TEMP, 0b011	
	sts TCCR2B, TEMP
	
	; set timer counter, 1/16sec
	ldi TEMP,0x3D
	sts TCNT3H, TEMP
	ldi TEMP, 0x09
	sts TCNT3L,TEMP
	
	; allow timer to interrupt the CPU when it's counter overflows
	ldi TEMP, 1<<TOV3
	sts TIMSK3, TEMP

	; enable interrupts (the I bit in SREG)
	sei	

	ret

timer1_setup:	
	; timer mode: normal	
	ldi TEMP, 0x00
	sts TCCR1A, TEMP

	; clock / 64
	ldi TEMP, 0b011	
	sts TCCR1B, TEMP

	; load pointer spd
	ldi XH, high(display_dm1)
	ldi XL, low(display_dm1)
	adiw XH:XL, 14
	ld TEMP, X
	
	; set timer counter
	is_9:
		cpi TEMP, 57
		brne is_8

		ldi TEMP,0x3D
		sts TCNT1H, TEMP
		ldi TEMP, 0x09
		sts TCNT1L,TEMP

		ldi TEMP, 0
		sts overflow_counter, TEMP ; low
		ldi TEMP, 0
		sts overflow_counter+1, TEMP
		rjmp switch_end

	is_8:
		cpi TEMP, 56
		brne is_7

		ldi TEMP,0x7A
		sts TCNT1H, TEMP
		ldi TEMP, 0x12
		sts TCNT1L,TEMP

		ldi TEMP, 0
		sts overflow_counter, TEMP ; low
		ldi TEMP, 0
		sts overflow_counter+1, TEMP
		rjmp switch_end

	is_7:
		cpi TEMP, 55
		brne is_6

		ldi TEMP,0xF4
		sts TCNT1H, TEMP
		ldi TEMP, 0x24
		sts TCNT1L,TEMP

		ldi TEMP, 0
		sts overflow_counter, TEMP ; low
		ldi TEMP, 0
		sts overflow_counter+1, TEMP
		rjmp switch_end

	is_6:
		cpi TEMP, 54
		brne is_5

		ldi TEMP,0xE8
		sts TCNT1H, TEMP
		ldi TEMP, 0x48
		sts TCNT1L,TEMP

		ldi TEMP, 1
		sts overflow_counter, TEMP ; low
		ldi TEMP, 0
		sts overflow_counter+1, TEMP
		rjmp switch_end

	is_5:
		cpi TEMP, 53
		brne is_4

		ldi TEMP,0xD0
		sts TCNT1H, TEMP
		ldi TEMP, 0x90
		sts TCNT1L,TEMP

		ldi TEMP, 3
		sts overflow_counter, TEMP ; low
		ldi TEMP, 0
		sts overflow_counter+1, TEMP
		rjmp switch_end

	is_4:
		cpi TEMP, 52
		brne is_3

		ldi TEMP,0xB8
		sts TCNT1H, TEMP
		ldi TEMP, 0xD8
		sts TCNT1L,TEMP

		ldi TEMP, 5
		sts overflow_counter, TEMP ; low
		ldi TEMP, 0
		sts overflow_counter+1, TEMP
		rjmp switch_end

	is_3:
		cpi TEMP, 51
		brne is_2

		ldi TEMP,0xA1
		sts TCNT1H, TEMP
		ldi TEMP, 0x20
		sts TCNT1L,TEMP

		ldi TEMP, 7
		sts overflow_counter, TEMP ; low
		ldi TEMP, 0
		sts overflow_counter+1, TEMP
		rjmp switch_end

	is_2:
		cpi TEMP, 50
		brne is_1

		ldi TEMP,0x89
		sts TCNT1H, TEMP
		ldi TEMP, 0x68
		sts TCNT1L,TEMP

		ldi TEMP, 9
		sts overflow_counter, TEMP ; low
		ldi TEMP, 0
		sts overflow_counter+1, TEMP
		rjmp switch_end

	is_1:
		cpi TEMP, 49
		brne is_0

		ldi TEMP,0x71
		sts TCNT1H, TEMP
		ldi TEMP, 0xB0
		sts TCNT1L,TEMP

		ldi TEMP, 11
		sts overflow_counter, TEMP ; low
		ldi TEMP, 0
		sts overflow_counter+1, TEMP
		rjmp switch_end

	is_0:
		
		ldi TEMP, 0	; stop
		sts TCCR1B, TEMP

	switch_end: ; end for switch

	ldi TEMP, 0
	sts overflow_count, TEMP
	sts overflow_count+1, TEMP
	
	; allow timer to interrupt the CPU when it's counter overflows
	ldi TEMP, 1<<TOV1
	sts TIMSK1, TEMP

	; enable interrupts (the I bit in SREG)
	sei	

	ret

.dseg
overflow_counter: .byte 2
.cseg




; Configure the ADC
adc_init:
 
	ldi TEMP, 0b10000111
	sts ADCSRA, TEMP
	ldi r16, 0b01000000
	sts ADMUX, TEMP
	ret




; Flash Greetings on Screen
put_greetings:
	; Load name
	ldi TEMP, high(display_dm1)
	push TEMP
	ldi TEMP, low(display_dm1)
	push TEMP
	ldi TEMP, high(greetings_pm1<<1)
	push TEMP
	ldi TEMP, low(greetings_pm1<<1)
	push TEMP

	call str_init

	pop TEMP
	pop TEMP
	pop TEMP
	pop TEMP

	; Load csc 230 fall 2019
	ldi TEMP, high(display_dm2)
	push TEMP
	ldi TEMP, low(display_dm2)
	push TEMP
	ldi TEMP, high(greetings_pm2<<1)
	push TEMP
	ldi TEMP, low(greetings_pm2<<1)
	push TEMP

	call str_init

	pop TEMP
	pop TEMP
	pop TEMP
	pop TEMP

	ret

greetings_pm1: .db "Damandeep Bawa  ",0,0
greetings_pm2: .db "CSC230 Fall 2019",0,0




put_working_display:
	; Load first row
	ldi TEMP, high(display_dm1)
	push TEMP
	ldi TEMP, low(display_dm1)
	push TEMP
	ldi TEMP, high(display_pm1<<1)
	push TEMP
	ldi TEMP, low(display_pm1<<1)
	push TEMP

	call str_init

	pop TEMP
	pop TEMP
	pop TEMP
	pop TEMP

	; Load second row
	ldi TEMP, high(display_dm2)
	push TEMP
	ldi TEMP, low(display_dm2)
	push TEMP
	ldi TEMP, high(display_pm2<<1)
	push TEMP
	ldi TEMP, low(display_pm2<<1)
	push TEMP

	call str_init

	pop TEMP
	pop TEMP
	pop TEMP
	pop TEMP

	ret




refresh_screen:
	; goto first row
	ldi TEMP, 0
	push TEMP
	ldi TEMP, 0
	push TEMP

	call lcd_gotoxy

	pop TEMP
	pop TEMP
	
	; put first row on lcd
	ldi TEMP, high(display_dm1)
	push TEMP
	ldi TEMP, low(display_dm1)
	push TEMP

	call lcd_puts
	
	pop TEMP
	pop TEMP

	; goto second row
	ldi TEMP, 2
	push TEMP
	ldi TEMP, 0
	push TEMP

	call lcd_gotoxy

	pop TEMP
	pop TEMP

	; put second row on lcd
	ldi TEMP, high(display_dm2)
	push TEMP
	ldi TEMP, low(display_dm2)
	push TEMP

	call lcd_puts
	
	pop TEMP
	pop TEMP

	ret

display_pm1: .db " n=000*   SPD:0 ",0,0
display_pm2: .db "cnt:000 v:000000",0,0

.dseg
display_dm1: .byte 17
display_dm2: .byte 17
.cseg




; Reinforces char before moving cursor
reinforce_cursor_char:
	; load pointer to row 1 string
	ldi XH, high(display_dm1)
	ldi XL, low(display_dm1)

	; load offset in TEMP using DICT_LOOKUP
	ldi ZH, high(row1_offset_dict<<1)
	ldi ZL, low(row1_offset_dict<<1)
	ldi TEMP, 0
	add ZL, row1_offset
	adc ZH, TEMP
	lpm TEMP, Z 

	; point X to selected char
	ldi TEMP2, 0
	add XL, TEMP
	adc XH, TEMP2

	; ensure char is in memory
	lds TEMP, char
	st X, TEMP

	ret




; if select is pressed restart count process
reset_count:

	ldi TEMP, 48

	; load pointer to row 2 string
	ldi XH, high(display_dm2)
	ldi XL, low(display_dm2)

	; load pointer to n
	ldi ZH, high(display_dm1)
	ldi ZL, low(display_dm1)
	adiw ZH:ZL, 3

	; point X to first digit
	adiw XH:XL, 4

	; set cnt to 1
	st X+, TEMP
	st X+, TEMP
	inc TEMP
	st X+, TEMP
	dec TEMP

	; set v=n
	adiw XH:XL, 3
	st X+, TEMP
	st X+, TEMP
	st X+, TEMP
	ld TEMP, Z+
	st X+, TEMP
	ld TEMP, Z+
	st X+, TEMP
	ld TEMP, Z+
	st X+, TEMP

	call timer1_setup

	ret




inc_cnt_in_memory:
	clr ZL ; store count
	clr ZH

	; load pointer to row 2 string
	ldi XH, high(display_dm2)
	ldi XL, low(display_dm2)

	; point X to first digit
	adiw XH:XL, 4

	; get first digit
	ld TEMP, X+
	subi TEMP, 48

	ldi TEMP2, 100
	mul TEMP, TEMP2
	mov ZL, r0
	mov ZH, r1

	; second digit
	ld TEMP, X+
	subi TEMP, 48

	ldi TEMP2, 10
	mul TEMP, TEMP2
	add ZL, r0
	adc ZH, r1

	; third digit
	ld TEMP, X+
	subi TEMP, 48

	ldi TEMP2, 0
	add ZL, TEMP
	adc ZH, TEMP2

	adiw ZH:ZL, 1

	subi XL, 3
	sbci XH, 0

	; put back first digit
	clr TEMP
	ldi TEMP2, 100
	ldi TEMP3, 0

	inc_cnt_in_memory_lp1:
		cp ZL, TEMP2
		cpc ZH, TEMP3
		brlo inc_cnt_in_memory_lp1_out
		inc TEMP
		subi ZL, 100
		sbci ZH, 0
		rjmp inc_cnt_in_memory_lp1

	inc_cnt_in_memory_lp1_out:

	ldi TEMP2, 48
	add TEMP, TEMP2
	st X+, TEMP

	; put back second digit
	clr TEMP
	ldi TEMP2, 10
	ldi TEMP3, 0

	inc_cnt_in_memory_lp2:
		cp ZL, TEMP2
		cpc ZH, TEMP3
		brlo inc_cnt_in_memory_lp2_out
		inc TEMP
		subi ZL, 10
		sbci ZH, 0
		rjmp inc_cnt_in_memory_lp2

	inc_cnt_in_memory_lp2_out:

	ldi TEMP2, 48
	add TEMP, TEMP2
	st X+, TEMP

	; put back third digit
	clr TEMP
	ldi TEMP2, 1
	ldi TEMP3, 0

	inc_cnt_in_memory_lp3:
		cp ZL, TEMP2
		cpc ZH, TEMP3
		brlo inc_cnt_in_memory_lp3_out
		inc TEMP
		subi ZL, 1
		sbci ZH, 0
		rjmp inc_cnt_in_memory_lp3

	inc_cnt_in_memory_lp3_out:

	ldi TEMP2, 48
	add TEMP, TEMP2
	st X+, TEMP
	ret




next_v:
	push XL
	push XH
	push YL
	push ZL
	push ZH
	
	in ZH, SPH
	in ZL, SPL

	ldd YL, Z+9
	ldd XH, Z+10
	ldd XL, Z+11

	; divide by 2
	lsr YL
	ror XH
	ror XL

	brcc next_v_end ; if no carry

	; inp = 2*inp + 1 (reverse division)
	rol XL ; or does not affect carry
	rol XH
	rol YL 

	; multiply by 3
	mov TEMP, XL
	mov TEMP2, XH
	mov TEMP3, YL

	add XL, TEMP
	adc XH, TEMP2
	adc YL, TEMP3

	add XL, TEMP
	adc XH, TEMP2
	adc YL, TEMP3

	; add 1
	ldi TEMP, 1
	ldi TEMP2, 0
	add XL, TEMP
	adc XH, TEMP2
	adc YL, TEMP2

	next_v_end:

	std Z+9, YL
	std Z+10, XH
	std Z+11, XL

	pop ZH
	pop ZL
	pop YL
	pop XH
	pop XL

	ret




next_v_in_memory:
	clr ZL ; store count
	clr ZH
	clr YL
	ldi TEMP3, 0

	; load pointer to row 2 string
	ldi XH, high(display_dm2)
	ldi XL, low(display_dm2)

	; point X to first digit
	adiw XH:XL, 10

	; get first digit
	ld TEMP, X+
	subi TEMP, 48

	ldi TEMP2, 0xA0
	mul TEMP, TEMP2
	mov ZL, r0
	mov ZH, r1
	ldi TEMP2, 0x86
	mul TEMP, TEMP2
	add ZH, r0
	adc YL, r1
	ldi TEMP2, 0x1
	mul TEMP, TEMP2
	add YL, r0

	; second digit
	ld TEMP, X+
	subi TEMP, 48

	ldi TEMP2, 0x10
	mul TEMP, TEMP2
	add ZL, r0
	adc ZH, r1
	adc YL, TEMP3
	ldi TEMP2, 0x27
	mul TEMP, TEMP2
	add ZH, r0
	adc YL, r1

	; third digit
	ld TEMP, X+
	subi TEMP, 48

	ldi TEMP2, 0xE8
	mul TEMP, TEMP2
	add ZL, r0
	adc ZH, r1
	adc YL, TEMP3
	ldi TEMP2, 0x3
	mul TEMP, TEMP2
	add ZH, r0
	adc YL, r1

	; fourth digit
	ld TEMP, X+
	subi TEMP, 48

	ldi TEMP2, 100
	mul TEMP, TEMP2
	add ZL, r0
	adc ZH, r1
	adc YL, TEMP3

	; fifth digit
	ld TEMP, X+
	subi TEMP, 48

	ldi TEMP2, 10
	mul TEMP, TEMP2
	add ZL, r0
	adc ZH, r1
	adc YL, TEMP3

	; sixth digit
	ld TEMP, X+
	subi TEMP, 48

	ldi TEMP2, 0
	add ZL, TEMP
	adc ZH, TEMP2
	adc YL, TEMP3

	; add 1
	push ZL
	push ZH
	push YL
	call next_v
	pop YL
	pop ZH
	pop ZL

	; revert X pointer
	subi XL, 6
	sbci XH, 0

	; put back first digit
	clr TEMP
	ldi TEMP2, 0xA0
	ldi TEMP3, 0x86
	ldi TEMP4, 0x1

	next_v_in_memory_lp1:
		cp ZL, TEMP2
		cpc ZH, TEMP3
		cpc YL, TEMP4
		brlo next_v_in_memory_lp1_out
		inc TEMP
		sub ZL, TEMP2
		sbc ZH, TEMP3
		sbc YL, r18
		rjmp next_v_in_memory_lp1

	next_v_in_memory_lp1_out:

	ldi TEMP2, 48
	add TEMP, TEMP2
	st X+, TEMP

	; put back second digit
	clr TEMP
	ldi TEMP2, 0x10
	ldi TEMP3, 0x27

	next_v_in_memory_lp2:
		cp ZL, TEMP2
		cpc ZH, TEMP3
		brlo next_v_in_memory_lp2_out
		inc TEMP
		sub ZL, TEMP2
		sbc ZH, TEMP3
		rjmp next_v_in_memory_lp2

	next_v_in_memory_lp2_out:

	ldi TEMP2, 48
	add TEMP, TEMP2
	st X+, TEMP

	; put back third digit
	clr TEMP
	ldi TEMP2, 0xE8
	ldi TEMP3, 0x3

	next_v_in_memory_lp3:
		cp ZL, TEMP2
		cpc ZH, TEMP3
		brlo next_v_in_memory_lp3_out
		inc TEMP
		sub ZL, TEMP2
		sbc ZH, TEMP3
		rjmp next_v_in_memory_lp3

	next_v_in_memory_lp3_out:

	ldi TEMP2, 48
	add TEMP, TEMP2
	st X+, TEMP

	; put back fourth digit
	clr TEMP
	ldi TEMP2, 100
	ldi TEMP3, 0

	next_v_in_memory_lp4:
		cp ZL, TEMP2
		cpc ZH, TEMP3
		brlo next_v_in_memory_lp4_out
		inc TEMP
		sub ZL, TEMP2
		sbc ZH, TEMP3
		rjmp next_v_in_memory_lp4

	next_v_in_memory_lp4_out:

	ldi TEMP2, 48
	add TEMP, TEMP2
	st X+, TEMP

	; put back fifth digit
	clr TEMP
	ldi TEMP2, 10
	ldi TEMP3, 0

	next_v_in_memory_lp5:
		cp ZL, TEMP2
		cpc ZH, TEMP3
		brlo next_v_in_memory_lp5_out
		inc TEMP
		sub ZL, TEMP2
		sbc ZH, TEMP3
		rjmp next_v_in_memory_lp5

	next_v_in_memory_lp5_out:

	ldi TEMP2, 48
	add TEMP, TEMP2
	st X+, TEMP

	; put back sixth digit
	clr TEMP
	ldi TEMP2, 1
	ldi TEMP3, 0

	next_v_in_memory_lp6:
		cp ZL, TEMP2
		cpc ZH, TEMP3
		brlo next_v_in_memory_lp6_out
		inc TEMP
		sub ZL, TEMP2
		sbc ZH, TEMP3
		rjmp next_v_in_memory_lp6

	next_v_in_memory_lp6_out:

	ldi TEMP2, 48
	add TEMP, TEMP2
	st X+, TEMP

	ret




; Function that delays for a period of time using busy-loop
delay:
	push TEMP
	push TEMP2
	push TEMP3
	; Nested delay loop
	ldi TEMP, 0x15
x1:
		ldi TEMP2, 0xFF
x2:
			ldi TEMP3, 0xFF
x3:
				dec TEMP3
				brne x3
			dec TEMP2
			brne x2
		dec TEMP
		brne x1

	pop TEMP3
	pop TEMP2
	pop TEMP
	ret





; FUNCTION
; Checks which bbutton has been pressed.
;
; Input: None 
; Return: button with coresponding value
;
; RIGHT = 5
; UP = 4
; DOWN = 3
; LEFT = 2
; SELECT = 1
; 
;
; ADC Values for Buttons
;
; RIGHT	= 0x032
;
; board v1.0 
; UP = 0x0FA
; DOWN = 0x1C2
; LEFT = 0x28A
; SELECT = 0x352
;
; board v1.1 
; UP = 0x0C3
; DOWN = 0x17C
; LEFT = 0x22B
; SELECT = 0x316

check_button:
	push TEMP
	push TEMP2
	push TEMP3

	; start conversion
	lds	TEMP, ADCSRA
	ori TEMP, 0b01000000     ; start conversion
	sts	ADCSRA, TEMP

	; wait for A2D conversion to complete
	wait:
		lds TEMP, ADCSRA
		andi TEMP, 0b01000000
		brne wait

	; read the value available as 10 bits in ADCH:ADCL
	lds TEMP, ADCL
	lds TEMP2, ADCH
		
	clr button

	rjmp v1
;; V.0
;; Currently diabled by rjmp
	ldi TEMP3,0x3
	cpi TEMP, 0x52
	cpc TEMP2, TEMP3
	brsh skip
	inc button
	
	ldi TEMP3,0x2
	cpi TEMP, 0x8a
	cpc TEMP2, TEMP3
	brsh skip
	inc button
	
	ldi TEMP3,0x1
	cpi TEMP, 0xc2
	cpc TEMP2, TEMP3
	brsh skip
	inc button
	
	ldi TEMP3,0x0
	cpi TEMP, 0xfa
	cpc TEMP2, TEMP3
	brsh skip
	inc button
	
	ldi TEMP3,0x0
	cpi TEMP, 0x32
	cpc TEMP2, TEMP3
	brsh skip
	inc button

	rjmp skip

v1:

;; FOR ASSIGNMENT, V.1

	ldi TEMP3,0x3
	cpi TEMP, 0x16
	cpc TEMP2, TEMP3
	brsh skip
	inc button
	
	ldi TEMP3,0x2
	cpi TEMP, 0x2b
	cpc TEMP2, TEMP3
	brsh skip
	inc button
	
	ldi TEMP3,0x1
	cpi TEMP, 0x7c
	cpc TEMP, TEMP3
	brsh skip
	inc button
	
	ldi TEMP3,0x0
	cpi TEMP, 0xc3
	cpc TEMP2, TEMP3
	brsh skip
	inc button
	
	ldi TEMP3,0x0
	cpi TEMP, 0x32
	cpc TEMP2, TEMP3
	brsh skip
	inc button

skip:
	pop TEMP3
	pop TEMP2
	pop TEMP
	ret
