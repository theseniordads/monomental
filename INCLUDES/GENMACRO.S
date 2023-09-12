* General macros

* Define macro- only defines an equate if not defined already
def_equ	macro	label,value
	IFND	\1
	list +
* Defining	\1 as \2
	list -
\1	equ	\2
	ELSE
	list +
* \1 is already defined.
	list -
	ENDC
	ENDM

_bps1		equ	0
_bps2		equ	1
_bps4		equ	2
_bps8		equ	3
_trucol		equ	4
_40col		equ	0
_80col		equ	8
_vga		equ	$10
_rgb		equ	0
_pal		equ	$20
_ntsc		equ	0
_overscan	equ	$40
_interlace	equ	$100
_line_double	equ	$100

* Key values:

ikbd		equ	$fffffc02
space_bar	equ	$39
l_curs		equ	$4b
r_curs		equ	$4d
u_curs		equ	$48
d_curs		equ	$50
pad_minus	equ	$4a
pad_plus	equ	$4e

* Vector values

vbl		equ	$70
timerb		equ	$120

* STE sound

ste_sound_base	equ	$ffff8900

_sound_freq50 equ	%11
_sound_freq25 equ	%10
_sound_freq12 equ	%01

_sound_mono	equ	1<<7
_sound_stereo	equ	0

_sound_16bit	equ	1<<6
_sound_8bit	equ	0<<6

start_sample	macro
	move.w	#1,ste_sound_base
	endm

start_sample_loop	macro
	move.w	#%11,ste_sound_base
	endm

stop_sample	macro
	clr.w	ste_sound_base
	endm


set_sample_player	macro	commands,sample_addr,sample_end
	stack_save	a0/d0/d1
	stop_sample
	lea	ste_sound_base.w,a0
	move.w	#\1,$20(a0)
	move.l	\2,d0
	move.b	d0,d1
	lsr.w	#8,d0
	move.l	d0,2(a0)
	move.b	d1,7(a0)
	move.l	\3,d0
	move.b	d0,d1
	lsr.w	#8,d0
	move.l	d0,$e(a0)
	move.b	d1,$13(a0)
	stack_restore	a0/d0/d1
	endm

wait_until_sample_end	macro
\@	tst.b	ste_sound_base+1.w
	bne.s	\@
	endm

* video

monitor_type	equ	$ffff8006
c16regs		equ	$ffff8240
st_res		equ	$ffff8260
vidhimid	equ	$ffff8200
vidlo		equ	$ffff820d
st_sync		equ	$ffff820a
c256regs	equ	$ffff9800
timer		equ	$468
keyclick	equ	$484
memtop		equ 	$42e

alt_help	equ	$502

iea		equ	$fffffa07
ima		equ	$fffffa13
timer_b_control	equ	$fffffa1b
timer_b_data	equ	$fffffa21
vector_register	equ	$fffffa17

	IFND	FASTER_MODE
FASTER_MODE	equ	1
	ENDC

	IFD set_screen_vars
	IFND	_planes
_planes	equ	2
	ENDC

	IFND	_columns
_columns	equ	80
	ENDC

	IFND	screen_height
screen_height	set	200
	ENDC

	IFND	screen_width
screen_width	set	(_planes*2)*(_columns/2)
	ENDC

	IFND	_screen_size
screen_size	set	screen_width*screen_height
	ENDC

set_screen_dims	macro	x_res,y_res[,mem]
screen_width	set	\1
screen_height	set	\2
screen_size	set	screen_width*screen_height
	IFNE	('\3'-'')
screen_width	set	screen_width*\3
screen_height	set	screen_height*\3
screen_size	set	screen_size*\3
	ENDC
	endm
	ENDC


getphys	macro	ret_addr
	stack_save	d0-d3/a0-a3
	move	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,\1
	stack_restore	d0-d3/a0-a3
	endm

getlog	macro	ret_addr
	stack_save	d0-d3/a0-a3
	move	#2,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,\1
	stack_restore	d0-d3/a0-a3
	endm

set_shift	macro	mode
	move	\1,-(sp)
	move	#$58,-(sp)
	trap	#14
	addq.l	#4,sp
	endm

getrez_falc	macro	ret_addr
	stack_save	d0-d3/a0-a3
	set_shift	#-1
	move	d0,\1
	stack_restore	d0-d3/a0-a3
	endm

