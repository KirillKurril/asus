include dmitruk_1.2.4.inc

.data
 str db 0fdh, 254 dup('$') 
 buffer db 0h     
 cmp_id dw 0h 
 file_handle dw ?
 seek_offset dw 0h
 cur_pos dw 0h, 0h
 dscount dw 0h
 detected db 0h 
 say_hello db "Enter the string to find$" 
 fname db "C:\file.txt", 0h   
    
.stack
    dw 128 dup(0)
    
.code 
;************************************************************************ 

return_position proc
  lite_push
  mov ax, 0
  mov bx, file_handle
  mov cx, cur_pos[0]
  mov dx, cur_pos[2]
  mov ah, 42h
  int 21h    
  lite_pop  
ret
return_position endp

;************************************************************************ 
    
save_position proc 
  lite_push
  mov ax, 1
  mov bx, file_handle
  mov cx, 0
  mov dx, 0
  mov ah, 42h
  int 21h             

  mov cur_pos[0], dx          
  mov cur_pos[2], ax  
  lite_pop 
ret
save_position endp    
;************************************************************************
detection proc 
  lite_push  
  xor dx, dx        
    
  get_char_by_index str, cmp_id
  cmp dl, buffer
  jne po_novoy
  inc cmp_id
  get_size str
  cmp dx, cmp_id 
  je is_word 
  jmp end_detection
    
    
is_word:
  call is_word_check
  jc po_novoy   
      
po_novoy:
  mov cmp_id, 0
  jmp end_detection      
      
end_detection:                     
  lite_pop  
     
ret
detection endp 
;************************************************************************
is_word_check proc
  call save_position
  lite_push
  mov dx, cmp_id 
  mov seek_offset, dx
  inc seek_offset
  neg seek_offset
    
  mov ah, 42h
  mov bx, file_handle 
  mov cx, seek_offset
  mov ax, 1    
  jc end_check
  
end_check:
  call return_position
  mov ah, 3Fh            
  mov bx, file_handle 
  mov cx, 1
  lea dx, buffer
  int 21h 
  jc is_word_check_end
  cmp buffer, 20h
  je good_end 
    
good_end:
   cmp detected, 1
   je detected_yet
   mov detected, 1
   inc dscount 
   
detected_yet:
   stc 
   jmp is_word_check_end     
         
begin_error: 
  call return_position
  stc
  jmp is_word_check_end

is_word_check_end:
  lite_pop
  
ret
is_word_check endp
;************************************************************************
    start:    
    
    data_init                           
    print_string say_hello
    print_new_line
    get_string str
    print_new_line
    
    ; Открытие файла для чтения
    mov ah, 3Dh                ; Системный вызов open
    lea dx, fname           ; Адрес имени файла
    mov al, 0                  ; Флаги (O_RDONLY)
    int 21h                    ; Вызов системного вызова

    ; Проверка на успешное открытие файла
    jc error                   ; Если ошибка, перейти к обработке ошибки
    mov file_handle, ax        ; Сохранить дескриптор файла

read_loop:
    ; Чтение одного байта из файла
    mov ah, 3Fh                ; Системный вызов read
    mov bx, file_handle        ; Дескриптор файла
    mov cx, 1        ; Количество байт для чтения
    lea dx, buffer             ; Адрес буфера для чтения
    int 21h 
      
    call detection
                       ; Вызов системного вызова
    jc end_of_file
    jmp read_loop
                               ; Проверка на успешное чтение
                 ; Если достигнут конец файла, перейти к завершению чтения

    ; Обработка прочитанного байта
    ; ...

                  ; Повторить чтение для следующего байта

end_of_file:
    ; Закрытие файла
    mov ah, 3Eh                ; Системный вызов close
    mov bx, file_handle        ; Дескриптор файла
    int 21h                    ; Вызов системного вызова

    ; Завершение программы
    mov ah, 4Ch                ; Системный вызов exit
    mov al, 0                  ; Код выхода
    int 21h                    ; Вызов системного вызова

error:
    ; Обработка ошибки открытия файла
    ; ...

    ; Завершение программы с ошибкой
    mov ah, 4Ch                ; Системный вызов exit
    mov al, 1                  ; Код выхода (с ошибкой)
    int 21h 
    
    
                   ; Вызов системного вызова
end start