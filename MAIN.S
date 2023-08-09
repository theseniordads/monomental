* MONO MENTAL by SENIOR DADS

	include includes/genmacro.s
	include includes/musmac.s

	section text

	init_prog	normal_exit

	move.l	a7,old_stack
	lea	new_stack,a7
	bsr	init
	jsr	sd_present
	jsr	test_card
	jsr	mono_mental_titles
	jsr	intro_pics
	jsr	yogie_baird
	jsr	codearokie
	jsr	steptoe_and_son
	jsr	doctor_who
	bsr	smack_my_bitch_up
	jsr	tridi_donut
	jsr	greetings
	jsr	man_from_uncle
	jsr	mono_mental_titles
	jsr	credits
	jsr	the_end
	bsr	ret
	movea.l	old_stack,a7
	rts

myvbl:
	subq.w	#1,timer.w
	rte

depack_pic_to_back:
	movea.l	back,a1
	lea	-34(a1),a1
	jsr	depack
	rts

init:	
	move.l	$45e.w,old_screen_ptr
	move.l	vbl.w,oldvbl
	move.l	#myvbl,vbl.w
	bsr		senior_text_intro
	get_vidaddr	old_vidaddr
	getrez_st d7				; <- Get ST Resolution
	cmp.b	#2,d7				; <- If it's not 2 (hi-res)...
	bne.s	hi_res_you_wally	; <- ...then show a little message!
	clr.b	front+3
	clr.b	back+3
	clr.b	scratch_screen+3
	movea.l	front,a0
	jsr		black_screen
	movea.l	back,a0
	jsr		black_screen
	jsr		swap_screens
	wait_vbl
	jsr		invert_stuffs
	sf		need_to_start_music
	rts

ret:	
	jsr		stop_music
	set_vidaddr	old_vidaddr
	move.l	oldvbl,vbl.w
	move.l	old_screen_ptr,$45e.w
	rts

hi_res_you_wally:
	print_string #.its_hi_res
	wait_key
	clr		-(a7)
	trap	#1		; Gemdos
.its_hi_res:
	dc.b 27, 'E'	; <- Clear screen
	dc.b 'OI! Idiot!', 13, 10, 10
	dc.b 'Haven''t you read the doc files?', 13,10
	dc.b 'This is an ST HI-RES demo you', 13, 10
	dc.b 'stupid cretin!!! Why don''t you', 13, 10
	dc.b 'upgrade your equipment and your', 13, 10
	dc.b 'braincells, you total thicko!!!', 0

the_end:
	move	#70-1,click_counter
	movea.l	back,a0
	jsr		black_screen
	movea.l	back,a1
	lea		txt_end_dot,a0
	move	#10,d0
	move	#200,d1
	jsr		font_string_mono
	wait_until_end_clicks
	jsr		swap_screens
	bsr		doctor_who_set_up_starfield
	lea		txt_end_the_end,a0
	moveq	#2,d0
	bsr		bottom_screen_title
	set_clicks	#280-1
	wait_until_end_clicks
	move	#19,click_counter
	move	#17,d7
.anim_loop:
	movem.l	d7,-(a7)
	bsr		scroll_starfield
	bsr		add_bottom_screen_title
	jsr	swap_screens
	wait_until_end_clicks
	move	#19,click_counter
	movem.l	(a7)+,d7
	dbf	d7,.anim_loop
	wait_until_end_clicks
	set_clicks	#320-1
	movea.l	back,a0
	jsr		black_screen
	movea.l	back,a1
	lea	txt_end_yes,a0
	move	#10,d0
	move	#200,d1
	jsr		font_string_mono
	wait_vbl
	jsr		swap_screens
	movea.l	back,a1
	lea		4.w,a2
	move	#(32000/4)-1,d0
.copy:
	move.l	(a0)+,(a1)+
	dbf	d0,.copy
	wait_until_end_clicks
	wait_vbl
	jsr		swap_screens
	jsr		stop_music
	jsr		mus_crash
	jsr		mus_crash+8
	wait_for	#300
	moveq	#6,d0
	jsr		do_bombs_mono
	move.l	#6000-1,d0
.sound_loop:
	jsr		mus_monomental_main+8
	dbf	d0,.sound_loop
	moveq	#11,d0
	jsr		do_bombs_mono
	movem.l	d0-d1,-(a7)
	wait_for	#100
	jsr		mus_monomental_main+4
	rts

txt_end_dot:
	dc.b	'.', 0
txt_end_the_end:
	dc.b	'The end?', 0
txt_end_yes:
	dc.b	'YES', 0
	even

senior_text_intro:
	print_string #.senior_intro_text
	move	#400,timer.w
.wait:
	tst		timer.w
	blt.s	.exit
	if_not_space.s 	.wait
.exit:
	rts

