* "PRODIGY TRIBUTE" aka "SMACK MY BITCH UP" SCREEN:
; This just displays a picture, and displays some timed text.
smack_my_bitch_up:
	set_clicks	#80-1
	lea		pic_smack_my_bitch_up,a0
	jsr		depack_pic_to_back
	jsr		swap_screens
	wait_until_end_clicks
	set_clicks #20-1
	movea.l	front,a1
	lea		txt_smack,a0
	move	#32,d0
	move	#50,d1
	jsr		font_string_mono
	wait_until_end_clicks
	set_clicks #20-1
	movea.l	front,a1
	lea		txt_my,a0
	move	#36,d0
	move	#150,d1
	jsr		font_string_mono
	wait_until_end_clicks
	set_clicks #20-1
	movea.l	front,a1
	lea		txt_bitch,a0
	move	#34,d0
	move	#250,d1
	jsr	font_string_mono
	wait_until_end_clicks
	set_clicks #20-1
	movea.l	front,a1
	lea		txt_up,a0
	move	#33,d0
	move	#350,d1
	jsr		font_string_mono
	wait_until_end_clicks
	set_clicks	#10
	wait_until_end_clicks
	rts

pic_smack_my_bitch_up:
	incbin graphics/packed/dog_smbu.pi3
	even

txt_smack:	dc.b 'SMACK', 0
txt_my:		dc.b 'MY', 0
txt_bitch	dc.b 'BITCH', 0
txt_up:		dc.b 'UP!!!', 0
	even

