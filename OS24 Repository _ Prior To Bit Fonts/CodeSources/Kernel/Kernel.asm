; ASM Kernel:
[BITS 16]
                ; [ORG 1000h] ; You have to use the ORG directive here,
                ; because the program counter is already set to reference
                ; the Bootloader at location zero.

                ; However, it gets set in the linker.

                ; In this case, ORG is used to set the program counter
                ; to reference address 1000h as this field of code.
                ; You can jump to the memory address, but if the
                ; counter doesn't align, data gets lost, and the code
                ; would not be able to syncronize with the frame of reference.

                ; The ORG directive is apparently the only
                ; possible way to change what the counter
                ; references, and setting it as the first instruction
                ; keeps things aligned when the jump is made to this
                ; block of code after it gets loaded to an address.
                ; As such, you need to make sure to set the ORG directive
                ; to match the address you load this block of code to.

                ; The reason ORG 0 works for the Bootloader section, is that
                ; the MBR is always set to load at 0x7C00, so when you jump
                ; there, it always has a frame of reference.

	mov ax, cs  ; This sets registers to reference the code segment/location.
	mov ds, ax  ; A register is required to copy the address value. Data
	mov es, ax  ; alone AKA immediate addressing (mov ds, 5) is not allowed
                ; when operating on segment registers.
                ; This method is called direct addressing, which is using
                ; an address to point the segment registers to a value
                ; in memory, or (address) block of code.
    call EnableVESA ; Move the instruction pointer to the included
                    ; code block file containing the instructions necessary
                    ; for changing the computer into display capabilities
                    ; for VBA/VESA modes using video memory address blocks.
                    ; An address block is the equivalent to a long array of
                    ; bytes stringed together to contain one single definition
                    ; of what it is.
    jmp ModeSetup   ; After the section of code is run, it the instruction
                    ; pointer returns to this location.

vesa_mode_info_block_address_buffer: equ 6000h  ; This address is the address
                                                ; to use for video memory
                                                ; assigned by the developer.
global vesa_mode_info_block_address_buffer      ; This sets the VESA/video memory
                                                ; address as global which tells
                                                ; the compiler to make it public
                                                ; for other code files to use/call.

mode_setup_string: db "Booted from a disk. Attempting to enable A20, and protected 32 bit mode.", 0

; These include instructions tell the compiler to add the code written 
; in these files to this location.
%include "../../CodeSources/AssemblyLanguage/16Bits/Software/DisplayFunctions/16Bits_int10h_CharacterStrings.asm"
%include "../../CodeSources/AssemblyLanguage/16Bits/Software/ModeSelection/16Bits_GlobalDescriptorTable.asm"
%include "../../CodeSources/AssemblyLanguage/16Bits/HardwareOperation/DisplayFunctions/VBE-VESA.asm"

ModeSetup:
    mov si, mode_setup_string   ; This string is meant to inform the user that a boot 
                                ; was succssessful, and the computer is attempting to 
                                ; move into protected mode.
    call DisplayCharacters      ; Calls the Display function for the string.
EnableA20:
    in al, 92h                  ; Modern computers have a fast enable.
	or al, 2                    ; There's a very lengthy explanation of this
	out 92h, al                 ; on wiki.osdev regarding the old way.
SetUpAGlobalDescriptorTable:
    cli                         ; The first thing that needs to be done
                                ; before loading the Global Descriptor Table.
    lgdt[GlobalDescriptorTable] ; Load the Global Descriptor Tables.
    mov eax, cr0                ; cr0 is used to initialize protected mode.
    or eax, 1h                  ; By default, it doesn't have its first bit set
                                ; high (1), so the register is copied onto eax
                                ; due to the fact that it is not accessible
                                ; directly, and then an or instruction is held
                                ; against the entire register. Since the least
                                ; significant bit is 0, the or against the 1
                                ; results in a 1, therefore setting the bit high
                                ; and "flipping it" over.
                                ; This new setting is then moved back into cr0
                                ; so the computer can operate from the route
    mov cr0, eax                ; it sets up.
    jmp Code_Segment:ProtectedMode ; At this point, the program counter is no
                                   ; longer in synchronization with the address
                                   ; so the address of the GDT is used to offset
                                   ; and find the next label.

[BITS 32]
ProtectedMode:
    mov ax, Data_Segment    ; Assign all the segment registers to the data segment.
    mov ds, ax              ; Using direct addressing to assign address values
    mov ss, ax              ; to the segment registers.
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov ebp, 0x90000    ; This places the stack to allow the most free space
    mov esp, ebp        ; possible.

    jmp Kernel          ; Jump to the kernel.

; Linker phase:
; All of these sections get filled in by the linker from C code.
; I feel that they have no use for the assembly language code in this format.
; You can go through and add sections to the ASM, but it seems to
; defeat the purpose, and makes it difficult to learn what
; is actually going on in this stage of the process.

section .text       ; This section is the code section for the instruction pointer.
                    ; The instruction pointer is the line of code the computer
                    ; is on.

; C Operating System:
[extern OperatingSystem]    ; Now that C language is being linked, its methods
                            ; can be added to the kernel
                            ; by declaring labels from the C source files
                            ; as external

Kernel:
	mov esi, mode_info_block                        ; Places the mode info block address onto memory to work with
	mov edi, vesa_mode_info_block_address_buffer    ; Assign a working space for the mode info block
	mov ecx, 64                                     ; Mode info block=256 byte / 4 = the number of double words
	rep movsd                                       ; Shifts entire block by 32 bits onto 6000h
    call OperatingSystem                            ; Call the external C methods from here
    cli
    hlt

section .bss        ; This section is reserved for "dynamic" variables,
                    ; or variables defined by the code itself, and during runtime.

section .data       ; This section is reserved for predefined variables, 
                    ; set in memory during link/compilation.

section .rodata     ; This section is reserved for readonly variables (constants),
                    ; set in memory during link/compilation.

times 8192-($-$$) db 0  ; Pad the file to an arbitrary size for now.
                        ; Will need to plan for making this a calculated size.