.senior_intro_text:
	dc.b 27, 'E'
	incbin	graphics\senior_l.ogo
	dc.b 13,10
	dc.b 'SENI0R dadS!!!',13,10
	dc.b '  .... Prezents!',13,10,10
	dc.b '    M   O   N  O M  e   N  TT   A   L   !!!',13,10,10
	dc.b 'A fabby-dabby-dooby-TUBBY!!   DEMO!',13,10,10
	dc.b '  DIS DEMO works **&&Any&&** komputers made by',13,10
	dc.b 'ATARI!!!   C-LAB!!!!    JTS!!!!!   HASBRO!!!',13,10,10,10
	dc.b '                  (except the 8-bit ones- sorry!!)',13,10,10
	dc.b ' yA needs a MOTOROLA chip for da procesaa!! And ONE mega memory!',13,10,10
	dc.b '<Wait a little time to prepare yourselfs!!! or press SPAC£!>',0

smack_my_bitch_up:
	set_clicks	#80-1
	lea		pic_smack_my_bitch_up,a0
	jsr		depack_pic_to_back
	jsr		swap_screens
	wait_until_end_clicks
	set_clicks #20-1
	movea.l	front,a1
	lea		txt_smack,a0
	move	#32,d0
	move	#50,d1
	jsr		font_string_mono
	wait_until_end_clicks
	set_clicks #20-1
	movea.l	front,a1
	lea		txt_my,a0
	move	#36,d0
	move	#150,d1
	jsr		font_string_mono
	wait_until_end_clicks
	set_clicks #20-1
	movea.l	front,a1
	lea		txt_bitch,a0
	move	#34,d0
	move	#250,d1
	jsr	font_string_mono
	wait_until_end_clicks
	set_clicks #20-1
	movea.l	front,a1
	lea		txt_up,a0
	move	#33,d0
	move	#350,d1
	jsr		font_string_mono
	wait_until_end_clicks
	set_clicks	#10
	wait_until_end_clicks
	rts

pic_smack_my_bitch_up:
	incbin graphics/packed/dog_smbu.pi3
	even

txt_smack:	dc.b 'SMACK', 0
txt_my:		dc.b 'MY', 0
txt_bitch	dc.b 'BITCH', 0
txt_up:		dc.b 'UP!!!', 0

doctor_who:	
	set_clicks #160-1
	bsr		doctor_who_set_up_starfield
	lea		txt_knock_knock,a0
	moveq	#4,d0
	bsr		bottom_screen_title
.anim_1:	
	bsr		scroll_starfield
	bsr		add_bottom_screen_title
	jsr		swap_screens
	movem.l	d6-d7,-(a7)
	move	#10,d7
	subq.l	#1,d7
.wait_loop:	
	wait_click
	dbf	d7,.wait_loop
	movem.l	(a7)+,d6-d7
	tst		click_counter
	bgt.s	.anim_1
	set_clicks #160-1
	lea		txt_whos_there,a0
	moveq	#4,d0
	bsr		bottom_screen_title
.anim_2:	
	bsr		scroll_starfield
	bsr		add_bottom_screen_title
	jsr		swap_screens
	movem.l	d6-d7,-(a7)
	move	#10,d7
	subq.l	#1,d7
.wait_loop2:
	wait_click
	dbf	d7,.wait_loop2
	movem.l	(a7)+,d6-d7
	tst		click_counter
	bgt.s	.anim_2
	set_clicks	#20-1
	lea		txt_doctor,a0
	moveq	#4,d0
	bsr		bottom_screen_title
	move	#7,d7
.anim3:		
	movem.l	d6-d7,-(a7)
	bsr		scroll_starfield
	bsr		add_bottom_screen_title
	lea		bmp_tardis,a4
	movea.l	back,a5
	adda.l	#28,a5
	jsr		plot_tardis
	wait_vbl
	jsr		swap_screens
.wait_loop3:
	tst		click_counter
	bgt.s	.wait_loop3
	set_clicks #20-1
	movem.l	(a7)+,d7
	dbf		d7,.anim3
	lea		txt_doctor_who,a0
	moveq	#4,d0
	bsr		bottom_screen_title
	move	#7,d7
.anim4:
	movem.l	d7,-(a7)
	bsr		scroll_starfield
	bsr		add_bottom_screen_title
	bsr		animate_tardis
	wait_vbl
	jsr		swap_screens
.wait_loop4:	
	tst		click_counter
	bgt.s	.wait_loop4
	set_clicks #20-1
	movem.l	(a7)+,d7
	dbf		d7,.anim4
	lea		txt_doh,a0
	moveq	#6,d0
	bsr		bottom_screen_title
	move	#17,d7
.anim5:
	movem.l	d7,-(a7)
	bsr		scroll_starfield
	bsr		add_bottom_screen_title
	bsr		animate_tardis
	wait_vbl
	jsr		swap_screens
.wait_loop5:
	tst	click_counter
	bgt.s	.wait_loop5
	set_clicks #20-1
	movem.l	(a7)+,d7
	dbf	d7,.anim5
	rts

credits:
	wait_until_end_clicks
	set_clicks #20-1
	bsr		doctor_who_set_up_starfield
	moveq	#5,d6
	lea		credits_ptr,a6
.loop:	
	movea.l	4(a6),a0
	moveq	#5,d0
	movem.l	d6/a6,-(a7)
	bsr		bottom_screen_title
	movem.l	(a7)+,d6/a6
	move	#7,d7
