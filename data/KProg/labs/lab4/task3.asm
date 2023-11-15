	org	$8000
	ldx	#$8200
	ldy	#$0

loop	ldab	0,x		;main loop
	orab	#%11111011
	cmpb	#%11111011
	beq	cpbtoe		;test 3 bit
aftst	cpx	#$8220		;goto end if x 
	bhs 	end		;greater then 8220
	inx
	iny
	jmp	loop
cpbtoe	ldaa	0,x
	staa	0,y
	jmp	aftst
end	jmp end			
	