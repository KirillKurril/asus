str_to_int macro str
	push_registers 
        xor     ax,ax
	xor si, si           

str_to_dec:
        get_char_by_index str, si
        sub     bl,'0'
        ; Для системы счисления с другим основанием замените следующую
        ; строчку на cmp bl,основание_системы
        cmp     bl,10
        jnb     .str2dec_ret
        ; Для системы счисления с другим основанием замените следующую
        ; строчку на imul eax,основание_системы
        imul    ax,10
        add     ax,bx
        inc     si
        jmp     .str2dec_loop
 
str2dec_ret:
        pop     si dx bx
        ret



endm
