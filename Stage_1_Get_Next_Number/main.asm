;
; CSC 230: Assignment 1
;  
; YOUR NAME GOES HERE: Damandeep Singh Bawa
;	Date: Sept 14, 2019
;
; This program generates each number in the Collatz sequence and stops at 1. 
; It retrieves the number at which to start the sequence from data memory 
; location labeled "input", then counts how many numbers there are in the 
; sequence (by generating them) and stores the resulting count in data memory
; location labeled "output". For more details see the related PDF on conneX.
;
; Input:
;  (input) Positive integer with which to start the sequence (8-bit).
;
; Output: 
;  (output) Number of items in the sequence as 16-bit little-endian integer.
;
; The code provided below already contains the labels "input" and "output".
; In the AVR there is no way to automatically initialize data memory, therefore
; the code that initializes data memory with values from program memory is also
; provided below.
;
.cseg
.org 0
	ldi ZH, high(init<<1)		; initialize Z to point to init
	ldi ZL, low(init<<1)
	lpm r0, Z+					; get the first byte
	sts input, r0				; store it in data memory
	lpm r0, Z					; get the second byte
	sts input+1, r0				; store it in data memory
	clr r0

;*** Do not change anything above this line ***

;****
; YOUR CODE GOES HERE:
;

.def ansL=r28 ; same as Y
.def ansH=r29
.def inpL=r26 ; same as X
.def inpH=r27
.def const3=r16
.def carry=r17   ; used in multiplication by 3
.def cmp_tmp=r18 ; used in checking if we had reached inp=1

	clr ansL
	clr ansH
	lds inpL, input
	ldi const3, 3

lp:
	; inc counter
	adiw ansH:ansL, 1

	; divide by 2
	lsr inpH
	ror inpL

	brcc lp ; if no carry (remainder after division)

	; exit if inpL=inpH=0 and carry 1 (number was 1)
	clr cmp_tmp
	or cmp_tmp, inpL
	or cmp_tmp, inpH
	breq store_output

	; inp = 2*inp + 1 (reverse division)
	rol inpL ; or does not affect carry
	rol inpH

	; multiply by 3
	mul inpL, const3 ; puts result in r1(H):r0(L)
	mov inpL, r0
	mov carry, r1
	
	mul inpH, const3
	mov inpH, r0     ; if value in r1, then data has overflowed
	add inpH, carry 

	; add 1
	adiw inpH:inpL, 1

	rjmp lp

store_output:
	sts output, ansL
	sts output+1, ansH
	rjmp done

;
; YOUR CODE FINISHES HERE
;****

;*** Do not change anything below this line ***

done:	jmp done

; This is the constant for initializing the "input" data memory location
; Note that program memory must be specified in double-bytes (words).
init:	.db 0x07, 0x00

; This is in the data memory segment (i.e. SRAM)
; The first real memory location in SRAM starts at location 0x200 on
; the ATMega 2560 processor. Locations below 0x200 are reserved for
; memory addressable registers and I/O
;
.dseg
.org 0x200
input:	.byte 2
output:	.byte 2