getrez_st	macro	mode
	stack_save	d0-d3/a0-a3
	move.w	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	move	d0,\1
	stack_restore	d0-d3/a0-a3
	endm


setrez_falc	macro	mode,phys,log
	stack_save	d0-d3/a0-a3
	set_shift	\1
	move	\1,-(sp)
	move	#3,-(sp)
	move.l	\2,-(sp)
	move.l	\3,-(sp)
	move	#5,-(sp)
	trap	#14
;      	move.w	#$25,-(sp)
;      	trap	#14
;	lea	16(sp),sp
	lea	14(sp),sp
	stack_restore	d0-d3/a0-a3
	endm

setrez_st	macro	mode,phys,log
	stack_save	d0-d3/a0-a3
;	IFEQ	('\1'-'#0')
;	clr	-(sp)
;	ELSE
	move	\1,-(sp)
;	ENDC
	move.l	\2,-(sp)
	move.l	\3,-(sp)
	move	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	stack_restore	d0-d3/a0-a3
	endm
	

set_falcvmode	macro	addr
	stack_save	a0/a1
	move.l	\1,a0
	jsr	_setfv
	stack_restore	a0/a1
	endm

set_asavmode	macro	addr
	stack_save	a0/a1
	move.l	\1,a0
	jsr	_setasa
	stack_restore	a0/a1
	endm

get_vidaddr	macro	screen_addr
	stack_save	d0-d1
	move.b	$ffff820d.w,d1
	move.l	$ffff8200.w,d0
	andi.l	#$ff00ff,d0
	lsl.w	#8,d0 
	add.b	d1,d0
	move.l	d0,\1
	stack_restore	d0-d1
	endm

set_vidaddr	macro	screen_addr
	stack_save	d0-d1
	move.l	\1,d0
	move.l	d0,d1
	lsr.w	#8,d0 
	move.l	d0,$ffff8200.w
	move.b	d1,$ffff820d.w
	stack_restore	d0-d1
	endm

set_vidptr	macro	addr
	stack_save	d0/d1
	move.l	\1,d0
	move.l	d0,d1
	lsr.w	#8,d0
	move.b	d1,$ffff8209.w
	move.l	d0,$ffff8204.w
	stack_restore	d0/d1
	endm

vga_monitor	equ	2

if_vga_monitor	macro	where
	cmp.b	#vga_monitor<<6,monitor_type.w
	IFEQ ('\0'-'')
	beq	\1
	ELSE
	beq.\0	\1
	ENDC
	endm
	
if_not_vga_monitor	macro	where
	cmp.b	#vga_monitor<<6,monitor_type.w
	IFEQ ('\0'-'')
	bne	\1
	ELSE
	bne.\0	\1
	ENDC
	endm
	
get_monitor	macro	return_addr	; 2 if a VGA monitor
		stack_save	d1-d3/a0-a3
		move.w	#$59,-(a7)	;get monitor
		trap	#14
		addq.l	#2,a7
		stack_restore	d1-d3/a0-a3
		IFNE	('\1'-'d0')
		move.w	d0,\1
		ENDC
		endm

if_monitor	macro	value,where
		get_monitor	d0
		cmp.w	\1,d0
		IFEQ ('\0'-'')
		beq	\2
		ELSE
		beq.\0	\2
		ENDC
		endm

if_not_monitor	macro	value,where
		get_monitor	d0
		cmp.w	\1,d0
		IFEQ ('\0'-'')
		bne	\2
		ELSE
		bne.\0	\2
		ENDC
		endm

modecode_monitor	macro	mode_value
		stack_save	d0
		move.w	#_rgb|_pal,d7
		if_monitor.s	#1,.\@
		moveq	#_vga,d7
.\@		ori.w	#\1,d7
		stack_restore	d0
		endm

* Timer B raster macros.

wait_timer_b	macro
	stack_save	d0
	move.b	timer_b_data.w,d0
\@	cmp.b	timer_b_data.w,d0
	beq.s	\@
	stack_restore	d0
	endm

stop_timer_b	macro
	clr.b	timer_b_control.w
	endm

restart_timer_b	macro
	move.b	#8,timer_b_control.w
	endm

set_timer_b_interrupt	macro	scanlines
	stop_timer_b
	move.b	\1,timer_b_data.w
	restart_timer_b
	endm


