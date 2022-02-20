[bits 16]
sound_main:
	mov ax, cs				;set ds, ss to mem location of your music data (cs)			
	mov ds, ax
	mov ss, ax
	
	mov di, NOTE				;set di, si to mem location of your music data (SND_NV, SND_NT)  
	mov si, SND_NT
	
	
	call string_len
	mov bx, ax				;set counter (8)

	mov di, NOTE 
	call screen_print_string


snd_loop:					;loop 
	mov cl, [ds:di]				;get sound feq and calcs io port val	

	mov dl, cl
	call screen_print_hex_b
	call screen_print_nl
	
	cmp cl, 0x43	
	jne snd_C
	mov cx, 164
	jmp snd_skipp1
snd_C:
	cmp cl, 0x44
	jne snd_D
	mov cx, 296
	jmp snd_skipp1
snd_D:
	cmp cl, 0x45
	jne snd_E
	mov cx, 330
	jmp snd_skipp1
snd_E:
	cmp cl, 0x46
	jne snd_F
	mov cx, 352
	jmp snd_skipp1
snd_F:
	cmp cl, 0x47
	jne snd_G
	mov cx, 396
	jmp snd_skipp1
snd_G:
	cmp cl, 0x41
	jne snd_A
	mov cx, 440
	jmp snd_skipp1
snd_A:
	cmp cl, 0x48
	jne snd_H
	mov cx, 495
	jmp snd_skipp1
snd_H:
	mov cx, 0xffff
snd_skipp1:

	mov [cs:SND_V_TMP], cx			;io port val = 0x001234DC / hz
	fild dword [cs:SND_V_PIT]
	fidiv dword [cs:SND_V_TMP]
	fistp dword [cs:SND_V_TMP]	
	
	mov dx, 0x0043				;set up dataport to 
	mov al, 0xb6				;serial interface lo-hi
	out dx, al
	
	mov eax, [cs:SND_V_TMP]			;get io port val
	mov dx, 0x0042				
	out dx, al				;set io port 0x42 to io port val
	shr eax, 8
	out dx, al				;set io port 0x42 to io port val >> 8

	mov dx, 0x0061				;get byte io 0x61 
	in al, dx
	or al, 0x03				;al = al | 0x03
	out dx, al				;set byte io 0x61

	mov ax, [ss:si]				;set lenght of sound and wait
	call sys_delay				;kernel function

	add di, 1				;inc pointer to note val
	add si, 2				;inc pointer to note len
	dec bx					;dec counter
	jnz snd_loop				;counter = 0 ==> exit loop

	call snd_mute				;no sound 
	call screen_print_nl
	ret					;exit

snd_mute:
	pusha					;save all reg
	mov dx, 0x0061				;get io 0x61 (byte)
	in al, dx
	and al, 0xFC				;al = al & 0xFC
	out dx, al				;send io 0x61 (byte)
	popa					;restore all reg
	ret					;return 

SND_V_PIT:		dd 0x001234DC		;pit frq 	
SND_V_TMP:		dd 0x00000000		;tem var

;C 164
;D 296
;E 330
;F 352
;G 396
;A 440
;H 495
;C 528


NOTE:
	db "DEFGAAHHHHA HHHHA GGGGFFAAAAD",0xff	
SND_NT:						;in ms
	dw 0x0016
	dw 0x0016
	dw 0x0016
	dw 0x0016
	dw 0x0032
	dw 0x0032

	dw 0x0016
	dw 0x0016
	dw 0x0016
	dw 0x0016
	dw 0x0032
	dw 0x0032

	dw 0x0016
	dw 0x0016
	dw 0x0016
	dw 0x0016
	dw 0x0032
	dw 0x0032

	dw 0x0016
	dw 0x0016
	dw 0x0016
	dw 0x0016
	dw 0x0032
	dw 0x0032
	
	dw 0x0016
	dw 0x0016
	dw 0x0016
	dw 0x0016
	dw 0x0032
	
