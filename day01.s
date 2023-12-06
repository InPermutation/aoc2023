.segment "CODE"

; Constants
NEWLINE = $0A
EOF = $FF

; Addresses
FIRST_DIG = $12
LAST_DIG = $13
SUM = $14
HTD_IN = SUM
HTD_OUT = $16
HALT := $FFF9

.import _putchar
.import _getchar

.import print_1dig
.import print_2dig

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; From http://www.6502.org/source/integers/hex2dec.htm
; (which is why it uses __H suffix syntax)
TABLE:	.byte    0, 0H, 1H,  0, 0H, 2H,  0, 0H, 4H,  0, 0H, 8H
	.byte    0, 0H,16H,  0, 0H,32H,  0, 0H,64H,  0, 1H,28H
	.byte    0, 2H,56H,  0, 5H,12H,  0,10H,24H,  0,20H,48H
	.byte    0,40H,96H,  0,81H,92H,  1,63H,84H,  3,27H,68H
htd:
	; Save registers A and X
	pha
	txa
	pha

	; Zero HTD_OUT
	ldx #0
	stx HTD_OUT
	stx HTD_OUT+1
	stx HTD_OUT+2

	ldx #15 + 15 + 15 ; 3x15 bits.
	sed
@loop:
	asl HTD_IN      ; (0 to 15 is 16 bit positions.)
	rol HTD_IN+1    ; If the next highest bit was 0,
	bcc @htd1       ; then skip to the next bit after that.
	lda HTD_OUT     ; But if the bit was 1,
	clc             ; get ready to
	adc TABLE+2,X   ; add the bit value in the table to the
	sta HTD_OUT     ; output sum in decimal--  first low byte,
	lda HTD_OUT+1   ; then middle byte,
	adc TABLE+1,X
	sta HTD_OUT+1
	lda HTD_OUT+2   ; then high byte,
	adc TABLE,X     ; storing each byte
	sta HTD_OUT+2   ; of the summed output in HTD_OUT.

@htd1:	dex             ; By taking X in steps of 3, we don't have to
	dex             ; multiply by 3 to get the right bytes from the
	dex             ; table.
	bpl @loop

	; Restore registers A and X
	pla
	tax
	pla
	cld
	rts
.endproc
.export _main
