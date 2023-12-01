.org $200
.segment "STARTUP"
.segment "INIT"
.segment "ONCE"
.segment "CODE"
begin:
	ldx #0
loop:	lda msg,X
	beq end
	sta $F000
	inx
	bne loop
end:
	brk

msg: .asciiz "Hellorld"
