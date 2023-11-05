include dmitruk.inc

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
        
        remove str1, str2
        
        print_string_as_chars str1

end start
