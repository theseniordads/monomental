* MONO MENTAL by SENIOR DADS
* Original demo release: 11th April 1998 at the ALT party in Turku, Finland.
* (https://www.altparty.org/2008/the-first-alternative-party.html)

* NOTE: This is not the original source code, as that is almost certainly lost.
* The source and data has been reverse engineered from the original executable,
* using a disassembler, various Atari rippers, MONST2, Steven Tattersall's HRDB,
* and Visual Studio Code along with VASM and Vlink to recreate the executable on
* modern systems. The aim is to make the compiled executable as close to the
* original as possible (Though it might not be 100%). For more details on how 
* this was done, see the DOCS/README.md file.

* As this is not the original source, you can safetly assume all comments here are new.

* ## Assembly information ##
 * Assembly format: Devpac 3 (VASM compatible)
 * Target processor: Motorola 68000
 * Exectuable format: Atari TOS .PRG
 * Minimum hardware: Atari STFM with 1MB RAM, **MONOCHROME** monitor only.

 ****** NOTE: WE'RE STIL WORKING ON THIS! ******

;FINAL_VERSION							; < Comment for labels and faster assembly

 	IFD	FINAL_VERSION
	opt	d-
	ENDC

	include includes/genmacro.s			; Useful general macros
	include includes/musmac.s			; Music and timing macros.

	section text	; <- Bit wierd how VLink doesn't mind this, but chucks a wobbly at 'section data' instead of 'data'!

	init_prog	normal_exit	; This macro executes the following code as a subroutine in supervisor mode, and sets up a custom stack at 'new_stack'.

	* DEMOHUB!!!!!
	; This is where all the demo parts are called from. It ends in an 'rts', as it's 
	; a subroutine running in supervisor mode via a 'superexec' call.
	move.l	a7,old_stack			; If you're wondering why we save the stack pointer here, and not in 'init'
	lea		new_stack,a7			; remember BSRs and JSRs affect the stack, so we need to save it here.
	bsr		init
	jsr		sd_present				
	jsr		test_card
	jsr		mono_mental_titles
	jsr		intro_pics
	jsr		yogie_baird
;	jsr		codearokie
;	jsr		steptoe_and_son
;	jsr		doctor_who
;	bsr		smack_my_bitch_up
;	jsr		tridi_donut
;	jsr		greetings
;	jsr		man_from_uncle
;	jsr		mono_mental_titles
;	jsr		credits
;	jsr		the_end
	bsr		ret
	movea.l	old_stack,a7
	rts

* VBL:
; We're not using the VBL to play the music, as we're doing that with Timer D to allow the music
; to play at 50Hz speed on a 71Hz mono display. (and also on a 50Hz mono emulator display), so
; all it really needs to do is count down the VBL timer.
myvbl:
	subq.w	#1,timer.w
	rte

* DEPACK PI3 to BACK SCREEN:
; The most important subroutine in this demo!
; Our target platform for this demo was a 1 meg STFM with mono monitor, so we packed the 18 (!)
; Degas PI3 files used in this demo using the Atomik v3.5 packer, and depacked them on the fly
; to the back screen when needed, ready for a screen flip to display them.
depack_pic_to_back:
	movea.l	back,a1
	lea	-34(a1),a1
	jsr	depack
	rts

* SAVE SYSTEM STUFF AND SETUP:
; This also:
; a) Does the opening text titles.
; b) Checks the display resolution is hi-res monochrome
init:	
	move.l	$45e.w,old_screen_ptr	; Not sure why we saved this, as we don't change it!
	move.l	vbl.w,oldvbl			; Save the old VBL vector
	move.l	#myvbl,vbl.w			; ... and slot in a "timer only" VBL
	bsr		senior_text_intro
	get_vidaddr	old_vidaddr			; Save the current video address
	getrez_st 	d7					; <- Get ST Resolution
	cmp.b	#2,d7					; <- If it's not 2 (hi-res)...
	bne.s	hi_res_you_wally		; <- ...then show a little message!
	clr.b	front+3					; Align the 3 screen addresses to 256 byte boundaries
	clr.b	back+3
	clr.b	scratch_screen+3
	movea.l	front,a0				; Blank the front and back screens
	jsr		black_screen
	movea.l	back,a0
	jsr		black_screen
	jsr		swap_screens			; Swap screens (Thus displaying the former back screen, which is now black)
	wait_vbl						; Not sure why we're wait for a VBL here!
	jsr		invert_stuffs
	sf		do_not_restart_music		; Tell the opening titles we need to start the music. (We explain that in that section!)
	rts