.loop2:	
	movem.l	d6-d7/a6,-(a7)
	bsr		scroll_starfield
	bsr		add_bottom_screen_title
	movem.l	(a7)+,d6-d7/a6
	movea.l	(a6),a4
	movem.l	d6-d7/a6,-(a7)
	movea.l	back,a5
	adda.l	#28,a5
	jsr		plot_tardis
	wait_vbl
	jsr		swap_screens
	wait_until_end_clicks
	set_clicks #20-1
	movem.l	(a7)+,d6-d7/a6
	dbf	d7,.loop2
	addq.l	#8,a6
	set_clicks #20-1
	dbf	d6,.loop
	set_clicks #20-1
	wait_until_end_clicks
	rts

bottom_screen_title:
	move	#1280-1,d7
	moveq	#-1,d1
	lea		bottom_screen_title_buffer,a6
.clear:
	move.l	d1,(a6)+
	dbf		d7,.clear
	lea		bottom_screen_title_buffer,a1
	move	#0,d1
	jsr		font_string_mono
	rts

add_bottom_screen_title:	
	movea.l	back,a1
	adda.l	#30720,a1
	lea		bottom_screen_title_buffer,a0
i 	set 0
	rept 	1280
	move	i(a0),d0
	and		d0,i(a1)
i set i+2
	endr
	rts
bottom_screen_title_buffer:
	ds.l	1280

txt_knock_knock:
	dc.b 'Knock Knock!',0
txt_whos_there:
	dc.b 'WHo''s there??',0
txt_doctor:	
	dc.b 'DOCTOR!!!!',0
txt_doctor_who:
	dc.b 'Doctor WHO?!?!',0
txt_doh:
	dc.b 'Doh!!!!!',0

doctor_who_set_up_starfield:	
	lea	pic_doctor_who_starfield,a0
	lea	screen3-34,a1
	jsr	depack
	move	#40-1,d0
	moveq	#-1,d1
	lea	screen3_end,a0
.clear:	
	move.l	d1,(a0)+
	dbf	d0,.clear
	clr.w		starfield_scroll_offset
	rts

scroll_starfield:
	lea		screen3,a0
	adda	starfield_scroll_offset,a0
L28552:	
	movea.l	back,a1
	move	#(3200/4)-1,d0
.clear:	
	move.l	(a0)+,(a1)+
	dbf		d0,.clear
	move	starfield_scroll_offset,d0
	addi.w	#2,d0
	move	d0,starfield_scroll_offset
	cmpi.w	#80,d0
	bne.s	.exit
	clr.w	starfield_scroll_offset
.exit:
	rts

animate_tardis:	
	move	tardis_anim_ptr,d0
	lea		tardis_anim_frames,a0
	move	d0,d1
	add		d1,d1
	add		d1,d1
	movea.l	0(a0,d1),a4
	addq.l	#1,d0
	cmp		#3,d0
	bne.s	.no_reset
	moveq	#0,d0
.no_reset:
	move	d0,tardis_anim_ptr
	movea.l	back,a5
	adda.l	#28,a5
	jsr	plot_tardis
	rts

starfield_scroll_offset:	dc.w	0

pic_doctor_who_starfield:
	incbin	graphics/packed/who_stars.pi3
	even

tardis_anim_ptr:	dc	0
tardis_anim_frames:	dc.l	bmp_tardis3
					dc.l	bmp_tardis1
					dc.l	bmp_tardis2

credits_ptr:		dc.l	bmp_credit_old_fart
					dc.l	txt_credit_code
					dc.l	bmp_credit_doddering_git
					dc.l	txt_credit_code
					dc.l	bmp_credit_colostomy_bag
					dc.l	txt_credit_code
					dc.l	bmp_credit_jackson_pollock
					dc.l	txt_credit_graphics
					dc.l	bmp_credit_dame_vera_lynn
					dc.l	txt_credit_music
					dc.l	bmp_credit_sd_logo
					dc.l	txt_credit_bye
txt_credit_code:
	dc.b 'CODE!!', 0
txt_credit_graphics:
	dc.b 'GRAFICX!', 0
txt_credit_music:
	dc.b 'MUSICX!!', 0
txt_credit_bye:
	dc.b 'bye!', 0
	even

bmp_tardis:
	incbin	graphics/bitmaps/tardis.pi3
bmp_tardis1 equ bmp_tardis+34
bmp_tardis2 equ bmp_tardis1+24
bmp_tardis3 equ bmp_tardis2+24
	even

bmp_crew1:
	incbin graphics/bitmaps/crew1.pi3
bmp_crew2:
	incbin graphics/bitmaps/crew2.pi3
bmp_credit_old_fart			equ bmp_crew1+34
bmp_credit_doddering_git 	equ bmp_credit_old_fart+24
bmp_credit_jackson_pollock 	equ bmp_credit_doddering_git+24
bmp_credit_dame_vera_lynn	equ bmp_crew2+34
bmp_credit_colostomy_bag	equ bmp_credit_dame_vera_lynn+24
bmp_credit_sd_logo			equ bmp_credit_colostomy_bag+24
	even
	
