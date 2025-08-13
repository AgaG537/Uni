%include    'functions.asm'

SECTION .text
global _start

_start:
    mov eax, 84015
    mov ebx, 16
    mov ecx, 0

.divisionLoop:
    mov edx, 0
    div ebx
    add edx, 48
    cmp edx, 57
    jg .setLetter

.saveCharacter:
    inc ecx
    push edx
    cmp eax, 0
    jz .show
    jmp .divisionLoop

.setLetter:
    add edx, 7
    jmp .saveCharacter

.show:
    dec ecx
    mov eax, esp
    call sprint
    pop eax

    cmp ecx, 1
    jg .show

.finish:
    mov eax, esp
    call sprintLF
    pop eax

    call quit
    