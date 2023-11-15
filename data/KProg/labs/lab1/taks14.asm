	org	$8000
	psha		;CCR
	tpa
	staa	$8100
	pula
	std	$8101	;D
	xgdx
	std	$8103	;X
	xgdy
	std	$8105	;Y
	psha
	tsx
	xgdx
	std	$8107	;SP
	
	
	