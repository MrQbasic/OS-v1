;idt_init

[bits 32]

idt_init:
	cli
	pusha
	mov al, 0x20					;set up to set the default isr
	mov ah, 0x8E
	mov ebx, isr_default
	mov cx, CODE_SEG
idt_init_loop:
	call idt_set_isr
	inc al
	cmp al, 0xFF				;loop 0xff entrys
	jne idt_init_loop
	mov al, 0x20
	mov ebx, isr_timer
	call idt_set_isr
	lidt[idtr]					;load idt register
	popa
	sti
	ret

idt_set_isr:
	pusha
	push eax
	mov edx, IDT_START			;calc IDT_Entry position
	and eax, 0xFF
	imul eax, 8
	add edx, eax
	pop eax
	mov [edx], bx				;set isr position low
	shr ebx, 16
	mov [edx+6], bx				;set isr position high
	mov [edx+2], cx				;set segment
	mov [edx+5], ah				;set gate type
	popa
	ret


;------------------------------------------------------------------------------------------
IDT_START equ 0x80000000
IDT_END equ 0x800007FF
idtr:					;idr register calc
	dw IDT_END - IDT_START
	dd IDT_START


T_INT: db " INT! \n\e"
isr_default:
	pushad
	mov ebx, T_INT
	call screen_print_string
	mov al, 0x20
    out 0x20, al
	popad
	iretd	

isr_timer:
	pusha

	inc byte [V_COUNTER]
	mov al, [V_COUNTER]
	shl al, 4
	mov bl, [0xB809F]
	and bl, 0x0F
	or al, bl
	mov [0xB809F], al
	mov al, 0x20
    out 0x20, al
	popa
	sti
	iret

V_COUNTER: db 0x0