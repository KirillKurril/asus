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
           
        space_check str2
        cmp al, -1
        je exp                         
                   
        remove_word str1, str2
                                  
        print_new_line   
        
        print_string_as_chars str1  
exp:

end start
