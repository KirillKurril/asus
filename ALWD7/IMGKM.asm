include dfiles_1.2.inc

.data
    dir_path db 255, 254 dup('$')
    exeExt db '*.exe', 0
    searchHandle dw 0
    searchResult db 256 dup(0)
    commandLine db 256 dup(0)
    execPath db 256 dup(0)
    execResult db 256 dup(0)
    errstr db "ERROR!$"

.stack
    
    
.code
    start:
    data_init
    copy_cmd dir_path
    jc error 
    print_string_as_chars  dir_path
    jmp exit 
    
error:
    print_string errstr  

exit:
        mov ah, 4Ch
        int 21h
    
end start