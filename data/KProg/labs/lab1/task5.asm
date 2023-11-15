	org	$8000
	xgdx		;first
	xgdy
	xgdx
	pshx		;second
	pshy
	pulx
	puly
	stx	$8100	;third
	sty	$8102
	ldx	$8102
	ldy	$8100