* RESTORE SYSTEM STUFF:
; As we haven't changed much, there's not much to restore! (The music player routines already have
; their save and restore routines.)
ret:	
	jsr		stop_music				; Stop the crash music
	set_vidaddr	old_vidaddr			; Restore the old video address
	move.l	oldvbl,vbl.w			; Restore the old VBL vector
	move.l	old_screen_ptr,$45e.w	; Restore the old screen pointer, even though we haven't changed it!
	rts

* MESSAGE IF DEMO IS NOT RUN ON A MONOCHROME MONITOR:
; This is the message that appears if you try to run the demo on an Atari video mode other than
; ST mode 2 (hi-res monochrome). It basically just clears the screen and prints a message, the 
; user presses a key, and the demo exits. However, we're a bit concerned about *how* it exits,
; as it uses a simple #0 trap #1 exit without restoring the stack or coming out of supervisor
; mode!
hi_res_you_wally:
	print_string #.its_hi_res
	wait_key
	clr		-(a7)					; <- Er, if we're leaving without restoring the stack or coming out
	trap	#1						; <- of supervisor mode, won't this crash the machine?
.its_hi_res:
	dc.b 27, 'E'	; <- Clear screen
	dc.b 'OI! Idiot!', 13, 10, 10						; <- Did Dame Vera Lynn write this?
	dc.b 'Haven''t you read the doc files?', 13,10
	dc.b 'This is an ST HI-RES demo you', 13, 10
	dc.b 'stupid cretin!!! Why don''t you', 13, 10
	dc.b 'upgrade your equipment and your', 13, 10
	dc.b 'braincells, you total thicko!!!', 0

* THE ENDING:
; Why this is the first demo part in our code, we don't know!
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
end_anim_loop:
	movem.l	d7,-(a7)
	bsr		scroll_starfield
	bsr		add_bottom_screen_title
	jsr	swap_screens
	wait_until_end_clicks
	move	#19,click_counter
	movem.l	(a7)+,d7
	dbf	d7,end_anim_loop
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
	cmpi.b	#space_bar,ikbd.w
	bne.s 	.wait
.exit:
	rts

.senior_intro_text:
	dc.b 27, 'E'
	incbin	graphics\senior_l.ogo
	dc.b 13,10
senior_text:
	dc.b 'SENI0R dadS!!!',13,10
	dc.b '  .... Prezents!',13,10,10
	dc.b '    M   O   N  O M  e   N  TT   A   L   !!!',13,10,10
	dc.b 'A fabby-dabby-dooby-TUBBY!!   DEMO!',13,10,10
	dc.b '  DIS DEMO works **&&Any&&** komputers made by',13,10
	dc.b 'ATARI!!!   C-LAB!!!!    JTS!!!!!   HASBRO!!!',13,10,10,10
	dc.b '                  (except the 8-bit ones- sorry!!)',13,10,10
	dc.b ' yA needs a MOTOROLA chip for da procesaa!! And ONE mega memory!',13,10,10
	dc.b '<Wait a little time to prepare yourselfs!!! or press SPAC', $9c, '!>',0
	even

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
	even

doctor_who:	
	set_clicks #160-1
	bsr		doctor_who_set_up_starfield
	lea		txt_knock_knock,a0
	moveq	#4,d0
	bsr		bottom_screen_title
dw_anim_1:	
	bsr		scroll_starfield
	bsr		add_bottom_screen_title
	jsr		swap_screens
	movem.l	d6-d7,-(a7)
	move	#10,d7
	subq.l	#1,d7
dw_wait_loop:	
	wait_click
	dbf	d7,dw_wait_loop
	movem.l	(a7)+,d6-d7
	tst		click_counter
	bgt.s	dw_anim_1
	set_clicks #160-1
	lea		txt_whos_there,a0
	moveq	#4,d0
	bsr		bottom_screen_title
dw_anim_2:	
	bsr		scroll_starfield
	bsr		add_bottom_screen_title
	jsr		swap_screens
	movem.l	d6-d7,-(a7)
	move	#10,d7
	subq.l	#1,d7
dw_wait_loop2:
	wait_click
	dbf	d7,dw_wait_loop2
	movem.l	(a7)+,d6-d7
	tst		click_counter
	bgt.s	dw_anim_2
	set_clicks	#20-1
	lea		txt_doctor,a0
	moveq	#4,d0
	bsr		bottom_screen_title
	move	#7,d7
