;screen_clear
;screen_print_char	dl=char
;screen_print_string	ebx=pointer to string
;screen_lineup
;screen_cursor_reset
;screen_cursor_set	dx  = position
;screen_nl
;screen_space
;screen_prompt
;screen_print_hex_n	dl  = number
;screen_print_hex_b	dl  = number
;screen_print_hex_w	dx  = number
;screen_print_hex_d	edx = number
;screen_print_bin_b	dl  = number
;screen_print_bin_w	dx  = number
;screen_print_bin_d	edx = number
;screen_debug_hex
;screen_debug_bin 
;screen_get_string	ebx = number of max chars	ebx => pointer to string
;screen_get_hex_n	dl  => number
;screen_get_hex_b	dl  => number
;screen_get_hex_w	dx  => number
;screen_get_hex_d 	edx => number
;screen_get_bin_n	dl  => number
;screen_reginfo
[bits 32]
screen_print_bin_d:
	push ax				;save ax
	mov ax, dx			;save low part
	shr edx, 16			;geht hight part
	call screen_print_bin_w		;print hight part
	call screen_space		;print space
	mov dx, ax			;get low part
	call screen_print_bin_w		;print low part
	pop ax				;get ax bacx
	ret				;return

screen_print_bin_w:
	push ax				;save ax
	mov al, dh			;save low part
	mov dl, dh			;get height part
	call screen_print_bin_b		;print hight part
	call screen_space		;print space
	mov dl, al			;get low part
	call screen_print_bin_b		;print low part
	pop ax				;get ax back
	ret				;retun

screen_print_bin_b:
	pusha				;save reg
	and edx, 0xFF			;get only relevant part of edx
	xor eax, eax			;clear eax
	mov ecx, 8			;setup loop-counter
screen_print_bin_b_loop:
	mov al, dl			;copy original
	and al, 0x01			;get lowest bit of copy
	mov ebx, BIN			;setup pointer
	add ebx, eax			;add offset(copy) to pointer
	mov ax, dx			;save original
	mov dl, [ebx]			;get char val
	call screen_print_char		;print char
	mov dx, ax			;get original back
	shr dl, 1			;shift 1 to right
	cmp cx, 5			;if cx = 5
	jne screen_print_bin_b_skipp	;if not skipp
	call screen_space		;print space
screen_print_bin_b_skipp:
	loop screen_print_bin_b_loop	;loop
	popa				;get reg back
	ret				;return

screen_print_hex_n:
	pusha				;save reg
	and edx, 0xF			;get only relevant part
	mov ebx, HEX			;load pointer to HEX
	add ebx, edx			;add input num as offset
	mov dl, [ebx]			;get char
	call screen_print_char		;print char
	popa				;get reg back
	ret				;return

screen_print_hex_b:
	pusha				;save reg
	mov al, dl			;save low part
	shr dl, 4			;get hight part
	call screen_print_hex_n		;print hight part
	mov dl, al			;get low part
	call screen_print_hex_n		;print low part
	popa				;get reg back
	ret				;return

screen_print_hex_w:
	pusha				;save reg
	mov al, dl			;save low part
	mov dl, dh			;get high part
	call screen_print_hex_b		;print height part
	mov dl, al			;get low part
	call screen_print_hex_b		;print low part
	popa				;get reg back
	ret				;return

screen_print_hex_d:
	pusha				;save reg
	mov eax, edx			;save low part
	shr edx, 16			;get hight part
	call screen_print_hex_w		;print hight part
	mov edx, eax			;get low part
	call screen_print_hex_w		;print low part
	popa				;get reg back
	ret				;return

screen_clear:
	pusha				;save all reg
	mov ebx, 0xb8000		;set ebx(pointer) to screenbuffer
screen_clear_loop:
	mov word [ebx], 0x0 		;mov 0 into [ebx](screenbuffer)
	add ebx, 2			;inc ebx to next word
	cmp ebx, [V_SCREEN_END]		;cmp pointer to V_SCREEN_END
	jle screen_clear_loop		;loop
	mov word [V_CURSOR], 0x00	;reset cursor position to 0
	popa				;get all re back
	ret				;return

screen_cursor_reset:
	pusha				;save all reg
	mov word [V_CURSOR], 0x00	;set V_CURSOR to 0
	popa				;get all reg back
	ret				;return

screen_cursor_set:
	pusha				;save all reg
	cmp dx, [V_CURSOR_MAX]		;check if you can use the val else exit
	jg screen_cursor_exit
	mov [V_CURSOR], dx		;overwrite cursor position
screen_cursor_exit:
	popa				;get al reg bakc
	ret

