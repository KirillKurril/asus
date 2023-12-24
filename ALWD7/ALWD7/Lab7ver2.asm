.model small


.stack 100h

.data
    disk db "d:",5Ch
    path db 20 dup(0)
    program_name db 20 dup(0)
    DTA_space db 2Ch dup(0)
    suffix db "*.EXE"
    file_name db 20 dup(0)
    data_seg dw ?
    
    command_line db 8 dup(0)
    epb      dw 0
    cmd_off  dw ?
    cmd_seg  dw ?
    fcb1     dd ?
    fcb2     dd ?
    
    no_directory db "No such directory!", 0Dh,0Ah,'$'
    no_files db "No files in directory!", 0Dh,0Ah,'$'
    unexp db "Unexcpected error!", 0Dh,0Ah,'$'
.code

puts macro string
    push ax
    push dx
    lea dx, string
    mov ah, 9
    int 21h
    pop dx
    pop ax    
endm

main:
    mov data_seg, ds
    
;clearing memory for program
    lea bx, last
    mov cl, 4
    shr bx, cl
    add bx, 17
    mov ah, 4Ah
    int 21h
    jc cset1
    jmp after_cset1
cset1:    
    jmp unexp_error
after_cset1:    
    mov ax, bx  ;setting new stack pointer
    shl ax, cl
    dec ax
    mov sp, ax
    lea bx, command_line
    mov cmd_off, bx
    mov ds, data_seg
    mov cmd_seg, ds
    
    mov ax,@data
    mov ds,ax
    mov bx, 0
    mov [bx], ":d"
    inc bx
    inc bx
    mov [bx], "\"
    
;transfering command line to variable <<path>>
    mov bx, 80h
    cmp es:[bx], 2001h
    cmp es:[bx], 0D00h
    je zset1
    jmp after_zset1
zset1:
    jmp no_directory_error
after_zset1:
    mov bx, 81h
    lea dx, path
    dec dx
transfer2:
    inc bx
    inc dx
    mov al, es:[bx]
    cmp al, 0Dh
    je transfer_end2
    push bx
    mov bx, dx
    mov [bx], al
    pop bx
    jmp transfer2
transfer_end2:
   
;setting path as default
    mov ah, 3Bh
    lea dx, disk
    int 21h
    jc no_directory_error    
       
;moving DTA
    mov ah, 1Ah
    lea dx, DTA_space
    int 21h
    jc unexp_error
    
;finding first file
    mov ah, 4Eh
    lea dx, suffix
    xor cx, cx
    int 21h
    jc no_files_error   
    
;executing program
    mov ax, ds
    mov es, ax
    lea bx, epb
    mov dx, offset DTA_space + 1Eh
    mov ax, 4B00h
    int 21h
    jc unexp_error

;repeating process    
procedures_dont_work:
;setting path as default
    mov ah, 3Bh
    lea dx, disk
    int 21h
    jc unexp_error    
       
;moving DTA
    mov ah, 1Ah
    lea dx, DTA_space
    int 21h
    jc unexp_error    
    
;searching next file
    lea dx, suffix
    mov ah, 4Fh
    xor cx, cx
    int 21h
    jc end_
    
;executing program
    mov ax, ds
    mov es, ax
    lea bx, epb
    mov dx, offset DTA_space + 1Eh
    mov ax, 4B00h
    int 21h
    jc unexp_error    
    
    jmp procedures_dont_work
unexp_error:
    puts unexp
    jmp end_
    
no_files_error:
    puts no_files
    jmp end_

no_directory_error:
    puts no_directory
    jmp end_
    
end_:    
    mov ax,4c00h
    int 21h

last: db ?    
end main