dw_anim_3:		
	movem.l	d6-d7,-(a7)
	bsr		scroll_starfield
	bsr		add_bottom_screen_title
	lea		bmp_tardis,a4
	movea.l	back,a5
	adda.l	#28,a5
	jsr		plot_tardis
	wait_vbl
	jsr		swap_screens
dw_wait_loop3:
	tst		click_counter
	bgt.s	dw_wait_loop3
	set_clicks #20-1
	movem.l	(a7)+,d7
	dbf		d7,dw_anim_3
	lea		txt_doctor_who,a0
	moveq	#4,d0
	bsr		bottom_screen_title
	move	#7,d7
dw_anim_4:
	movem.l	d7,-(a7)
	bsr		scroll_starfield
	bsr		add_bottom_screen_title
	bsr		animate_tardis
	wait_vbl
	jsr		swap_screens
dw_wait_loop4:	
	tst		click_counter
	bgt.s	dw_wait_loop4
	set_clicks #20-1
	movem.l	(a7)+,d7
	dbf		d7,dw_anim_4
	lea		txt_doh,a0
	moveq	#6,d0
	bsr		bottom_screen_title
	move	#17,d7
dw_anim_5:
	movem.l	d7,-(a7)
	bsr		scroll_starfield
	bsr		add_bottom_screen_title
	bsr		animate_tardis
	wait_vbl
	jsr		swap_screens
dw_wait_loop5:
	tst		click_counter
	bgt.s	dw_wait_loop5
	set_clicks #20-1
	movem.l	(a7)+,d7
	dbf	d7,dw_anim_5
	rts

credits:
	wait_until_end_clicks
	set_clicks #20-1
	bsr		doctor_who_set_up_starfield
	moveq	#5,d6
	lea		credits_ptr,a6
cr_loop1:	
	movea.l	4(a6),a0
	moveq	#5,d0
	movem.l	d6/a6,-(a7)
	bsr		bottom_screen_title
	movem.l	(a7)+,d6/a6
	move	#7,d7
cr_loop2:	
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
	dbf	d7,cr_loop2
	addq.l	#8,a6
	set_clicks #20-1
	dbf	d6,cr_loop1
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
	
tridi_donut: 
	set_clicks	#$95
	jsr 	sort_screen_pointers
	move.l 	screen3,a0
	jsr 	black_screen
	move.l 	screen3,a1
	lea 	txt_tridi_donut,a0
	move	#3,d0
	move	#150,d1
	jsr		font_string_mono
	wait_vbl
	set_vidaddr screen3
	lea		pic_donut1,a0
	jsr		depack_pic_to_back
	movea.l	back,a0
	suba.l	#32000,a0
	jsr		black_screen
	wait_until_end_clicks
	moveq	#2,d6
	movea.l	back,a0
	suba.l	#32000,a0
td_in_loop:
	adda	#8000,a0
	wait_vbl
	set_vidaddr a0
	set_clicks 	#80-1
	wait_until_end_clicks
	dbf	d6,td_in_loop
	move	#79,click_counter
	adda	#8000,a0
	wait_vbl
	set_vidaddr a0
	lea		pic_donut2,a0
	movea.l	front,a1
	lea		-34(a1),a1
	jsr		depack
	movea.l	back,a0
	adda.l	#32000,a0
	jsr		black_screen
	wait_until_end_clicks
	jsr		swap_screens
	set_clicks	#640-1
td_anim_loop1:
	wait_vbl
	jsr		swap_screens
	movem.l	d6-d7,-(a7)
	move	#19,d7
	subq.l	#1,d7
td_wait_loop1:
	wait_click
	dbf	d7,td_wait_loop1
	movem.l	(a7)+,d6-d7
	tst		click_counter
	bgt.s	td_anim_loop1
	jsr		swap_screens
	movea.l	back,a0
	move	#3,d7
td_out_loop:
	wait_vbl
	set_vidaddr	a0
	adda	#8000,a0
	set_clicks	#79
	wait_until_end_clicks
	dbf		d7,td_out_loop
	set_clicks	#319
td_anim2_loop:
	wait_vbl
	jsr		swap_screens
	movem.l	d6-d7,-(a7)
	move	#19,d7
	subq.l	#1,d7
td_wait_loop2:
	wait_click
	dbf	d7,td_wait_loop2
	movem.l	(a7)+,d6-d7
	tst		click_counter
	bgt.s	td_anim2_loop
	rts

