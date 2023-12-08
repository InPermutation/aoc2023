; Constants
NEWLINE = $0A
EOF = $FF

.ZEROPAGE
; Addresses
; All of these are in BCD!!
; Assumption: sum will fit in 6 digits (3 BCD bytes)
SUM: .res 3
; Assumption: NUM will fit in 4 digits (2 BCD bytes)
NUM: .res 2
LO: .res 1
HI: .res 1
IS_FINAL: .res 1
CH: .res 1

.CODE
; Addresses
LAST_ROW := $A000
CUR_ROW := $A100
NEXT_ROW := $A200
HALT := $FFF9

.import _putchar
.import _getchar

.import print_hex

_main:
	cli
	cld
	ldx #0
	stx SUM
	stx SUM+1
	stx SUM+2
	stx IS_FINAL
	lda #'.'
@init:
	sta LAST_ROW,X
	sta CUR_ROW,X
	sta NEXT_ROW,X
	dex
	bne @init


	; Load first row into NEXT_ROW
	jsr advance_row
@loop:
	jsr advance_row
	jsr process_cur_row
	lda IS_FINAL
	beq @loop
exit:
	lda SUM+2
	jsr print_hex
	lda SUM+1
	jsr print_hex
	lda SUM
	jsr print_hex

	lda #NEWLINE
	jsr putchar

	lda #0
	jmp HALT

advance_row:
	pha
	txa
	pha

	; Assumption: Input lines end with #NEWLINE
	ldx #0
@loop:
	lda CUR_ROW,X
	sta LAST_ROW,X
	lda NEXT_ROW,X
	sta CUR_ROW,X
	jsr getchar
	sta NEXT_ROW,X
	cmp #EOF
	beq advance_final_row
	cmp #NEWLINE
	beq @endl
	inx
	bne @loop ; Assumption: <256b of input
@endl:
	pla
	tax
	pla
	rts

advance_final_row:
	cpx #0
	beq @finish_advance
@err_eof_middle_of_line:
	; found EOF in a line
	lda #'E'
	jsr putchar
	lda #'O'
	jsr putchar
	lda #'F'
	jsr putchar
	txa
	jsr putchar
	lda #NEWLINE
	jsr putchar
	jmp HALT
@loop:
	lda CUR_ROW,X
	sta LAST_ROW,X
	lda NEXT_ROW,X
	sta CUR_ROW,X
	cmp #NEWLINE
	beq @endl
@finish_advance:
	lda #'.'
	sta NEXT_ROW,X
	inx
	bne @loop
@endl:
	pla
	tax
	pla
	inc IS_FINAL
	rts

process_cur_row:
	pha
	txa
	pha

	ldx #0
@loop:
	lda CUR_ROW,X
	cmp #NEWLINE
	beq @endl
	jsr is_digit
	beq @next
	jsr parse_num
	jsr check_around_num
	beq @next
	jsr add_to_sum
@next:
	inx
	bne @loop
@endl:
	pla
	tax
	pla
	rts

getchar:
	txa
	pha
	tya
	pha

	jsr _getchar
	sta CH

	pla
	tay
	pla
	tax
	lda CH
	rts

putchar:
	sta CH
	txa
	pha
	tya
	pha

	lda CH
	jsr _putchar

	pla
	tay
	pla
	tax
	lda CH
	rts

add_to_sum:
	pha
	sed

	lda NUM
	clc
	adc SUM
	sta SUM
	lda NUM+1
	adc SUM+1
	sta SUM+1
	lda #0
	adc SUM+2
	sta SUM+2

	cld
	pla
	rts

is_digit:
	cmp #'9'+1
	bpl @no
	cmp #'0'
	bmi @no
@yes:
	lda #1
	rts
@no:
	lda #0
	rts

parse_num:
	; LO = MAX(0, X-1)
	stx LO
	cpx #0
	beq @clrtmp
	dec LO
@clrtmp:
	lda #0
	sta NUM
	sta NUM+1
@ndig:

	.repeat 4
	asl NUM
	rol NUM+1
	.endrep

	lda CUR_ROW,X
	sec
	sbc #'0'
	ora NUM
	sta NUM
	inx
	lda CUR_ROW,X
	jsr is_digit
	bne @ndig

	; HI = X = last digit + 1
	stx HI
	rts

check_around_num:
	ldy LO
	lda CUR_ROW,Y
	jsr is_symbol
	bne @yes
@loop:
	lda LAST_ROW,Y
	jsr is_symbol
	bne @yes
	lda NEXT_ROW,Y
	jsr is_symbol
	bne @yes

	iny
	cpy HI
	bne @loop

	;Y==HI
	lda CUR_ROW,Y
	jsr is_symbol
	bne @yes
	lda LAST_ROW,Y
	jsr is_symbol
	bne @yes
	lda NEXT_ROW,Y
	jsr is_symbol
@yes:
	rts

is_symbol:
	cmp #NEWLINE
	beq @no
	cmp #'.'
	beq @no
	jsr is_digit
	bne @no
@yes:
	lda #1
	rts
@no:
	lda #0
	rts

.export _main
