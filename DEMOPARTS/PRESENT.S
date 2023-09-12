	text

* "SENIOR DADS PRESENT..." screen
; Not much to this one, just show the picture and play the fanfare.
sd_present:
	lea	pic_presents,a0					; Unpack the "Presents..." pic
	jsr	depack_pic_to_back
	bsr	swap_screens
	lea	mus_sd_fanfare,a0				; Play the fanfare
	jsr	start_music
	set_clicks #640-1					; Wait a bit....
	wait_until_end_clicks
	rts

