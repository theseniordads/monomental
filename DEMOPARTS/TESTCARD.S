
* "TEST CARD" SCREEN:
; This displays the "a NEW demo" titles on a third screen to the user,
; whilst generating a TV static effect on the front and back screens.
; Then after a while, it plays the testcard music, and displays the 
; test card whilst the music plays.
test_card:
	movea.l	scratch_screen,a0		; clear scratch screen
	jsr	black_screen
	set_vidaddr scratch_screen		; Show the blank screen
	set_clicks	#160
	movea.l	scratch_screen,a1		; Display the "a NEW demo" titles
	lea		txt_new_demo,a0
	moveq	#0,d0
	moveq	#80,d1
	jsr		font_string_mono
	movea.l	back,a6					; Start creating the static on the back screen
	bsr		create_tv_static
	wait_until_end_clicks			; Wait a bit...
	set_clicks	#159
	movea.l	scratch_screen,a1		; Display the "do you remember" titles
	lea		txt_do_you_remember,a0
	move	#8,d0
	move	#200,d1
	jsr		font_string_mono
	movea.l	front,a6				; Start creating the static on the front screen
	bsr		create_tv_static
	wait_until_end_clicks			; Wait a bit...
	movea.l	scratch_screen,a0		; Blank the scratch screen
	jsr		black_screen
	jsr		stop_music				; Stop the fanfare music
	jsr		mus_static				; Initialise the static music
	jsr		mus_static+8			; Play the static music. We only need to this once, as we're just wanting the initial sound.
	move	#200,timer.w			; For 200 frames...
.animate_static:
	jsr		swap_screens			; Swap and display the front and back screens to animate the static
	wait_for #3						; Wait for 3 frames (Swapping every frame would be ridiculous!)
	tst		timer.w
	bge.s	.animate_static
	set_vidaddr	scratch_screen		; Go back to the (blank) scratch screen
	lea		pic_testcard,a0			; ... because we're depacking the testcard to the back screen!
	jsr		depack_pic_to_back
	jsr		mus_static + 4			; Stop the static music
	lea		mus_testcard,a0			; Start the "Test Card" music
	jsr		start_music
	jsr		swap_screens			; ... And display the test card!
	set_clicks #2240-1				; Wait whilst the music plays
	wait_until_end_clicks
	movea.l	back,a0					; Clear the other screen
	jsr		black_screen
	jsr		swap_screens			; ... and flip the screens to create a "blackout" effect
	set_clicks #80-1
	wait_until_end_clicks			; Wait a little bit, to increase the anticipation!
	jsr		stop_music
	rts

txt_new_demo:
	dc.b '... a n3w d$mo! 1', 0

txt_do_you_remember:
	dc.b 'Do you', 13
	dc.b '  remember', 13
	dc.b ' old telly?'
	even

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
