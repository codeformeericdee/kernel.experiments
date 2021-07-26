; Purpose: A boot sector to load a kernel from.

; The convention is to tell the computer to load the MBR (Master Boot Record)
; using the number 0xAA55. This entire assembly file gets loaded into the MBR
; when the computer is started. That is because you will be storing it as data
; onto a virtual floppy image to load into an emulator. That gets done when you
; build it, which you can learn more about in the makefile.

; The thing that tells the computer to do this is that number I mentioned; 0xAA55,
; which you can see at the bottom of this file. When the computer sees that number,
; it then loads the data before it into the address 0x7C00, and then starts executing
; the code at memory location zero.

[BITS 16]           ; Tell the compiler how to write the machine code mnuemonics.

[ORG 0]             ; Tell the compiler to assign the program counter at its current
                    ; address to the first available address relative to the BIOS; since
                    ; that actual address is handeled by the BIOS, or the OS kernel.

    jmp 7C0h:Boot   ; The first thing that happens when the instruction pointer goes
                    ; to this address of zero (relative to the BIOS or Kernel), is the
                    ; computer gets told to jump to where the hardware loaded the data
                    ; found in the master boot record (0x7C00, but with an offest of Boot).
                    ; 7C0h=0x7C0. You can change 0x at the start to an h at the end
                    ; (stands for hexadecimal). Both work. Also, this method differs
                    ; from [org 0x7C00], in that the second zero at the end denotes
                    ; you are using origin zero at address 0x7C0. The Boot label is an
                    ; address. Since this origin is pre-set to zero, you don't need the
                    ; extra information to tell the instruction pointer where to go within
                    ; that address. The jump occurs to the MBR load address
                    ; (0x7C0+origin 0; AKA 0x7C00) adding however many bytes to get to the
                    ; label address for Boot. You'd assume you can just use address 1 as an
                    ; offset, but when the file is assembled, the assembler might actually
                    ; place it somewhere else, so it's safer to just use the label.

                    ; This method is my preferrence, because it is less reliant on the
                    ; assembler, and it also tells you that your code isn't loading properly
                    ; if there's nothing showing. Technically you can delete the
                    ; ORG directive, and the jump, but again, this really ensures your
                    ; bootloader loaded properly. It also ensures that the program counter
                    ; is aligned with the instructions.

; Variables:

boot_file_location: equ 7C0h    ; This is the bootloader address in every computer
                                ; following modern convention.

kernel_location: equ 1000h      ; This is the kernel location designated by the
                                ; developer.

boot_disk: db 0     ; This is disk zero, the default first disk for
                    ; conventional computer systems.

boot_string: db "The bootloader was found.", 0    ; This is the string to print
                                                  ; to tell where the instruction pointer
                                                  ; is at.

boot_failure_string: db "An error occurred, and the second sector was not found.", 0
                                                  ; This is the string to print
                                                  ; if the disk read fails.

; These include instructions tell the compiler to add the code written 
; in these files to this location.
%include "../../CodeSources/AssemblyLanguage/16Bits/Software/DisplayFunctions/16Bits_int10h_CharacterStrings.asm"
%include "../../CodeSources/AssemblyLanguage/16Bits/HardwareOperation/DiskFunctions/16Bits_int13h_DiskRead.asm"

; Instructions:

Boot:
    mov byte dl, [boot_disk]    ; This moves the default/BIOS defined disk number into dl
                                ; so that it can be read by the disk function it is about
                                ; to call.

    mov ax, cs                  ; Load the boot file code segment address to ax
                                ; to pass to argument registers.

    mov ds, ax                  ; Place the boot file address via ax into the data segment,
                                ; so the string labels can be recalled (found).

    mov es, ax                  ; Place the code segment into the extra segment so that
                                ; the disk read doesn't fault.

                                ; There are other segments, but they aren't being used.

    mov si, boot_string         ; Moves the data array address into si (source index)
                                ; si is a special purpose register.
                                ; Its offset is relative to the data segment
                                ; You can use di for this, but you'd want to set the es.
                                ; es is the extra segment. In my case, I chose to only set
                                ; the ds (data segment).

    call DisplayCharacters      ; Calls the function to display the string character by
                                ; character from the include file above.
                                ; Which will then return here. Call is different from
                                ; jump, in that it has the ability to use the "ret"
                                ; instruction which takes control back to the address after
                                ; the last call.

    call LoadSector2            ; Calls the function to load the next sector from the disk.
    jmp 0:kernel_location       ; Jumps to the predefined kernel location which should
                                ; now be found in memory (Random Access Memory).

                                ; The computer reaches the next point...
                                ; only if there is an error.
BootFailure:
    mov si, boot_failure_string ; Load the boot failure string to si.

    call DisplayCharacters      ; Display the string, because the only way to get to this
                                ; location is from the error handler in the
                    ; ../HardwareOperation/DiskFunctions/16Bits_int13h_DiskRead.asm function.

    cli                         ; This clears the interrupt flag data for a processor 
    hlt                         ; This halts the cpu and waits for an interrupt to occur,
                                ; which was why the flags were cleared prior to halting.
                                ; For example, a program might use an interrupt 0x80
                                ; to tell the OS to take back control of the computer.
                                ; Right after the hlt, there would be a jmp instruction to
                                ; a loop, or comparison to the interrupt flags for where to
                                ; go after an application on the OS
                                ; has finished its process. Having extra flags set can
                                ; sometimes cause the computer to not actually halt.

; End of file instructions:

times 510-($-$$) db 0   ; Fills the remainder of the file with zeros
                        ; (1 byte of data) until the file is 510 bytes in size.
                        ; $ means the current address, and
                        ; $$ means the address of the first valid entry of code
                        ; in this file;
                        ; (510 - bytes of instructions = bytes to fill as zero).
                        ; All comments are ignored by the compiler, and aren't
                        ; placed into your compiled code (binaries/objects).

db 0x55                 ; dw 0xAA55 places 2 bytes of data at the end of 510 zeros
db 0xAA                 ; that instruct the hardware to attempt to boot.
                        ; instead of defining a word (2 bytes), you can define them each
                        ; seperately like I have.

                        ; Apparently modern systems don't require the AA55 "magic number"
                        ; anymore, but this has been left for general compatibility.
                        ; It is still a requirement in some of the Bochs and QEMU settings.

                        ; The MBR (Master Boot Record) is where this is stored
                        ; which is the very first sector on the first readable disk.
                        ; If this value isn't found, then the system defaults to 
                        ; searching for the same boot number,
                        ; 0xAA55 on the next disk it finds.

                        ; Why is it shown as 0x55, then 0xAA though?

                        ; This has to do with the way computers arrange memory.
                        ; It's called "endianness". As humans, everyone reads number size
                        ; from left to right. To do this on a computer, you have to store
                        ; data by the larger numbers first. For example, the number
                        ; 32 in binary is       00100000
                        ; and the number 1 is   00000001
                        ; If you added these numbers, big endian would store it as:
                        ; 00100000 (32), 00000001 (1)
                        ; And little endian would store it using the smaller number first:
                        ; 00000001 (1), 00100000 (32)

                        ; AA in hexadecimal means two 10's (170)
                        ; A=10(16^1)=160 + A=10(16^0)=10 (160 + 10)
                        ; Whereas 55 means two 5's (85)
                        ; 5=5(16^1)=80 + 5=5(16^0)=5 (80 + 5)

                        ; You'll notice that the numbers start in big endian by default.
                        ; Some computer architectures keep it that way, and others
                        ; like x86 and x86_64 store them in little endian format.