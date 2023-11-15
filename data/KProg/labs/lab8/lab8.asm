.model small
.stack 100h
.data
     arg_string db 127 + 2 dup(0)
     fname db 'Your filename is: ', '$'
     nonEmpty db 'Non empty lines in your file: ', '$'
     strError db 'Error', '$'
     buffer db 22 dup(0)
     kol dw 0
     strKol db 5 dup (?), '$' 
     StrEnd	= $-1      
     smb db 0Ah
     new_line db 0Dh, 0Ah, '$'
.code 

    print macro out_str
        mov ah,9
        mov dx,offset out_str
        int 21h
    endm
    
    println macro
        print new_line
    endm
   
    OpenFileRead PROC    
        mov ah, 3dh             ; INT for open file
        mov al, 0               ; only read
        int 21h
        ret
    OpenFileRead ENDP 

    CloseFile PROC
        mov ah, 3eh             ; INT for close file
        int 21h
        ret
    CloseFile ENDP


    SearchStrings PROC
        push ax                 ; save registers in stack                
        push cx                 ; proc for lobufferad string from file to 
        push dx
        push si
        
        mov ax, kol             ; load to AL number of string  
        mov dl, smb
        
    Search:
        cmp buffer[si], 0Dh     ; check simbol in buffer
        jne notFound
        cmp dl, 0Ah             ; check empty string
        je notFound 
        inc ax                  ; increment number of not empty strings
        
    notFound:
        mov dl, buffer[si]      ; save in DL position in buffer
        inc si                  ; increment index in buffer
        
        loop Search
        
        mov kol, ax             ; save in KOL number of not empty string  
        mov smb, dl             ; save last symbol in SMB
        
        pop si                  ; return registers
        pop dx
        pop cx
        pop ax
        ret
    SearchStrings ENDP 
    
    WriteString PROC
        xor ax, ax             ; set AX in 0
		std                    ; reverse read
		lea	di, StrEnd-1 ;     ; set DI in the end of string

		mov	ax, kol            

		mov	cx, 10             ; divide 10
    Repeat:
		xor	dx, dx             ; set DS in 0
		div	cx                 ; div AX on CX
                   
		xchg ax,dx             ; exchange AX and AX
		add	al, '0'            ; add AL position of symbol '0'
		stosb                  ; save in string
		xchg ax,dx             ; exchange AX and DX
		or	ax,ax              ; check ax with 0
		jne	Repeat  
		                               
		ret
	WriteString ENDP	
        
    start:
        
        mov ax, @data           ; load data segment
        mov es, ax
        xor cx, cx
        mov cl, [80h]
        mov si, 82h
        lea di, arg_string
        rep movsb
        mov ds, ax
        mov [di-1], '$'
        print fname
        print arg_string
        mov [di-1], 0
        println
        lea dx, arg_string 
        
        xor si, si
        xor di, di
        call OpenFileRead       
     
        jc Error                ; check file error
        
        mov bx, ax                                           
        
    Read:                       ; read part of file in buffer
        mov ah, 3fh
        mov cx, 20              ; size 20
        lea dx, buffer          ; in BUFFER
        int 21h
        
        jc Error
        
        cmp cx, ax
        jg Last                 ; if it's last part of file
        
        call SearchStrings
        
        loop Read
        
    Last: 
        cmp ax, 0              ; no simbols in last string
        je Then
        mov cx, ax             ; save number of simbols in last string
        lea di, buffer
        add di, cx
        push ax
        mov al, 0Dh            ; add 0Dh in the end of string 
        stosb
        mov al, 0Ah            ; add 0Ah in the end of string
        stosb
        add cx, 2              ; add 2 to counter
        pop ax
         
        call SearchStrings 
        
    Then:    
        cmp smb, 0Ah           ; last string is empty or no string (default)
        je noAdd
        add kol, 1
    noAdd:    
            
        call CloseFile
        
        call WriteString
        
		lea	dx,[di+1]          ; load in DX strKol
		jmp Write
    Error:
        lea dx, strError        
        mov ah, 09h
        int 21h
        jmp Exit 
    Write:
        push dx
        print nonEmpty
        pop dx
        mov ah, 09h
        int 21h
 
    Exit:        
        mov ax, 4c00h
        int 21h          
        
        end start