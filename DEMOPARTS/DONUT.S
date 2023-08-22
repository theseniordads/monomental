* "TRI-DI DONUT" SCREEN:
; Would it surprise you to learn that this screen isn't really 3D, but flipping between two pre-made
; Degas PI3 pictures? 
; 
; One feature of this screen is that the donut creeps on and off the screen in time with
; the music. For this feature, we're using a combination of the three screen buffers and plain vanilla
; ST hardware scrolling. During the "creep", both screens 1 and 3 are blank, and the donut is on screen 2.
tridi_donut: 
	set_clicks	#150-1
	jsr 	sort_screen_pointers				; Make sure fron screen pointer is screen 1 and back pointer is screen 2
	move.l 	scratch_screen,a0					; Clear screen 3
	jsr 	black_screen
	move.l 	scratch_screen,a1					; Write text on this screen, as we're using screens 1 and 2
	lea 	txt_tridi_donut,a0					; "Time for tea and DONUTS!"
	move	#3,d0
	move	#150,d1
	jsr		font_string_mono
	wait_vbl
	set_vidaddr scratch_screen					; Display text
	lea		pic_donut1,a0						; Depack initial donut pic to screen 2
	jsr		depack_pic_to_back
	movea.l	back,a0
	suba.l	#32000,a0							; Go to screen 1
	jsr		black_screen						; Clear it
	wait_until_end_clicks						; Wait until the music is ready
	moveq	#2,d6
	movea.l	back,a0
	suba.l	#32000,a0							; Set a0 to point to screen 1 (blank screen)
td_in_loop:
	adda	#8000,a0							; {
	wait_vbl									; { "Creep" in donut from screen 2 using hardware scrolling
	set_vidaddr a0								; {
	set_clicks 	#80-1
	wait_until_end_clicks						; Wait in time with the music
	dbf	d6,td_in_loop
	move	#80-1,click_counter
	adda	#8000,a0							; {
	wait_vbl									; { Fully line up display with screen 2
	set_vidaddr a0								; {
	lea		pic_donut2,a0						; Meanwhile, we depack the other frame of the donut animation to screen 1
	movea.l	front,a1
	lea		-34(a1),a1
	jsr		depack
	movea.l	back,a0								; ... Also, we clear screen 3
	adda.l	#32000,a0
	jsr		black_screen
	wait_until_end_clicks						; Wait until the music is ready!
	jsr		swap_screens
	set_clicks	#640-1
td_anim_loop1:									; This is dead easy: we animate the donut by swapping between screens 1 and 2!
	wait_vbl
	jsr		swap_screens
	movem.l	d6-d7,-(a7)							; Wait in time with the music before another frame of the animation
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
	wait_vbl									; { "Creep" out donut by moving forward to screen 3 
	set_vidaddr	a0								; { ... (which is blank) using hardware scrolling
	adda	#8000,a0							; {
	set_clicks	#79
	wait_until_end_clicks						; Wait in time with the music
	dbf		d7,td_out_loop
	set_clicks	#319
td_anim2_loop:									; Oh no! We're back to flipping between screens 1 and 2!
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
