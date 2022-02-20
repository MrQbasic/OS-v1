[bits 16]
render_main:
	xor ax, ax
render_main_loop:	
	pusha
	mov ax, 0x20
	call sys_delay
	popa
	pusha
	mov ah, 0x00
	int 0x10
	popa
	mov dl, al
	call screen_print_hex_b
	inc al
	jmp render_main_loop
	ret
