; AH = 02
; AL = Number of sectors to read (1-128 decimal)
; CH = Track/cylinder number (0-1023 decimal, see below)
; CL = Sector number (0-17 decimal)
; DH = Head number (0-15 decimal)
; DL = Drive number (0=A:, 1=2nd floppy, 80h=drive 0, 81h=drive 1)

; On return:
; AH = Status
; AL = Number of sectors that were read
; CF = 0 (if success)
; CF = 1 (if error)

; The documentation recommends that programmers attempt to read a 
; disk at least 3 times if it fails.

LoadSector2:
    mov si, load_a_sector_string
    call DisplayCharacters

    xor ax, ax
    mov es, ax          ; Clears es so there's no offset when read.
    mov ah, 0x02
    mov al, 16
    mov ch, 0
    mov cl, 2
    mov bx, 0x1000
    mov dh, 0
    mov dl, 0

    int 0x13
    jc .readDiskError
    mov si, read_disk_success_string
    call DisplayCharacters
    ret
.readDiskError:
    mov si, read_disk_error_string
    call DisplayCharacters
    jmp 7C0h:BootFailure

load_a_sector_string: db "An attempt to read a sector from the disk was made", 0

read_disk_error_string: db "There was an error. For some reason the disk could not be read.", 0

read_disk_success_string: db "A successful disk read occurred.", 0