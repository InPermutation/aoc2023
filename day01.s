; Constants
NEWLINE = $0A
EOF = $FF

.ZEROPAGE
; Addresses
FIRST_DIG: .res 1
LAST_DIG: .res 1
.import HTD_IN, HTD_OUT
FSM: .res 2
SUM = HTD_IN
HALT := $FFF9

.CODE
.import _putchar
.import _getchar

.import htd
.import print_1dig, print_2dig

.macro chgstate addr
	pha
	lda #>addr
	sta FSM+1
	lda #<addr
	sta FSM
	pla
.endmacro

.macro cond_ch ch, addr
	cmp ch
	bne :+
	chgstate addr
	jmp do_ch
:
.endmacro

.macro final_cond_ch ch, addr
	.local Skip
	cmp ch
	bne Skip
	chgstate addr
Skip:
.endmacro

.macro final_ch ch, emit
	cmp ch
	bne :+
	; Same as fsm_restart but keep PC here
	chgstate fsm_init
	final_cond_ch #'o', fsm_init_o
	final_cond_ch #'t', fsm_init_t
	final_cond_ch #'f', fsm_init_f
	final_cond_ch #'s', fsm_init_s
	final_cond_ch #'e', fsm_init_e
	final_cond_ch #'n', fsm_init_n
	lda emit
	jmp do_digit
:	jmp fsm_restart
.endmacro

_main:
	cli
	cld
	ldx #0
	stx SUM
	stx SUM+1
do_line:
	lda #NEWLINE
	sta FIRST_DIG
	chgstate fsm_init
	jsr _getchar
	cmp #EOF
	beq exit
	bne chknl
do_ch:
	jsr _getchar
	cmp #EOF
	beq endl
chknl:
	cmp #NEWLINE
	beq endl
	cmp #'9' + 1
	bmi do_digit
	jmp (FSM)
do_digit:
	; always update LAST_DIG
	sta LAST_DIG
	ldx FIRST_DIG
	cpx #NEWLINE
	; if FIRST_DIG is already set: try next ch
	bne do_ch
	; else: set FIRST_DIG before trying next ch
	sta FIRST_DIG
	beq do_ch

endl:
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

exit:
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


fsm_restart:
	; reset state to fsm_init and also retry
	chgstate fsm_init
fsm_init:
	cond_ch #'o', fsm_init_o
	cond_ch #'t', fsm_init_t
	cond_ch #'f', fsm_init_f
	cond_ch #'s', fsm_init_s
	cond_ch #'e', fsm_init_e
	cond_ch #'n', fsm_init_n
	jmp do_ch
; ONE
fsm_init_o:
	cond_ch #'n', fsm_one_n
	jmp fsm_restart
fsm_one_n:
	cond_ch #'i', fsm_nine_i
	final_ch #'e', #'1'

; TWO | THREE
fsm_init_t:
	cond_ch #'w', fsm_two_w
	cond_ch #'h', fsm_three_h
	jmp fsm_restart
fsm_two_w:
	final_ch #'o', #'2'
fsm_three_h:
	cond_ch #'r', fsm_three_r
	jmp fsm_restart
fsm_three_r:
	cond_ch #'e', fsm_three_e0
	jmp fsm_restart
fsm_three_e0:
	cond_ch #'i', fsm_eight_i
	final_ch #'e', #'3'

; FOUR | FIVE
fsm_init_f:
	cond_ch #'o', fsm_four_o
	cond_ch #'i', fsm_five_i
	jmp fsm_restart
fsm_four_o:
	cond_ch #'n', fsm_one_n
	cond_ch #'u', fsm_four_u
	jmp fsm_restart
fsm_four_u:
	final_ch #'r', #'4'
fsm_five_i:
	cond_ch #'v', fsm_five_v
	jmp fsm_restart
fsm_five_v:
	final_ch #'e', #'5'

; SIX | SEVEN
fsm_init_s:
	cond_ch #'i', fsm_six_i
	cond_ch #'e', fsm_seven_e0
	jmp fsm_restart
fsm_six_i:
	final_ch #'x', #'6'
fsm_seven_e0:
	cond_ch #'v', fsm_seven_v
	cond_ch #'i', fsm_eight_i
	jmp fsm_restart
fsm_seven_v:
	cond_ch #'e', fsm_seven_e1
	jmp fsm_restart
fsm_seven_e1:
	cond_ch #'i', fsm_eight_i
	final_ch #'n', #'7'

; EIGHT
fsm_init_e:
	cond_ch #'i', fsm_eight_i
	jmp fsm_restart
fsm_eight_i:
	cond_ch #'g', fsm_eight_g
	jmp fsm_restart
fsm_eight_g:
	cond_ch #'h', fsm_eight_h
	jmp fsm_restart
fsm_eight_h:
	final_ch #'t', #'8'

; NINE
fsm_init_n:
	cond_ch #'i', fsm_nine_i
	jmp fsm_restart
fsm_nine_i:
	cond_ch #'n', fsm_nine_n1
	jmp fsm_restart
fsm_nine_n1:
	cond_ch #'i', fsm_nine_i
	final_ch #'e', #'9'

.export _main
