[bits 16]
screen_get_hex:
	mov ah, 0x00 
	int 0x16
	cmp al, 0x30
	jl screen_get_hex_nothing
	cmp al, 0x39
	jle screen_get_hex_num
	cmp al, 0x41
	jl screen_get_hex_nothing
	cmp al, 0x46
	jle screen_get_hex_let
	jmp screen_get_hex_nothing
screen_get_hex_let:
	sub al, 0x41
	add al, 0x0A
	jmp screen_get_hex_done
screen_get_hex_num:
	sub al, 0x30
	jmp screen_get_hex_done
screen_get_hex_nothing:
	jmp screen_get_hex
screen_get_hex_done:
	push dx
	mov dl, al
	call screen_print_hex_n
	pop dx
	ret

screen_get_hex_b:
	push bx
	call screen_get_hex
	mov bl, al
	call screen_get_hex
	shl bl, 0x04
	or al, bl
	pop bx
	ret

screen_get_hex_w:
	push bx
	call screen_get_hex_b
	mov bh, al
	call screen_get_hex_b
	mov bl, al
	mov ax, bx
	pop bx
	ret

screen_get_hex_d:
	push ebx
	xor eax, ebx
	xor ebx, ebx	
	call screen_get_hex_w
	mov bx, ax
	call screen_get_hex_w	
	shr ebx, 16
	or eax, ebx
	pop ebx
	ret

screen_get_char:
	push bx
	mov bh, ah
	xor ax, ax
	int 0x16
	mov ah, bh
	pop bx
	ret

screen_get_string:
	pusha
screen_get_string_loop:
	xor ax, ax
	int 0x16
	mov [ds:di], al	
	inc di
	cmp al, 0x0D
	je screen_get_string_end
	mov ah, 0x0E
	int 0x10
	loop screen_get_string_loop
screen_get_string_end:
	mov byte [ds:di], 0xff
	popa
	ret
	
screen_print_hex_n:
	pusha
	mov ah, 0x0E  ;print int code
	mov al, dl		
	and al, 0x0f  ;pw use the lower 4 bits from dl to print
	cmp al, 0x09  ;check is al is a hex number or letter
	jle screen_print_hex_n_digit
	sub al, 0x0A
	add al, 0x41  ;ajust so its ascii
	jmp screen_print_hex_n_done
screen_print_hex_n_digit:
	add al, 0x30  ;ajust so its ascii
screen_print_hex_n_done:
	int 0x10	  ;int call
	popa 
	ret

screen_print_hex_w:
	pusha
	mov bx, dx
	mov dl, dh
	call screen_print_hex_b
	mov dx, bx
    	call screen_print_hex_b
    	popa
	ret 

screen_print_hex_b:
	pusha
	mov bl, dl
	shr dl, 0x04                ;movs higher 4 bits in dl and call a sub 
	call screen_print_hex_n
	mov dl, bl  
	and dl, 0x0f                ;moves lower 4 bits in dl and calls a sub
	call screen_print_hex_n
	popa 
    	ret

screen_print_hex_d:
	pusha
	mov cx, ax
	shr eax, 16
	mov dx, ax
	call screen_print_hex_w
	mov dx, cx
	call screen_print_hex_w
	popa
	ret

screen_print_bin_w:
	pusha
	mov ax, 0x0E20
	int 0x10
	mov cx, 0x10
screen_print_bin_w_loop1:
	rol dx, 1	
	mov bx, dx
	and bx, 0x01
	cmp bx, 0x00
	jne screen_print_bin_w_skipp1
	mov ax, 0x0E30
	int 0x10
	jmp screen_print_bin_w_skipp2
screen_print_bin_w_skipp1:
	mov ax, 0x0E31
	int 0x10
screen_print_bin_w_skipp2:		
	pusha
	xor dx, dx
	mov ax, cx
	add ax, 0x03
	mov cx, 0x04
	div cx
	cmp dx, 0x00
	jne screen_print_bin_w_skipp3
	mov ax, 0x0E20
	int 0x10
screen_print_bin_w_skipp3:
	popa
	loop screen_print_bin_w_loop1	
	popa
	ret

screen_print_bin_d:
	push ax
	call screen_print_bin_w
	shr edx, 16
	call screen_print_bin_w
	pop ax
	ret

