	text

* "DOCTOR WHO" SCREEN:
; Amazing to see "Doctor Who" crop up in this demo as "old telly"! But at the time of the demo's
; release in April 1998, that was the case! The show had been cancelled in 1989, and the attempted
; "backdoor pilot" TV movie in 1996 didn't work out, so at the time, it was "old telly"! Of course,
; seven years later Russell T. Davies brought it back, and it was a massive success, so now it's "new 
; telly" again!
;
; This screen shows a TARDIS animation moving over a "starfield", along with a hilarious joke! We think
; this screen compares favourably with 1960s Doctor Who special effects shots!
doctor_who:	
	set_clicks #160-1
	bsr		doctor_who_set_up_starfield			; Set up the starfield
	lea		txt_knock_knock,a0					; "Knock, knock!"
	moveq	#4,d0
	bsr		bottom_screen_title					; Write text to screen buffer
dw_anim_1:	
	bsr		scroll_starfield					; "Scroll" "Starfield"
	bsr		add_bottom_screen_title				; Add bottom text bitmap to screen buffer
	jsr		swap_screens						; Display
	movem.l	d6-d7,-(a7)
	move	#10,d7								; Wait a bit...
	subq.l	#1,d7
dw_wait_loop:	
	wait_click
	dbf	d7,dw_wait_loop
	movem.l	(a7)+,d6-d7
	tst		click_counter						; Continue until part 1 is done
	bgt.s	dw_anim_1
	set_clicks #160-1
	lea		txt_whos_there,a0					; "Who's there?"
	moveq	#4,d0
	bsr		bottom_screen_title					; Write text to bitmap buffer
dw_anim_2:	
	bsr		scroll_starfield					; "Scroll" "Starfield"
	bsr		add_bottom_screen_title				; Add bottom text bitmap to screen buffer
	jsr		swap_screens						; Display
	movem.l	d6-d7,-(a7)
	move	#10,d7								; Wait a bit...
	subq.l	#1,d7
dw_wait_loop2:
	wait_click
	dbf	d7,dw_wait_loop2
	movem.l	(a7)+,d6-d7
	tst		click_counter
	bgt.s	dw_anim_2							; Continue until part 2 is done
	set_clicks	#20-1
	lea		txt_doctor,a0						; "Doctor!"
	moveq	#4,d0
	bsr		bottom_screen_title					; Write text to bitmap buffer
	moveq	#7,d7
dw_anim_3:		
	movem.l	d6-d7,-(a7)
	bsr		scroll_starfield					; "Scroll" "Starfield"
	bsr		add_bottom_screen_title				; Add bottom text bitmap to screen buffer
	lea		bmp_tardis1,a4
	movea.l	back,a5
	adda.l	#28,a5
	jsr		plot_bitmap_anim_frame							; Add static TARDIS bitmap to screen buffer
	wait_vbl
	jsr		swap_screens						; Display
dw_wait_loop3:									; Wait a bit...
	tst		click_counter
	bgt.s	dw_wait_loop3
	set_clicks #20-1
	movem.l	(a7)+,d6-d7
	dbf		d7,dw_anim_3						; Continue until part 3 is done
	lea		txt_doctor_who,a0
	moveq	#4,d0
	bsr		bottom_screen_title					; Write text to bitmap buffer
	move	#7,d7
dw_anim_4:
	movem.l	d7,-(a7)
	bsr		scroll_starfield					; "Scroll" "Starfield"
	bsr		add_bottom_screen_title				; Add bottom text bitmap to screen buffer
	bsr		animate_tardis						; Add animated TARDIS bitmap to screen buffer
	wait_vbl
	jsr		swap_screens						; Display
dw_wait_loop4:	
	tst		click_counter						; Wait a bit...
	bgt.s	dw_wait_loop4
	set_clicks #20-1
	movem.l	(a7)+,d7
	dbf		d7,dw_anim_4						; Continue until part 4 is done
	lea		txt_doh,a0							; "Doh!"
	moveq	#6,d0
	bsr		bottom_screen_title					; Write text to bitmap buffer
	move	#17,d7
