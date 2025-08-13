%include        'functions.asm'

section .data
msg     db      10,"Liczba liczb pierwszych do 100.000: "

section .text
global _start

_start:
    ; EBX - sprawdzana liczba
    ; ECX - licznik liczb pierwszych
    ; EBP - sprawdzany dzielnik
    mov ebx, 2
    mov ecx, 1
    mov eax, ebx
    call iprintLF

.loop:
    cmp ebx, 100000
    jae .finish
    mov ebp, 2
    inc ebx

.check:
    mov eax, ebx
    mov edx, 0
    div ebp
    cmp edx, 0
    je .loop
    inc ebp
    cmp ebp, ebx
    jb .check

.show:
    push eax
    mov eax, ebx
    call iprintLF
    pop eax
    inc ecx
    jmp .loop

.finish:
    mov eax, msg
    call sprint
    mov eax, ecx
    call iprintLF
    call quit