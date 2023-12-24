; Hello, World!
; Simple Hello World program in Assembly

; Author: Lakhya Jyoti Nath aka ljnath
; Email: ljnath@ljnath.com
; https://www.ljnath.com
; Dated: 04th February 2013

DATA_SEG    SEGMENT
   MESSAGE  DB  'PROGRAM 1',0Dh,0Ah,'$'
DATA_SEG    ENDS

CODE_SEG    SEGMENT
   ASSUME CS: CODE_SEG, DS:DATA_SEG

    START:
        MOV   AX, DATA_SEG
        MOV   DS, AX

        MOV    AH,9
        MOV    DX,OFFSET MESSAGE
        INT    21H

        MOV    AH,4CH
        MOV    AL,0
        INT    21H
CODE_SEG    ENDS
   END  START
