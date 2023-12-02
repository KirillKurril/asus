.model small

.data
    dir_path db 255, 254 dup('$')
    errstr db "ERROR!$" 

.stack
    dw 128 dup(0)
    
.code
start:

    mov ax, @data
    mov ds, ax

    xor bx, bx
    mov bl, es:[80h]
    test bl, bl
    jz error
    dec bl
    
    
    push si
    mov si, offset dir_path
        add si, 1
        mov [si], bl
    pop si
    
    mov cx, bx
    mov si, 82h
    mov di, 2 
        
copy_loop:
    mov dl,es:[si]
    mov dir_path[di],dl
    inc di
    inc si
    loop copy_loop
    jmp exit

error:
    mov ah, 09h
    mov dx, offset errstr
    int 21h
    
exit:

end start
