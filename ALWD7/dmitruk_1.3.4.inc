; data_init ()
; print_string (str_name) 
; print_string_as_chars (str_name)
; print_new_line()
; get_string (str_name)
; get_char_by_index (str_name, index_as_wb) it's prohibited to use bx as index
; get_size (str_name)
; print_new_line ()
; print_ax ()
; print_char(char)
; find_substr (base_str, sought_str)
; remove_word (base_str, removable_str) removable string must be a separate word in the base string 
; remove_substr (base_str, removable_str)
; push_registers () don't push "ip" and "cs"
; pop_registers () don't pop "ip" and "cs"
; space_check () returns -1 in al if string contains spaces
; set_size (str_name, new_size) set string size from dl value
; is_empty (str_name) set ZF if string is empty
; to_uint (str_name) if error, returns ffff in ax and cf = 1, si must be 0h or if is called from to_int 0h or 01h
; to_int (str_name) if error, returns ffff in ax and cf = 1
; decimalize_print() prints number from ax as signed int
; copy_cmd (str_name)



;------------------------------------------------------------------------------------------------------------------------------------------------------------------------

data_init macro
       	mov ax, data
       	mov ds, ax
endm

;------------------------------------------------------------------------------------------------------------------------------------------------------------------------

print_string macro str
	push ax
	push dx
	mov ah, 09h
	mov dx, offset str
	int 21h
	pop dx
	pop ax

endm

;------------------------------------------------------------------------------------------------------------------------------------------------------------------------

print_string_as_chars macro str 
	local print_loop, print_empty, print_as_char_exit
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

;------------------------------------------------------------------------------------------------------------------------------------------------------------------------

get_string macro str
	lea dx, str
        mov ah, 0Ah
       	int 21h
endm

;------------------------------------------------------------------------------------------------------------------------------------------------------------------------

get_size macro str				;returns size in dl
	push si 
	mov si, offset str
        add si, 1
       	mov dl, [si]
	pop si 
endm

;------------------------------------------------------------------------------------------------------------------------------------------------------------------------

get_char_by_index macro str, index		;returns a character in dl
	push bx
	mov bx, offset str + 2
        add bx, index
       	mov dl, [bx]
	pop bx
endm	

;------------------------------------------------------------------------------------------------------------------------------------------------------------------------

print_new_line macro 
	push ax
	push dx
	mov ah, 02h
	mov dl, 10
	int 21h
	mov dl, 13
	int 21h
	pop dx
	pop ax

endm


;------------------------------------------------------------------------------------------------------------------------------------------------------------------------

print_ax macro 
	push ax
	push dx
	mov dl, ah
	mov ah, 02h
	int 21h
	mov dl, al
	int 21h
	pop dx
	pop ax

endm


;------------------------------------------------------------------------------------------------------------------------------------------------------------------------

print_char macro ch
	push ax
	push dx
	mov dl, ch
	mov ah, 02h
	int 21h
	pop dx
	pop ax

endm

;------------------------------------------------------------------------------------------------------------------------------------------------------------------------

find_substr macro bstr, fstr			;returns the first index of the substring occurrence in al or ff if the substring is not found
	local find_loop, equal, success, not_equal, return, exit   
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

;------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
remove_word macro str1, str2
	local word_check, both_spaces_1, both_spaces_2, before_space, beforespace_exists, after_space, increase_substring_size, continue_removing, word_remove_loop, word_end_loop, remove_word_exit       
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

;------------------------------------------------------------------------------------------------------------------------------------------------------------------------

remove_substr macro str1, str2
	    local substr_remove_loop, substr_end_loop, substr_end_loop, substr_end_loop, remove_substr_exit   
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
  
;------------------------------------------------------------------------------------------------------------------------------------------------------------------------

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

;------------------------------------------------------------------------------------------------------------------------------------------------------------------------

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

;------------------------------------------------------------------------------------------------------------------------------------------------------------------------

