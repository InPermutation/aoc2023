;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; From http://www.6502.org/source/integers/hex2dec.htm
; (which is why it uses __H suffix syntax)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.RODATA
TABLE:	.byte    0, 0H, 1H,  0, 0H, 2H,  0, 0H, 4H,  0, 0H, 8H
	.byte    0, 0H,16H,  0, 0H,32H,  0, 0H,64H,  0, 1H,28H
	.byte    0, 2H,56H,  0, 5H,12H,  0,10H,24H,  0,20H,48H
	.byte    0,40H,96H,  0,81H,92H,  1,63H,84H,  3,27H,68H

.ZEROPAGE
HTD_IN: .res 2
HTD_OUT: .res 3

.CODE
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

.export htd
.export HTD_IN
.export HTD_OUT