L125534:movea.l	back,a0
	jsr	black_screen
	movea.l	back,a1
	lea	L125588,a0
	move	#0,d0
	move	#0,d1
	jsr	font_string_mono
	jsr	swap_screens
L125578:
	tst	click_counter
	bgt.s	L125578
	rts

L125588:dc	15934
	movea.l	d1,a0
	bcc.s	L125694
	movea.l	$6F757220,a0
	dc	25193
	moveq	#13,d2
	btst	d6,-(a0)
	move.l	-(a0),d0
	bvs.s	L125720
	movea.l	25970(a0),a0
	bcs.s	L125660
	movea.l	d3,a0
	move.l	d2,24935(a6)
	move.l	d0,-(a0)

sd_present:
	lea	pic_presents,a0
	jsr	depack_pic_to_back
	bsr	swap_screens
	lea	mus_sd_fanfare,a0
	jsr	start_music
	set_clicks #640-1
	wait_until_end_clicks
	rts

mono_mental_titles:
	lea		pic_mono_titles1,a0
	jsr		depack_pic_to_back
	lea		mus_monomental_main,a0
	tst.b	need_to_start_music
L125694:
	bne.s	.omit_music_start
	jsr		start_music
	st		need_to_start_music
.omit_music_start:
	bsr		swap_screens
	set_clicks #80-1
L125720:
	lea		pic_mono_titles2,a0
	jsr		depack_pic_to_back
	wait_until_end_clicks
	bsr		swap_screens
	wait_vbl
	set_clicks #80-1
	lea		pic_mono_titles3,a0
	jsr		depack_pic_to_back
	wait_until_end_clicks
	bsr		swap_screens
	wait_vbl
	set_clicks #80-1
	lea		pic_mono_titles4,a0
	jsr		depack_pic_to_back
	wait_until_end_clicks
	bsr		swap_screens
	wait_vbl
	set_clicks #80-1
	rts

intro_pics:
	lea	pic_jason_king,a0
	jsr	depack_pic_to_back
	wait_until_end_clicks
	bsr		swap_screens
	wait_vbl
	set_clicks #320-1
	lea	pic_first_mono_demo,a0
	jsr	depack_pic_to_back
	wait_until_end_clicks
	wait_vbl
	set_clicks #320-1
	wait_until_end_clicks
	rts

pic_mono_titles1:
	incbin graphics/packed/mono1.pi3
	even
pic_mono_titles2:
	incbin graphics/packed/mono2.pi3
	even
pic_mono_titles3:
	incbin graphics/packed/mono3.pi3
	even
pic_mono_titles4:
	incbin graphics/packed/mono4.pi3
	even

pic_jason_king:
	incbin graphics/packed/j_king.pi3
	even
pic_first_mono_demo:
	incbin graphics/packed/firstmono.pi3
	even

need_to_start_music:
	dc.w	0

copy_front_to_back:
	movea.l	front,a0
	movea.l	back,a1
	move	#8000-1,d0
.copy:
	move.l	(a0)+,(a1)+
	dbf		d0,.copy
	rts

do_bombs_mono:
	movea.l	front,a1
	adda.l	#16000,a1
	lea		bmp_bomb,a0
.bomb:
i	set 	0
j 	set		0
	REPT	30/2
	move	i(a0),j(a1)
i	set		i+2
j	set		j+80
	ENDR
	addq.l	#2,a1
	dbf	d0,.bomb
	rts

bmp_bomb:
	dc.w	%0000011000000000
	dc.w	%0010100100000000
	dc.w	%0000000010000000
	dc.w	%0100100001000000
	dc.w	%0001000111110000
	dc.w	%0000000111110000
	dc.w	%0000011111111100
	dc.w	%0000111111111110
	dc.w	%0000111111111110
	dc.w	%0001111111111111
	dc.w	%0001111111101111
	dc.w	%0000111111101110
	dc.w	%0000111111011110
	dc.w	%0000011111111100
	dc.w	%0000001111111000
	dc.w	%0000000011100000

plot_tardis:
	move	#288-1,d0
.copy:
i 	set 0
	REPT 22/2
	move	i(a4),d1
	and		d1,i(a5)
i 	set 	i+2
	ENDR
	lea	80(a4),a4
	lea	80(a5),a5
	dbf	d0,.copy
	wait_for #1
	rts

	movem.l	d0/a0,-(a7)
	move.l	#L147164,-(a7)
	move	#9,-(a7)	; Cconws
	trap	#1		; Gemdos
	addq.l	#6,a7
	movem.l	(a7)+,d0/a0
	move.l	#32,d6
	movea.l	1102.w,a5
	lea	L147172,a6
	move	#93,d7
