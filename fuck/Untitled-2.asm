data segment
    bufferSize equ 10
    currentSize dw 0
    buffer db bufferSize dup(?)
    ch db ?

    newBuffer db ?
    newBufferSize dw ?

    message db 10, 13, 'Enter a string: $'
    outputMessage db 10, 13, 'You entered: $'

    newline db 10, 13, '$'
ends

stack segment
    dw 128 dup(0)
ends

code segment
start:
    assume cs:code, ds:data

    mov ax, data
    mov ds, ax ; Устанавливаем сегмент данных

    ; Выделяем память для буфера
    mov ax, bufferSize
    mov bx, 1 ; Размер элемента (1 байт)
    mul bx ; Умножаем bufferSize на размер элемента
    add ax, 1 ; Увеличиваем на 1 для хранения символа '$'
    mov newBufferSize, ax ; Сохраняем новый размер буфера

    mov ah, 48h ; Выделяем память для буфера
    mov bx, newBufferSize
    int 21h
    mov newBuffer, ax ; Сохраняем адрес выделенной памяти

    mov bx, offset buffer
    mov ax, newBuffer
    mov es, ax ; Устанавливаем сегмент памяти для нового буфера
    cld ; Устанавливаем флаг направления вперед

    mov ah, 0Ah ; Считываем строку с консоли
    mov dx, offset message
    int 21h

read_loop:
    mov ah, 01h ; Читаем символ с консоли
    int 21h
    mov ch, al ; Сохраняем символ в переменной ch

    cmp ch, '$' ; Проверяем, если символ '$', завершаем цикл
    je end_read

    cmp word ptr [currentSize], bufferSize - 1 ; Проверяем, если достигнута максимальная длина буфера
    jne not_full

    ; Увеличиваем размер буфера в два раза
    mov ax, bufferSize
    shl ax, 1 ; Умножаем на 2
    mov newBufferSize, ax ; Сохраняем новый размер буфера

    mov ah, 48h ; Выделяем память для нового буфера
    mov bx, newBufferSize
    int 21h
    mov newBuffer, ax ; Сохраняем адрес выделенной памяти

    mov bx, offset buffer
    mov ax, newBuffer
    mov es, ax ; Устанавливаем сегмент памяти для нового буфера

not_full:
    mov di, word ptr [currentSize] ; Загружаем текущий размер буфера в di
    mov al, ch ; Загружаем символ в al
    stosb ; Сохраняем символ в буфер
    inc word ptr [currentSize] ; Увеличиваем размер буфера на 1

    jmp read_loop ; Переход к чтению следующего символа

end_read:
    mov ah, 3Fh ; Записываем символ новой строки в буфер
    mov bx, 1 ; Дескриптор файла - стандартный ввод
    mov cx, 1 ; Количество символов для записи
    mov dx, offset newline
    int 21h

    mov ah, 40h ; Выводим сообщение для вывода введенной строки
    mov bx, 1 ; Дескриптор файла - стандартный вывод
    mov cx, word ptr [currentSize] ; Количество символов для вывода
    mov dx, offset buffer ; Адрес буфера
    int 21h

    mov ah, 4Ch ; Завершаем программу
    mov al, 0
    int 21h

ends

end start ; Устанавливаем точку входа и останавливаем ассемблер