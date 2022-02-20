;pd_entry_set 		eax=entry data  ebx=entry id
;pd_entry_get 		bx=entry id				=> eax=entry data
;pageing_enable
;pageing_disable



;PD is at 0x0 so it is in a 4Kib seg
PD equ 0x80100000
PT equ 0x80110000

[bits 32]
pageing_init:
	pusha

	;PD setup
	mov eax, PT
	and ax, 0xF000
	mov [PD], eax
	mov al, 0b00100111
	mov [PD], al

	;PT setup
	mov eax, 0
	mov ebx, PT
.loop1:
	cmp eax, 0x400
	je .skipp1

	mov edx, eax
	shl edx, 12

	mov dl, 0b00000011
	and dh, 0xF0
	mov [ebx], edx

	inc eax
	add ebx, 4
	jmp .loop1
.skipp1:

	;für nen 1:1 remap geh einfach durch die PTEs und or dennen deren id * x1000 rein 
	;PTE ID id = va und PTE = pa 

	;mov eax, [PT]
	;or eax, 0x00002000
	;mov [PT], eax

	;mov eax, [PT+8]
	;or eax, 0x00002000
	;mov [PT+8], eax

.pd_on:
	mov eax, PD
	mov cr3, eax

	call pageing_enable

	popa
	ret 

pd_entry_set:
	push ebx
	and ebx, 0b1111111111		;clap val
	imul ebx, 4			;translate
	add ebx, PD			;add offset of PDTable to val	

	pusha
	mov edx, ebx
	call screen_print_hex_d
	call screen_nl	
	popa

	mov [ebx], eax
	pop ebx
	ret

pd_entry_get:
	push ebx
	and ebx, 0b1111111111		;clamp val
	imul ebx, 4			;translate
	add ebx, PD			;add offset of PDTable to val
	mov eax, [ebx]
	pop ebx
	ret

pageing_enable:
	push eax
	mov eax, cr0
	or eax, 0x80000000
	mov cr0, eax
	pop eax 
	ret

pageing_disable:
	push eax 
	mov eax, cr0
	and eax, 0x7FFFFFFF
	mov cr0, eax
	pop eax
	ret

;------------------------------------------------------------------------------------------
