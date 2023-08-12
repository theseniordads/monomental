* MONO MENTAL by SENIOR DADS
* "Yogie Baird" sequence.

yogie_baird:
	lea	yogie_screen,a0
	lea	screen3-34,a1
	bsr	depack
	move.l	#screen3,yogie_source
.loop	move.l	back,a0
	bsr	black_screen
	bsr	scan_strip
	bsr	fadein_mask
	wait_vbl	
	bsr	swap_screens
	cmp.b	#$39,$fffffc02.w
	bne.s	.loop
	rts

scan_strip:
	move.w	scan_pos,d0
	move.w	d0,d1
	add.w	#12,d0
	cmp.w	#80,d0
	ble.s	.no_reset
	sub.w	#80,d0
	st	scan_wrapped
.no_reset
	move.w	d0,scan_pos
	move.l	back,a0
	move.l	yogie_source,a1
	adda.w	d1,a0
	adda.w	d1,a1
	movem.l	scan_mask,d1-d3
	move.l	d1,d4
	move.l	d2,d5
	move.l	d3,d6
	not.l	d4
	not.l	d5
	not.l	d6

i	set	0
	REPT	400
	move.l	i(a1),d0
	and.l	d1,d0
	or.l	d4,d0
	move.l	d0,i(a0)
	move.l	i+4(a1),d0
	and.l	d2,d0
	or.l	d5,d0
	move.l	d0,i+4(a0)
	move.l	i+8(a1),d0
	and.l	d3,d0
	or.l	d6,d0
	move.l	d0,i+8(a0)
i	set	i+80
	ENDR
	rts

fadein_mask:
	if_false.s	scan_wrapped,.no_fadeup
	sf	scan_wrapped
	bsr	.scroll_mask
	bsr	.scroll_mask
	bsr	.scroll_mask
	lea	scan_mask_source,a1
	lea	scan_mask,a2
	REPT	6
	move.w	(a0)+,d0
	move.w	(a1)+,d1
	and.w	d0,d1
	move.w	d1,(a2)+
	ENDR
.no_fadeup
	rts
.scroll_mask
	lea	fadein_data+(6*2),a0
	REPT	6
	roxl.w	-(a0)
	ENDR
	ori.w	#1,(5*2)(a0)
	rts

scan_mask_source
	REPT	6
	dc.w	%1111111111110101
	ENDR
scan_mask	ds.l	3

fadein_data	dcb.l	3,0

scan_pos	dc.w	0

yogie_screen	incbin	pix\yogie.pi3
	even

yogie_source	ds.l	1
scan_wrapped	ds.b	1
	even

