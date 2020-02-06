;
; A2.asm
;
; Created: 2019-10-05 10:48:34 AM
; Author : daman
;


; Replace with your application code

; TEMP = r16, r17, r20, r21

.def _x=r24
.def _y=r25
.def cursor=r13
.def button=r19
.def const_10=r23
.def const_9=r22
.def zero=r12

prep:
	clr _x
	clr _y
	clr zero
	ldi const_10, 10
	ldi const_9, 9
    call load_data

	; Ready the ADC
	ldi r16, 0b10000111
	sts ADCSRA, r16
	ldi r16, 0b01000000
	sts ADMUX, r16

	; initialize PORTB and PORTL for output
	ldi	r16, 0b00001010
	out DDRB, r16
	ldi	r16, 0b10101010
	sts DDRL, r16


main:
	call refresh_cursor
	call refresh_lights
	;call delay
	;call check_button
	ldi button, 3
	call update_xy
	ldi button, 5
	call update_xy
	ldi button, 3
	call update_xy
    rjmp main


init: .db 1,0,0,0,0,0,0,0,0,0, 1,1,0,0,0,0,0,0,0,0, 1,2,1,0,0,0,0,0,0,0, 1,3,3,1,0,0,0,0,0,0, 1,4,6,4,1,0,0,0,0,0, 1,5,10,10,5,1,0,0,0,0, 1,6,15,20,15,6,1,0,0,0, 1,7,21,35,35,21,7,1,0,0, 1,8,28,56,70,56,28,8,1,0, 1,9,36,84,126,126,84,36,9,1

; FUNCTION
; Intialise psacal's trinagle in memory
;
; Overwrites: r16, r17, X, Z 
; Return: X = start of array
load_data:
	; set up couunter till 100
	clr r16
	ldi r17, 100

	ldi ZH, high(init<<1)
	ldi ZL, low(init<<1)

	ldi XH, high(pascal_triangle)
	ldi XL, low(pascal_triangle)

	load_next:
		lpm r0, Z+
		st X+, r0

		; break out after storing 100 elements
		inc r16
		cpse r16, r17
		rjmp load_next

		subi XL, 100
		sbci XH, 0

	ret

.dseg
.org 0x200
pascal_triangle: .byte 100
.cseg


; FUNCTION
; Writes new value to cursor
;
; Input: _x, _y, X(array head)
; Overwrites: r0, r1
; Return: cursor = start of array
refresh_cursor:
	; calculate 1D index in r1:0
	mul const_10, _y
	add r0, _x
	adc r1, zero

	; extract value to cursor
	add XL, r0
	adc XH, r1

	ld cursor, X
	
	sub XL, r0
	sbc XH, r1

	ret


; FUNCTION
; Shows output of cursor
;
; Input: cursor
; Overwrites: r16, cursor
; Return: shows lest significant 6-bits of cursor
refresh_lights:
	
	; Prepare 4 most significate bits
	lsl cursor
	rol r16
	lsl r16
	lsl cursor
	rol r16
	lsl r16
	lsl cursor
	rol r16
	lsl r16
	lsl cursor
	rol r16
	lsl r16

	out PORTB, r16

	; Prepare 4 least significate bits
	lsl cursor
	rol r16
	lsl r16
	lsl cursor
	rol r16
	lsl r16
	lsl cursor
	rol r16
	lsl r16
	lsl cursor
	rol r16
	lsl r16

	sts PORTL, r16

	ret


; FUNCTION
; Delay execution
;
; Input: None
; Overwrites: r16, r17, r20
; Return: resume execution after some time
delay:
	ldi r16, 0x3D
	
	x1:
		ldi r17, 0xFF
		x2:
			ldi r20, 0xFF
			x3:
				dec r20
				brne x3
			dec r17
			brne x2
		dec r16
		brne x1
	ret


; FUNCTION
; Checks which bbutton has been pressed.
;
; Input: None 
; Overwrites: r16, r17, r21, r20
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

	; start conversion
	lds	r16, ADCSRA
	ori r16, 0b01000000     ; start conversion
	sts	ADCSRA, r16

	; wait for A2D conversion to complete
	wait:
		lds r16, ADCSRA
		andi r16, 0b01000000
		brne wait

	; read the value available as 10 bits in ADCH:ADCL
	lds r16, ADCL
	lds r17, ADCH
		
	clr button

	rjmp v0
;; V.1
;; Currently diabled by rjmp
	ldi r21,0x3
	ldi r20,0x52
	cp r16, r20
	cpc r17, r21
	brsh skip
	inc button
	
	ldi r21,0x2
	ldi r20,0x8a
	cp r16, r20
	cpc r17, r21
	brsh skip
	inc button
	
	ldi r21,0x1
	ldi r20,0xc2
	cp r16, r20
	cpc r17, r21
	brsh skip
	inc button
	
	ldi r21,0x0
	ldi r20,0xfa
	cp r16, r20
	cpc r17, r21
	brsh skip
	inc button
	
	ldi r21,0x0
	ldi r20,0x32
	cp r16, r20
	cpc r17, r21
	brsh skip
	inc button

	rjmp skip

v0:

;; FOR ASSIGNMENT, V.0

	ldi r21,0x3
	ldi r20,0x16
	cp r16, r20
	cpc r17, r21
	brsh skip
	inc button
	
	ldi r21,0x2
	ldi r20,0x2b
	cp r16, r20
	cpc r17, r21
	brsh skip
	inc button
	
	ldi r21,0x1
	ldi r20,0x7c
	cp r16, r20
	cpc r17, r21
	brsh skip
	inc button
	
	ldi r21,0x0
	ldi r20,0xc3
	cp r16, r20
	cpc r17, r21
	brsh skip
	inc button
	
	ldi r21,0x0
	ldi r20,0x32
	cp r16, r20
	cpc r17, r21
	brsh skip
	inc button

skip:	
	ret


; FUNCTION
; Updates _x and _y values
;
; Input: button
; Overwrite: None
; Return: updated _x, _y

update_xy:

	case_1: ; SELECT
		cpi button, 1
		brne case_2
		rjmp update_xy_end

	case_2: ; LEFT
		cpi button, 2
		brne case_3
		cpse _x, zero
		dec _x
		rjmp update_xy_end

	case_3: ; DOWN
		cpi button, 3
		brne case_4
		cpse _y, const_9
		inc _y
		rjmp update_xy_end

	case_4: ; UP
		cpi button, 4
		brne case_5
		cpse _x, _y
		dec _y
		rjmp update_xy_end
	
	case_5: ; RIGHT
		cpse _x, _y
		inc _x

	update_xy_end:	
		ret