* Timer macro - if timer goes down to zero (Put in vbl), branch somewhere

if_time_up	macro	where
	tst.w	timer.w
	blt.\0	\1
	endm

if_not_time_up	macro	where
	tst.w	timer.w
	bge.\0	\1
	endm

* Interrupts.

off	equ	0
on	equ	1

auto_end_of_interrupt	macro	on/off
	IFEQ	(\1-on)
	bclr	#3,vector_register
	ELSE
	bset	#3,vector_register
	ENDC
	endm
	

_num2text_on	set	0

_compare_string	macro	str1,str2,action,[neg]
	IF\4C	'\1','\2'
	\3
	ENDC
	endm

_ifsamestring	macro	str1,str2,action
	_compare_string	\1,\2,<\3>
	endm

_ifnotsamestring	macro	str1,str2,action
	_compare_string	\1,\2,<\3>,N
	endm

IFsingle_reg macro	register_list,action
	_ifsamestring	<\1>,<d0>,<\2>
	_ifsamestring	<\1>,<d1>,<\2>
	_ifsamestring	<\1>,<d2>,<\2>
	_ifsamestring	<\1>,<d3>,<\2>
	_ifsamestring	<\1>,<d4>,<\2>
	_ifsamestring	<\1>,<d5>,<\2>
	_ifsamestring	<\1>,<d6>,<\2>
	_ifsamestring	<\1>,<d7>,<\2>
	_ifsamestring	<\1>,<a0>,<\2>
	_ifsamestring	<\1>,<a1>,<\2>
	_ifsamestring	<\1>,<a2>,<\2>
	_ifsamestring	<\1>,<a3>,<\2>
	_ifsamestring	<\1>,<a4>,<\2>
	_ifsamestring	<\1>,<a5>,<\2>
	_ifsamestring	<\1>,<a6>,<\2>
	endm

_decregslist	macro
_regslist	set	_regslist-1
	endm

IFNEsingle_reg macro	register_list,action
	IFEQ	FASTER_MODE
_regslist	set	15
	_ifnotsamestring	<\1>,<d0>,<_decregslist>
	_ifnotsamestring	<\1>,<d1>,<_decregslist>
	_ifnotsamestring	<\1>,<d2>,<_decregslist>
	_ifnotsamestring	<\1>,<d3>,<_decregslist>
	_ifnotsamestring	<\1>,<d4>,<_decregslist>
	_ifnotsamestring	<\1>,<d5>,<_decregslist>
	_ifnotsamestring	<\1>,<d6>,<_decregslist>
	_ifnotsamestring	<\1>,<d7>,<_decregslist>
	_ifnotsamestring	<\1>,<a0>,<_decregslist>
	_ifnotsamestring	<\1>,<a1>,<_decregslist>
	_ifnotsamestring	<\1>,<a2>,<_decregslist>
	_ifnotsamestring	<\1>,<a3>,<_decregslist>
	_ifnotsamestring	<\1>,<a4>,<_decregslist>
	_ifnotsamestring	<\1>,<a5>,<_decregslist>
	_ifnotsamestring	<\1>,<a6>,<_decregslist>
		IFEQ	_regslist
		\2
		ENDC
	ELSE
	\2
	ENDC
	endm

stack_save	macro	register_list
	IFEQ	FASTER_MODE
	IFsingle_reg	\1,<move.l \1,-(sp)>
	ENDC
	IFNEsingle_reg	\1,<movem.l \1,-(sp)>
	endm

stack_restore	macro	register_list
	IFEQ	FASTER_MODE
	IFsingle_reg	\1,<move.l (sp)+,\1>
	ENDC
	IFNEsingle_reg	\1,<movem.l (sp)+,\1>
	endm

if_true		macro	flag,branch
	tst.b	\1
	IFEQ	('\0'-'')
	bne	\2
	ELSE
	bne.\0	\2
	ENDC
	endm

if_false	macro	flag,branch
	tst.b	\1
	IFEQ	('\0'-'')
	beq	\2
	ELSE
	beq.\0	\2
	ENDC
	endm

mem_shrink	macro	end_prg,error_bra[,param]
	move.l	4(sp),a5
	move.l	\1,d0
	sub.l	a5,d0
	addi.l	#$100,d0
	move.l	d0,-(sp)
	pea	(a5)
	clr	-(sp)
	move	#$4a,-(sp)
	trap	#1
	lea	12(sp),sp
	tst	d0
	bne	\2
	IFNE	('\3'-'')
	lea	$81(a5),a5
	IFNE	('\3'-'a5')
	move.l	a5,\3
	ENDC
	ENDC
	endm

