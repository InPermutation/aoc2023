; destroys A register
.ZEROPAGE
.import HTD_OUT
HEXTMP: .res 1

.CODE
.import _putchar, htd

print_5dig:
	; Convert SUM to BCD
	jsr htd

	; Print the BCD sum as a 5-digit decimal number
	lda HTD_OUT+2
	jsr print_1dig
	lda HTD_OUT+1
	jsr print_2dig
	lda HTD_OUT
print_2dig:
	pha

	clc
	and #$F0
	ror
	ror
	ror
	ror
	clc
	adc #'0'
	jsr _putchar

	pla
print_1dig:
	and #$0F
	clc
	adc #'0'
	jsr _putchar

	rts

print_hex:
	pha

	and #$F0
	clc
	ror
	ror
	ror
	ror
	jsr print_hex1
	pla
	and #$0F
	clc
print_hex1:
	sta HEXTMP
	txa
	pha
	ldx HEXTMP
	lda HEXDIGITS,X
	jsr _putchar

	pla
	tax
	rts

HEXDIGITS: .byte "0123456789ABCDEF"


.export print_1dig, print_2dig, print_5dig, print_hex
