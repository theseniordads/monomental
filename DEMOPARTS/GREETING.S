* "GREETINGS" SCREEN:
; This follows the template set by "Xmas Card '97", and plonks on the crews we're greeting in a 
; seemingly random fashion. In the case, the graphics are a reference to the cover of The Chemical
; Brothers (then new) album "Dig Your Own Hole".
greetings:
	set_clicks	#620-1							; If you're wondering about the large value, this how long the *whole* screen goes on for!
	lea		pic_greetings,a0					; "Dig Your Own Demo" pic
	jsr		depack_pic_to_back
	jsr		swap_screens						; Display
	movem.l	d6-d7,-(a7)
	move	#100,d7								; Wait a bit
	subq.l	#1,d7								; (We're beginning to think we could have done with another click counter at this point!)
greets_wait_loop1:
	wait_click
	dbf	d7,greets_wait_loop1
	movem.l	(a7)+,d6-d7
	lea		greets_list_ptr,a5					; Get the pointer to the greetings table
greets_loop:
	move.l	(a5)+,d0							; Greetings text
	tst.l	d0									; If we're not at the end, continue
	beq.s	greets_end
	movea.l	d0,a0
	movea.l	front,a1							; Write to front screen
	move	(a5)+,d0							; X-pos of text
	move	(a5)+,d1							; Y-pos of text
	jsr		font_string_mono
	movem.l	d6-d7,-(a7)
	move	(a5)+,d7							; Amount of clicks to wait
	subq.l	#1,d7
greets_wait_loop2:								; (Yep, we should have definately done with another click counter!)
	wait_click
	dbf		d7,greets_wait_loop2
	movem.l	(a7)+,d6-d7
	bra.s	greets_loop							; Continue with next greet
greets_end:
	moveq	#5,d0								; ZERO DIVIDE ERROR!
	jsr		do_bombs_mono
	wait_until_end_clicks
	rts

pic_greetings:
	incbin graphics/packed/hole.pi3				; "Dig Your Own Demo"
	even

* Tri-di donut animation pics
pic_donut1:
	incbin graphics/packed/donut1.pi3			; Err, why are they here in the code, and not next to the tri-di code?!?!?
	even
pic_donut2:
	incbin graphics/packed/donut2.pi3
	even

* GREETINGS TABLE:
; Data is in the following format
;
; 	dc.l	pointer_to_text_string
;   dc.w	x_pos, y_pos
;	dc.w	no_of_clicks_to_wait
;	:
;	:
;	dc.l	0			; <- End of the table
greets_list_ptr:
	dc.l	txt_greet1
	dc.w	7, 0, 40-1
	dc.l	txt_greet2
	dc.w	4, 32, 20-1
	dc.l	txt_greet3
	dc.w	7, 370, 8-1
	dc.l	txt_greet4
	dc.w	9, 64, 10-1
	dc.l	txt_greet5
	dc.w	10, 50, 20-1
	dc.l	txt_greet6
	dc.w	5, 150, 20-1
	dc.l	txt_greet7
	dc.w	7, 100, 20-1
	dc.l	txt_greet8
	dc.w	8, 350, 9-1
	dc.l	txt_greet9
	dc.w	7, 250, 20-1
	dc.l	txt_greet10
	dc.w	6, 200, 20-1
	dc.l	txt_greet11
	dc.w	5, 75, 20-1
	dc.l	txt_greet12
	dc.w	10, 225, 20-1
	dc.l	txt_greet13
	dc.w	5, 125, 20-1
	dc.l	txt_greet14
	dc.w	4, 325, 20-1
	dc.l	txt_greet15	
	dc.w	8, 275, 20-1
	dc.l	txt_greet16
	dc.w	8, 175, 20-1
	dc.l	txt_greet17
	dc.w	5, 25, 20-1
	dc.l	txt_greet18
	dc.w	5, 375, 20-1
	dc.l	txt_greet19
	dc.w	5, 300, 20-1
	dc.l	txt_greet20
	dc.w	3, 384, 20-1
	dc.l	0					; <- End of the table

* Greetingss text
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