lite_push macro
	push bx
	push cx
 	push dx
	push si
	push di

endm

;------------------------------------------------------------------------------------------------------------------------------------------------------------------------

lite_pop macro
	pop di
	pop si
 	pop dx
	pop cx
	pop bx

endm

;------------------------------------------------------------------------------------------------------------------------------------------------------------------------

space_check macro str
	local check_loop, space_imposter_detected, space_check_exit  
	get_size str
	xor cx, cx
	mov cl, dl
	xor si, 0h
	mov al, 0h

check_loop:
	get_char_by_index str, si
        inc si
	cmp dl, 20h
	je space_imposter_detected
	loop check_loop
	jmp space_check_exit
	
	
space_imposter_detected:
	stc

space_check_exit:

endm

;------------------------------------------------------------------------------------------------------------------------------------------------------------------------

set_size macro str, new_size
	push si
	mov si, offset str
        add si, 1
       	mov [si], new_size
	pop si

endm

;------------------------------------------------------------------------------------------------------------------------------------------------------------------------

is_empty macro str	
	get_size str
	cmp dl, 0h

endm

;------------------------------------------------------------------------------------------------------------------------------------------------------------------------

to_uint macro str 
	local to_uint_loop, to_uint_error, to_uint_exit 
	lite_push 
	xor ax, ax
	xor bx, bx  
	xor dx, dx
 
	get_size str
	mov cx, dx
	cmp si, 1
	ja to_uint_error
	mov di,10  

to_uint_loop:
	get_char_by_index str, si 
	mov bl, dl
	cmp bl,'0'
	jb to_uint_error
	cmp bl,'9'
	ja to_uint_error
	sub bl, '0'
	mul di
	jc to_uint_error
	add ax, bx 
	jc to_uint_error
	inc si
	loop to_uint_loop
	jmp to_uint_exit

to_uint_error:
	stc
	mov ax, -1

to_uint_exit:
	lite_pop

endm

;------------------------------------------------------------------------------------------------------------------------------------------------------------------------

to_int macro
	local pre_signed, positive, to_int_succes, to_int_error, to_int_exit,      
	lite_push 
	mov si, 0

	is_empty str
	je to_int_error
	get_char_by_index str, 0
	cmp dl, '-'
	jne pre_signed
	inc si
	get_size str
	dec dl
	set_size str

pre_signed:
	to_uint str
	jc to_int_error
	
	get_char_by_index str, 0
	cmp dl, '-'
	jne positive 
	cmp ax,32768
	ja to_int_error
	neg ax
	jmp to_int_succes

positive:
	cmp ax,32767
	ja to_int_error

to_int_succes:
	clc
	jmp to_int_exit

to_int_error:
	mov ax, -1
	stc

to_int_exit:
	lite_pop

endm

;------------------------------------------------------------------------------------------------------------------------------------------------------------------------

decimalize_print macro
	lite_push
	local positive, oi2, oi3
        test ax, ax
        jns positive

        mov cx, ax
        mov ah, 02h
        mov dl, '-'
        int 21h
        mov ax, cx
        neg ax

positive:
        xor cx, cx
        mov bx, 10
     
oi2:
        xor dx,dx
        div bx
        push dx
        inc cx
        test ax, ax
        jnz oi2

        mov ah, 02h
oi3:
        pop dx
        add dl, '0'
        int 21h
        loop oi3
	lite_pop

endm

;------------------------------------------------------------------------------------------------------------------------------------------------------------------------

copy_cmd macro str

local copy_loop, bad_end, exit
lite_push  
  
    xor bx, bx
    mov bl, es:[80h]
    test bl, bl
    jz bad_end
    dec bl
    set_size str, bl
    
    mov cx, bx
    mov si, 82h
    mov di, 2 
        
copy_loop:
    mov dl,es:[si]
    mov str[di],dl
    inc di
    inc si
    loop copy_loop
    jmp exit

bad_end:
    stc

exit:
lite_pop 

endm
