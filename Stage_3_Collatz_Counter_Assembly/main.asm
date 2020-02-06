
.org 0x0000
	jmp setup

.org 0x0048
	jmp timer3_ISR

.org 0x0028
	jmp timer1_ISR
    
.org 0x0072

#include "lcd.asm"

.cseg

; r18, r19 reserved for liberary use.
; TEMP=r16, defined in liberary
; TEMP2=r17, defined in liberary
; X and Y may be used in temps
.def TEMP3=r20
.def TEMP4=r21
.def button=r22
.def row1_offset=r23
.def prev_button=r15

#include "helper (1).asm"

setup:
	; initialize
	clr button
	clr prev_button
	clr row1_offset
	inc row1_offset
	inc row1_offset

	; init stack pointer
	ldi TEMP, high(RAMEND)
	out SPH, TEMP
	ldi TEMP, low(RAMEND)
	out SPL, TEMP

	call adc_init
	call lcd_init

	; put 0 in char
	ldi TEMP, 0b00110000
	sts char, TEMP

	; SHOW GREETINGS AT START
	call put_greetings
	call refresh_screen

	call delay ; wait some time
	call delay
	call delay ; wait some time
	call delay

	; PUT WORKING DISPLAY
	call put_working_display
	call refresh_screen

	call timer1_setup
	call timer3_setup

	rjmp main_loop


main_loop:	
	;call delay
	call check_button

	; depending on button
	cp button, prev_button
	breq main_after_buttons

	call update_cursor_pos
	call update_value_under_cursor

	main_after_buttons:
	; toggle lights
	lds r16, PORTL
	ldi r17, 0b10100000
	eor r16, r17
	sts PORTL, r16

	call refresh_screen

	call toggle_cursor_char; in memory

	mov prev_button, button

	rjmp main_loop

; if left or right is pressed go to corrsenponding position.
update_cursor_pos:

	cpi button, 2
	breq move_left

	cpi button, 5
	breq move_right

	ret

	move_left:
		call reinforce_cursor_char

		cpi row1_offset, 0
		breq update_cursor_pos_end
		dec row1_offset	
		rjmp update_cursor_pos_end

	move_right:
		call reinforce_cursor_char

		cpi row1_offset, 4
		breq update_cursor_pos_end
		inc row1_offset	
		rjmp update_cursor_pos_end

	update_cursor_pos_end:
		
		; STORE CORESPONDING VALUE IN CHAR
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

		; store selected char
		ld TEMP, X
		sts char, TEMP

		ret

row1_offset_dict: .db 3,4,5,6,14,0


; if up or down change to corrsenponding value
; use array of ofssets to only update one char in memory.
update_value_under_cursor:

	; load char in TEMP
	lds TEMP, char

	cpi button, 4
	breq move_up

	cpi button, 3
	breq move_down

	ret
	
	move_up:
		cpi TEMP, 42
		breq call_reset_count
		cpi TEMP, 57
		breq wrap_zero
		inc TEMP
		rjmp update_value_under_cursor_end

	wrap_zero:
		ldi TEMP, 48
		rjmp update_value_under_cursor_end

	move_down:
		cpi TEMP, 42
		breq call_reset_count
		cpi TEMP, 48
		breq wrap_nine
		dec TEMP
		rjmp update_value_under_cursor_end

	wrap_nine:
		ldi TEMP, 57
		rjmp update_value_under_cursor_end

	call_reset_count:
		call reset_count
		ret

	update_value_under_cursor_end:
		sts char, TEMP
		call reinforce_cursor_char
		ret

toggle_cursor_char:

	; load pointer to row 1 string
	ldi XH, high(display_dm1)
	ldi XL, low(display_dm1)

	; load offset in TEMP DICT_LOOKUP
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

	; load char in TEMP
	ld TEMP, X

	lds TEMP2, char
	eor TEMP, TEMP2
	ldi TEMP2, 0b00100000 
	eor TEMP, TEMP2

	st X, TEMP

	ret

.dseg 
char: .byte 1
.cseg

timer1_ISR:

	push TEMP
	push TEMP2
	push ZL
	push ZH
	push XL
	push XH
	lds TEMP, SREG
	push TEMP

	lds ZL, overflow_count
	lds ZH, overflow_count+1
	lds XL, overflow_counter
	lds XH, overflow_counter+1

	cp XL, ZL
	cpc XH, ZH
	breq timer1_do

	adiw ZH:ZL, 1
	
	sts overflow_count, ZL
	sts overflow_count+1, ZH

	rjmp timer1_end

	timer1_do: ; do the thing
	
	call inc_cnt_in_memory
	call next_v_in_memory

	lds TEMP, PORTL
	ldi TEMP2, 0b00001010
	eor TEMP, TEMP2
	sts PORTL, TEMP

	ldi TEMP, 0
	sts overflow_count, TEMP
	sts overflow_count+1, TEMP

	timer1_end:

	pop TEMP
	sts SREG, TEMP
	pop XH
	pop XL
	pop ZH
	pop ZL
	pop TEMP2
	pop TEMP
	reti

.dseg
overflow_count:.byte 2
.cseg

timer3_ISR:

	push TEMP
	push TEMP2
	push ZL
	push ZH
	push XL
	push XH
	lds TEMP, SREG
	push TEMP

	; do some

	timer3_end:

	pop TEMP
	sts SREG, TEMP
	pop XH
	pop XL
	pop ZH
	pop ZL
	pop TEMP2
	pop TEMP
	reti

