include dmitruk_1.2.1.inc

.data 
    str db 255 dup('$')  
    array dw 30 dup(0)
    error db "Error! Incorrect input data!$"
    say_hallo db "Please enter the number of values to enter$"  
    say_goodbye db "The most common element is$" 
    iteration db "Enter the value$"
    mostFrequentElement dw 0
    maxFrequency dw 0
    frequency dw 0     
    
.stack
    dw 128 dup(0)
    
.code 
    start:   
    
    data_init                                   
    
    print_string say_hallo 
    print_new_line 
    get_string str 
    print_new_line 
    to_int str
    cmp ax, 1
    jb read_error 
    cmp ax, 30
    ja read_error
    mov cx, ax 
    mov dx, cx   
    set_size array
    mov si, offset array + 2
    
    
readloop:   
    print_string iteration   
    print_new_line 
    get_string str
    print_new_line 
    call str_to_int
    jc read_error
    mov [si], ax
    add si, 2
    loop readloop
    jmp find 
    
read_error:
    print_string error
    print_new_line  
    print_new_line 
    xor cx, cx 
    jmp start 	
    

find_the_most_frequent proc
    mov si, offset array + 2
    xor dx, dx
    get_size array
    mov al, dl
    mov cl, 2
    mul cl 
    add ax, 02h
    mov cx, ax    ; размер массива
    mov si, 02h    ; i
    mov di, 02h    ; j
    xor ax, ax    ; mostFrequentElement

    mov bx, array[si]
    mov mostFrequentElement, bx

big_loop:
    mov frequency, 0
    
    mov di, 02h
small_loop:
    mov bx, array[di]  ; теперь di это arr[j]
    cmp bx, array[si]
    jne small_loop_end
    inc frequency

small_loop_end:
    add di, 2
    cmp di, cx
    jb small_loop

    mov bx, frequency
    cmp bx, maxFrequency
    jng big_loop_end
    mov maxFrequency, bx
    mov ax, array[si]
    mov mostFrequentElement, ax

big_loop_end:
    add si, 2
    cmp si, cx
    jb big_loop
 
    mov ax, mostFrequentElement
    ret
find_the_most_frequent endp
               
               
               
               
               
               
str_to_int proc  
    lite_push 
	mov si, 0

	is_empty str
	je to_int_error_
	get_char_by_index str, 0
	cmp dl, '-'
	jne pre_signed_
	inc si
	get_size str
	dec dl
	set_size str

pre_signed_:
	call str_to_uint
	jc to_int_error_
	
	get_char_by_index str, 0
	cmp dl, '-'
	jne positive_ 
	cmp ax,32768
	ja to_int_error_
	neg ax
	jmp to_int_succes_

positive_:
	cmp ax,32767
	ja to_int_error_

to_int_succes_:
	clc
	jmp to_int_exit_

to_int_error_:
	mov ax, -1
	stc

to_int_exit_:  
	lite_pop
               

ret   
str_to_int endp   


str_to_uint proc
    lite_push 
	xor ax, ax
	xor bx, bx  
	xor dx, dx
 
	get_size str
	mov cx, dx
	cmp si, 1
	ja to_uint_error_
	mov di,10  

to_uint_loop_:
	get_char_by_index str, si 
	mov bl, dl
	cmp bl,'0'
	jb to_uint_error_
	cmp bl,'9'
	ja to_uint_error_
	sub bl, '0'
	mul di
	jc to_uint_error_
	add ax, bx 
	jc to_uint_error_
	inc si
	loop to_uint_loop_
	jmp to_uint_exit_

to_uint_error_:
	stc
	mov ax, -1

to_uint_exit_:
	lite_pop
    
ret           
str_to_uint endp 
 
find:
    call find_the_most_frequent 
    print_string say_goodbye
    print_new_line
    decimalize_print 

end start