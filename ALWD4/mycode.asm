include dmitruk1.1.inc

.data 
    str1 db 0fdh, 254 dup('$')
    str2 db 0fdh, 254 dup('$')   
    
.stack
    dw 128 dup(0)
    
.code
    start:     
	    
        data_init
                 
        get_string str1 
        
        print_new_line  
         
        get_string str2 
         
        print_new_line   
        
      find_substr str1, str2
      cmp al, 0ffh   
      je gerauahier
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
	inc dl				;!!!
	mov bl, dl
	get_size str1	
	cmp dl, bl
	je before_space

both_spaces_1:
  dec al
  xor ah, ah
  get_char_by_inedx str1, ax
  cmp dl, 20h
  je both_spaces_2
  jmp gerauahier

both_spaces_2:
  inc al
  xor dx, dx
  get_size str2
  mov bx, dx
  inc bx
  xor ah, ah
  add bx, ax
  xor dx, dx
  get_char_by_inedx str1, bx
  cmp dl, 20h
  je increase_substring_size
  jmp gerauahier
  

before_space:
  dec al
  xor ah, ah
  get_char_by_inedx str1, ax
  cmp dl, 20h
  je beforespace_exists
  jmp gerauahier
  
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
  get_char_by_inedx str1, bx
  cmp dl, 20h
  je increase_substring_size
  jmp gerauahier
  
increase_substring_size:
  pop_registers 
  inc ah
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
        
        print_string_as_chars str1

end start
