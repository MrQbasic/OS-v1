[bits 16]
minimon:
	mov ax, cs
	mov ds, ax
	call screen_print_clear
	mov di, MI_HELP
	call screen_print_string
	call screen_print_nl
mi_loop:
	mov ax, cs
	mov ds, ax
	call screen_print_nl
	mov di, MI_CURSOR
	call screen_print_string
	call screen_get_hex

	cmp al, 0x1
	je minimon

	cmp al, 0x2
	jne mi_skipp1
	call mi_get_addr
	mov cx, ds
	mov ds, bx
	mov di, ax
	mov dl, [di]
	mov ds, cx
	call screen_print_nl
	call screen_print_hex_b
	call mi_loop
mi_skipp1:

	cmp al, 0x3
	jne mi_skipp2
	call screen_print_nl
	mov di, MI_T_INP
	call screen_print_string
	call screen_get_hex_b
	mov cl, al
	call mi_get_addr
	mov dx, ds
	push dx
	mov ds, bx
	mov di, ax
	mov [di], cl
	pop dx
	mov ds, dx
	jmp mi_loop
mi_skipp2:
	
	cmp al, 0x04
	jne mi_skipp3
	call mi_get_addr
	push ax
	push bx
	call screen_print_nl
	mov di, MI_T_INP
	call screen_print_string
	call screen_get_hex_w
	call screen_print_nl
	mov cx, ax
	pop bx
	pop ax
mi_loop1:
	mov ds, bx
	mov di, ax
	mov dl, [di]
	call screen_print_hex_b
	mov di, MI_T_SP
	call screen_print_string
	inc ax
	dec cx
	jnz mi_loop1 
	jmp mi_loop
mi_skipp3:

	cmp al, 0x5
	jne mi_skipp4
	call screen_print_nl
	mov di, MI_T_INT
	call screen_print_string
	call screen_get_hex_b
	mov [mi_lb1 + 1], al
	call screen_print_nl
	call sys_set_reg
mi_lb1:
	int 0xff
	call debug
	jmp mi_loop
mi_skipp4:


	cmp al, 0x6
	jne mi_skipp5	
	call screen_print_nl
	mov di, MI_T_POT	
	call screen_print_string
	call screen_get_hex_w
	mov [mi_lb2+1], ax
mi_lb2:
	in ax, 0x000
	mov dx, ax
	call screen_print_nl
	call screen_print_hex_w
	jmp mi_loop
mi_skipp5:

	cmp al, 0x7
	jne mi_skipp6
	call screen_print_nl
	mov di, MI_T_POT
	call screen_print_string
	call screen_get_hex_w
	mov dx, ax
	call screen_print_nl
	mov di, MI_T_OUT
	call screen_print_string
	call screen_get_hex_w
	out dx, al
	jmp mi_loop
mi_skipp6:

	cmp al, 0x8
	jne mi_skipp7
	call screen_print_nl
	mov di, MI_T_INT
	call screen_print_string
	call screen_get_hex_b
	xor ah, ah 
	call screen_print_nl
	mov cx, 0x0000
	mov ds, cx
	imul ax, 4
	mov di, ax
	mov cx,	word [ds:di]
	mov dx, word [ds:di+2]
	mov di, MI_T_SEG	
	call screen_print_string
	call screen_print_hex_w
	call screen_print_nl
	mov di, MI_T_OFS
	call screen_print_string
	mov dx, cx
	call screen_print_hex_w
	call screen_print_nl
	jmp mi_loop
mi_skipp7:
	cmp al, 0x9
	jne mi_skipp8
	call screen_print_nl
	mov di, MI_T_INT
	call screen_print_string
	call screen_get_hex_b
	xor ah, ah
	imul ax, 0x04
	mov bl, al
	call screen_print_nl
	mov di, MI_T_SEG
	call screen_print_string
	call screen_get_hex_w
	mov cx, ax
	call screen_print_nl
	mov di, MI_T_OFS
	call screen_print_string
	call screen_get_hex_w
	mov dx, ax
	mov ax, 0x0000
	mov ds, ax
	xor bh, bh
	mov di, bx
	cli
	mov word [ds:di], dx
	mov word [ds:di+2], cx
	sti
	jmp mi_loop
mi_skipp8:	
	cmp al, 0xa	
	jne mi_skipp9
	call mi_get_addr	
	call debug
	jmp mi_loop
	jmp mi_loop
mi_skipp9:
	cmp al, 0xb
	jne mi_skipp10
	call mi_get_addr
	call ax
	jmp mi_loop
mi_skipp10:

	cmp al, 0xc
	jne mi_skipp11
	call screen_print_nl
	mov di, MI_T_CODE
	call screen_print_string
	call screen_get_hex_d
	call screen_print_nl
	xor ebx, ebx
	xor ecx, ecx
	xor edx, edx
	cpuid
	call debug_bin
	call screen_print_nl
	jmp mi_loop
mi_skipp11:

	cmp al, 0xf
	je mi_end

	jmp mi_loop
mi_end:
	call screen_print_clear
	jmp os_main	

mi_get_addr:
	call screen_print_nl
	mov di, MI_T_SEG
	call screen_print_string
	call screen_get_hex_w	
	mov bx, ax	
	call screen_print_nl
	mov di, MI_T_OFS
	call screen_print_string
	call screen_get_hex_w
	ret

MI_HELP:
		db "Minimon 1.0",0x0d, 0x0a
		db "1 -- Help        ",0x0d, 0x0a		
		db "2 -- Read        ",0x0d, 0x0a
		db "3 -- Write       ",0x0d, 0x0a
		db "4 -- MEM list    ",0x0d, 0x0a
		db "5 -- Int         ",0x0d, 0x0a
		db "6 -- Port In     ",0x0d, 0x0a
		db "7 -- Port Out    ",0x0d, 0x0a
		db "8 -- IVT Get     ",0x0d, 0x0a
		db "9 -- IVT Set     ",0x0d, 0x0a
		db "A -- Jump        ",0x0d, 0x0a
		db "B -- Call        ",0x0d, 0x0a
		db "C -- CpuId       ",0x0d, 0x0a
		db "D",0x0d, 0x0a
		db "E",0x0d, 0x0a
		db "F -- Exit",0xff

MI_CURSOR:	db "=) ", 0xff	
MI_T_SEG:	db "Segment: ", 0xff
MI_T_OFS:	db "Offset: ", 0xff
MI_T_INP:	db "Input: ", 0xff
MI_T_OUT:	db "Output: ", 0xff
MI_T_SP:	db "  ", 0xff
MI_T_POT:	db "Port: ", 0xff
MI_T_INT:	db "Int: ", 0xff
MI_T_CODE:	db "Code: ",0xff