txt_tridi_donut:
	dc.b 	'Time for tea', 13
	dc.b   	' and DONUTS!!!!', 0
	even

	include demoparts/present.s			; "Senior Dads present..." screen.
	include demoparts/title.s			; "Titles" and "Intro pics" screens.

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

* Print text using a 32X16 font
; a0 = string
; a1 = screen
; d0,d1 = x,y
font_string_mono:
	movem.l	d0-d7/a0-a6,-(a7)
	add	d0,d0
	add	d0,d0
	lea	(a1,d0.w),a1
	mulu	#80,d1
	lea	(a1,d1.w),a1
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
	lea		(a2,d0.w),a3
i 	set 	0
	REPT	16	
	move	(a3)+,i(a4)
	move	(a3)+,i+2(a4)
i 	set 	i+80
	ENDR
	adda.l	#4,a4
	bra	.loop
.exit:
	movem.l	(a7)+,d0-d7/a0-a6
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

sort_screen_pointers:
	movem.l	front,d0-d1
	cmp.l	d0,d1
	bge.s	.sorted
	exg	d0,d1
	movem.l	d0-d1,front
.sorted
	rts
			
greetings:
	set_clicks	#639
	lea		pic_greetings,a0
	jsr		depack_pic_to_back
	jsr		swap_screens
	movem.l	d6-d7,-(a7)
	move	#80,d7
	subq.l	#1,d7
td_wait_loop21:
	wait_click
	dbf	d7,td_wait_loop21
	movem.l	(a7)+,d6-d7
	lea		greets_list_ptr,a5
greets_loop:
	move.l	(a5)+,d0
	tst.l	d0
	beq.s	greets_end
	movea.l	d0,a0
	movea.l	front,a1
	move	(a5)+,d0
	move	(a5)+,d1
	jsr		font_string_mono
	movem.l	d6-d7,-(a7)
	move	(a5)+,d7
	subq.l	#1,d7
td_wait_loop22:
	wait_click
	dbf		d7,td_wait_loop22
	movem.l	(a7)+,d6-d7
	bra.s	greets_loop

greets_end:
	moveq	#5,d0
	jsr		do_bombs_mono
	wait_until_end_clicks
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

greets_list_ptr:
	dc.l	txt_greet1
	dc.w	7, 0
	dc.l	txt_greet2
	dc.w	4, 32
	dc.l	txt_greet3
	dc.w	7, 370
	dc.l	txt_greet4
	dc.w	9, 64
	dc.l	txt_greet5
	dc.w	10, 50
	dc.l	txt_greet6
	dc.w	5, 150
	dc.l	txt_greet7
	dc.w	7, 100
	dc.l	txt_greet8
	dc.w	8, 350
	dc.l	txt_greet9
	dc.w	7, 250
	dc.l	txt_greet10
	dc.w	6, 200
	dc.l	txt_greet11
	dc.w	5, 75
	dc.l	txt_greet12
	dc.w	10, 225
	dc.l	txt_greet13
	dc.w	5, 125
	dc.l	txt_greet14
	dc.w	4, 325
	dc.l	txt_greet15	
	dc.w	8, 275
	dc.l	txt_greet16
	dc.w	8, 175
	dc.l	txt_greet17
	dc.w	5, 25
	dc.l	txt_greet18
	dc.w	5, 375
	dc.l	txt_greet19
	dc.w	5, 300
	dc.l	txt_greet20
	dc.w	3, 384
	dc.l	0

txt_greet1:		dc.b 'GREETS 2:', 0
txt_greet2:		dc.b 'Everyone at ALT!', 0
txt_greet3:		dc.b 'Hello!', 0
txt_greet4:		dc.b 'MAGIE TEEM!', 0
txt_greet5:		dc.b 'Rejexct!', 0
txt_greet6:		dc.b 'reservoir Frogs!', 0
txt_greet7:		dc.b '#atari IRC!', 0
txt_greet8:		dc.b 'Network mag!!!', 0
txt_greet9:		dc.b 'Undercuver mag!', 0
txt_greet10:	dc.b 'Mystik Bites!', 0
txt_greet11:	dc.b 'ded Hacxers Soc!', 0
txt_greet12:	dc.b 'ipir!', 0
txt_greet13:	dc.b 'Rasero Team- NOT!', 0
txt_greet14:	dc.b 'Mystik Bites!', 0
txt_greet15:	dc.b 'Bill Gates- our hero!', 0
txt_greet16:	dc.b 'Sin BAD!', 0
txt_greet17:	dc.b 'ST Pluz!', 0
txt_greet18:	dc.b 'Atari Computing!!!', 0
txt_greet19:	dc.b 'Father Michael!!', 0
txt_greet20:	dc.b '<< and any 1 else!!', 0
	even

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
.next_frame:
	bsr		codearokie_frame
	tst.b	codearokie_abort
	bne.s	.exit
	bra.s	.next_frame
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
	bmi		c_finished_codearokie
	move.l	a0,codearokie_pointer
	movea.l	d0,a2
	movea.l	front,a0
	lea		30720(a0),a0
	moveq	#-1,d0
	REPT 	32000-30720
	move.l	d0,(a0)+
	ENDR
