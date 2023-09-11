
* "YOGIE BAIRD":
; This takes a picture on a 3rd screen buffer, and uses a left -> right scrolling mask to put it
; on the current screen buffers, creating a "scan" effect in honour to "Yogie" Baird's original
; mechanical TV process at the BBC! There is also a mask on the mask, making it "fade" in.
; 
; The main "scan" effect is in another subroutine 'telly_scanner', as we use it in other parts
; of the demo.
yogie_baird:
	movea.l	back,a0						; Blank the back screen
	jsr		black_screen
	movea.l	back,a1
	lea		txt_yogie_baird,a0			; Write the "Yogie invents TV" titles
	move	#1,d0
	move	#100,d1
	jsr		font_string_mono
	jsr		swap_screens				; Display
	set_clicks #300-1					; Wait a bit
	wait_until_end_clicks
	lea		pic_yogie_baird,a0			; Depack the "Yogie Baird" pic onto the Telly Scan source buffer
	lea		screen3-34,a1
	jsr		depack
	move.l	#screen3,telly_scan_source	; Start the Telly Scanner
	set_clicks	#640-1		; <- Set when the Scanner ends
	bsr		telly_scanner
	rts

* "STEPTOOL AND SON" screen.
steptool_and_son:
	jsr		swap_screens
	lea		pic_steptool_and_son,a0		; Depack the "Steptool and Son" pic onto the Telly Scan source buffer
	lea		screen3-34,a1
	jsr		depack
	move.l	#screen3,telly_scan_source	; Start the Telly Scanner
	set_clicks #640-1		; <- Set when the Scanner ends
	bsr		telly_scanner
	rts

* "MAN FROM UNCLE SCREEN" screen.
man_from_uncle:
	jsr		swap_screens
	lea		pic_man_from_uncle,a0		; Depack the "Man from UNCLE" pic onto the Telly Scan source buffer
	lea		screen3-34,a1
	jsr		depack
	move.l	#screen3,telly_scan_source	; Start the Telly Scanner
	set_clicks #630-1		; <- Set when the Scanner ends
	bsr		telly_scanner
	rts

* "TELLY SCANNER" SUBROUTINE:
; For each frame, this frame will draw a strip of the source screen memory (The address of which is 
; set in the longword 'telly_scan_source'.) ANDed through a 96 pixel wide mask value which "fades in"
; (using a seperate mask) over time. The strip moves from left to right and wraps, creating a "scan" 
; effect. This continues until the timer set using the 'set_clicks' macro runs out.
;
; Note this demo was deisgned for a monochrome monitor, which at the time would have been a CRT monitor.
; So this effect in particular was designed around the fact that on a CRT monitor when you go from a white
; image to complete black in a frame's time, for a split second there's a "ghost" image of that white image
; in the black. So this effect actually looks better on an old-school CRT monitor!
telly_scanner:
	moveq	#0,d0				; First we intialise by clearing the mask and "fade" mask, so we can "fade" it in.
	lea	fadein_data,a0
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	lea	scan_mask,a0
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
.loop:
	movea.l	back,a0				; Blank the back screen
	jsr	black_screen
	bsr	scan_strip				; Draw a strip
	bsr	fadein_mask				; "Fade" in the mask for the next frame
	wait_vbl
	jsr	swap_screens			; Display
	tst.w 	click_counter		; Check if the timer has run out
	bgt.s 	.loop				; if not, do the next frame
	sf	scan_wrapped			; Reset
	rts

* PLOT "TELLY SCAN" STRIP:
scan_strip:
	move	scan_pos,d0				; Get previous "scan" position
	move	d0,d1					; (... errr?)
	addi.w	#12,d0					; Go to next position
	cmpi.w	#80,d0					; Are we at right-most "scan"?
	ble.s	.no_reset				; ... If not, continue
	subi.w	#80,d0					; ... Otherwise, reset
	st		scan_wrapped
.no_reset:
	move	d0,scan_pos				; Save new "scan" position
	movea.l	back,a0					; We're drawing to the back screen
	movea.l	telly_scan_source,a1	; Ready source screen memory
	adda	d1,a0					; This is a bit wierd! We appear to be using the *previous* scan position
	adda	d1,a1					; ... to offset the position we're drawing from and to!
	movem.l	scan_mask,d1-d3			; Get the 96 pixel wide scan mask
	move.l	d1,d4					; Duplicate the mask. (Don't worry, this will make sense soon!)
	move.l	d2,d5
	move.l	d3,d6
	not.l	d4						; Invert the duplicate mask. We're doing this because we're ANDing
	not.l	d5						; ... the source screen with the mask, and then ORing the results with
	not.l	d6						; ... the inverted mask.
i	set	0
	REPT	400						; For 400 lines...
	move.l	i(a1),d0				; ... Get a 32 pixel wide bit of source screen memory,
	and.l	d1,d0					; ... AND with the mask,
	or.l	d4,d0					; ... OR with inverted mask,
	move.l	d0,i(a0)				; ... and plot to back screen.
	move.l	i+4(a1),d0				; ... Repeat for next 32 pixels.
	and.l	d2,d0
	or.l	d5,d0
	move.l	d0,i+4(a0)
	move.l	i+8(a1),d0				; ... Repeat for follow 32 pixels.
	and.l	d3,d0
	or.l	d6,d0
	move.l	d0,i+8(a0)
i	set	i+80
	ENDR
	rts

* "FADE" IN "SCAN" MASK:
; Of course, as this is a demo for a monochrome ST monitor, there's no actual fade!
; What's happening is that 'fade_in_data' is slowly being filled in, 3 pixels at a time
; from right to left each frame, and is ANDed with 'scan_mask_source', (The fully 
; "faded-up" "scan" mask.) and result is put in 'scan_mask' for use by the main Telly
; Scanner routine.
fadein_mask:
	if_false.s	scan_wrapped,.no_fadeup		; To make the "fade" more uniform, we only animate it each time the "scan" wraps.
	sf		scan_wrapped
	bsr		.scroll_mask					; "Fade" in 3 pixels
	bsr		.scroll_mask
	bsr		.scroll_mask
	lea	scan_mask_source,a1					; Get "Faded-up" mask
	lea	scan_mask,a2						; Set destination mask
	REPT	6
	move.w	(a0)+,d0						; Dunno why we're not doing this with longwords!
	move.w	(a1)+,d1
	and.w	d0,d1							; Mask the mask!
	move.w	d1,(a2)+
	ENDR
.no_fadeup:
	rts

; Here we're filling in 'fade_in_data' by scrolling all the data left one pixel using our old
; friend ROXL, and adding in a new pixel at the end.
.scroll_mask
	lea	fadein_data+(6*2),a0		; Go to the end of the data
	REPT	6						; Scroll everything one pixel to the left
	roxl.w	-(a0)
	ENDR
	ori.w	#1,(5*2)(a0)			; Add new pixel at the end
	rts

scan_mask_source
	REPT	6
	dc.w	%1111111111110101       ; <- Note we've added in a couple of lines to the mask for extra authenticity!
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