reserve_mem	macro	no_bytes,reserved_addr
	stack_save	a0/d0
	move.l	\1,-(sp)
	move	#$48,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,\2
	tst.l	d0
	stack_restore	a0/d0
	endm

mem_free	macro	addr_to_free
	stack_save	a0/d0
	move.l	\1,-(sp)	
	move	#$49,-(sp)
	trap	#1
	addq.l	#6,sp
	tst.l	d0
	stack_restore	a0/d0
	endm

clear_registers	macro
	moveq.l	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.l	d0,d4
	move.l	d0,d5
	move.l	d0,d6
	move.l	d0,d7
	endm

print_string	macro	text
	stack_save	a0/d0
	move.l	\1,-(sp)
	move	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	stack_restore	a0/d0
	endm

wait_key	macro
	move	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	endm

* Switch keyclick on and off

keyclick_on	macro
	bset	#0,keyclick.w
	endm

keyclick_off	macro
	bclr	#0,keyclick.w
	endm



num2text	macro	textstore,number,no_of_chars[,.len]
_num2text_on	set	1
	stack_save	a6/d6/d7
	move.l	\1,a6
	move\4	\2,d6
	move.l	\3,d7
	jsr	_num2text
	stack_restore	a6/d6/d7
	endm

text2num	macro	textstore,number,no_of_chars
	IFND	_text2num_on
_text2num_on
	ENDC
	stack_save	a6/d6/d7
	move.l	\1,a6
	moveq.l	#0,d6
	move.l	\3,d7
	jsr	_text2num
	move.\0	d6,\2
	stack_restore	a6/d6/d7
	endm

* File reading commands

set_dta_buffer	macro	where
	move.l	\1,-(sp)
	move	#$1a,-(sp)
	trap	#1
	addq.l	#6,sp
	endm

s_first	macro	filename,attrib,dta_buffer
	set_dta_buffer	\3
	move	\2,-(sp)
	move.l	\1,-(sp)
	move	#$4e,-(sp)
	trap	#1
	addq.l	#8,sp
	tst	d0
	endm

s_next	macro
	move	#$4f,-(sp)
	trap	#1
	addq.l	#2,sp
	tst	d0
	endm

ch_drv	macro	drive
	move	\1,-(sp)
	move	#$e,-(sp)
	trap	#1
	addq.l	#4,sp
	endm

ch_dir	macro	dir
	move.l	\1,-(sp)
	move	#$3b,-(sp)
	trap	#1
	addq.l	#6,sp
	endm

get_dir	macro	dir_addr
	clr	-(sp)
	move.l	\1,-(sp)
	move	#$47,-(sp)
	trap	#1
	addq.l	#8,sp
	endm

	rsreset	
		rs.b	21
dta_fill_attr	rs.b	1
dta_time	rs.b	2
dta_date	rs.b	2
dta_filesize	rs.b	4
dta_fname	rs.b	14

file_open	macro	filename,handle,err
	move	#2,-(sp)
	move.l	\1,-(sp)
	move	#$3d,-(sp)
	trap	#1
	addq.l	#8,sp
	tst	d0
	bmi	\3
	move	d0,\2
	endm

file_create	macro	filename,handle,err
	move	#0,-(sp)
	move.l	\1,-(sp)
	move	#$3c,-(sp)
	trap	#1
	addq.l	#8,sp
	tst	d0
	bmi	\3
	move	d0,\2
	endm

file_read	macro	buffer,number,handle,err
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	move.w	\3,-(sp)
	move	#$3f,-(sp)
	trap	#1
	lea	12(sp),sp
	tst.l	d0
	bmi	\4
	endm

file_write	macro	buffer,number,handle,err
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	move.w	\3,-(sp)
	move	#$40,-(sp)
	trap	#1
	lea	12(sp),sp
	tst.l	d0
	bmi	\4
	endm

file_close	macro	handle,err
	move.w	\1,-(sp)
	move	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	tst	d0
	bmi	\2
	endm

* Disk reading commands

