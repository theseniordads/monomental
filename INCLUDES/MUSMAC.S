set_clicks	macro
	move.w	\1,click_counter
	endm

if_not_endclicks	macro
	tst.w	click_counter
	IFEQ	('\0'-'')
	bne	\1
	ELSE
	bne.\0	\1
	ENDC
	endm

wait_until_end_clicks	macro
\@	if_not_endclicks.s	\@
	endm

wait_click	macro
	move.w	click_counter,d6
\@	cmp.w	click_counter,d6
	beq.s	\@
	endm

wait_clicks	macro	number_of_clicks
	stack_save	d0/d1
	move.w	\1,d1
\@	wait_click
	dbf	d1,\@
	stack_restore	d0/d1
	endm

