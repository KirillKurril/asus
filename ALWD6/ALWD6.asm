include dfiles_1.0.inc

.data
 substr db 0fdh, 254 dup('$') 
 char_buffer db 0h     
 cmp_id dw 0h 
 file_handler dw ?
 position_buffer dd 0h
 counter dw 0h 
 errstr db "ERROR!$" 
 fname db "C:\file1.txt", 0h 
 answer db "The number of matching rows is:$"
 cur_offset dw 0h  
    
.stack
    dw 128 dup(0)
    
.code 
    start:       
    data_init                           
    copy_cmd substr
    jc error 
    space_check substr
    jc error
    
    open_read fname, file_handler
    jc error
    
count_loop:
    clc 
    fstr_contains fname, substr, file_handler, counter, char_buffer, position_buffer    
    jc error 
    cmp ah, 0FFh
    jne count_loop
    
    close file_handler 
    
    mov ax, counter
    print_string answer
    print_new_line 
    decimalize_print
    jmp exit
    
error:
    print_string errstr
 
exit:  
                       
end start