L147096:
	move.b	d6,L147170
	addq.l	#1,d6
	movem.l	d0/a0,-(a7)
	move.l	#L147168,-(a7)
	move	#9,-(a7)	; Cconws
	trap	#1		; Gemdos
	addq.l	#6,a7
	movem.l	(a7)+,d0/a0
	move.b	0(a5),(a6)+
	move.b	160(a5),(a6)+
	move.b	320(a5),(a6)+
	move.b	480(a5),(a6)+
	move.b	640(a5),(a6)+
	move.b	800(a5),(a6)+
	move.b	960(a5),(a6)+
	move.b	1120(a5),(a6)+
	dbf	d7,L147096
	rts

L147164:move.b	-(a2),12544(a5)
L147168:dc	6984
L147170:ori.b	#0,d0
L147172	=	*-2
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
L147307	=	*-3
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
L147646:ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	dc	0

invert_stuffs:
	lea		main_font,a0
	move	#3999,d0
.loop:
	not.w	(a0)+
	dbf	d0,.loop
	rts

* Print text using a 32X32 font
; a0 = string
; a1 = screen
; d0,d1 = x,y
; d2 = plane

font_string
	add	d2,d2				{ - move to plane in screen 
	lea	(a1,d2.w),a1			{
	lsl.w	#3,d0				; Move to..
	lea	(a1,d0.w),a1			; ..X-position
	mulu	#160,d1				; Move to..
	lea	(a1,d1.w),a1			; ..Y-position
	move.l	a1,a4				; Get starting position
.loop	lea	main_font,a2			; Get font ready
	moveq	#0,d0
.ag	move.b	(a0)+,d0			; Get character
	beq	.exit				; Until at end of string...
	cmp.b	#13,d0				;   If c/r detected...
	bne.s	.fn
	adda.l	#160*16,a1			;     Go down a line.
	move.l	a1,a4				;     Update starting position
	bra.s	.ag				;     Get another character
.fn	subi.b	#' ',d0				;   Subtract base of font
	lsl.l	#6,d0				;   Multiply by length (64 bytes) of single char
	lea	(a2,d0.w),a3			;   Now a3 = bitmap representation of char
i	set	0
	REPT	16				{
	move	(a3)+,i(a4)			{ - Copy letter bitmap to screen
	move	(a3)+,i+8(a4)			{
i	set	i+160				{
	ENDR
	adda.l	#16,a4				;   Move forward to next char position on screen
	bra	.loop				; Do next character
.exit	rts

* Print text using a 32X32 font
; a0 = string
; a1 = screen
; d0,d1 = x,y
font_string_mono:
	movem.l	d0-d7/a0-a6,-(a7)
	add	d0,d0
	add	d0,d0
	lea	0(a1,d0),a1
	mulu	#80,d1
	lea	0(a1,d1),a1
	movea.l	a1,a4
.loop:
	lea	main_font,a2
	moveq	#0,d0
.ag:
	move.b	(a0)+,d0
	beq		.exit
	cmp.b	#13,d0
	bne.s	.fn
	adda.l	#1280,a1
	movea.l	a1,a4
	bra.s	.ag
.fn: 
	subi.b	#' ',d0
	lsl.l	#6,d0
	lea		(a2,d0),a3
i set 0
	REPT	16
	move	(a3)+,i(a4)
	move	(a3)+,i+2(a4)
i set i + 80
	ENDR
	adda.l	#4,a4
	bra	.loop

.exit:movem.l	(a7)+,d0-d7/a0-a6
	rts

main_font:
	incbin 	graphics/bitmaps/crapfont.dat
	even

black_screen:
	moveq	#-1,d0
	move	#(32000/4)-1,d1
.loop:
	move.l	d0,(a0)+
	dbf	d1,.loop
	rts

swap_screens:
	movem.l	front,d0-d1
	exg	d0,d1
	movem.l	d0-d1,front
	set_vidaddr	d0
	rts

greetings:
	move	#639,click_counter
	lea	pic_greetings,a0
	jsr	depack_pic_to_back
	jsr	swap_screens
	movem.l	d6-d7,-(a7)
	move	#80,d7
	subq.l	#1,d7
L156264:move	click_counter,d6
L156270:cmp	click_counter,d6
	beq.s	L156270
	dbf	d7,L156264
	movem.l	(a7)+,d6-d7
	lea	greets_list_ptr,a5
L156292:move.l	(a5)+,d0
	tst.l	d0
	beq.s	L156348
	movea.l	d0,a0
	movea.l	front,a1
	move	(a5)+,d0
	move	(a5)+,d1
	jsr	font_string_mono
	movem.l	d6-d7,-(a7)
	move	(a5)+,d7
	subq.l	#1,d7
L156324:move	click_counter,d6
L156330:cmp	click_counter,d6
	beq.s	L156330
	dbf	d7,L156324
	movem.l	(a7)+,d6-d7
	bra.s	L156292

L156348:moveq	#5,d0
	jsr	do_bombs_mono
L156356:tst	click_counter
	bgt.s	L156356
	rts

pic_greetings:
	incbin graphics/packed/hole.pi3
	even
pic_donut1:
	incbin graphics/packed/donut1.pi3
	even
pic_donut2:
	incbin graphics/packed/donut2.pi3
	even

txt_tridi_donut:addq	#2,28005(a1)
	movea.l	-(a6),a0
	ble.s	.exit
	dc	8308
	dc	25953
	btst	d6,-(a0)
L170652:bsr.s	L170764
	bcc.s	L170688
	dc	17487
	dc	20053
	addq	#2,(a3)
	move.l	-(a1),-(a0)
	move.l	-(a1),-(a0)
	dc	0

codearokie:
	movea.l	back,a0
	jsr		black_screen
	movea.l	back,a1
	lea		txt_codearokie,a0
	move	#1,d0
	move	#100,d1
	jsr		font_string_mono
	jsr		swap_screens
	set_clicks #320-1
	lea		pic_codearokie,a0
	jsr		depack_pic_to_back
	wait_until_end_clicks
	jsr		swap_screens
.next_word:
	bsr		codearokie_frame
	tst.b	codearokie_abort
	bne.s	.exit
	bra.s	.next_word
.exit:
	set_vidaddr back
	set_clicks #328-1
	lea		pic_basil,a0
	jsr		depack_pic_to_back
	wait_until_end_clicks
	rts

codearokie_abort: ds.b	1
	even
codearokie_frame:
	sf		codearokie_abort
	movea.l	codearokie_pointer,a0
	move.l	(a0)+,d0
	tst.l	d0
	bmi		.finished_codearokie
	move.l	a0,codearokie_pointer
	movea.l	d0,a2
	movea.l	front,a0
	lea		30720(a0),a0
	moveq	#-1,d0
	REPT 	32000-30720
	move.l	d0,(a0)+
	ENDR
.next_word:
	move.l	(a2)+,d7
	move	(a2)+,d0
	move	(a2)+,d2
	tst.l	d7
	bmi.s	.finished_frame
	movea.l	front,a1
	movea.l	d7,a0
	move	#384,d1
	set_clicks d2
	jsr		font_string_mono
	wait_until_end_clicks
	bra.s	.next_word

.finished_frame:	
	set_clicks d2
	wait_until_end_clicks
	rts

.finished_codearokie:
	set_clicks d2
	wait_until_end_clicks
	st	codearokie_abort
	rts
		
pic_codearokie:
	incbin graphics/packed/codearok.pi3
	even
pic_basil:
	incbin graphics/packed/basil.pi3
	even

txt_codearokie:
	dc.b 	'1998!!', 13
	dc.b 	'  The world ', 13
	dc.b 	' changes!', 13, 13
	dc.b	' COLOSTOMY BAG', 13
	dc.b	'invents a new', 13
	dc.b	' demo effect!!', 13, 13, 13
	dc.b	'CODEAROKE!!!', 0

codearokie_frame_pointers:
	dc.l	codearokie_frame_1
	dc.l	codearokie_frame_2
	dc.l	codearokie_frame_3
	dc.l	codearokie_frame_4
	dc.l	codearokie_frame_5
	dc.l	codearokie_frame_6
	dc.l	codearokie_frame_7
	dc.l	codearokie_frame_8
	dc.l 	-1
codearokie_pointer:
	dc.l	codearokie_frame_pointers

codearokie_frame_1:
	dc.l	frame1_text1
	dc.w	0, 13
	dc.l	frame1_text2
	dc.w	5, 13
	dc.l	frame1_text3
	dc.w	8, 13
	dc.l	-1
	dc.w	-1,13

codearokie_frame_2:
	dc.l	frame2_text1
	dc.w	0, 13
	dc.l	frame2_text2
	dc.w	7, 13
	dc.l	frame2_text3
	dc.w	9, 13
	dc.l	-1
	dc.w	-1,13

codearokie_frame_3:
	dc.l	frame3_text1
	dc.w	0, $13
	dc.l	frame3_text2
	dc.w	7, $13
	dc.l	frame3_text3
	dc.w	10, $13
	dc.l	-1
	dc.w	-1, $13

codearokie_frame_4:
	dc.l	frame4_text1
	dc.w	0, $27
	dc.l	frame4_text2
	dc.w	4, $13
	dc.l	-1
	dc.w	-1, $13

codearokie_frame_5:
	dc.l	frame5_text1
	dc.w	0, $13
	dc.l	frame5_text2
	dc.w	7, $13
	dc.l	frame5_text3
	dc.w	10, $d
	dc.l	-1
	dc.w	-1, $13

codearokie_frame_6:
	dc.l	frame6_text1
	dc.w	0, $27
	dc.l	frame6_text2
	dc.w	5, $13
	dc.l 	-1
	dc.w	-1, $13

codearokie_frame_7:
	dc.l	frame7_text1
	dc.w	0, $13
	dc.l	frame7_text2
	dc.w	4, $13
	dc.l	-1
	dc.w	-1, $13

codearokie_frame_8:

frame1_text1 dc.b 'Join', 0
	even
frame1_text2 dc.b 'in', 0
	even
frame1_text3 dc.b 'folks!!', 0
	even

frame2_text1 dc.b 'MOVE.L', 0
	even
frame2_text2 dc.b '4,', 0
	even
frame2_text3 dc.b '$70', 0
	even

frame3_text1 dc.b 'MOVE.W', 0
	even
frame3_text2 dc.b '55,', 0
	even
frame3_text3 dc.b '+(A9,D10)', 0
	even

frame4_text1 dc.b 'TAS', 0
	even
frame4_text2 dc.b '$DD068.W', 0
	even

frame5_text1 dc.b 'MOVE.w', 0
	even
frame5_text2 dc.b '+(A3),', 0
	even
frame5_text3 dc.b 'A8', 0
	even

frame6_text1 dc.b 'CMP.B', 0
	even
frame6_text2 dc.b '#678,', 0
	even
frame6_text3 dc.b 'A12', 0
	even

frame7_text1 dc.b 'DROP', 0
	even
frame7_text2 dc.b '<<FRAME>>', 0
	even

frame8_text1 dc.b 'RTS', 0
	even
frame8_text2 dc.b '!!!!!', 0
	even

yogie_baird:
	movea.l	back,a0
	jsr		black_screen
	movea.l	back,a1
	lea		txt_yogie_baird,a0
	move	#1,d0
	move	#100,d1
	jsr		font_string_mono
	jsr		swap_screens
	set_clicks #320-1
	wait_until_end_clicks
	lea		pic_yogie_baird,a0
	lea		screen3-34,a1
	jsr		depack
	move.l	#screen3,telly_scan_source
	set_clicks	#640-1
	bsr		telly_scanner
	rts

steptoe_and_son:
	jsr		swap_screens
	lea		pic_steptoe_and_son,a0
	lea		screen3-34,a1
	jsr		depack
	move.l	#screen3,telly_scan_source
	set_clicks #640-1
	bsr		telly_scanner
	rts

man_from_uncle:
	jsr		swap_screens
	lea		pic_man_from_uncle,a0
	lea		screen3-34,a1
	jsr		depack
	move.l	#screen3,telly_scan_source
	set_clicks #640-1
	bsr		telly_scanner
	rts

telly_scanner:
	moveq	#0,d0
	lea	L205326,a0
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	lea	scan_mask,a0
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
.loop:
	movea.l	back,a0
	jsr	black_screen
	bsr	scan_strip
	bsr	fadein_mask
	wait_vbl
	jsr	swap_screens
	if_not_endclicks .loop
	sf	scan_wrapped
	rts

scan_strip:
	move	scan_pos,d0
	move	d0,d1
	addi.w	#12,d0
	cmpi.w	#80,d0
	ble.s	.no_reset
	subi.w	#80,d0
	st		scan_wrapped
.no_reset:
	move	d0,scan_pos
	movea.l	back,a0
	movea.l	telly_scan_source,a1
	adda	d1,a0
	adda	d1,a1
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
	sf		scan_wrapped
	bsr		.scroll_mask
	bsr		.scroll_mask
	bsr		.scroll_mask
	lea	scan_mask_source,a1
	lea	scan_mask,a2
	REPT	6
	move.w	(a0)+,d0
	move.w	(a1)+,d1
	and.w	d0,d1
	move.w	d1,(a2)+
	ENDR
.no_fadeup:
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

pic_yogie_baird:
	incbin graphics/packed/yogie.pi3
	even

telly_scan_source: dc.l	0

scan_wrapped:	dc.w	0

txt_yogie_baird:
	dc.b '1927!!', 13
	dc.b '  The world ', 13
	dc.b ' changes!', 13, 13
	dc.b '  John "Yogie"', 13
	dc.b 'BAIRD invents TV!', 0

test_card:
	movea.l	scratch_screen,a0
	jsr	black_screen
	set_vidaddr scratch_screen
	set_clicks	#160
	movea.l	scratch_screen,a1
	lea		txt_new_demo,a0
	moveq	#0,d0
	moveq	#80,d1
	jsr		font_string_mono
	movea.l	back,a6
	bsr		create_tv_static
	wait_until_end_clicks
	set_clicks	#159
	movea.l	scratch_screen,a1
	lea		txt_do_you_remember,a0
	move	#8,d0
	move	#200,d1
	jsr		font_string_mono
	movea.l	front,a6
	bsr		create_tv_static
	wait_until_end_clicks
	movea.l	scratch_screen,a0
	jsr		black_screen
	jsr		stop_music
	jsr		mus_static
	jsr		mus_static + 8
	move	#200,timer.w
.animate_static:
	jsr		swap_screens
	wait_for #3
	tst		timer.w
	bge.s	.animate_static
	set_vidaddr	scratch_screen
	lea		pic_testcard,a0
	jsr		depack_pic_to_back
	jsr		mus_static + 4
	lea		mus_testcard,a0
	jsr		start_music
	jsr		swap_screens
	set_clicks #2240-1
	wait_until_end_clicks
	movea.l	back,a0
	jsr		black_screen
	jsr		swap_screens
	set_clicks #80-1
	wait_until_end_clicks
	jsr		stop_music
	rts

txt_new_demo:
	dc.b '... a n3w d$mo! 1', 0

txt_do_you_remember:
	dc.b 'Do you', 13
	dc.b '  remember', 13
	dc.b ' old telly?'

create_tv_static:
	move	#16000-1,d7
.static_loop:
	move	#17,-(a7)	; Random
	trap	#14			; Xbios
	addq.l	#2,a7
	move	d0,(a6)+
	dbf		d7,.static_loop
	rts

	movem.l	d0,-(a7)
	ext.l	d6
	moveq	#0,d0
	subq.l	#1,d7
.loop:
	divu	#10,d6
	swap	d6
	move	d6,d0
	clr	d6
	swap	d6
	addi.b	#48,d0
	move.b	d0,0(a6,d7)
	dbf		d7,.loop
	movem.l	(a7)+,d0
	rts

.clear:
	move.b	(a5)+,(a6)+
	dbf	d7,.clear
	rts

L224636:
	cmpi.l	#$4656444F,(a0)+
	bne.s	L224738
L224644:addq.l	#2,a0
	move.l	vbl.w,-(a7)
	move	sr,-(a7)
	move.l	#L224762,112
L224660	=	*-2
	move	#8960,sr
	move	timer.w,d0
L224670:cmp	timer.w,d0
L224672	=	*-2
	beq.s	L224670
	move.l	(a0)+,$00FF820E
	move	(a0)+,$00FF8266
	movea.l	#$00FF8282,a1
L224694:move	(a0)+,(a1)+
	cmpa.l	#$00FF8292,a1
	bne.s	L224694
	movea.l	#$00FF82A2,a1
L224710:move	(a0)+,(a1)+
	cmpa.l	#$00FF82AE,a1
	bne.s	L224710
	move	(a0)+,$00FF82C2
	move	(a7)+,sr
	move.l	(a7)+,112
	moveq	#0,d0
	rts

L224738:moveq	#-1,d0
	rts

L224742:moveq	#-2,d0
	rts

	cmpi.b	#0,(a0)
	bne.s	L224742
	bra.s	L224644

	cmpi.b	#2,(a0)
	bne.s	L224742
	bra.s	L224644

L224762:addq	#1,timer.w
	rte

	lea	L224856,a1
	move.l	#$4656444F,(a1)+
	move.b	$00FF8006,(a1)+
	move.b	$00FF820A,(a1)+
	move.l	$00FF820E,(a1)+
L224798:move	$00FF8266,(a1)+
	movea.l	#$00FF8282,a0
L224810:move	(a0)+,(a1)+
	cmpa.l	#$00FF8292,a0
	bne.s	L224810
	movea.l	#$00FF82A2,a0
L224826:move	(a0)+,(a1)+
	cmpa.l	#$00FF82AE,a0
	bne.s	L224826
	move	$00FF82C2,(a1)+
	rts

	movea.l	#L224856,a0
	bsr	L224636
	rts

L224856:ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	ori.b	#0,d0
	move.l	vbl.w,-(a7)
	move	sr,-(a7)
	move.l	#L225008,vbl.w
	move	#8960,sr
	move	timer.w,d0
L224922:cmp	timer.w,d0
	beq.s	L224922
	move.b	(a0)+,-32246.w
	move.b	(a0)+,-32160.w
	move	(a0)+,-32154.w
	move	(a0)+,-32126.w
	move	(a0)+,-32116.w
	move	(a0)+,-32084.w
	move	(a0)+,-32064.w
	move	(a0)+,-32062.w
	move	(a0)+,-32124.w
	move	(a0)+,-32122.w
	move	(a0)+,-32120.w
	move	(a0)+,-32118.w
	move	(a0)+,-32094.w
	move	(a0)+,-32092.w
	move	(a0)+,-32090.w
	move	(a0)+,-32088.w
	move	(a0)+,-32086.w
	move	(a0),-32240.w
	move	(a7)+,sr
	move.l	(a7)+,vbl.w
	rts

L225008:addq	#1,timer.w
	rte

	move.b	d7,-1022.w
	rts

L225020:bsr.s	L225028
	dbf	d0,L225020
	rts

	include	includes/musplay.s
	include includes/genbin.s
	include includes/depack35.s

	section data

pic_testcard:
	incbin graphics/packed/testcard.pi3
	even

pic_presents:
	incbin graphics/packed/presents.pi3
	even

pic_steptoe_and_son:
	incbin graphics/packed/steptool.pi3
	even
	
pic_man_from_uncle:
	incbin graphics/packed/uncle.pi3
	even
	
front:			dc.l	screen1
back:			dc.l	screen2
scratch_screen:	dc.l	screen3

mus_sd_fanfare:
	incbin	music/fanfare.thk
	even
mus_testcard:
	incbin 	music/testcard.thk
	even
mus_monomental_main:
	incbin 	music/monomntl.thk
	even
mus_static:
	incbin 	music/static.thk
	even
mus_crash:
	incbin 	music/crash.thk
	even
	
	section bss

old_screen_ptr:	ds.l	1
oldvbl:			ds.l	1
old_vidaddr:	ds.l	1 

				ds.b 	256
screen1:		ds.b	32000
				ds.b 	256
screen2:		ds.b	32000
				ds.b 	256
screen3:		ds.b	32000
screen3_end:	ds.l	40