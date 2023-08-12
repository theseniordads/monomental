* MONO MENTAL by SENIOR DADS

	include	..\includes\genmacro.s

	init_prog	normal_exit

	move.l	a7,old_stack
	lea	new_stack,a7
	bsr	init

	bsr	opening_titles
	bsr	yogie_baird	

	bsr	ret
	move.l	old_stack,a7
	rts

myvbl	subq.w	#1,$468.w
	rte

depack_pic_to_back
	move.l	back,a1
	lea	-34(a1),a1
	jsr	depack
	rts	

init	move.l	$70.w,oldvbl
	move.l	#myvbl,$70.w
	get_vidaddr	old_vidaddr
	clr.b	front+3
	clr.b	back+3
	move.l	front,a0
	bsr	black_screen
	move.l	back,a0
	bsr	black_screen
	bsr	swap_screens
	wait_vbl
	lea	opening_pic1,a0
	bsr	depack_pic_to_back
	lea	main_music,a0
	bsr	start_music
	bsr	swap_screens	
	rts

ret	bsr	stop_music
	set_vidaddr	old_vidaddr
	move.l	oldvbl,$70.w
	rts


set_clicks	macro
	move.w	\1,click_counter
	endm

if_not_endclicks	macro
	tst.w	click_counter
	IFEQ	('\0'-'')
	bne	\1
	ELSE
	bne.\0	\1
	ENDC
	endm

wait_until_end_clicks	macro
\@	if_not_endclicks.s	\@
	endm

wait_clicks	macro
	set_clicks	\1
	wait_until_end_clicks
	endm

opening_titles	
	set_clicks	#79
	lea	opening_pic2,a0
	bsr	depack_pic_to_back
	wait_until_end_clicks
	bsr	swap_screens
	wait_vbl
	set_clicks	#79
	lea	opening_pic3,a0
	bsr	depack_pic_to_back
	wait_until_end_clicks
	bsr	swap_screens
	wait_vbl
	set_clicks	#79
	lea	opening_pic4,a0
	bsr	depack_pic_to_back
	wait_until_end_clicks
	bsr	swap_screens
	wait_vbl
	set_clicks	#79
	lea	opening_pic5,a0
	bsr	depack_pic_to_back
	wait_until_end_clicks
	bsr	swap_screens
	wait_vbl
	set_clicks	#(80*4)-1
	lea	opening_pic6,a0
	bsr	depack_pic_to_back
	wait_until_end_clicks
	bsr	swap_screens
	wait_vbl
	wait_clicks	#(80*4)-1
	rts

opening_pic1	incbin	pix\monom1.pi3
	even
opening_pic2	incbin	pix\monom2.pi3
	even
opening_pic3	incbin	pix\monom3.pi3
	even
opening_pic4	incbin	pix\monom4.pi3
	even
opening_pic5	incbin	pix\great.pi3
	even
opening_pic6	incbin	pix\great2.pi3
	even


black_screen
	moveq	#-1,d0
	move	#(32000/4)-1,d1
.loop	move.l	d0,(a0)+
	dbf	d1,.loop
	rts

swap_screens
	movem.l	front,d0-d1
	exg	d0,d1
	movem.l	d0-d1,front
	set_vidaddr	d0
	rts

	include	musplay.s
	include	yogie.s
	include	..\includes\genbin.s
MODE	equ	0
	include	..\includes\depack35.s

	section	data
front	dc.l	screen1
back	dc.l	screen2

main_music	incbin	music\mono.thk

	section	bss

oldvbl		ds.l	1
old_vidaddr	ds.l	1

	ds.b	256
screen1	ds.b	32000

	ds.b	256
screen2	ds.b	32000

	ds.b	256
screen3	ds.b	32000
	