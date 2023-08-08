* General binaries

* Converts from a number in d6 into character form d7 chars long in the
; text store a6.

;	IFNE	_num2text_on
_num2text:
	stack_save	d0
	ext.l	d6
	moveq	#0,d0
	subq.l	#1,d7
.loop	divu	#10,d6
	swap	d6
	move	d6,d0
	clr	d6
	swap	d6
	addi.b	#'0',d0
	move.b	d0,(a6,d7.w)
	dbf	d7,.loop
	stack_restore	d0
	rts
;	ENDC

* Converts into a number in d6 from a character d7 chars long in the
; text store a6.

	IFD	_text2num_on
_text2num:
	stack_save	d0
	ext.l	d6
	moveq	#0,d0
	subq.l	#1,d7
.loop	move.b	(a6)+,d0
	tst.b	d0
	beq.s	.exit
	mulu	#10,d6
	subi.b	#'0',d0
	add.b	d0,d6
	dbf	d7,.loop
.exit	stack_restore	d0
	rts
	ENDC

_copy_chars
.loop	move.b	(a5)+,(a6)+
	dbf	d7,.loop
	rts

* Set falcon video mode

_setfv		cmp.l	#'FVDO',(a0)+	4 bytes header
		bne.s	.error
		
.ready		addq.l	#2,a0
		move.l	$70.w,-(sp)
		move	sr,-(sp)
		move.l	#.vbl,$70
		move	#$2300,sr
		
		move	timer.w,d0
.wait		cmp	timer.w,d0
		beq.s	.wait
		
		move.l	(a0)+,$ff820e	offset & vwrap
		move.w	(a0)+,$ff8266	spshift
		move.l	#$ff8282,a1	horizontal control registers
.loop1		move	(a0)+,(a1)+
		cmp.l	#$ff8292,a1
		bne.s	.loop1
		move.l	#$ff82a2,a1	vertical control registers
.loop2		move	(a0)+,(a1)+
		cmp.l	#$ff82ae,a1
		bne.s	.loop2
		move	(a0)+,$ff82c2	video control
		move	(sp)+,sr
		move.l	(sp)+,$70
		moveq	#0,d0
		rts
.error		moveq	#-1,d0
		rts
.wrongmon	moveq	#-2,d0
		rts
.sm124		cmp.b	#0,(a0)
		bne.s	.wrongmon
		bra.s	.ready
.vga		cmp.b	#2,(a0)
		bne.s	.wrongmon
		bra.s	.ready
.vbl		addq.w	#1,timer.w
		rte
		

_savefv		lea	_FVbuffer1298,a1
		move.l	#'FVDO',(a1)+	4 bytes header
		move.b	$ff8006,(a1)+	monitor type
		move.b	$ff820a,(a1)+	sync
		move.l	$ff820e,(a1)+	offset & vwrap
		move.w	$ff8266,(a1)+	spshift
		move.l	#$ff8282,a0	horizontal control registers
.loop1		move	(a0)+,(a1)+
		cmp.l	#$ff8292,a0
		bne.s	.loop1
		move.l	#$ff82a2,a0	vertical control registers
.loop2		move	(a0)+,(a1)+
		cmp.l	#$ff82ae,a0
		bne.s	.loop2
		move	$ff82c2,(a1)+	video control
		rts
		
_restorefv	move.l	#_FVbuffer1298,a0
		bsr	_setfv
		rts


_FVbuffer1298	ds.w	22

* Another set mode.

_setasa
	move.l	$70.w,-(sp)
	move	sr,-(sp)
	move.l	#.vbl,$70.w
	move	#$2300,sr

	move	timer.w,d0
.wait	cmp	timer.w,d0
	beq.s	.wait

	move.b  (a0)+,$FFFF820A.w
	move.b  (a0)+,$FFFF8260.w
	move.w  (a0)+,$FFFF8266.w
	move.w  (a0)+,$FFFF8282.w
	move.w  (a0)+,$FFFF828C.w
	move.w  (a0)+,$FFFF82AC.w
	move.w  (a0)+,$FFFF82C0.w
	move.w  (a0)+,$FFFF82C2.w
	move.w  (a0)+,$FFFF8284.w
	move.w  (a0)+,$FFFF8286.w
	move.w  (a0)+,$FFFF8288.w
	move.w  (a0)+,$FFFF828A.w
	move.w  (a0)+,$FFFF82A2.w
	move.w  (a0)+,$FFFF82A4.w
	move.w  (a0)+,$FFFF82A6.w
	move.w  (a0)+,$FFFF82A8.w
	move.w  (a0)+,$FFFF82AA.w
	move.w  (a0),$FFFF8210.w           

	move	(sp)+,sr
	move.l	(sp)+,$70.w
	rts

.vbl	addq.w	#1,timer.w
	rte

_write_ikbd
	move.b	d7,ikbd.w
;	move.b	#1,key_flushed
;.loop	tst.b	key_flushed
;	bne.s	.loop
	rts

	IFD	_dc_ws
_digicall_writestring
.loop	move.b	(a0)+,d0
;.wait	digicall_outgoing
;	beq.s	.wait
	write_char_to_midi	d0
	tst.b	d0
	beq.s	.exit
	bra.s	.loop
.exit	rts
	ENDC
	
* Wait for d0 frames

	IFD	_wait_for_on
_wait_for
	bsr.s	_wait_once
	dbf	d0,_wait_for
	rts
_wait_once
	move	timer.w,d1
.loop	cmp.w	timer.w,d1
	beq.s	.loop
	rts
	ENDC
	
* Put trucolour logo in a1 (width d2 by height d3) at coords d0,d1 in
; screen pointed to by a0.

	IFND	screen_width
screen_width	equ	320
	ENDC

	IFD	_put_trucol_logo_on
_put_trucol_logo:
	ext.l	d1
	mulu	#screen_width*2,d1
	lea	(a0,d1.l),a0
	lea	(a0,d0.w*2),a0
	lsr	#1,d2
	subq	#1,d2
	subq	#1,d3
.loop1	move	d2,d0
	move.l	a0,a2
.loop2	move.l	(a1)+,(a2)+
	dbf	d0,.loop2
	adda.l	#screen_width*2,a0
	dbf	d3,.loop1
	rts
	ENDC 