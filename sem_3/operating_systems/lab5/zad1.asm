%include        'functions.asm'
 
SECTION .data
msg1        db      'Wprowadz liczbe: ', 0h
msg2        db      'Suma cyfr: ', 0h
 
SECTION .bss
input:     resb    255
 
SECTION .text
global  _start
 
 
_start:

    mov     eax, msg1
    call    sprint
 
    mov     edx, 255
    mov     ecx, input
    mov     ebx, 0
    mov     eax, 3
    int     80h
 
    mov     eax, msg2
    call    sprint
 
    mov     eax, input
    call    .sumDigits

    call    iprintLF
    call    quit



.sumDigits:
    push    ebx
    push    ecx
    push    edx
    push    esi
    mov     esi, eax
    mov     eax, 0
    mov     ecx, 0
 
.additionLoop:
    xor     ebx, ebx
    mov     bl, [esi+ecx]
    cmp     bl, 48
    jl      .restore
    cmp     bl, 57
    jg      .restore
 
    sub     bl, 48
    add     eax, ebx
    inc     ecx
    jmp     .additionLoop
 
.restore:
    pop     esi
    pop     edx
    pop     ecx
    pop     ebx
    ret
