; destroys A register
.import _putchar

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

.export print_1dig
.export print_2dig
