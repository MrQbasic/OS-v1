[bits 16]
os_main:
	mov ax, cs			;set ds to cs
	mov ds, ax
	call screen_print_clear 
	mov di, S_OS_NAME		;print bootup msg
	call screen_print_string
	call screen_print_nl
os_bootup:
	mov di, V_LIB_POSI	
	mov ax, grapics_main
	mov [di], ax

	add di, 2
	mov ax, math_main
	mov [di], ax

	add di, 2
	mov ax, minimon
	mov [di], ax

	add di, 2
	mov ax, os_main
	mov [di], ax

	add di, 2
	mov ax, pit_main
	mov [di], ax
	
	add di, 2
	mov ax, sound_main
	mov [di], ax 
	
	add di, 2	
	mov ax, render_main
	mov [di], ax
	
	add di, 2
	mov ax, string_main
	mov [di], ax
	
	mov bx, V_LIB_POSI 
	mov ax, T_LIB
	mov cx, [V_ALIB]
os_bootup_loop1:
	mov di, ax
	push ax
	mov ax, cs
	mov ds, ax
	pop ax
	call screen_print_string
	mov dx, [bx]
	call screen_print_hex_w
	call screen_print_nl	
	add ax, 0x09
	add bx, 0x02
	dec cx
	cmp cx, 0x0000
	jne os_bootup_loop1
os_loop:
	mov di, T_CURSOR		;display cursor
	call screen_print_string
	call screen_get_hex_w
	call screen_print_nl
	call ax
	jmp os_loop	



	jmp $
S_OS_NAME:		db "TEMPLATE OS", 0xff
T_CURSOR:		db "->", 0xff

V_ALIB:			dw 0x0008
T_LIB:			db "Grapics ", 0xff 
			db "Math    ", 0xff
			db "Minimon ", 0xff
			db "OS      ", 0xff
			db "Pit     ", 0xff
			db "Sound   ", 0xff
			db "3D      ", 0xff
			db "String  ", 0xff

V_LIB_POSI:		dw 0x0000
			dw 0x0000
			dw 0x0000
			dw 0x0000
			dw 0x0000
			dw 0x0000
			dw 0x0000
			dw 0x0000
			dw 0x0000
			dw 0x0000	

V_CURSOR:		db 0x00
V_BUTTON:		db 0x00
