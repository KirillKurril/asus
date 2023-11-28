include dfiles_1.0.inc

.data
 substr db 0fdh, 254 dup('$') 
 char_buffer db 0h     
 cmp_id dw 0h 
 file_handler dw ?
 position_buffer dd 0h
 counter dw 0h 
 say_hello db "Enter the string to find$"
 errstr db "ERROR!$" 
 fname db "C:\file1.txt", 0h 
 answer db "The number of matching rows is:$"
 cur_offset dw 0h  
    
.stack
    dw 128 dup(0)
    
.code 
    start:       
    data_init                           
    print_string say_hello
    print_new_line
    get_string substr 
    space_check substr
    jc error
    print_new_line
    
    open_read fname, file_handler
    jc error
    
count_loop:
    print_new_line
    clc
    ;find
      lite_push  
xor cx, cx

read_loop:
    read_byte file_handler, char_buffer
    
    push ax
    mov al, char_buffer
    print_char al 
    pop ax
    
    jc exit_find
    cmp ax, 0h
    je end_of_file
    cmp char_buffer, 0Ah
    je exit_find
    
    xor dx, dx        
    
    get_char_by_index str, cx
    cmp dl, char_buffer
    jne start_over
    inc cx
    get_size substr
    cmp dx, cx 
    je word_check 
    jmp read_loop
    
    
word_check:
    ;word
    lite_push
save_position file_handler, position_buffer 
  
    get_size substr    
    inc dx
    neg dx
    mov cur_offset, dx
    ;move
    lite_push
    mov al, 0
    mov ah, 42h
    mov bx, file_handler 
    mov cx, word ptr [position_buffer]
    mov dx, word ptr [position_buffer + 2]
    add dx, cur_offset
    int 21h
    lite_pop  
    ;move
    jc end_check
    read_byte file_handler, char_buffer
    cmp char_buffer, 20h
    je end_check
    cmp char_buffer, 0Ah
    je end_check
    ;set_pos
    lite_push
    mov ax, 0
    mov bx, file_handler
    mov cx, word ptr [position_buffer]
    mov dx, word ptr [position_buffer + 2]
    mov ah, 42h
    int 21h    
    lite_pop   
    ;
    jmp bad_end
    
end_check:
    clc
    ;set_pos
    lite_push
    mov ax, 0
    mov bx, file_handler
    mov cx, word ptr [position_buffer]
    mov dx, word ptr [position_buffer + 2]
    mov ah, 42h
    int 21h    
    lite_pop   
    ;
    read_byte file_handler, char_buffer
    cmp ax, 0h
    je exit_word
    cmp char_buffer, 0Dh
    je exit_word
    cmp char_buffer, 20h
    je exit_word
    jmp bad_end

bad_end:
    stc
    
exit_word:     
lite_pop  
    ;word
    jc start_over
    inc counter
    ;skip
skip_read_loop:
    read_byte file_handler, char_buffer
    cmp ax, 0h
    je end_of_file_skip
    cmp char_buffer, 0Ah
    je exit_skip
    jmp skip_read_loop 
    
end_of_file_skip:
    stc
    
exit_skip:  
    ;skip
    jc end_of_file
    jmp exit_find   
      
start_over:
    xor cx, cx
    jmp read_loop      
          
    
end_of_file:
    clc
    mov ah, 0FFh
    
exit_find:
lite_pop
    ;find
    jc error 
    cmp ah, 0FFh
    jne count_loop
    
    close file_handler 
    
    mov ax, counter
    print_new_line
    print_string answer
    print_new_line 
    decimalize_print
    jmp eexit
    
error:
    print_string errstr
    jmp start
    




  
eexit:  
                       
end start