screen_space:
	push dx				;save dx
	mov dl, " "			;get char " "
	call screen_print_char		;print char
	pop dx				;get dx back
	ret				;return

screen_prompt:
	pusha				;save all reg
	mov ebx, T_PROMPT		;get pointer to prompt string
	call screen_print_string	;print string at pointer
	popa				;get all reg back
	ret				;return

screen_print_char:
	pusha				;save all reg
	mov ebx, 0xb8000		;set ebx to screen buffe
	inc word [V_CURSOR]		;set coursor to next postition
	mov ax, [V_CURSOR_MAX]		;load cursor_max
	cmp [V_CURSOR], ax		;if cursor > cursor max
	jle screen_print_char_skipp	;no then skipp
	call screen_lineup		;scroll 1 line up
screen_print_char_skipp:
	add bx, word [V_CURSOR]		;add cursor offset to screenpointer + screenpointer = screenpointer * 2
	add bx, word [V_CURSOR]
	sub bx, 2			;screenpointer - 2
	mov dh, [C_DEFAULT]		;set default color
	mov[ebx], dx			;write color+char to screenpointer
	popa				;get all reg back
	ret

screen_print_string:
	pusha				;save all reg
screen_print_string_loop:	
	mov dl, [ebx]			;get char
	cmp dl, "\"			;if not cmd then skipp
	jne screen_print_string_skipp1	
	inc ebx				;get next char
	mov dl, [ebx]			
	cmp dl, "e"			;if e then exit	
	je screen_print_string_exit	
	cmp dl, "n"			;if n then new line
	jne screen_print_string_skipp2
	call screen_nl
screen_print_string_skipp2:
	
	;other cmds here

	inc ebx				;set pointer to next char
	jmp screen_print_string_loop	;goto loop start
screen_print_string_skipp1:
	call screen_print_char		;print char
	inc ebx				;inc pointer to next char
	jmp screen_print_string_loop	;loop
screen_print_string_exit:
	popa				;get all erg back
	ret				;return

screen_nl:
	pusha				;save all reg
	xor dx, dx			;set dx to 0
	mov ax, [V_CURSOR]		;set ax to V_CURSOR
	mov cx, [V_SCREEN_W]		;set cx to V_SCREEN_W
	div cx				;div dx-ax by cx 
	sub [V_CURSOR], dx		;sub remainder from V_CURSOR to ret to start of line
	add [V_CURSOR], cx		;add cx(V_SCREEN_W = 1LINE) to V_CURSOR to get to next line
	popa				;get all reg back
	ret				;return
	
screen_lineup:
	pusha
	mov eax, 0xb8000		;set pointer 1 to screenbuffer
	mov ebx, 0xb8000		;set pointer 2 to screenbuffer
	add ebx, [V_SCREEN_W]		;add V_SCREEN_W to pointer 2
	add ebx, [V_SCREEN_W]		;add V_SCREEN_W to pointer 2	=  add V_SCREEN * 2 to pointer 2
screen_lineup_loop:
	mov ecx, [ebx]			;copy val at pointer 2 to pointer 1
	mov [eax], ecx
	add eax, 2			;next word pointer 1
	add ebx, 2			;next word pointer 2
	cmp ebx, [V_SCREEN_END]		;end ?
	jle screen_lineup_loop		;no -> loop yes -> go on
	mov ax, [V_SCREEN_W]		;sub 1 Line from V_CURSOR
	sub [V_CURSOR], ax
	popa
	ret

screen_debug_hex:
	pusha
	push edx
	push ebx
	mov ebx, T_REG_A
	call screen_print_string
	mov edx, eax	
	call screen_print_hex_d
	mov ebx, T_REG_B
	call screen_print_string
	pop ebx
	mov edx, ebx
	call screen_print_hex_d
	mov ebx, T_REG_C
	call screen_print_string
	mov edx, ecx
	call screen_print_hex_d
	mov ebx, T_REG_D
	call screen_print_string
	pop edx
	call screen_print_hex_d
	call screen_nl
	popa
	ret

screen_debug_bin:
	pusha
	push edx
	push ebx
	mov ebx, T_REG_A
	call screen_print_string
	mov edx, eax	
	call screen_print_bin_d
	mov ebx, T_REG_B
	call screen_print_string
	pop ebx
	mov edx, ebx
	call screen_print_bin_d
	mov ebx, T_REG_C
	call screen_print_string
	mov edx, ecx
	call screen_print_bin_d
	mov ebx, T_REG_D
	call screen_print_string
	pop edx
	call screen_print_bin_d
	call screen_nl
	popa
	ret