read_track	macro	secs_per_trk,side,track,drive,addr
	stack_save	a0-a2/d0-d2
	move	\1,-(sp)
	move	\2,-(sp)
	move	\3,-(sp)
	move	#1,-(sp)
	move	\4,-(sp)
	clr.l	-(sp)
	move.l	\5,-(sp)
	move	#8,-(sp)
	trap	#14
	lea	20(sp),sp
	tst	d0
	move	d0,derrnum
	stack_restore	a0-a2/d0-d2
	endm

rwabs	macro	drive,start,sector,addr
	stack_save	a0-a2/d0-d2
	move	\1,-(sp)
;	IFEQ	('#0'-'\2')
;	clr	-(sp)
;	ELSE
	move	\2,-(sp)
;	ENDC
	move	\3,-(sp)
	move.l	\4,-(sp)
	move	\5,-(sp)
	move	#4,-(sp)
	trap	#13
	lea	14(sp),sp
	tst	d0
	move	d0,derrnum
	stack_restore	a0-a2/d0-d2
	endm

read_sectors	macro	drive,start,sector,addr
	rwabs	\1,\2,\3,\4,#2
	endm

write_sectors	macro	drive,start,sector,addr
	rwabs	\1,\2,\3,\4,#3
	endm

read_bootsector	macro	drive,addr
	read_sectors	\1,#0,#1,\2
	endm

write_bootsector	macro	drive,addr
	write_sectors	\1,#0,#1,\2
	endm

make_bootsector	macro	boot_addr
	stack_save	a0/d0/d1
	move.l	\1,a0
	move	#$1234,d0
	move	#(510/2)-1,d1
	sub	(a0)+,d0
	dbf	d1,*-2
	move	d0,(a0)+
	stack_restore	a0/d0/d1
	endm

write_track	macro	secs_per_trk,side,track,drive,addr
	stack_save	a0-a2/d0-d2
	move	\1,-(sp)
	move	\2,-(sp)
	move	\3,-(sp)
	move	#1,-(sp)
	move	\4,-(sp)
	clr.l	-(sp)
	move.l	\5,-(sp)
	move	#9,-(sp)
	trap	#14
	lea	20(sp),sp
	tst	d0
	move	d0,derrnum
	stack_restore	a0-a2/d0-d2
	endm

format_track	macro	secs_per_trk,side,track,drive,addr
	stack_save	a0-a2/d0-d2
	move	#$e5e5,-(sp)
	move.l	#$87654321,-(sp)
	move	#1,-(sp)
	move	\2,-(sp)
	move	\3,-(sp)
	move	\1,-(sp)
	move	\4,-(sp)
	clr.l	-(sp)
	move.l	\5,-(sp)
	move	#10,-(sp)
	trap	#14
	lea	26(sp),sp
	tst	d0
	move	d0,derrnum
	stack_restore	a0-a2/d0-d2
	endm

copy_chars	macro	from,to,num
	stack_save	a5/a6/d7
	move.l	\1,a5
	move.l	\2,a6
	move.l	\3-1,d7
	bsr	_copy_chars
	stack_restore	a5/a6/d7
	endm

copy_filename	macro
	copy_chars	\1,\2,#14
	endm

