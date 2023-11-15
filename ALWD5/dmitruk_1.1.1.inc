; data_init ()
; print_string (str_name) 
; print_string_as_chars (str_name)
; get_string (str_name)
; get_char_by_index (str_name, index_as_wb)
; print_new_line ()
; find_substr (base_str, sought_str)
; remove_word (base_str, removable_str) removable string must be a separate word in the base string 
; remove_substr (base_str, removable_str)
; push_registers () don't push "ip" and "cs"
; pop_registers () don't pop "ip" and "cs"
; space_check () returns -1 in al if string contains spaces



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
	cmp dx, 0h
	je print_empty
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
	je print_as_char_exit

print_empty:
print_new_line 

print_as_char_exit:        
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



get_char_by_index macro str, index		;returns a character in dl
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
	mov al, dl
	get_size str2
	mov bl, dl
	mov cl, al
	xor ch, ch
	xor bh, bh 
	xor di, di
	xor ax, ax

find_loop:
	get_char_by_index bstr, di
	mov dh, dl
	get_char_by_index fstr, ax
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
	mov ax, -1
	
exit:    
endm


	
remove_word macro str1, str2
      find_substr str1, str2
      cmp al, 0ffh   
      je remove_word_exit
      jmp word_check

word_check:
	push_registers

	xor dx, dx
	get_size str1	
	mov bx, dx
	xor dx, dx
	get_size str2	
	cmp bx, dx
	je continue_removing

	cmp al, 0h
	je after_space

	xor dx, dx
	get_size str2
	add dl, al				
	mov bl, dl
	get_size str1	
	cmp dl, bl
	je before_space

both_spaces_1:
  	dec al
  	xor ah, ah
  	get_char_by_index str1, ax
  	cmp dl, 20h
  	je both_spaces_2
  	jmp remove_word_exit

both_spaces_2:
  	inc al
  	xor dx, dx
  	get_size str2
  	mov bx, dx
  	xor ah, ah
  	add bx, ax
  	xor dx, dx
  	get_char_by_index str1, bx
  	cmp dl, 20h
  	je increase_substring_size
  	jmp remove_word_exit
  

before_space:
  	dec al
  	xor ah, ah
  	get_char_by_index str1, ax
  	cmp dl, 20h
  	je beforespace_exists
  	jmp remove_word_exit
  
beforespace_exists:
  	pop_registers 
  	dec al
  	push_registers
  	jmp increase_substring_size
 
after_space:
  	xor dx, dx
  	xor bx, bx
  	get_size str2
  	mov bx, dx
  	xor dx, dx
  	get_char_by_index str1, bx
  	cmp dl, 20h
  	je increase_substring_size
  	jmp remove_word_exit
  
increase_substring_size:
  	pop_registers 
  	inc bl
  	push_registers
  	jmp continue_removing

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
   
word_remove_loop:
      cmp si, dx
      ja word_end_loop
      mov ax, [si]
      mov [di], ax 
      ;movsb
      inc di
      inc si 
      loop word_remove_loop
   
word_end_loop:   
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
               
remove_word_exit:

endm 

remove_substr macro str1, str2
	    find_substr str1, str2
	    cmp al, 0ffh   
	    je remove_substr_exit
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
	 
substr_remove_loop:
	    cmp si, dx
	    ja substr_end_loop  
	    mov ax, [si]
	    mov [di], ax 
	    ;movsb
	    inc di
	    inc si 
	    loop substr_remove_loop
	 
substr_end_loop:   
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
         	    
remove_substr_exit:

endm 
  

push_registers macro
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

pop_registers macro
	pop es  
	pop ds
	pop di
	pop si
 	pop bp
	pop sp
	pop ss
 	pop dx
	pop cx
 	pop bx
	pop ax

endm

space_check macro str
	get_size str
	xor cx, cx
	mov cl, dl
	mov bx, 0h
	mov al, 0h

check_loop:
	get_char_by_index str, bx
	cmp dl, 20h
	je space_imposter_detected
	loop check_loop
	jmp space_check_exit
	
	
space_imposter_detected:
	mov al, -1

space_check_exit:

endm