; Constants
NEWLINE = $0A
EOF = $FF

.ZEROPAGE
; Addresses
; All of these are in BCD!!
; Assumption: sum will fit in 6 digits (3 BCD bytes)
SUM: .res 3
HALT := $FFF9

.CODE
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
exit:
	lda SUM+2
	jsr print_hex
	lda SUM+1
	jsr print_hex
	lda SUM
	jsr print_hex

	lda #NEWLINE
	jsr _putchar

	lda #0
	jmp HALT

.export _main
