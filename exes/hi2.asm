.data 
    hi db "Hi2!$"

.stack
    dw 128 dup(0)

.code
start:
    mov ax, data
    mov ds, ax

    mov ah, 09h
	mov dx, offset hi
	int 21h

end start