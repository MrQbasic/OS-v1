[bits 16]
check:	
	mov ax, cs
	mov ds, ax

	call screen_print_clear

	;check Vesa
	mov di, T_CHECKING
	call screen_print_string
	mov di, T_VESA
	call screen_print_string

	mov di, BUFFER
	mov ax, 0x4F00
	int 0x10
	cmp al,	0x4f 
	jne check_error

	mov di, T_GOOD
	call screen_print_string
	call screen_print_nl
	
	;screen int
	mov di, T_CHECKING
	call screen_print_string
	mov di, T_SCREEN
	call screen_print_string

	xor ax, ax
	call screen_int_set		
	cmp ax, 0xFEFE
	jne check_error
	mov di, T_GOOD
	call screen_print_string

	mov ax, 100
	call sys_delay
	
	ret

check_error:
	mov di, T_ERROR
	call screen_print_string
	jmp $



T_SCREEN:		db "SCREEN INT SETUP ",0xff
T_VESA:			db "VESA SUPPORT ",0xff
T_CHECKING:		db "CHECKING ",0xff

BUFFER:			resb 512

