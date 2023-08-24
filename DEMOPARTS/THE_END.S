* THE ENDING AKA "WHITE DOT" SCREEN:
; For younger readers, this is a tribute to the "white dot" that briefly appeared when you
; switched off an old analogue CRT-based TV! Upon switching off, the picture would rapidly
; shrink to a white dot in the centre of the screen, which then faded out!
;
; Why this is the first demo part in our code, we don't know!
the_end:
	move	#70-1,click_counter
	movea.l	back,a0								; Blank the back screen
	jsr		black_screen
	movea.l	back,a1
	lea		txt_end_dot,a0						; "White dot"
	move	#10,d0
	move	#200,d1
	jsr		font_string_mono
	wait_until_end_clicks
	jsr		swap_screens						; Display the "White dot"
	bsr		doctor_who_set_up_starfield
	lea		txt_end_the_end,a0					; "The end?"
	moveq	#2,d0
	bsr		bottom_screen_title
	set_clicks	#280-1
	wait_until_end_clicks
	move	#19,click_counter
	move	#17,d7
end_anim_loop:
	movem.l	d7,-(a7)							; Display "The end?" on a scrolling starfield.
	bsr		scroll_starfield
	bsr		add_bottom_screen_title
	jsr	swap_screens
	wait_until_end_clicks
	move	#19,click_counter
	movem.l	(a7)+,d7
	dbf	d7,end_anim_loop
	wait_until_end_clicks
	set_clicks	#320-1
	movea.l	back,a0								; Blank the back screen
	jsr		black_screen
	movea.l	back,a1
	lea	txt_end_yes,a0							; "YES"
	move	#10,d0
	move	#200,d1
	jsr		font_string_mono
	wait_vbl
	jsr		swap_screens						; Display "YES"
	movea.l	back,a1
	lea		4.w,a2								; ?? We don't use this! We suspect we were originally going to copy memory from here to the back screen!
	move	#(32000/4)-1,d0						; Instead we're actually copying from the address of txt_end_yes to the back screen!
.copy:
	move.l	(a0)+,(a1)+
	dbf	d0,.copy
	wait_until_end_clicks
	wait_vbl
	jsr		swap_screens						; Display
	jsr		stop_music							; Stop main music
	jsr		mus_crash							; Initialise crash music
	jsr		mus_crash+8							; Play crash music
	wait_for	#300							; Wait a bit
	jsr		mus_crash+4							; Stop crash music
	moveq	#6,d0
	jsr		do_bombs_mono						; CHK ERROR!
	jsr 	mus_monomental_main					; Now we play the main music again, but instead of using
	move.l	#6000-1,d0							; ... interrupts to play, we're playing it manuallly in a loop
.sound_loop:									; ... resulting in a super fast-forward splurge of sound!
	jsr		mus_monomental_main+8
	dbf	d0,.sound_loop
	moveq	#11,d0								; LINE 1111 ERROR!
	jsr		do_bombs_mono
	movem.l	d0-d1,-(a7)
	wait_for	#100							; Wait a bit
	movem.l	(a7)+,d0-d1
	jsr		mus_monomental_main+4				; Stop music.
	rts

txt_end_dot:
	dc.b	'.', 0
txt_end_the_end:
	dc.b	'The end?', 0
	even
txt_end_yes:				; This needs to be on an even byte boundry as we're copying by longwords from here later!
	dc.b	'YES', 0
	even

