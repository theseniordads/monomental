* MONO MENTAL by SENIOR DADS
* 
* (REMIX version)
*
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

 ****** NOTE: WE'RE STILL WORKING ON THIS! ******

FINAL_VERSION							; < Comment for labels and faster assembly

 	IFD	FINAL_VERSION
	opt	d-
	ENDC

	include includes/genmacro.s			; Useful general macros
	include includes/musmac.s			; Music and timing macros.

	text

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
end_demo
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
; a) Checks the display resolution is hi-res monochrome
; b) Does the opening text titles.
init:	
	getrez_st 	d7					; <- Get ST Resolution
	cmp.b	#2,d7					; <- If it's not 2 (hi-res)...
	bne		hi_res_you_wally		; <- ...then show a little message!
	move.l	$45e.w,old_screen_ptr	; Not sure why we saved this, as we don't change it!
	move.l	vbl.w,oldvbl			; Save the old VBL vector
	move.l	#myvbl,vbl.w			; ... and slot in a "timer only" VBL
	bsr		senior_text_intro
	get_vidaddr	old_vidaddr			; Save the current video address
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
; user presses a key, and the demo exits. 
hi_res_you_wally:
	print_string #.its_hi_res
	wait_key
	bra 	end_demo	; <- Normally, we'd have to correct the stack here, as it has the return address of the "init" routine, but as next statement restores the old stack, we don't need to here.
	data
.its_hi_res:
	dc.b 27, 'E'	; <- Clear screen
	dc.b 'OI! Idiot!', 13, 10, 10						; <- Did Dame Vera Lynn write this?
	dc.b 'Haven''t you read the doc files?', 13,10
	dc.b 'This is an ST HI-RES demo you', 13, 10
	dc.b 'stupid cretin!!! Why don''t you', 13, 10
	dc.b 'upgrade your equipment and your', 13, 10
	dc.b 'braincells, you total thicko!!!', 0
	even
	text

	include demoparts/the_end.s			; "The End" aka "White dot" screen.
	include demoparts/seniortx.s		; Text intro.
	include demoparts/smbu.s			; "Prodigy Tribute" aka "Smack My Bitch Up" screen.
	include demoparts/who_cred.s		; "Doctor Who" and "Credits" screen
	include demoparts/donut.s			; "Tri-di Donut" screen.
	include demoparts/present.s			; "Senior Dads present..." screen.
	include demoparts/title.s			; "Titles" and "Intro pics" screens.

	text

* COPY FRONT SCREEN TO BACK SCREEN:
; Errr, guess what this routine does!
copy_front_to_back:
	movea.l	front,a0
	movea.l	back,a1
	move	#8000-1,d0
.copy:
	move.l	(a0)+,(a1)+
	dbf		d0,.copy
	rts

* DISPLAY TOS BOMBS ON SCREEN:
; Adapted for hi-res from a lo-res routine used in "Air Dirt"
do_bombs_mono:
	movea.l	front,a1
	adda.l	#16000,a1				; Go to middle of screen in vertical terms
	lea		bmp_bomb,a0
.bomb:
i	set 	0
j 	set		0
	REPT	30/2					; Plonk 16x30 bomb on screen buffer
	move	i(a0),j(a1)				; 16 pixel line
i	set		i+2
j	set		j+80					; Go to line below
	ENDR
	addq.l	#2,a1					; Do next bomb on next 16 pixel boundry
	dbf	d0,.bomb
	rts

	data
* Here's the bitmap for the bomb- copied out of a TOS source listing in ST Internals!
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

	text

* PLOT BITMAP ANIMATION FRAME:
; Plots a 192x288 bitmap to a screen buffer.
; a4 = source bitmap on a PI3 file in memory
; a5 = destination screen buffer
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

* INVERT STUFFS:
; Errr, actually, the only thing that's inverted here is the font! We do this 
; because in monochrome mode on the ST, the colour 0 is white, and the colour 1
; is black!
invert_stuffs:
	lea		main_font,a0
	move	#3999,d0
.loop:
	not.w	(a0)+			; Invert 
	dbf	d0,.loop
	rts

