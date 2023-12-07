; Constants
NEWLINE = $0A
EOF = $FF

BAG_RED = 12
BAG_GREEN = 13
BAG_BLUE = 14

.ZEROPAGE
; Addresses
.import HTD_IN, HTD_OUT
SUM := HTD_IN
SUM_POS: .res 3
GAME_NUM: .res 1 ; game ID number
GAME_VALID: .res 1 ; 0 -> not valid, else -> valid
SHOW_RED: .res 1 ; the count of reds shown on this hand
SHOW_GREEN: .res 1 ; the count of green shown on this hand
SHOW_BLUE: .res 1 ; the count of blues shown on this hand
MAX_RED: .res 1
MAX_GREEN: .res 1
MAX_BLUE: .res 1
TMP: .res 2 ; temp var
POWER: .res 2 ; power of the current game

HALT := $FFF9

.CODE
.import _putchar
.import _getchar

.import print_5dig, print_hex

_main:
	cli
	cld
	ldx #0
	stx SUM
	stx SUM+1
	stx SUM_POS
	stx SUM_POS+1
	stx SUM_POS+2

next_game:
	jsr reset_game
	jsr read_game_num
@show_one:
	jsr read_one_show
	jsr check_one_show
	jsr update_maxes
	cmp #';'
	beq @show_one
@end_show:
	pha ; save last-read char
	lda GAME_VALID
	beq @not_valid
	clc
	lda GAME_NUM
	adc SUM
	sta SUM
	lda #0
	adc SUM+1
	sta SUM+1

@not_valid:
	jsr max_power
	clc
	lda POWER
	adc SUM_POS
	sta SUM_POS
	lda POWER+1
	adc SUM_POS+1
	sta SUM_POS+1
	lda #0
	adc SUM_POS+2
	sta SUM_POS+2

	pla ; restore last-read char
	cmp #EOF
	bne next_game
exit:
	jsr print_5dig
	lda #' '
	jsr _putchar

	lda SUM_POS+2
	jsr print_hex
	lda SUM_POS+1
	jsr print_hex
	lda SUM_POS
	jsr print_hex

	lda #NEWLINE
	jsr _putchar

	lda #0
	jmp HALT

reset_game:
	pha
	lda #1
	sta GAME_VALID
	lda #0
	sta SHOW_RED
	sta SHOW_GREEN
	sta SHOW_BLUE
	sta MAX_RED
	sta MAX_GREEN
	sta MAX_BLUE
	pla
	rts

read_game_num:
	pha
@find_space:
	jsr _getchar
	cmp #EOF
	beq exit
	cmp #' '
	bne @find_space

	jsr read_decimal ; chomps ':'
	sta GAME_NUM
	pla
	rts

check_one_show:
	pha

	lda SHOW_RED
	lda SHOW_GREEN
	lda SHOW_BLUE

	lda #BAG_RED
	cmp SHOW_RED
	bmi @not_valid

	lda #BAG_GREEN
	cmp SHOW_GREEN
	bmi @not_valid

	lda #BAG_BLUE
	cmp SHOW_BLUE
	bmi @not_valid
@valid:
	pla
	rts
@not_valid:
	lda #0
	sta GAME_VALID
	pla
	rts

read_decimal:
	lda #0
	sta TMP
@loop:
	jsr _getchar

	; Is it a digit? No -> @done
	cmp #'0'
	bmi @done
	cmp #'9'+1
	bpl @done

	; Convert ASCII to decimal
	sec
	sbc #'0'

	; Set aside next ones column:
	pha

	; Multiply existing TMP by 10
	clc
	lda TMP
	adc TMP
	adc TMP
	adc TMP
	adc TMP
	adc TMP
	adc TMP
	adc TMP
	adc TMP
	adc TMP
	sta TMP
	; Add A back in
	pla
	clc
	adc TMP
	sta TMP
	; Check next char
	jmp @loop
@done:
	lda TMP
	rts

read_one_show:
	jsr _getchar
	cmp #' '
	beq @read_one_hand
@not_ok:
	jsr _putchar
	lda #'!'
	jsr _putchar
	jmp HALT
@read_one_hand:
	jsr read_decimal
	pha
	jsr _getchar
	cmp #'r'
	beq @red
	cmp #'g'
	beq @green
	cmp #'b'
	beq @blue

@whoops:
	jsr _putchar
	lda #'E'
	jsr _putchar
	jmp HALT
@red:
	pla
	sta SHOW_RED
	bne @terminator
@green:
	pla
	sta SHOW_GREEN
	bne @terminator
@blue:
	pla
	sta SHOW_BLUE
	bne @terminator
@terminator:
	jsr _getchar
	cmp #'a'-1
	bpl @terminator
	cmp #','
	beq read_one_show
	pha

	pla
	rts

unexpected:
	lda #'?'
	jsr _putchar
	jmp HALT

max_power:
	pha
	txa
	pha

	lda #0
	sta POWER+1
	sta POWER

	; ASSUMPTION: power is never 0 (there's always red, green, and blue at least once in each game)
	ldx MAX_GREEN
@loopg:
	clc
	lda MAX_RED
	adc POWER
	sta POWER
	sta TMP
	lda #0
	adc POWER+1
	sta POWER+1
	sta TMP+1

	dex
	bne @loopg

	ldx MAX_BLUE
	dex
	beq @done
@loopb:
	lda TMP
	clc
	adc POWER
	sta POWER
	lda TMP+1
	adc POWER+1
	sta POWER+1

	dex
	bne @loopb
@done:

;	DEBUG
	lda SUM
	pha
	lda SUM+1
	pha

	lda POWER
	sta SUM
	lda POWER+1
	sta SUM+1
	jsr print_5dig
	lda #NEWLINE
	jsr _putchar

	pla
	sta SUM+1
	pla
	sta SUM
;	/DEBUG

	pla
	tax
	pla
	rts

update_maxes:
	pha

	lda SHOW_RED
	cmp MAX_RED
	bmi @g
	sta MAX_RED
@g:
	lda SHOW_GREEN
	cmp MAX_GREEN
	bmi @b
	sta MAX_GREEN
@b:
	lda SHOW_BLUE
	cmp MAX_BLUE
	bmi @q
	sta MAX_BLUE
@q:
	pla
	rts

.export _main
