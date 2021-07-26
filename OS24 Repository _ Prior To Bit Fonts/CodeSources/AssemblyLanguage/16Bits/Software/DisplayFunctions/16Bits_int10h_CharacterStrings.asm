; DisplayCharacters:

; Purpose: Displays characters character by character.
; It moves the data array address into si (source index)
; si is a special purpose register.
; Its offset is relative to the data segment
; You can use di for this, but you'd want to set the es.
; es is the extra segment. In my case, I chose to only set
; the ds (data segment)

DisplayCharacters:
    pusha
    xor ax, ax
.characterloop:
    mov ah, 0x0E
    mov al, [si]
    cmp al, 0
    je .exitDisplayCharacters
    int 0x10
    inc si
    jmp .characterloop
.exitDisplayCharacters:
    popa
    ret