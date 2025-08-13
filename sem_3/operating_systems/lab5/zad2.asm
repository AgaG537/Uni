%include        'functions.asm'
 
SECTION .data
msg1        db      'Suma elementow: ', 0h
msg2        db      'Suma przekatnej: ', 0h
matrix      db      15, 3, 24, 35, 13, 8, 31, 28, 11
matrix_len  equ     9
 
SECTION .text
global  _start


_start:
    mov ecx, matrix_len
    mov eax, 0
    mov edx, 0
    lea esi, [matrix]

    call .sumElements
    mov eax, msg1
    call sprint
    mov eax, edx
    call iprintLF

    mov ecx, matrix_len
    mov eax, 0
    mov edx, 0
    lea esi, [matrix]

    call .sumDiagonal
    mov eax, msg2
    call sprint
    mov eax, edx
    call iprintLF

    call quit


.sumElements:
    mov al, [esi]
    add edx, eax
    inc esi
    dec ecx 
    jnz .sumElements
    ret

.sumDiagonal:
    mov al, [esi]
    add edx, eax
    mov al, [esi + 4]
    add edx, eax
    mov al, [esi + 8]
    add edx, eax
    ret