; I followed a tutorial on Youtube for this part, so
; I don't know how to explain it very well yet.
; For now, if you'd like to learn more, go here:
; https://www.youtube.com/watch?v=yimDZ1Nxg28&list=PLT7NbkyNWaqajsw8Xh7SP9KJwjfpP8TNX&index=31

EnableVESA:
	xor ax, ax
	mov es, ax
	mov ah, 4Fh
	mov di, vbe_info_block
	int 10h
	cmp ax, 4Fh
	jnz .enableVESAError
		mov ax, word [vbe_info_block.video_mode_pointer]
		mov [offset], ax
		mov ax, word [vbe_info_block.video_mode_pointer+2]
		mov [t_segment], ax
		mov fs, ax
		mov si, [offset]
	.enableVESAFindModes:
	mov dx, [fs:si]
	inc si
	inc si
	mov [offset], si
	mov [mode], dx
	cmp dx, word 0FFFFh
	je .enableVESAEndOfModes
		mov ax, 4F01h
		mov cx, [mode]
		mov di, mode_info_block
		int 10h
		cmp ax, 4Fh
		jne .enableVESAError
	.enableVESAPrintFoundMode:
	mov dx, [mode_info_block.x_resolution]
	; call DisplayHexadecimal
	mov ax, 0E20h
	int 10h
	mov dx, [mode_info_block.y_resolution]
	; call DisplayHexadecimal
	mov ax, 0E20h
	int 10h
	xor dh, dh
	mov dl, [mode_info_block.bits_per_pixel]
	; call DisplayHexadecimal
	mov ax, 0E0Ah
	int 10h
	mov al, 0Dh
	int 10h
	.enableVESADetermineCompatibility:
	mov ax, [width]
	cmp ax, [mode_info_block.x_resolution]
	jnz .enableVESACheckNextMode
	mov ax, [height]
	cmp ax, [mode_info_block.y_resolution]
	jnz .enableVESACheckNextMode
	mov ax, [bpp]
	cmp al, [mode_info_block.bits_per_pixel]
	jnz .enableVESACheckNextMode
	; cli                                       ;
	; hlt                                       ; Halts when found until you comment this out
	.enableVESAEnableVBE:
	mov ax, 4F02h
	mov bx, [mode]
	or bx, 4000h
	xor di, di
	int 10h
	cmp ax, 4Fh
	jnz .enableVESAError
	jmp .enableVESASuccess
	.enableVESAError:
	mov ax, 0E45h
	int 10h
	cli
	hlt
	.enableVESASuccess:

	ret

	.enableVESACheckNextMode:
	mov ax, [t_segment]
	mov fs, ax
	mov si, [offset]
	jmp .enableVESAFindModes
	.enableVESAEndOfModes:
	mov ax, 0E65h
	int 10h
	cli
	hlt



[bits 32] ; VBE-VESA headers (32 bits)

width: dw 1920
height: dw 1080
bpp: db 32
offset: dw 0
t_segment: dw 0
mode: dw 0

; This can be optimized by adding 512 padding to keep each block at the length
; of a sector.

vbe_info_block:                             ; 'Sector' 2
	.vbe_signature: db 'VBE2'
	.vbe_version: dw 0                      ; Can be 0300h / BCD value
	.oem_string_pointer: dd 0 
	.capabilities: dd 0
	.video_mode_pointer: dd 0
	.total_memory: dw 0
	.oem_software_rev: dw 0
	.oem_vendor_name_pointer: dd 0
	.oem_product_name_pointer: dd 0
	.oem_product_revision_pointer: dd 0
	.reserved: times 222 db 0
	.oem_data: times 256 db 0

mode_info_block:                            ; 'Sector' 3
                                            ; Mandatory info for all VBE revisions
	.mode_attributes: dw 0
	.window_a_attributes: db 0
	.window_b_attributes: db 0
	.window_granularity: dw 0
	.window_size: dw 0
	.window_a_segment: dw 0
	.window_b_segment: dw 0
	.window_function_pointer: dd 0
	.bytes_per_scanline: dw 0

                                            ; Mandatory info for VBE 1.2 and above
	.x_resolution: dw 0
	.y_resolution: dw 0
	.x_charsize: db 0
	.y_charsize: db 0
	.number_of_planes: db 0
	.bits_per_pixel: db 0
	.number_of_banks: db 0
	.memory_model: db 0
	.bank_size: db 0
	.number_of_image_pages: db 0
	.reserved1: db 1

                                            ; Direct color fields (required for direct/6 and YUV/7 memory models)
	.red_mask_size: db 0
	.red_field_position: db 0
	.green_mask_size: db 0
	.green_field_position: db 0
	.blue_mask_size: db 0
	.blue_field_position: db 0
	.reserved_mask_size: db 0
	.reserved_field_position: db 0
	.direct_color_mode_info: db 0

                                            ; Mandatory info for VBE 2.0 and above
	.physical_base_pointer: dd 0            ; Physical address for flat memory frame buffer
	.reserved2: dd 0
	.reserved3: dw 0

                                            ; Mandatory info for VBE 3.0 and above
	.linear_bytes_per_scan_line: dw 0
    .bank_number_of_image_pages: db 0
    .linear_number_of_image_pages: db 0
    .linear_red_mask_size: db 0
    .linear_red_field_position: db 0
    .linear_green_mask_size: db 0
    .linear_green_field_position: db 0
    .linear_blue_mask_size: db 0
    .linear_blue_field_position: db 0
    .linear_reserved_mask_size: db 0
    .linear_reserved_field_position: db 0   ;
    .max_pixel_clock: dd 0

    .reserved4: times 190 db 0              ; Remainder of mode info block



[bits 16] ; Changes back to 16 bits, because the computer is still in real mode.