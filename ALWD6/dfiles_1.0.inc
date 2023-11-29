include dmitruk_1.2.6.inc
; !!!!!!!!!!DON'T INCLUDE dmitruk_1.2.5 IF YOU USE THIS INC!!!!!!!!!!!!

; *****************************
; char_buffer must be db
; position_buffer must be dw array for 2 items
; file_handler must be dw
; str_size must be dw    
; *****************************

; open_read (file_name)      CF clear if successful, AX = file handle 
  
; open_write (file_name)     CF set on error AX = error code

; open_rw (file_name)

; close (file_handler)

; read_byte(file_handler, char_buffer)   CF is clear if successful
;                                        AX = number of bytes actually read;
;                                        AX = 0 if current position in file is EOF
;                                        CF is set on error AX = error code       

; find_substr_in_f_str (file_name, substr, file_handler, counter, char_buffer, position_buffer)

; save_position (file_handler, position_buffer)    

; set_buffer_position (file_handler, position_buffer)   file_handler must be dw, file_handler must be dw array for 2 items

; move_position macro (new_pos_offset, file_handler)	new_pos_offset musn't be ax, bx, dx or cx   

; word_check_f (str_size, file_handler, position_buffer, char_buffer)   

; skip_string (file_handler, char_buffer)   returns 0FFh in AX if the last string in file 


;--------------------------------------------------------------------------------------------------------      

save_position macro file_handler, position_buffer
lite_push
    mov ax, 1
    mov bx, file_handler
    mov cx, 0
    mov dx, 0
    mov ah, 42h
    int 21h             

    mov word ptr [position_buffer], dx          
    mov word ptr [position_buffer + 2], ax  
lite_pop          
    
endm 

;--------------------------------------------------------------------------------------------------------

set_pos_from_buff macro file_handler, position_buffer
lite_push
    mov ax, 0
    mov bx, file_handler
    mov cx, word ptr [position_buffer]
    mov dx, word ptr [position_buffer + 2]
    mov ah, 42h
    int 21h    
lite_pop     
    
endm

;--------------------------------------------------------------------------------------------------------

open_read macro file_name, file_handler
lite_push
    mov ah, 3Dh
    lea dx, file_name 
    mov al, 0 
    int 21h
    mov file_handler, ax
lite_pop 
        
endm
   
;--------------------------------------------------------------------------------------------------------

open_write macro file_name, file_handler
lite_push    
    mov ah, 3Dh
    lea dx, file_name 
    mov al, 1 
    int 21h
    mov file_handler, ax
lite_pop 
        
endm

;--------------------------------------------------------------------------------------------------------

open_rw macro file_name, file_handler
lite_push         
    mov ah, 3Dh
    lea dx, file_name 
    mov al, 2 
    int 21h
    mov file_handler, ax
lite_pop 
    
endm

;--------------------------------------------------------------------------------------------------------

read_byte macro file_handler, char_buffer
lite_push
    mov ah, 3Fh
    mov bx, file_handler
    mov cx, 1               ;number of bytes to read 
    lea dx, char_buffer
    int 21h
lite_pop 
    
endm

;--------------------------------------------------------------------------------------------------------

fstr_contains macro file_name, substr, file_handler, counter, char_buffer, position_buffer 
    
local exit, read_loop, end_of_file, start_over, word_check
lite_push  
xor cx, cx

read_loop:
    read_byte file_handler, char_buffer
    jc exit
    cmp ax, 0h
    je end_of_file
    cmp char_buffer, 0Ah
    je exit
    
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
    word_check_f substr, file_handler, position_buffer, char_buffer   
    jc start_over
    inc counter
    skip_string file_handler, char_buffer
    jc end_of_file
    jmp exit   
      
start_over:
    xor cx, cx
    jmp read_loop      
          
    
end_of_file:
    clc
    mov ah, 0FFh
    
exit:
lite_pop

endm

;--------------------------------------------------------------------------------------------------------

skip_string macro file_handler, char_buffer

local read_loop, end_of_file, exit

read_loop:
    read_byte file_handler, char_buffer
    cmp ax, 0h
    je end_of_file
    cmp char_buffer, 0Ah
    je exit
    jmp read_loop 
    
end_of_file:
    stc
    
exit:
endm   

;-------------------------------------------------------------------------------------------------------- 
                                                                                                         
move_position macro new_pos_offset, file_handler               
lite_push

    mov ax, 1
    mov bx, file_handler
    mov cx, 0
    mov dx, 0
    mov ah, 42h
    int 21h

    mov cx, dx
    mov dx, ax 	

    mov al, 0
    mov ah, 42h 
    add dx, new_pos_offset
    int 21h
lite_pop    
endm                                                                                                         
                                                                                                         
;--------------------------------------------------------------------------------------------------------

word_check_f macro substr, file_handler, position_buffer, char_buffer  

local end_check, bad_end, exit
lite_push
save_position file_handler, position_buffer 
  
    get_size substr    
    inc dx
    neg dx
    mov di, dx
    move_position di, file_handler
    jc end_check
    read_byte file_handler, char_buffer
    cmp char_buffer, 20h
    je end_check
    cmp char_buffer, 0Ah
    je end_check
    set_pos_from_buff file_handler, position_buffer
    jmp bad_end 
    
end_check:
    clc
    set_pos_from_buff file_handler, position_buffer
    read_byte file_handler, char_buffer
    cmp ax, 0h
    je exit
    cmp char_buffer, 0Dh
    je exit
    cmp char_buffer, 20h
    je exit
    jmp bad_end

bad_end:
    stc
    
exit:     
lite_pop

endm

;--------------------------------------------------------------------------------------------------------

close macro file_handler 
lite_push
    
    mov ah, 3Eh
    mov bx, file_handler
    int 21h

lite_pop
    
endm