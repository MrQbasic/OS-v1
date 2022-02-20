;string_cmp:	str1= ds:di	str2= ss:si
;char_cmp:	char1=al	char2=bl	out=cl		0:eq		FF:neq

[bits 16]
string_main:
	pusha
	mov ax, cx
	mov ds, ax
	mov ss, ax

	mov di, STRING1
	call screen_get_string
	call screen_print_nl
	mov di, STRING2
	call screen_get_string
	call screen_print_nl

	mov di, STRING1
	mov si, STRING2

	call string_cmp
		
	jne string_skipp1
		mov di, T_TRUE
		call screen_print_string
		jmp string_skipp2
	string_skipp1:
		mov di, T_FALSE
		call screen_print_string
	string_skipp2:

	call screen_print_nl	
	popa
	ret


string_len:
	push di
	push bx
	xor ax, ax
string_len_loop:
	mov bl, [ds:di]
	inc di
	inc al
	cmp bl, 0xff
	jne string_len_loop
	pop bx
	pop di
	dec al
	ret

string_cmp:
	pusha
	mov cl, 0x00
	push di
	push si
	call string_len			;get len of string di
	mov bl, al	
	mov di, si
	call string_len			;get len of string si
	cmp al, bl			;cmp len of strings
	jne string_cmp_exit_len		;if not eq exit
	pop si
	pop di
string_cmp_loop1:
	mov al, [ds:di]			;load chars
	mov bl, [ss:si]
	cmp al, 0xff			;check if char al is endmarker
	je string_cmp_exit		;exit
	cmp bl, 0xff			;check if char bl is endmarker
	je string_cmp_exit		;exit
	cmp al, bl			;cmp chars
	jne string_cmp_exit		;exit
	inc di				;inc charpointer di
	inc si				;inc charpointer si
	jmp string_cmp_loop1		;loop
string_cmp_exit_len:
	pop si
	pop di
string_cmp_exit:
	popa
	ret


STRING1:
	db "HALLO",0xff,"                                  "

STRING2:
	db "HALLO",0xff,"                                  "


T_TRUE:		db "TRUE",0xff
T_FALSE:	db "FALSE",0xff
