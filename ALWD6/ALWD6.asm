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
 fname db "C:\file.txt", 0h   
    
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
    
count_loop:
    find_substr_in_f_str fname, substr, file_handler, counter, char_buffer, position_buffer
    jc error 
    cmp ah, 0FFh
    jne count_loop
    
    close file_handler 
    
    mov ax, counter
    decimalize_print
    jmp exit
    
error:
    print_string errstr
    jmp start
        
exit:  
                       
end start