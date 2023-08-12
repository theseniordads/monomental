FILES

/PIX Pictures- all in Degas PI3 format
	
  OLDFART.PI3 - credit for Old Fart
  DODGIT.PI3 - credit for Doddering Git
  DAMEVERA.PI3 - credit for Dame Vera Lynn
  JACKPOL.PI3 - credit for Jackson Pollock
  PRESENTS.PI3 - mono version of "Senior Dads Presents" pic
  BASIL.PI3 - plug for Jackson Pollocks band

/MUSIC Music

  CRASH.THK 	- Music to play during a crash!
  MONO.THK	- "The Past is an undiscovered country- I am the 
                   Viking to rape and pillage it" by Dame Vera Lynn
  SENIOR.THK	- Senior Dads fanfare- played during the "Presents" bit


play music:
	jsr	music 		init music
	jsr	music+8		play music (As usual call this every vbl)
	jsr	music+4		stop music sound.
  