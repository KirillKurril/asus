data_init macro
       	mov ax, data
       	mov ds, ax
endm



print_string macro str
	mov ah, 09h
	mov dx, offset str + 2
	int 21h
endm



print_string_as_chars macro str 
	xor dx,dx
	get_size str
	cmp dl, 0h
	je adios
	mov cx, dx
	mov bx, offset str
	mov si, bx
	add si, 2

print_loop:
	mov dl, [si]
    	mov ah, 02h
    	int 21h
    	inc si
    	loop print_loop  
adios:
        
endm



get_string macro str
	lea dx, str
        mov ah, 0Ah
       	int 21h
endm



get_size macro str				;returns size in dl
	mov si, offset str
        add si, 1
       	mov dl, [si]
endm



get_char_by_inedx macro str, index		;returns a character in dl
	mov si, offset str + 2
        add si, index
       	mov dl, [si]
endm	



print_new_line macro 
	mov ah, 02h
	mov dl, 10
	int 21h
	mov dl, 13
	int 21h
endm



find_substr macro bstr, fstr			;returns the first index of the substring occurrence in al or ff if the substring is not found
    	get_size str1
	cmp dl, 0h
	je meow
	mov al, dl
	get_size str2
	cmp dl, 0h
	je meow
	mov bl, dl
	mov cl, al
	xor ch, ch
	xor bh, bh 
	xor di, di
	xor ax, ax

find_loop:
	get_char_by_inedx bstr, di
	mov dh, dl
	get_char_by_inedx fstr, ax
	cmp dh, dl
	je equal
	jmp not_equal

equal: 
    inc ax
	cmp al, bl
	je success
	jmp return

success: 
    dec ax
	sub di, ax
	mov ax, di
	jmp exit

not_equal:
	xor ax, ax
	jmp return

return:
	inc di
	loop find_loop 
	jmp meow

meow:
	mov ax, -1
	
exit:    
endm


	
remove macro str1, str2
	    find_substr str1, str2
	    cmp al, 0ffh   
	    je gerauahier
	    jmp word_check

word_check:

	push_registers
	cmp al, 0ffh
	je start_index

after_space:
	get_char_by_inedx str1, 
	mov bx, offset str1
	xor dx, dx
	xor ah, ah
	get_size str2
	add bx, dx
	add bx, ax
	add bx, 3
	
	mov dh, [bx]
	cmp bx, 32
	je continue_removing
	jmp gerauahier:
	
	

continue_removing:
	    pop_registers 
	    get_size str1
	    mov cl, dl
	    sub cl, bl
	                               
	    xor dh, dh
	    mov ah, bl 
	    mov bx, offset str1
	    add bx, 2           ;bx -- 0 cell address in the string
	    add dx, bx
	    dec dx              ;dx -- last cell address in the string
	    
	    push ax             ;ah -- substring length, al -- index of the first occurrence of the substring 
	    mov ah, 0
	    add bx, ax 
	    mov di, bx
	    pop ax
	    push ax
	    mov al, ah
	    mov ah, 0
	    add bx, ax
	    mov si, bx
	    xor dh, dh
	 
remove_loop:
	    cmp si, dx
	    ja end_loop  
	    mov ax, [si]
	    mov [di], ax 
	    ;movsb
	    inc di
	    inc si 
	    loop remove_loop
	 
end_loop:   
        pop ax           
        mov al, ah              ;mov [offste str1 + dl - ah], '$'
        mov ah, 0
        mov bx, offset str1
        add bx, dx
        sub bx, ax  
        inc bx
        mov [bx], '$'
        mov bx, offset str1     ;mov [offste str1 + 1], dl - ah
        inc bx 
        get_size str1
        sub dx, ax
        mov [bx], dl
         	    
gerauahier:

endm 
	

push_registers macro	;exept "ip" and "cs"
	push ax
	push bx
	push cx
	push dx
	push ss
	push sp
	push bp
	push si
	push di
	push ds
	push es
endm

pop_registers macro	;exept "ip" and "cs"
	pop ax
	pop bx
	pop cx
	pop dx
	pop ss
	pop sp
	pop bp
	pop si
	pop di
	pop ds
	pop es
endm