; Purpose: To allow the computer to boot into a protected 32 bit mode.

GlobalDescriptorTableStart:

NullDescriptor: ; DD means define double word (4 bytes).
    dd 0x0      ; Two double words are defined.
    dd 0x0      ; This causes exceptions to be thrown by the CPU
                ; If a jump is made to the start of the table
                ; without setting segment registers.

CodeSegment:
    dw 0xFFFF
    dw 0x0
    db 0x0
    db 10011010b
    db 11001111b
    db 0x0

DataSegment:
    dw 0xFFFF
    dw 0x0
    db 0x0
    db 10010010b
    db 11001111b
    db 0x0

GlobalDescriptorTableEnd:

GlobalDescriptorTable:
    dw GlobalDescriptorTableEnd - GlobalDescriptorTableStart - 1
    dd GlobalDescriptorTableStart

Code_Segment equ CodeSegment - GlobalDescriptorTableStart
Data_Segment equ DataSegment - GlobalDescriptorTableStart