pexec	macro	filename[,env[,command[,mode]]
	IFNE	('\2'-'')
	move.l	\2,-(sp)
	ELSE
	pea	env
	ENDC
	IFNE	('\3'-'')
	move.l	\3,-(sp)
	ELSE
	pea	cmd
	ENDC
	move.l	\1,-(sp)
	IFNE	('\4'-'')
	move.l	\4,-(sp)
	ELSE
	clr	-(sp)
	ENDC
	move.w	#$4b,-(sp)
	trap	#1
	lea	16(sp),sp
	endm

super_execute	macro	routine
	move.l	\1,-(sp)
	move	#38,-(sp)
	trap	#14
	addq.l	#6,sp
	endm

normal_exit	equ	0
keep_process	equ	1

init_prog	macro	type_of_exit [, end_of_prog]
	super_execute	#main
	IFEQ	\1
end_prog
	clr	-(sp)
	trap	#1
	ELSE
	clr.w	-(sp)
	move.l	\2,d0
	sub.l	4(a7),d0
	move.l	d0,-(sp)
	move.w	#$31,-(sp)
	trap	#1
	ENDC

	bss

	ds.l	200
new_stack
	ds.l	1
old_stack
	ds.l	1

	text

main
	endm

save_old_stack	macro
	move.l	a7,old_stack
	lea	new_stack,a7
	endm

restore_old_stack	macro
	move.l	old_stack,a7
	endm

write_ikbd	macro	byte
	move.b	\1,d7
	bsr	_write_ikbd
	endm

read_absolute_mouse	macro	max_x,max_y
	bsr	ret_keyints
	stack_save	d0/d1
	write_ikbd	#9	
	move	\1,d0
	move	d0,d1
	lsr	#8,d1
	write_ikbd	d1	
	write_ikbd	d0	
	move	\2,d0
	move	d0,d1
	lsr	#8,d1
	write_ikbd	d1	
	write_ikbd	d0	
	stack_restore	d0/d1
	bsr	set_keyints
	endm

set_absolute_mouse_scale	macro	x,y
	bsr	ret_keyints
	move.b	#$c,ikbd.w
	move.b	\1,ikbd.w
	move.b	\2,ikbd.w
	bsr	set_keyints
	endm

read_relative_mouse	macro
	bsr	ret_keyints
	move.b	#8,ikbd.w
	bsr	set_keyints
	endm

bconout	macro	char,dev
	stack_save	d0-d2/a0-a2
	move	\2,-(sp)
	move	\1,-(sp)
	move	#3,-(sp)
	trap	#13
	addq.l	#6,sp
	tst	d0
	stack_restore	d0-d2/a0-a2
	endm

bconin	macro	dev
	stack_save	d1-d2/a0-a2
	move	\1,-(sp)
	move	#2,-(sp)
	trap	#13
	addq.l	#4,sp
	stack_restore	d1-d2/a0-a2
	endm

* Flash CPU time

;	def_equ	FLASH_ON,1

flash_cputime	macro	[col,streg]
	IFNE	FLASH_ON

	IFEQ	('\2'-'')
		IFEQ	('\1'-'')
			eori.l	#$ff00ff,c256regs.w
		ELSE
			eori.l	\1,c256regs.w
		ENDC
	ELSE
		eori.w	\1,c16regs.w
	ENDC

	ENDC
	endm

* Switch resetvector on/off

resvalid	equ	$426
resvector	equ	$42a
magic_reset	equ	$31415926

set_resetvector	macro	routine_addr
	move.l	#magic_reset,resvalid.w
	move.l	\1,resvector.w
	endm

restore_resetvector	macro
	clr.l	resvalid.w
	endm

* Go 50/60 hz;

hz50	equ	2
hz60	equ	0

go50hz	macro
	move.b	#hz50,st_sync.w
	endm

go60hz	macro
	move.b	#hz60,st_sync.w
	endm

* Keyboard commands

normal		equ	0
midi_on		equ	%01
typewriter_on	equ	%10

set_keybd_mode	macro	type
	IFEQ	\1
	st	midi_off
	sf	typewriter_mode
	ELSE	IFEQ	(\1-midi_on)
	sf	midi_off
	sf	typewriter_mode
	ELSE	IFEQ	(\1-typewriter_on)
	st	midi_off
	st	typewriter_mode
	ELSE	IFEQ	(\1-midi_on|typewriter_on)
	sf	midi_off
	st	typewriter_mode
	ENDC
	jsr	_save_keyints
	endm
	
go_keybd	macro
	jsr	_set_keyints
	endm

stop_keybd	macro
	jsr	_ret_keyints
	endm

if_key	macro	key,where
	cmp.b	\1,keybuff
	beq.\0	\2
	endm

if_not_key	macro	key,where
	cmp.b	\1,keybuff
	bne.\0	\2
	endm

if_space	macro	where
	if_key.\0	#space_bar,\1
	endm

if_not_space	macro	where
	if_not_key.\0	#space_bar,\1
	endm

wait_space	macro
	clr.b	keybuff
\@	cmp.b	#space_bar,keybuff
	bne.s	\@
	endm

j_u	equ	0
j_d	equ	1
j_l	equ	2
j_r	equ	3
j_f	equ	7

if_joystick	macro	bit,where
	btst.b	#\1,_joy_data
	IFEQ ('\0'-'')
	bne	\2
	ELSE
	bne.\0	\2
	ENDC
	endm

if_not_joystick	macro	bit,where
	btst.b	#\1,_joy_data
	IFEQ ('\0'-'')
	beq	\2
	ELSE
	beq.\0	\2
	ENDC
	endm

if_joystick_left	macro	where
	if_joystick	j_l,\1
	endm

if_joystick_right	macro	where
	if_joystick	j_r,\1
	endm

if_joystick_up		macro	where
	if_joystick	j_u,\1
	endm

if_joystick_down	macro	where
	if_joystick	j_d,\1
	endm

if_joystick_fire	macro	where
	if_joystick	j_f,\1
	endm

if_not_joystick_left	macro	where
	if_not_joystick	j_l,\1
	endm

if_not_joystick_right	macro	where
	if_not_joystick	j_r,\1
	endm

if_not_joystick_up		macro	where
	if_not_joystick	j_u,\1
	endm

if_not_joystick_down	macro	where
	if_not_joystick	j_d,\1
	endm

if_not_joystick_fire	macro	where
	if_not_joystick	j_f,\1
	endm

* Wait command

wait_for	macro	 period
	IFND	_wait_for_on
_wait_for_on
	ENDC
	IFEQ	('\1'-'#0')
	stack_save	d1
	jsr	_wait_once
	stack_restore	d1
	ELSE
	stack_save	d0/d1
	move	\1,d0
	jsr	_wait_for
	stack_restore	d0/d1
	ENDIF
	endm

wait_vbl	macro
	wait_for	#0
	endm
	
* Put trucolour	logo on screen at x,y coords

put_trucol_logo	macro	screen,x,y,addr,w,h
	IFND	_put_trucol_logo_on
_put_trucol_logo_on
	ENDC
	stack_save	d0-d3/a0-a2
;	IFNE	('\1'-'a0')
	move.l	\1,a0
;	ENDC
	IFNE	('\2'-'d0')
	move	\2,d0
	ENDC
	IFNE	('\3'-'d1')
	move	\3,d1
	ENDC
;	IFNE	('\4'-'a1')
	move.l	\4,a1
;	ENDC
	IFNE	('\5'-'d2')
	move	\5,d2
	ENDC
	IFNE	('\6'-'d3')
	move	\6,d3
	ENDC
	jsr	_put_trucol_logo
	stack_restore	d0-d3/a0-a2
	endm
	
* DigiCall macros.

midi_port	equ	3

dc_get_usernames	equ	1
dc_introduce		equ	1
dc_who			equ	2
dc_relay		equ	3

superuser	equ	0

write_char_to_midi	macro	char
	bconout	#midi_port,\1
	endm

get_char_from_midi	macro
	bconin	#midi_port
	endm

digicall_incoming	macro
	stack_save	d0-d2/a0-a2
	move	#midi_port,-(sp)
	move	#1,-(sp)
	trap	#13
	addq.l	#4,sp
	tst	d0
	stack_restore	d0-d2/a0-a2
	endm

digicall_outgoing	macro
	stack_save	d0-d2/a0-a2
	move	#midi_port,-(sp)
	move	#8,-(sp)
	trap	#13
	addq.l	#4,sp
	tst	d0
	stack_restore	d0-d2/a0-a2
	endm

digicall_sentinel	macro
	write_char_to_midi	#0
	endm

digicall_get_callsigns	macro
	write_char_to_midi	#0
	digicall_sentinel
	st	me_call
	endm

digicall_mycallsign	macro
	write_char_to_midi	you_are
	digicall_sentinel
	endm

digicall_command	macro	command
	write_char_to_midi	\1
	endm

digicall_get_usernames	macro
	digicall_command	#dc_get_usernames
	digicall_writestring	you_are
	digicall_sentinel
	endm

digicall_introduce macro
	digicall_command	#dc_introduce
	digicall_writestring	#you_are
	endm	

digicall_relay 	macro	string
	digicall_command	#dc_relay
	digicall_writestring	#you_are
	digicall_writestring	\1
	endm	

digicall_writestring	macro	string
	IFND	_dc_ws
_dc_ws
	ENDC
	stack_save	a0/d0
	move.l	\1,a0
	bsr	_digicall_writestring
	stack_restore	a0/d0
	endm

write_midi_string	macro	string
	move.l	\1,a0
	bsr	_midi_string
	endm

write_midi_char		macro	char.b
	move.b	\1,d0
	bsr	_midi_char
	endm

write_midi_data		macro	data,length
	move.l	\2,d0
	move.l	\1,a0
	bsr	_midi_data
	endm
