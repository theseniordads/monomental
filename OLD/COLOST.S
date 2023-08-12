; Colostomy Bags contribution to the mono mental screen
; 68030 only  
; It could be called "How the fuck was I supposed to 
; know that high res on the Falcon requires the screen to be set to
; a 256 byte boundry" 

raster_bar_amount	equ	10


start
	move.w	#32,-(sp)
	trap	#1
	addq	#2,sp
	
	move.b	$ff8201,vidhigh
	move.b	$ff8203,vidmid
	move.b	$ff820d,vidlow
	move.l	$70.w,oldvbl
	move.l	#myvbl,$70.w
	clr.b	front+3
	clr.b	back+3

wait_key
	bsr	clear_screen

	rept	1  
	add.w	#1,x
	bsr	plot_raster_sprites
	endr

	bsr	wait_vbl
	bsr	swap_screens


	cmp.b	#57,$fffc02
	bne	wait_key	

	move.l	oldvbl,$70.w
	move.b	vidhigh,$ff8201
	move.b	vidmid,$ff8203
	move.b	vidlow,$ff820d

	clr.l	(sp)
	trap	#1

myvbl	subq.w	#1,$468.w
	rte

oldvbl	ds.l	1

; subroutines

clear_screen
	move.l	back,a0
	move.w	#2000-1,d0
	moveq	#-1,d1
zap
	rept	4
	move.l	d1,(a0)+		; yeah I know I should be
	endr				; using movem.l	 d0-a5,-(a6)
				        ; for more speed!
	dbf	d0,zap
	rts	

swap_screens
	movem.l	front,d0-d1
	exg.l	d0,d1
	movem.l	d0-d1,front
	
	move.b	d0,d1
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w
	move.b	d1,$ffff820d.w
	rts


wait_vbl	
	move.w	$468.w,d0
.loop	cmp.w	$468.w,d0
	beq.s	.loop
	rts

plot_raster_sprites

	moveq	#0,d1
	moveq	#0,d2
	move.l	back,d3

	lea	raster_sprite+34,a2

	move.w	x,d1
	
	cmp.w	#639-32,d1
	blt.s	no_clip

	move.w	#0,x			; clip the x 
	moveq	#0,d1

no_clip
	move.w	d1,d2

	and.l	#$f,d1			; work out shift
	lsr.l	#4,d2			; divide by 16
	add.l	d2,d2			; multiply by 2


	add.l	d3,d2
	move.l	d2,a0


	; now repeat for the size of the screen

	move.w	#400-1,d7		; height

draw_it	
	 move.l	(a2),d0
	;move.w	#-1,d0
	bfins	d0,(a0){d1:32}		; src, dst , bitshift, width
		
	;move.l	2(a2),d2
	;bfins	d0,2(a0){d1:32}		; src, dst , bitshift, width
	

;	move.l	d0,d3
;	lsr.l	d1,d3	
;	move.l	d3,(a0)	

	lea	80(a0),a0			; next line please
	dbf	d7,draw_it	

	rts


fast_clear
;	moveq	#0,d0
;	move.l	d0,d1
;	move.l	d0,d2
;	move.l	d0,d3
;	move.l	d0,d4
;	move.l	d0,d5
;	move.l	d0,d6

;	move.l	d0,a0
;	move.l	d0,a1
;	move.l	d0,a2
;	move.l	d0,a3
;	move.l	d0,a4
;	move.l	d0,a5


;	move.l	back,a6 	; set the address for a6
;	add.l	#32000,a6	; add a complete screens worth


	; 80 bytes - 52 = 28 
	; 28 * 400 = (28 * 4 = 112)
	; there is 112 bytes left at the end 

	; 112 - 52 = 60
	; 60 - 52 = 8

	; there is 8 bytes to be cleared at the end 

	; therefor loop 402 times and clear the last 8 bytes at 
	; the end 

;	move.w	#402-1,d7		; 52 bytes 

;clear
;	movem.l	d0-d6/a0-a5,-(a6)
;	dbf	d7,clear

;	move.l	#0,-(a6)
;	move.l	#0,-(a6)

	rts


; data goes here

		cnop	0,4		; makes the meovem faster	

front		dc.l	screen1
back		dc.l	screen2
	
vidhigh		dc.b	0
vidmid		dc.b	0
vidlow		dc.b	0

		cnop	0,4

	even
raster_sprite				; incbin the converted pic here
		incbin	k:\mono\pix\vrtras.pi3
	


; this is the raster sprite packet

packet_size	dc.w	0	

sprite_packet				; only one for now
	
x	dc.w	0

	section	bss

		cnop	0,4
	ds.b	256
screen1		dcb.b	32000,0	

		cnop	0,4

screen2		dcb.b	32000,0	

