* MONO MENTAL demo by SENIOR DADS!

* Music player and "click counter"
* Uses Timer D so that music is played at right speed
* regardless of frequency of display (Which can be 50,
* 60, or 70Hz depending on what "mono" mode you are
* running the demo in!) Also used for frequency
* independent timing

* Adapted from source on Megatizer disk.



* Start Music- music is in a0

start_music
	move.l	a0,current_music
	jsr	(a0)			Initialize the music
	
	lea saves(pc),a0		Buffer where old datas will be in
	move.l $110.w,(a0)+		Timer D vector
	move.l $fffffa06.w,(a0)+	Interrupt enable A & B
	move.l $fffffa12.w,(a0)+	Interrupt mask A & B
	move.b $fffffa1d.w,(a0)+	Timer C & D control
	move.b $fffffa25.w,(a0)+	Timer D data
	move.b $fffffa17.w,(a0)		Vector
	
	move #$2700,sr			Stop all interrupts
	move.l #rout,$110.w		Our own timer D routine
	or.l #$200010,$fffffa06.w	IERA
	or.l #$200010,$fffffa12.w	IMRA
	andi.b #$f0,$fffffa1d.w		TCDCR
	move.b #246,$fffffa25.w		TDDR	
	or.b #7,$fffffa1d.w		TCDCR
	bclr #3,$fffffa17.w		VR
	move #$2300,sr			Enable all interrupts
	rts

current_music	ds.l	1
	

* Stops current music

stop_music
	move #$2700,sr			Stop all interrupts
	move.l	current_music,a0
	jsr	4(a0)			Current noises off
	
	lea saves(pc),a0	
	move.l (a0)+,$110.w
	move.l (a0)+,$fffffa06.w
	move.l (a0)+,$fffffa12.w	Restore interrupts
	move.b (a0)+,$fffffa1d.w
	move.b (a0)+,$fffffa25.w
	move.b (a0),$fffffa17.w
	move.b #15,$484.w		Click !!!
	move #$2300,sr			Enable all interrupts
	rts
	
rout
	movem.l	d0-a6,-(sp)
	move.l	current_music,a0
	jsr	8(a0)			Play
	movem.l	(sp)+,d0-a6
	subq.w	#1,click_counter
	rte 

click_counter	ds.w	1

saves	ds.l 4				Old datas
