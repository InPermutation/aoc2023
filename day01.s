; Constants
NEWLINE = $0A
EOF = $FF

.ZEROPAGE
; Addresses
FIRST_DIG = $12
LAST_DIG = $13
.import HTD_IN, HTD_OUT
SUM = HTD_IN
HALT := $FFF9

.CODE
.import _putchar
.import _getchar

.import htd
.import print_1dig, print_2dig

.proc _main
	cli
	cld
	ldx #0
	stx SUM
	stx SUM+1
do_line:
	lda #NEWLINE
	sta FIRST_DIG
	jsr _getchar
	cmp #EOF
	beq @exit
	bne @chknl
@do_ch:
	jsr _getchar
	cmp #EOF
	beq @endl
@chknl:
	cmp #NEWLINE
	beq @endl
	cmp #'9' + 1
	bmi @do_digit
	; assumes #':' never appears in the input:
	bne @do_ch
@do_digit:
	; always update LAST_DIG
	sta LAST_DIG
	ldx FIRST_DIG
	cpx #NEWLINE
	; if FIRST_DIG is already set: try next ch
	bne @do_ch
	; else: set FIRST_DIG before trying next ch
	sta FIRST_DIG
	beq @do_ch

@endl:
	; ASC to binary
	lda LAST_DIG
	sec
	sbc #'0'
	sta LAST_DIG
	lda FIRST_DIG
	sec
	sbc #'0'
	sta FIRST_DIG

	; 10x FIRST_DIG
	clc
	adc FIRST_DIG
	adc FIRST_DIG
	adc FIRST_DIG
	adc FIRST_DIG
	adc FIRST_DIG
	adc FIRST_DIG
	adc FIRST_DIG
	adc FIRST_DIG
	adc FIRST_DIG
	; +1x LAST_DIG
	adc LAST_DIG

	; Add to SUM
	clc
	adc SUM
	sta SUM
	lda #0
	adc SUM+1
	sta SUM+1

	jmp do_line

@exit:
	; Convert SUM to BCD
	jsr htd

	; Print the BCD sum as a 5-digit decimal number
	lda HTD_OUT+2
	jsr print_1dig
	lda HTD_OUT+1
	jsr print_2dig
	lda HTD_OUT
	jsr print_2dig

	lda #NEWLINE
	jsr _putchar

	lda #0
	jmp HALT

.endproc
.export _main
