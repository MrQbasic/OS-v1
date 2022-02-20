[bits 16]
MATH_T_INPA:		db "A = ", 0xff
MATH_T_INPB:		db "B = ", 0xff
MATH_T_EQ:		db "A=B", 0xff
MATH_T_G:		db "A>B", 0xff
MATH_T_L:		db "A<B", 0xff

math_main:	
	mov di, MATH_T_INPA
	call screen_print_string
	call screen_get_hex_w
	mov word [cs:a], ax
	call screen_print_nl

	mov di, MATH_T_INPB
	call screen_print_string
	call screen_get_hex_w
	mov word [cs:b], ax
	call screen_print_nl
	
	mov ax, word [cs:a]
	mov bx, word [cs:b]
	cmp ax, bx
	jne math_skipp1
	mov di, MATH_T_EQ
	jmp math_end
math_skipp1:
	jle math_skipp2
	mov di, MATH_T_G
	jmp math_end
math_skipp2:
	jge math_skipp3
	mov di, MATH_T_L
	jmp math_end
math_skipp3:	



math_end:
	call screen_print_string
	call screen_print_nl
	ret 	

print_64:
	pusha
	add di, 6
	mov dx, word[di]
	call screen_print_hex_w
	sub di, 2
	mov dx, word[di]	
	call screen_print_hex_w
	sub di, 2
	mov dx, word[di]
	call screen_print_hex_w	
	sub di, 2
	mov dx, word [di]
	call screen_print_hex_w	
	call screen_print_nl
	popa
	ret 	

add_vector:
	pusha
	mov dx, cs
	mov ds, dx
	mov di, ax
	fld qword [di]
	mov di, bx
	fld qword [di]
	faddp
	mov di, cx
	fstp qword [di]
	mov di, ax
	fld qword [di + 9]
	mov di, bx
	fld qword [di + 9]
	faddp
	mov di, cx
	fstp qword [di + 9] 
	popa
	ret

intabs:
	cmp ax, 0x8000
	jge intabs_skipp
	xor ax, 0xffff
	add ax, 0x0001
intabs_skipp:	
	ret



a:	dw	 -03
b: 	dw	 +01

res:
	resq 	1

