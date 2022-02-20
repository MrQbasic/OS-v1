[bits 16]
pit_main:
	mov ax, 0x2E9C				;set pit to 100 hz
	call pit_set
	ret					;return

pit_set:
	pusha					;save all reg
	mov cl, al
	mov al, 0x34				;set cmd port 0x43 to 0x34
	mov dx, 0x0043				;hi-lo mode
	out dx, al
	mov dx, 0x0040				;set data port 0x40 to hi part
	mov al, ah
	out dx, al
	mov dx, 0x0040				;set data port 0x40 to lo part
	mov al, cl
	out dx, al
	popa

	cli					;dissable int
	pusha					;save all reg
	mov dx, ds				;save ds
	mov ax, 0x0000				;set ds to ivt segment
	mov ds, ax
	mov di, 0x20				;set di to irq 0
	mov word [di], pit_int			;write offset of pit_int into 0x0000:0x0020
	mov ax, cs				;write segment of pit_int into 0x0000:0x0022 
	mov word [di+2], ax
	mov ds, dx				;get ds back
	popa					;get all reg back
	sti					;enable int
	ret


;INT 20H
pit_int:
	pusha					;save all reg
	inc word [cs:PIT_V_COUNTER]		;inc counter word
	mov al, 0x20				;reset master pic
	mov dx, 0x20
	out dx, al
	mov dx, 0xA0				;reset slave pic
	out dx, al
	popa					;get all reg back
	iret					;return from int



PIT_V_COUNTER:
	dw 0x0000