screen_reginfo:
	pushad
	call screen_debug_hex
	mov ebx, T_REG_EBP
	call screen_print_string
	mov edx, ebp
	call screen_print_hex_d
	mov ebx, T_REG_ESP 
	call screen_print_string
	mov edx, esp
	call screen_print_hex_d
	popad
	ret

screen_get_string:
	push edx		
	push ecx
	push eax
	mov [V_MAX_LEN], ebx
	mov ebx, T_PROMPT
	call screen_print_string
	xor ecx, ecx
	mov eax, eax
screen_get_string_loop1:
	push ebx
	push ecx
	xor ecx, ecx
screen_get_string_loop2:
	mov ecx, eax
	xor eax, eax
	in al, 0x60
	cmp eax, ecx
	je screen_get_string_loop2
	mov ebx, SCAN
	add ebx, eax
	cmp byte [V_SHIFT], 0x00
	je screen_get_string_skipp3
	add ebx, 77
screen_get_string_skipp3:
	mov dl, [ebx]
	pop ecx
	pop ebx

	cmp eax, 0x2A				;if scancode = Shift 1 down then
	je screen_get_string_skipp5		;goto shift down
	cmp eax, 0x36				;if scancode = Shift 2 down then
	je screen_get_string_skipp5		;goto shift down
	cmp eax, 0xB6				;if scancode = Shift 1 up then
	je screen_get_string_skipp6		;goto shift up
	cmp eax, 0xAA				;if scancode = Shift 2 up then
	je screen_get_string_skipp6		;goto shift up
	jmp screen_get_string_skipp4		;skipp if no shift down
screen_get_string_skipp5:			;shift down:
	or byte [V_SHIFT], 0xff			;set shift flag to not 0
	jmp screen_get_string_loop1		;loop to start
screen_get_string_skipp6:			;shift up:
	mov byte [V_SHIFT], 0x00		;set shift flag to 0
	jmp screen_get_string_loop1		;loopto start
screen_get_string_skipp4:
	cmp eax, 0x80				;ignore key up scanncodes
	jg screen_get_string_loop1		;loop back to start
	cmp eax, 0x1C				;if scancode is not enter then
	jne screen_get_string_skipp2		;skipp
	jmp screen_get_string_exit		;else exit
screen_get_string_skipp2:
	cmp al, 0x0E				;if scancode is not backspace then
	jne screen_get_string_skipp1		;skipp
	cmp ecx, 0				;if pointer is on char nr 0
	je screen_get_string_loop1		;loop to start (dont go more back then start)
	dec word [V_CURSOR]			;set Cursor 1 back
	mov dl, " "				;write a blank
	call screen_print_char
	dec word [V_CURSOR]			;set cursor one back
	dec ecx					;set pointer one back
	jmp screen_get_string_loop1		;goto start
screen_get_string_skipp1:
	cmp ecx, [V_MAX_LEN]			;if pointer = max len then
	je screen_get_string_loop1		;loop to start
	inc ecx					;if no backspace & not max len then set pointer +1
	push ebx				;save ebx
	mov ebx, T_BUFFER			;set ebx to the buuffer location
	add ebx, ecx				;add pointer as offset
	dec ebx
	mov [ebx], dl
	pop ebx					;get ebx back
	call screen_print_char			;print char
	jmp screen_get_string_loop1		;loop to start
screen_get_string_exit:
	mov ebx, T_BUFFER			;get pointer to buffer position
	add ebx, ecx				;add offset to pointer
	mov byte [ebx], "\"			;write "\" at pointer
	inc ebx					;add 1 to pointer
	mov byte [ebx], "e" 			;write "e" at pointer
	add ecx, 2				;add 2 to counter (String terminator)
	mov eax, ecx				;set up to find free space 
	;call find_space				;find free space in data storage ebx = pointer to new location
	mov eax, T_BUFFER
	;call copy				TODO <------------------------------------------------------------------------------<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	pop eax					;get eax back
	pop ecx					;get ecx back
	pop edx					;get edx back
	ret					;return

screen_get_hex_n:
	push eax				;save reg to stack
	push ebx
	push ecx
	xor bx, bx				;set b to 0
screen_get_hex_n_loop:
	mov bl, al				;save old al to bl
	in al, 0x60				;get new scancode into al
	cmp al, bl				;if oldscancode = newscancode then
	je screen_get_hex_n_loop		;loop to start
	cmp al, 0x02				;if scancode is < 1 then
	jl screen_get_hex_n_skipp1		;skipp
	cmp al, 0x0A				;if scancode is > 9 then
	jg screen_get_hex_n_skipp1		;skipp
	dec al					;dec so scancode mapps to real number between 1 and 9
	jmp screen_get_hex_n_exit		;exit