dw_anim_5:
	movem.l	d7,-(a7)
	bsr		scroll_starfield					; "Scroll" "Starfield"
	bsr		add_bottom_screen_title				; Add bottom text bitmap to screen buffer
	bsr		animate_tardis						; Add animated TARDIS bitmap to screen buffer
	wait_vbl
	jsr		swap_screens						; Display
dw_wait_loop5:
	tst		click_counter						; Wait a bit...
	bgt.s	dw_wait_loop5
	set_clicks #20-1
	movem.l	(a7)+,d7
	dbf	d7,dw_anim_5							; Continue until part 5 is done
	rts

* "CREDITS" SCREEN:
; This uses some of the subroutine from the "Doctor Who" screen, only it displays logos for each of
; the crew members, and the credits. After our experience in doing the "Doctor Who" screen, we decided
; to improve on it by automating the process of changing the logos, instead of repeating the same code for
; each credit!
credits:
	wait_until_end_clicks
	set_clicks #20-1
	bsr		doctor_who_set_up_starfield				; Set up the starfield
	moveq	#5,d6
	lea		credits_ptr,a6							; Get the pointer to our credits table
cr_loop1:											; For each credit....
	movea.l	4(a6),a0									; Get the credit text
	moveq	#5,d0										; X-pos = 5
	movem.l	d6/a6,-(a7)
	bsr		bottom_screen_title							; Write text to bitmap buffer
	movem.l	(a7)+,d6/a6
	move	#7,d7
cr_loop2:												; For the time the credit is on-screen...
	movem.l	d6-d7/a6,-(a7)
	bsr		scroll_starfield								; "Scroll" "Starfield"
	bsr		add_bottom_screen_title							; Add bottom text bitmap to screen buffer
	movem.l	(a7)+,d6-d7/a6
	movea.l	(a6),a4											; Get address of bitmap for crew member logo
	movem.l	d6-d7/a6,-(a7)
	movea.l	back,a5
	adda.l	#28,a5
	jsr		plot_bitmap_anim_frame										; Plot crew member logo onto screen buffer
	wait_vbl
	jsr		swap_screens									; Display completed screen
	wait_until_end_clicks									; Wait a bit...
	set_clicks #20-1
	movem.l	(a7)+,d6-d7/a6
	dbf	d7,cr_loop2
	addq.l	#8,a6
	set_clicks #20-1
	dbf	d6,cr_loop1
	set_clicks #20-1
	wait_until_end_clicks
	rts

* CREATE TITLE FOR BOTTOM OF THE SCREEN:
; This uses the font_string_mono routine as if it's writing a single line of text at the top of a
; screen buffer, but in reality, it's writing to a 640x16 pixel buffer.
;
; d0 = X position
; a0 = address of zero-byte terminated text string.
bottom_screen_title:
	move	#(80*16)-1,d7
	moveq	#-1,d1									; Set all pixels to black
	lea		bottom_screen_title_buffer,a6			; Clear the title buffer
.clear:
	move.l	d1,(a6)+
	dbf		d7,.clear
	lea		bottom_screen_title_buffer,a1			; Set title buffer as destination "screen"
	move	#0,d1									; Set y-pos to zero
	jsr		font_string_mono
	rts

* ADD TITLE TO BOTTOM OF SCREEN:
; This just ANDs the context of the titles buffer to the last 16 lines on the screen buffer.
add_bottom_screen_title:	
	movea.l	back,a1
	adda.l	#(400-16)*80,a1							; Go to last 156 lines of screen buffer
	lea		bottom_screen_title_buffer,a0			; Get title buffer
i 	set 0
	rept 	80*16									; And add to the screen buffer
	move	i(a0),d0
	and		d0,i(a1)
i set i+2
	endr
	rts

	bss

; Here's where the title buffer is stored
bottom_screen_title_buffer:
	ds.l	80*16

	data

; Text for the knock-knock joke. Try not to injure yourself laughing!
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

	text

* SET UP "DOCTOR WHO" STARFIELD:
; This doesn't do too much- it basically unpacks a (1k!) "starfield" PI3 to a screen buffer and 
; clears things up. Of note is that we're unpacking to a *third* screen buffer instead of the back
; screen as we're using this screen buffer as a source as we're copying it to the back screen, then putting 
; titles and bitmaps on top it!
doctor_who_set_up_starfield:	
	lea		pic_doctor_who_starfield,a0
	lea		screen3-34,a1
	jsr		depack
	move	#40-1,d0						; As the unpacked DEGAS PI3 will have data after the bitmap
	moveq	#-1,d1							; ... image, and we're doing "scrolling" of the bitmap, we'll 
	lea 	screen3_end,a0					; ... clear away that data, or else, it will become visible
.clear:										; ... during the "scrolling".
	move.l	d1,(a0)+
	dbf		d0,.clear
	clr.w	starfield_scroll_offset			; Start scrolling offset at zero.
	rts

* "SCROLL" "STARFIELD":
; As you can probably guess, we're "scrolling" by copying the starfield screen onto the back screeen
; with increasing word offsets, resulting in a right -> left scroll effect. We reset at an offset of 80 
; bytes when the starfield has effectively "wrapped" over.
scroll_starfield:
	lea		screen3,a0								; Copying from the starfield source screen buffer
	adda	starfield_scroll_offset,a0				; Start copying from the scroll offset
	movea.l	back,a1									; Copy to the back screen
	move	#(32000/4)-1,d0							; Copy for a full screen's worth (~32K)
.clear:	
	move.l	(a0)+,(a1)+
	dbf		d0,.clear
	move	starfield_scroll_offset,d0				; Increase the scroll offset
	addi.w	#2,d0
	move	d0,starfield_scroll_offset				; Save it for the next time
	cmpi.w	#80,d0									; Have we "wrapped"?
	bne.s	.exit
	clr.w	starfield_scroll_offset					; ... If so, reset the scroll offset
.exit:
	rts

* ANIMATE TARDIS:
; Here we pop off the address of the current TARDIS bitmap animation frame from an
; animation table, and plot it.
animate_tardis:	
	move	tardis_anim_ptr,d0				; Get the current frame number
	lea		tardis_anim_frames,a0			; TARDIS animation table
	move	d0,d1
	add		d1,d1							; {
	add		d1,d1							; { - Multiply frames number by 4 
	movea.l	(a0,d1),a4						; Use the result as an offset on the animation table to get the address of the current TARDIS bitmap frame
	addq.l	#1,d0							; add to the current frame number
	cmp		#3,d0							; If we've reached the end...
	bne.s	.no_reset
	moveq	#0,d0							; ... go back to the beginning
.no_reset:
	move	d0,tardis_anim_ptr				; Save the next frame number
	movea.l	back,a5							; Set the back screen as the destination
	adda.l	#28,a5							; Plot in the middle top of the screen
	jsr	plot_bitmap_anim_frame
	rts

	bss

starfield_scroll_offset:					; 0-80
	ds.w	1

	data

* Starfield PI3 source (packed)
pic_doctor_who_starfield:
	incbin	graphics/packed/who_stars.pi3
	even

* TARDIS animation data
tardis_anim_ptr:	dc.w	0				; Current TARDIS animation frame
tardis_anim_frames:	dc.l	bmp_tardis1		; Tardis animation table
					dc.l	bmp_tardis2
					dc.l	bmp_tardis3

* Credits sequencing table
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

* Credits text
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
	incbin	graphics/packed/tardis.pi3				; TARDIS source PI3 (packed)
	even
bmp_tardis1 equ screen4+34							; Pointers to TARDIS bitmaps (Note that the picture is depacked to screen buffer 4)
bmp_tardis2 equ bmp_tardis1+24
bmp_tardis3 equ bmp_tardis2+24

bmp_crew1:
	incbin graphics/packed/crew1.pi3				; Crew source PI3s (packed)
	even
bmp_crew2:
	incbin graphics/packed/crew2.pi3
	even
bmp_credit_old_fart			equ screen4+34						; Pointers to Crew bitmaps (Note that the pictures are depack to screen buffers 4 & 5)
bmp_credit_doddering_git 	equ bmp_credit_old_fart+24
bmp_credit_jackson_pollock 	equ bmp_credit_doddering_git+24
bmp_credit_dame_vera_lynn	equ screen5+34
bmp_credit_colostomy_bag	equ bmp_credit_dame_vera_lynn+24
bmp_credit_sd_logo			equ bmp_credit_colostomy_bag+24