c_next_word:
	move.l	(a2)+,d7
	move	(a2)+,d0
	move	(a2)+,d2
	tst.l	d7
	bmi.s	c_finished_frame
	movea.l	front,a1
	movea.l	d7,a0
	move	#384,d1
	set_clicks d2
	jsr		font_string_mono
	wait_until_end_clicks
	bra.s	c_next_word

c_finished_frame:	
	set_clicks d2
	wait_until_end_clicks
	rts

c_finished_codearokie:
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
	even

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
	dc.w	0, 20-1
	dc.l	frame1_text2
	dc.w	5, 20-1
	dc.l	frame1_text3
	dc.w	8, 20-1
	dc.l	-1
	dc.w	-1, 20-1

codearokie_frame_2:
	dc.l	frame2_text1
	dc.w	0, 20-1
	dc.l	frame2_text2
	dc.w	7, 20-1
	dc.l	frame2_text3
	dc.w	9, 20-1
	dc.l	-1
	dc.w	-1, 20-1

codearokie_frame_3:
	dc.l	frame3_text1
	dc.w	0, 20-1
	dc.l	frame3_text2
	dc.w	7, 20-1
	dc.l	frame3_text3
	dc.w	10, 20-1
	dc.l	-1
	dc.w	-1, 20-1

codearokie_frame_4:
	dc.l	frame4_text1
	dc.w	0, 40-1
	dc.l	frame4_text2
	dc.w	4, 20-1
	dc.l	-1
	dc.w	-1, 20-1

codearokie_frame_5:
	dc.l	frame5_text1
	dc.w	0, 20-1
	dc.l	frame5_text2
	dc.w	7, 20-1
	dc.l	frame5_text3
	dc.w	13, 20-1
	dc.l	-1
	dc.w	-1, 20-1

codearokie_frame_6:
	dc.l	frame6_text1
	dc.w	0, 20-1
	dc.l	frame6_text2
	dc.w	6, 20-1
	dc.l	frame6_text3
	dc.w	11, 20-1
	dc.l	-1
	dc.w	-1, 20-1

codearokie_frame_7:
	dc.l	frame7_text1
	dc.w	0, 40-1
	dc.l	frame7_text2
	dc.w	5, 20-1
	dc.l	-1
	dc.w	-1, 20-1

codearokie_frame_8:
	dc.l	frame8_text1
	dc.w	0, 40-1
	dc.l	frame8_text2
	dc.w	4, 20-1
	dc.l	-1
	dc.w	-1, 20-1

frame1_text1 dc.b 'Join', 0
frame1_text2 dc.b 'in', 0
frame1_text3 dc.b 'folks!!', 0

frame2_text1 dc.b 'MOVE.L', 0
frame2_text2 dc.b '4,', 0
frame2_text3 dc.b '$70', 0

frame3_text1 dc.b 'MOVE.W', 0
frame3_text2 dc.b '55,', 0
frame3_text3 dc.b '+(A9,D10)', 0

frame4_text1 dc.b 'TAS', 0
frame4_text2 dc.b '$DD068.W', 0

frame5_text1 dc.b 'MOVE.w', 0
frame5_text2 dc.b '+(A3),', 0
frame5_text3 dc.b 'A8', 0

frame6_text1 dc.b 'CMP.B', 0
frame6_text2 dc.b '#678,', 0
frame6_text3 dc.b 'A12', 0

frame7_text1 dc.b 'DROP', 0
frame7_text2 dc.b '<<FRAME>>', 0

frame8_text1 dc.b 'RTS', 0
frame8_text2 dc.b '!!!!!', 0
	even

	include demoparts/yogie.s			; "Yogie Baird", "Steptool and Son", and "Man from UNCLE" screens.
	include demoparts/testcard.s		; "Do you remember old telly?" and "Test Card" screens.
	
	include	includes/musplay.s
	include includes/genbin.s
	include includes/depack35.s

	data

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
	
	bss

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