screen_get_hex_n_skipp1:
	cmp al, 0x0B				;if scancode is not 0 then
	jne screen_get_hex_n_skipp2		;skipp
	mov al, 0x00				;else set al to 0
	jmp screen_get_hex_n_exit		;exit
screen_get_hex_n_skipp2:
	cmp al, 0x1E				;0x0A
	jne screen_get_hex_n_skipp3
	mov al, 0x0A
	jmp screen_get_hex_n_exit
screen_get_hex_n_skipp3:
	cmp al, 0x30				;0x0B
	jne screen_get_hex_n_skipp4
	mov al, 0x0B
	jmp screen_get_hex_n_exit
screen_get_hex_n_skipp4:
	cmp al, 0x2E				;0x0C	
	jne screen_get_hex_n_skipp5
	mov al, 0x0C
	jmp screen_get_hex_n_exit
screen_get_hex_n_skipp5:
	cmp al, 0x20				;0x0D
	jne screen_get_hex_n_skipp6
	mov al, 0x0D
	jmp screen_get_hex_n_exit
screen_get_hex_n_skipp6:
	cmp al, 0x12				;0x0E
	jne screen_get_hex_n_skipp7
	mov al, 0x0E
	jmp screen_get_hex_n_exit
screen_get_hex_n_skipp7:
	cmp al, 0x21				;0x0F
	jne screen_get_hex_n_skipp8
	mov al, 0x0F
	jmp screen_get_hex_n_exit
screen_get_hex_n_skipp8:
	jmp screen_get_hex_n_loop		;if nothing is matching was found loop pack to start

screen_get_hex_n_exit:
	mov dl, al				;mov dl, al
	call screen_print_hex_n			;print number	
	xor ax, ax				;set ax to 0
screen_get_hex_n_loop1:
	in al, 0x60				;get new scancode
	cmp ax, 0x80				;if scancode < 0x80 then
	jl screen_get_hex_n_loop1		;loo
	pop ecx					;get reg back
	pop ebx
	pop eax
	ret					;return

screen_get_hex_b:
	push eax				;save eax
	call screen_get_hex_n			;get hight part
	shl dl, 4				;shift to hight offset
	mov al, dl				;store hight part
	call screen_get_hex_n			;get low part
	or dl, al				;or low and hight part together
	pop eax					;get eax back
	ret					;return

screen_get_hex_w:
	call screen_get_hex_b			;get byte into low part
	mov dh, dl				;make low part to high part
	call screen_get_hex_b			;get byte into low part
	ret					;return

screen_get_hex_d:
	call screen_get_hex_w			;get word
	shl edx, 16				;shift wort from low to hight part
	call screen_get_hex_w			;get word
	ret					;return

screen_get_bin_n:
	push eax
	push ebx
	push ecx



screen_get_bin_loop1:
	mov ebx, T_BIN
	call screen_print_string
	mov ebx, 4
	call screen_get_string

	call screen_nl
	xor edx, edx				;set d to 0
screen_get_bin_loop2:
	;shr edx, 1	

	or edx, 1	

	pusha
	mov dl, [ebx]
	call screen_print_char
	call screen_nl
	popa

	cmp byte [ebx], "0"
	je screen_get_bin_next_char

	cmp byte [ebx], "\"			;if command that means \e then
	je screen_get_bin_exit			;exit

	jmp screen_get_bin_loop1		;if no matching char found repeat input

screen_get_bin_next_char:
	inc ebx
	jmp screen_get_bin_loop2

screen_get_bin_exit:
	pop ecx
	pop ebx
	pop eax
	ret


T_BUFFER:		db "                                                                           "
T_REG_A:		db "\nA: \e"
T_REG_B:		db "  B: \e"
T_REG_C:		db "  C: \e"
T_REG_D:		db "  D: \e"
T_REG_EBP:		db "EBP: \e"
T_REG_ESP:		db "  ESP: \e"
T_PROMPT:		db "\n->> \e"
T_BIN:			db "\n0b\e"
C_DEFAULT:		db 0x07
V_CURSOR:		dw 0x0000
V_CURSOR_MAX:	dw 0x7D0 - 80
V_SCREEN_W:		dd 80
V_SCREEN_END:	dd 0xb8FFF
V_SHIFT:		db 0x00
V_MAX_LEN:		dd 0x0
HEX:			db "0123456789ABCDEF"
BIN:			db "01"
SCAN:			db " -1234567890ß´qwertzuiopü+-asdfghjklöä#yxcvbnm,.-012 3          DEFGHIJK"
				db " -!2§$%&/()=?  QWERTZUIOPÜ*-ASDFGHJKLÖÄ'YXCVBNM;:_012 3          DEFGHIJK"
