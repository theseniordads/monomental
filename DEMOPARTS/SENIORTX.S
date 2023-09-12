	text

* SENIOR TEXT INTRO:
; Displayed at the very beginning of the demo.
;
; After the text is played, we wait for 400 frames or until 
; the user presses the space bar.
senior_text_intro:
	print_string #.senior_intro_text
	move	#400,timer.w                    ; Wait 400 frames
.wait:
	tst		timer.w
	blt.s	.exit
	cmpi.b	#space_bar,ikbd.w               ; ... or until the user presses space
	bne.s 	.wait
.exit:
	rts

	data

.senior_intro_text:
	dc.b 27, 'E'                            ; Clear screen
	incbin	graphics\senior_l.ogo           ; Huge Senior Dads logo in ASCII form- think this was made using a GIF -> ASCII art convertor on the PC!
	dc.b 13,10                              ; New line after the logo
senior_text:
	dc.b 'SENI0R dadS!!!',13,10
	dc.b '  .... Prezents!',13,10,10
	dc.b '    M   O   N  O M  e   N  TT   A   L   !!!',13,10,10
	dc.b 'A fabby-dabby-dooby-TUBBY!!   DEMO!',13,10,10
	dc.b '  DIS DEMO works **&&Any&&** komputers made by',13,10
	dc.b 'ATARI!!!   C-LAB!!!!    JTS!!!!!   HASBRO!!!',13,10,10,10
	dc.b '                  (except the 8-bit ones- sorry!!)',13,10,10
	dc.b ' yA needs a MOTOROLA chip for da procesaa!! And ONE mega memory!',13,10,10
	dc.b '<Wait a little time to prepare yourselfs!!! or press SPAC', $9c, '!>',0       ; <- $9c is the ASCII code on the Atari for "£".
	even
