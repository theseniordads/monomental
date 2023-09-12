	text

* "MONO-MENTAL" TITLES:
; Display a 4 frame "TV ident" style titles for the demo. Whilst each frame is displayed,
; the next frame is depacked to the back screen.
;
; This subroutine is called twice in the demo. The first time it's called, the main
; music is also started.
mono_mental_titles:
	lea		pic_mono_titles1,a0					; Title anim 1: "R" globe
	jsr		depack_pic_to_back
	lea		mus_monomental_main,a0				; Load up "Mono-mental" main music
	tst.b	do_not_restart_music				; As this title is called again later in the demo, 
	bne.s	.omit_music_start					; test for if we have to start the music
	jsr		start_music	
	st		do_not_restart_music
.omit_music_start:
	bsr		swap_screens						; Show anim 1 for first note of music
	set_clicks #80-1
	lea		pic_mono_titles2,a0					; Title anim 2: Add "G" globe
	jsr		depack_pic_to_back
	wait_until_end_clicks						; Wait until second note
	bsr		swap_screens						; Show anim 2
	wait_vbl
	set_clicks #80-1
	lea		pic_mono_titles3,a0					; Title anim 3: Add "B" globe and text "MONO"
	jsr		depack_pic_to_back
	wait_until_end_clicks						; Wait until third note
	bsr		swap_screens						; Show anim 3
	wait_vbl
	set_clicks #80-1
	lea		pic_mono_titles4,a0					; Title anim 4: Add text "MENTAL"
	jsr		depack_pic_to_back
	wait_until_end_clicks						; Wait until fourth note
	bsr		swap_screens						; Show anim 4
	wait_vbl
	set_clicks #80-1							; Set next screen to show upon end of fourth note.
	rts

    	
* INTRO PICS:
; Dead simple- it just shows two pics! It was probably seperated out from the titles screen
; when that was re-used later in the demo.
intro_pics:
	lea	pic_jason_king,a0
	jsr	depack_pic_to_back				; Jason King!
	wait_until_end_clicks
	bsr		swap_screens				; Show Jason in his majesty!
	wait_vbl
	set_clicks #320-1
	lea	pic_first_mono_demo,a0			; The first mono demo!
	jsr	depack_pic_to_back
	wait_until_end_clicks
	bsr		swap_screens				; Wow!
	wait_vbl
	set_clicks #320-1
	wait_until_end_clicks
	rts

	data

pic_mono_titles1:
	incbin graphics/packed/mono1.pi3
	even
pic_mono_titles2:
	incbin graphics/packed/mono2.pi3
	even
pic_mono_titles3:
	incbin graphics/packed/mono3.pi3
	even
pic_mono_titles4:
	incbin graphics/packed/mono4.pi3
	even

pic_jason_king:
	incbin graphics/packed/j_king.pi3
	even
pic_first_mono_demo:
	incbin graphics/packed/firstmon.pi3
	even

	bss

do_not_restart_music:
	ds.w	1