screen_print_clear:	
	pusha
	mov ax, 0xb800
	mov ds, ax
	xor di, di
screen_print_clear_loop:
	mov [di], word 0x0f00
	inc di
	inc di
	cmp di, 0xffe
	jne screen_print_clear_loop
	xor bh, bh          ;reset cursor position
	mov ah, 0x02 
	xor dx, dx 
	int 0x10
	popa
	ret

screen_print_nl:
	pusha
	mov ax, 0x0E0A
	int 0x10
	mov ax, 0x0E0D
	int 0x10
	popa
	ret

screen_print_string:
	pusha
	mov ax, cs
	mov ds, ax
screen_print_string_loop:
	mov al, [di]
	cmp al, 0xff
	je screen_print_string_done
	mov ah, 0x0E
	int 0x10
	inc di
	jmp screen_print_string_loop
screen_print_string_done:
    	popa
   	ret



debug:
	pusha 	
	push dx 
	push ax
	call screen_print_nl
	mov ax, 0x0E41
	int 0x10
	pop ax
	mov dx, ax
	call screen_print_hex_w
	call screen_print_nl
	mov ax, 0x0E42
	int 0x10
	mov dx, bx
	call screen_print_hex_w
	call screen_print_nl
	mov ax, 0x0E43
	int 0x10
	mov dx, cx
	call screen_print_hex_w
	call screen_print_nl
	pop dx
	mov ax, 0x0E44
	int 0x10
	call screen_print_hex_w
	popa
	ret


debug_bin:
	pusha 	
	push edx 
	push eax
	call screen_print_nl
	mov eax, 0x0E41
	int 0x10
	pop eax
	mov edx, eax
	call screen_print_bin_d
	call screen_print_nl
	mov eax, 0x0E42
	int 0x10
	mov edx, ebx
	call screen_print_bin_d
	call screen_print_nl
	mov eax, 0x0E43
	int 0x10
	mov edx, ecx
	call screen_print_bin_d
	call screen_print_nl
	pop edx
	mov eax, 0x0E44
	int 0x10
	call screen_print_bin_d
	popa
	ret

screen_print_carry:
	pusha
	pushf
	mov ax, 0x0E43
	int 0x10	
	mov ax, 0x0E52
	int 0x10
	mov ax, 0x0E20
	int 0x10
	popf
	jc screen_print_carry_skipp1
	mov ax, 0x0E30
	int 0x10
	jmp screen_print_carry_skipp2
screen_print_carry_skipp1:
	mov ax, 0x0E31
	int 0x10
screen_print_carry_skipp2:
	popa
	ret

screen_wait_input:
	popa
screen_wait_input_loop:
	mov ah, 0x00
	int 0x16
	pusha
	ret

screen_int_set:
	pusha
	cli
	mov dx, ds
	mov ax, 0x0000
	mov ds, ax
	mov di, 0xC8				;int * 4
	mov word [di],screen_int
	mov ax, cs
	mov word [di+2],ax
	mov ds, dx
	sti
	popa
	mov ax, 0xFEFE
	ret
	
screen_int:
	push cx
	mov cx, screen_int_exit			;setup fake function call
	push cx
	
	cmp al, 0x00
	je screen_print_clear
	cmp al, 0x01
	je screen_print_nl
	cmp al, 0x10
	je screen_print_string
	cmp al, 0x20
	je screen_print_hex_n
	cmp al, 0x21
	je screen_print_hex_b
	cmp al, 0x22	
	je screen_print_hex_w
	cmp al, 0x23
	je screen_print_hex_d
	cmp al, 0x30
	je screen_get_hex
	cmp al, 0x31
	je screen_get_hex_b
	cmp al, 0x32
	je screen_get_hex_w
	cmp al, 0x33
	je screen_get_hex_d

screen_int_exit:
	push dx
	push ax
	mov al, 0x20
	mov dx, 0x20
	out dx, al
	mov dx, 0xA0
	out dx, al
	pop ax
	pop dx

	pop cx
	iret

;screen int
;al = 00	clear
;al = 01	nl

;al = 10	print string

;al = 20 	print hex n
;al = 21	print hex b
;al = 22	print hex w
;al = 23 	print hex d

;al = 30	get hex n (ret ax)
;al = 31	get hex b (ret ax)
;al = 32	get hex w (ret ax)
;al = 33	get hex d (ret ax)

