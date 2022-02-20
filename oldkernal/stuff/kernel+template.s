	jmp start
	db "THIS IS THE KERNEL"
[org 0x1000]
[bits 16]
start:
	call screen_print_clear

	mov di, msg_start
	call screen_print_string
	call screen_print_nl

xy:	dq 20.5
yx:	dq 30.0

	;smth
	mov di, xy
	fld qword [di]
	call print_64
	fistp qword [di]
	call print_64

loop_main:
	mov di, msg_input
	call screen_print_string
	
	mov ax, cs
	mov ds, ax
	mov di, str_buffer
	
	xor cx, cx
loop_input:
	mov ah, 0x00
	int 0x16
	cmp al, 0x0D
	je loop_input_end
	mov [di], al
	inc di
	mov ah, 0x0E
	int 0x10
	jmp loop_input
loop_input_end:
	mov di, str_buffer
	add di, 0x39
	mov [di], byte 0xff
	call screen_print_nl

	mov di, str_buffer
	mov al, [di]
	cmp al, 0x50
	je inp_print
	cmp al, 0x4E
	je inp_nl
	cmp al, 0x49
	je inp_in
	cmp al, 0x43
	je inp_calc
	cmp al, 0x47
	je callgrapics
	cmp al, 0x4D
	je inp_math

	mov di, msg_error
	call screen_print_string
	jmp inp_done

inp_math:
	pusha
	call math_main
	popa
	jmp inp_done 

inp_calc:
	pusha
	call screen_get_hex
	mov dl, al
	call screen_print_hex_n
	mov bl, al
	call screen_print_nl
	call screen_get_hex
	mov dl, al
	call screen_print_hex_n
	call screen_print_nl
	xor ah, ah
	mov di, t_val
	add di, ax
	add di, ax
	mov dx, [di]
	mov al, bl
	xor ah, ah
	mov di, t_val
	add di, ax
	add di, ax
	mov ax, [di]
	add ax, dx
	mov [di], ax
	popa
	jmp inp_done

inp_print:
	add di, 0x2 
	cmp [di], byte 0x58
	je inp_print_val
	sub di, 0x2

	call cmd_print
	jmp inp_done
inp_print_val:
	call screen_get_hex
	mov dl, al
	call screen_print_hex_n
	call screen_print_nl
	mov di, t_val
	xor ah, ah
	add di, ax
	add di, ax
	mov dx, [di]
	call screen_print_hex_w
	call screen_print_nl
	jmp inp_done

inp_nl:
	call cmd_nl
	jmp inp_done
inp_in:
	call screen_get_hex
	mov dl, al
	call screen_print_hex_n
	call screen_print_nl
	mov di, t_val
	xor ah, ah
	add di, ax
	add di, ax
	call get_word
	mov [di], dx
	call screen_print_nl
	jmp inp_done

inp_done:

jmp loop_main
jmp $


t_val:				resw 0x10
str_buffer:			resb 0x45


msg_segment:		db "SEGMENT ",0xff
msg_offset: 		db "OFFSET ",0xff
msg_error:		db "ERROR",0x0D, 0x0A,0xff
msg_input:		db "#> ",0xff
msg_start:		db "TEMPLATE 0.1",0xff


%include "./screen_print.s"
%include "./grapics.s"
%include "./math.s"

cmd_print:
	pusha
	inc di
	inc di
	call screen_print_string
	call screen_print_nl
	popa
	ret

cmd_nl:
	call screen_print_clear
	ret

get_word:
	push cx
	mov cx, 0x04
get_word_loop:
	call screen_get_hex
	cmp al, 0xff
	je get_word_loop
	push dx
	mov dl, al
	call screen_print_hex_n
	pop dx
	shl dx, 0x4
	xor ah, ah
	or dx, ax
	dec cx
	jnz get_word_loop
	pop cx
	ret	

callgrapics:
	call grapics_main
	jmp inp_done



;TEMPLATE COMMANDS
;-----------------
;P
;	P X --> prints contnt of template register
;	P "ANYTING" --> prints everything after space
;
;N	--> clears screen
;

sys_kyb:
	push ax
	push cx
	in al, 0x60 		;get Scan Code from PS/2 Data Port
	mov cx, cs		;mov cx to ds
	mov ds, cx
	mov di, scann_code	;set offset for scanncode
	xor ah, ah
	add di, ax		;add scanncode to offset
	xor dx, dx
	mov dl, [di]		;mov ascii code to dl
	pop cx
	pop ax
	ret 


scann_code:
	db 0x00, 0x00, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x30, 0xE1, 0xB4, 0x08, 0x00
	db 0x51, 0x57, 0x45, 0x52, 0x54, 0x5A, 0x55, 0x49, 0x4F, 0x50, 0x9A, 0x2b, 0x00, 0x00,
	db 0x41, 0x53, 0x44, 0x46, 0x47, 0x48, 0x4A, 0x4B, 0x4C, 0x94, 0x84, 0x23, 0x00, 0x00,
	db 0x59, 0x58, 0x43, 0x56, 0x42, 0x4E, 0x4D, 0x2C, 0x2E, 0x2D, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00