* PRINT TEXT USING 32X16 FONT IN ST MONO MODE:
; Adapted for mono from a lo-res based routine used in "Air Dirt".
;
; a0 = Address of zero-byte terminated string
; a1 = Address of destination screen buffer
; d0 = x (in character units, each chcarcter is 32 pixels wide)
; d1 = y (in pixels)
font_string_mono:
	movem.l	d0-d7/a0-a6,-(a7)
	add	d0,d0					; { Multiply by 4 to get the X starting position
	add	d0,d0					; { ... of the text on the screen buffer
	lea	(a1,d0.w),a1			; Set x position
	mulu	#80,d1				; Multiply y by 80 (screen width) to get the y starting position
	lea	(a1,d1.w),a1			; Set y position
	movea.l	a1,a4				; Save x position
.loop:
	lea	main_font,a2			; Now we need to get the font data. (Maybe we could have put this outside the loop, as a2 isn't getting changed?)
	moveq	#0,d0
.ag:
	move.b	(a0)+,d0			; Get the current character from the string, and move the address to the next character
	beq		.exit				; If it's a zero byte, then we're done!
	cmp.b	#13,d0				; Is it a carriage return? ...
	bne.s	.fn					; ... If not, continue.
	adda.l	#16*80,a1			; ... If yes, move down 16 lines on the screen buffer ...
	movea.l	a1,a4				; ... and save the new x,y position ...
	bra.s	.ag					; ... and get the next character.	
.fn: 
	subi.b	#' ',d0				; The font data starts with the space "character", so we subtract the ASCII value of a space
	lsl.l	#6,d0				; Multiply by 64 to get the offset into the font data
	lea		(a2,d0.w),a3		; Now we've got the address of the relevant letter in the font data!
i 	set 	0
	REPT	16					; Now we write the 16 lines of the character to the screen buffer
	move	(a3)+,i(a4)			; (Notice how we're using a4 as the destination address? We're doing this so we
	move	(a3)+,i+2(a4)		; ... can advance a4 by characters length on the screen buffer, whilst keeping a1 as the "start" of the line, which we can use as a basis for moving to the next "line"!)
i 	set 	i+80				; Go to next line on screen buffer
	ENDR
	adda.l	#4,a4				; Move x position on the screen buffer to the next character
	bra	.loop					; Do next character
.exit:
	movem.l	(a7)+,d0-d7/a0-a6
	rts

	data

* Here's the 32x16 font- If want to see the source for this, 
; look in the "Air Dirt" source code under "SRC_DATA/GFX/FONT.PC1".
; (Obviously you'll need Degas or PC1 compatible software to view it!)
main_font:
	incbin 	graphics/bitmaps/crapfont.dat
	even

	text

* CLEAR SCREEN TO BLACK:
; a0 = Address of screen buffer
black_screen:
	moveq	#-1,d0				; Set 32px pixel strip to colour 1. Remember that in monochrome mode, colour 1 is black!
	move	#(32000/4)-1,d1		; Blat the whole screen buffer with black!
.loop:
	move.l	d0,(a0)+
	dbf	d1,.loop
	rts

* SWAP SCREENS AND DISPLAY CURRENT FRONT SCREEN:
swap_screens:
	movem.l	front,d0-d1			; The pointers for front and back screens are right next to each other in memory, so we can do this!
	exg	d0,d1					; SWAP!
	movem.l	d0-d1,front			; And save the new pointers
	set_vidaddr	d0				; Display the new front screen
	rts

* SORT SCREEN POINTERS:
; This sorts the screen pointers so that the front screen pointers points to the screen buffer
; with the lower address compared to the pointer to the back screen. This was only used in the
; "Tri-di Donut" screen, as we had to some sorting of the pointers in order to the hardware
; scrolling effects on the donut to work. We porbably kept it seperate just in case we needed
; it again.
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

* Main screen buffers, used for "front" and "back" screens.
				ds.b 	256
screen1:		ds.b	32000
				ds.b 	256
screen2:		ds.b	32000
				ds.b 	256
* Additional screen buffer for "Doctor Who" and "Tri-di Donut" screens.
screen3:		ds.b	32000
screen3_end:	ds.l	40
* Additional screen buffers for "Doctor Who" and "Credits" screens.
screen4:		ds.b	32066
screen5:		ds.b	32066

