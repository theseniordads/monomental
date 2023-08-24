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
	jsr		codearokie
	jsr		steptool_and_son
	jsr		doctor_who
	bsr		smack_my_bitch_up
	jsr		tridi_donut
	jsr		greetings
	jsr		man_from_uncle
	jsr		mono_mental_titles
	jsr		credits
	jsr		the_end
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

	include demoparts/the_end.s			; "The End" aka "White dot" screen.
	include demoparts/seniortx.s		; Text intro.
	include demoparts/smbu.s			; "Prodigy Tribute" aka "Smack My Bitch Up" screen.
	include demoparts/who_cred.s		; "Doctor Who" and "Credits" screen
	include demoparts/donut.s			; "Tri-di Donut" screen.
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

plot_bitmap_anim_frame:
	move	#288-1,d0
.copy:
i 	set 0
	REPT 24/2
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
	add	d2,d2					; { - move to plane in screen 
	lea	(a1,d2.w),a1			; {
	lsl.w	#3,d0				; Move to..
	lea	(a1,d0.w),a1			; ..X-position
	mulu	#160,d1				; Move to..
	lea	(a1,d1.w),a1			; ..Y-position
	move.l	a1,a4				; Get starting position
.loop:
	lea	main_font,a2			; Get font ready
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
	REPT	16					; {
	move	(a3)+,i(a4)			; { - Copy letter bitmap to screen
	move	(a3)+,i+8(a4)		; {
i	set	i+160					; {
	ENDR
	adda.l	#16,a4				;   Move forward to next char position on screen
	bra	.loop					; Do next character
.exit	rts

* Print text using a 32X16 font in ST monochrome mode
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

	include demoparts/greeting.s		; "Greetings" screen- and "Tri-di Donut" graphics!
	include	demoparts/codearokie.s		; "Codearokie" and "Basil" screens
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

pic_steptool_and_son:
	incbin graphics/packed/steptool.pi3
	even
	
pic_man_from_uncle:
	incbin graphics/packed/uncle.pi3
	even
	
front:			dc.l	screen1
back:			dc.l	screen2
scratch_screen:	dc.l	screen3

mus_crash:
	incbin 	music/crash.thk
	even
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
