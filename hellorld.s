.org $200
.segment "STARTUP"
.segment "INIT"
.segment "ONCE"
.segment "CODE"

; Constants
NEWLINE = $0A

; Addresses
PTR = $10
FIRST_DIG = $12
LAST_DIG = $13
SUM = $14
OUT = $F000

init:
	cli
	cld
	ldx #$ff
	txs

	ldy #0 ; Y must remain 0 at all times for indirect addressing
	; We can also use it to zero-out (SUM)
	sty SUM
	sty SUM+1

	lda #<(data)
	sta PTR
	lda #>(data)
	sta PTR+1

do_line:
	lda #NEWLINE
	sta FIRST_DIG
	lda (PTR),Y
	beq exit
do_ch:
	lda (PTR),Y
	beq endl
	cmp #NEWLINE
	beq endl
	cmp #'9' + 1
	bmi do_digit
backout:
	jsr next_ch
	jmp do_ch
do_digit:
	sta LAST_DIG
	ldx FIRST_DIG
	cpx #NEWLINE
	bne backout
	sta FIRST_DIG
	jmp backout

endl:
	; ASC to binary
	lda FIRST_DIG
	sec
	sbc #'0'
	sta FIRST_DIG
	sta OUT
	lda LAST_DIG
	sec
	sbc #'0'
	sta LAST_DIG
	sta OUT
	jsr next_ch
	jmp do_line

exit:
	brk

next_ch:
	pha
	lda PTR
	clc
	adc #1
	sta PTR
	lda PTR+1
	adc #0
	sta PTR+1
	pla
	rts

data: .incbin "input"
	.byte 0
