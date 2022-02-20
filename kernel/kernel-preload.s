[org 0x1000]
[bits 16]
	mov ah, 0x01
	mov cx, 0x2607
	int 0x10

	jmp PM_enter
	jmp $
	db "THIS IS THE KERNEL MADE BY LEON"

%define PM_STACK 0x90000
PM_enter:
	cli
	lgdt[gdtrbuffer]
	mov eax, cr0
	or eax, 0x1
	mov cr0, eax	
	jmp CODE_SEG:PM_enter_2

[bits 32]
PM_enter_2:
	mov ax, DATA_SEG
	mov ds, ax
	mov ss, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ebp, PM_STACK
	mov esp, ebp

	jmp start

%include "./gdt.s"
%include "./idt.s"
%include "./screen.s"
%include "./exceptions.s"
%include "./disk.s"
%include "./pic.s"
%include "./pci.s"
;------------------------------------------------------------------------------------------------------------------------------

start:
	call screen_clear				;clear screen
	mov ebx, T_BOOTMSG				;print kernel bootmsg
	call screen_print_string

	mov eax, 0x20					;irq 0-7 to int 0x20-0x27  
	mov ebx, 0x28					;irq 8-15 to int 0x28-0x2F
	call pic_remap					;pic remap of irq
	mov ebx, T_PIC
	call screen_print_string

	call exception_init				;init exception handler

	call idt_init					;init IDT. GDT is already set up beacuse we are in PM
	mov ebx, T_IDT
	call screen_print_string
 
 
	call disk_probe_port


exit:
	jmp $

	mov ebx, T_HANDOVER
	call screen_print_string
	call KERNEL


T_BOOTMSG:			db "----KEREL BOOT----\e"
T_IDT:				db "\n IDT init\e"
T_PIC:				db "\n PIC remap\e"
T_HANDOVER:		    db "\n PERFORMING HANDOVER\e"

KERNEL equ 0x80200000

;---GDT-TO-ENTER-PM---
gdt_start:
gdt_null:
	dd 0
	dd 0
gdt_code:
	dw 0xffff
	dw 0x0000
	db 0x00
	db 10011010b
	db 11001111b
	db 0x00
gdt_data:
	dw 0xffff
	dw 0x0000
	db 0x00
	db 10010010b
	db 11001111b
	db 0x00
gdt_end:
gdtrbuffer:
	dw gdt_end - gdt_start - 1
	dd gdt_start
CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start
;---------------------------------------------------------



END_OF_SYSTEM:
