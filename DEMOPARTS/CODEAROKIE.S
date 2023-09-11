
* "CODEAROKIE" SCREEN:
; This displays a list of multipart Codearokie "frames", and then advertises
; Jackson Pollocks cool new (then) indie band Basil!
codearokie:
	movea.l	back,a0						; Blank back screen
	jsr		black_screen
	movea.l	back,a1
	lea		txt_codearokie,a0			; "Codearokie" titles
	move	#1,d0
	move	#100,d1
	jsr		font_string_mono
	jsr		swap_screens				; Display
	set_clicks #320-1
	lea		pic_codearokie,a0			; Get "Codearokie" picture ready
	jsr		depack_pic_to_back
	wait_until_end_clicks
	jsr		swap_screens				; Display it
.next_frame:
	bsr		codearokie_frame			; Do a codearokie "frame"
	tst.b	codearokie_abort			; Are we finished yet?
	bne.s	.exit
	bra.s	.next_frame					; ... if not, continue with next frame.
.exit:
	set_vidaddr back					; Wait, what? Why are we displaying the back screen instead of the front?
	set_clicks #308-1
	lea		pic_basil,a0				; ... It's so that when the "Basil" picture depacks...
	jsr		depack_pic_to_back			; ... We can see it happening on screen!
	wait_until_end_clicks
	rts

codearokie_abort: ds.b	1	; <- Dunno why this is here on it's own, and not somewhere more sensible!
	even

* CODEAROKIE FRAME:
; This subroutine take the address from a pointer table to data consisting of timing, positioning,
; and text to diplay, and uses that data to display a "frame" in two or more parts. All text is 
; display in a single line at the bottom of the screen.
codearokie_frame:
	sf		codearokie_abort			; If you're doing a frame, then obviously your not aborting the Codearokie!
	movea.l	codearokie_pointer,a0		; Get the latest frame address from the pointer table
	move.l	(a0)+,d0
	tst.l	d0							; Are we at the end of the Codearokie frames
	bmi		c_finished_codearokie		; ... Then set the abort, and exit.
	move.l	a0,codearokie_pointer		; Save the pointer position
	movea.l	d0,a2						; a2 now points to the data for the Codearokie frame to be displayed.
	movea.l	front,a0					; Now we clear the last 16 lines of the screen. (To clear text from the previous frame.)
	lea		30720(a0),a0
	moveq	#-1,d0
	REPT 	16*80
	move.l	d0,(a0)+
	ENDR
c_next_word:							; Display a single part of the frame
	move.l	(a2)+,d7					; <- address of text to display
	move	(a2)+,d0					; <- X position of text (Y is always the same, so we don't need to specify that)
	move	(a2)+,d2					; <- no of 'clicks' to wait before the next part.
	tst.l	d7							; Have we finished all parts?
	bmi.s	c_finished_frame			; ... Then we have finished the frame
	movea.l	front,a1
	movea.l	d7,a0
	move	#400-16,d1					; <- Y position of text
	set_clicks d2						; Set the number of 'clicks'
	jsr		font_string_mono			; Display the part
	wait_until_end_clicks
	bra.s	c_next_word

c_finished_frame:	
	set_clicks d2						; If we're finished the frame, just wait for the required amount.
	wait_until_end_clicks
	rts

c_finished_codearokie:
	set_clicks d2	
	wait_until_end_clicks				; If we're finished the *last* frame, just wait for the 
	st	codearokie_abort				; ... required amount AND abort.
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

; This is a table containing the pointers to each Codearokie frame in order,
; and ends with a -1 terminator
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
	dc.l	codearokie_frame_pointers	; <- Pointer to the pointers! It's set to the start of the pointer table.

* CODEAROKIE FRAMES
; This data is in the following format:
;
; 	dc.l	frame_text_address					; { Do this for each part of the frame
;	dc.w	x_position, no_of_clicks_to_wait	; {
;    :
;    :
;   dc.l	-1									; <- This marks the end of the frame
;	dc.w	-1, no_of_clicks_to_wait			; <- You still need to specify how long to wait once the frame has completed
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

* TEXT FOR THE CODEAROKIE FRAMES
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
