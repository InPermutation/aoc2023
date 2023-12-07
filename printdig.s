; destroys A register
.ZEROPAGE
.import HTD_OUT

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

.export print_1dig, print_2dig, print_5dig
