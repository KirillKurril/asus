.8086
.model tiny

.code
org 100h

print macro out_str ; макро вывода строки  
    mov ah,9
    mov dx,offset out_str
    int 21h
endm

println macro ; макро вывода символа новой линии
    print new_line
endm
 
start:
    
    ; считываем 2 числа, заносим в стек                       
    print enter_first_number
    call InputInt
    push ax
    print enter_second_number
    call InputInt
    push ax 
    
    
    ; выводим xor
    print xor_str
    pop ax
    pop bx
    push bx
    push ax
    xor ax, bx
    call OutInt
    println
    
    ; выводим and
    print and_str
    pop ax
    pop bx
    push ax
    push bx
    and ax, bx
    call OutInt
    println
    
    ; выводим or
    print or_str
    pop ax
    pop bx
    or ax, bx
    call OutInt
    println 
          
    ret

InputInt proc 
 
    mov ah,0ah
    xor di,di
    mov dx,offset buff ; аддрес буфера
    int 21h ; принимаем строку
    println
    
; обрабатываем содержимое буфера
    mov si,offset buff+2 ; берем аддрес начала строки
    
    ; длина строки > 0
    mov cl, buff+1
    cmp cl, 0
    je er
    xor ax,ax
    mov bx,10  ; основание сc
lp:
    xor cx, cx  ; очищаем регистр cx
    mov cl,[si] ; берем символ из буфера
    cmp cl,0dh  ; проверяем не последний ли он
    jz endin
    
; если символ не последний, то проверяем его на правильность
    cmp cl,'0'  ; если введен неверный символ <0
    jl er
    cmp cl,'9'  ; если введен неверный символ >9
    ja er
 
    sub cl,'0' ; делаем из символа число 
    mul bx     ; умножаем на 10
    add ax,cx  ; прибавляем к остальным
    inc si     ; указатель на следующий символ
    jmp lp     ; повторяем
 
er:   ; если была ошибка, то выводим сообщение об этом и выходим
    mov dx, offset error
    mov ah,09
    int 21h
    int 20h
 
; все символы из буфера обработаны число находится в ax
endin:
    ret
InputInt endp

OutInt proc
    xor     cx, cx
    mov     bx, 10 ; основание сс. 10 для десятеричной и т.п.
oi2:
    xor     dx,dx
    div     bx
; Делим число на основание сс. В остатке получается последняя цифра.
; Сразу выводить её нельзя, поэтому сохраним её в стэке.
    push    dx
    inc     cx
; А с частным повторяем то же самое, отделяя от него очередную
; цифру справа, пока не останется ноль, что значит, что дальше
; слева только нули.
    test    ax, ax
    jnz     oi2
; Теперь приступим к выводу.
    mov     ah, 02h
oi3:
    pop     dx
; Извлекаем очередную цифру, переводим её в символ и выводим.
    add     dl, '0'
    int     21h
; Повторим ровно столько раз, сколько цифр насчитали.
    loop    oi3  
    ret
OutInt endp

buff                   db      5,6 Dup(?)
error                  db      "Incorrect input$"
enter_first_number:    db      "Enter first number:", 0Dh,0Ah, '$'
enter_second_number:   db      "Enter second number:", 0Dh,0Ah, '$'
xor_str:               db      "Xor: $" 
or_str:                db      "Or:  $"
and_str:               db      "And: $"
new_line:              db      0Dh, 0Ah, '$'
end start