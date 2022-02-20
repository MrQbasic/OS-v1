[bits 16]		        ; force 16 bit code for real mode
[org 0x7c00]		    ; set base address
start:
	cli                 ; no interrupts
	xor ax, ax          ; zero out
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov sp, STACK	    ; set stack address
	mov sp, bp
	jmp 0:main	        ; far jump for cs
main:
	sti			        ; set interrupts
	mov [BOOT_DRV], dl	; remember the boot device
	call clear_screen	; clear the screen
	mov ax, BOOT_MSG	; print boot msg
	call print_cstring
	call load_kernel	; actually load the system
	call KERNEL_OFFSET
	hlt			        ; halt - shouldn't execute

KERNEL_OFFSET equ 0x1000
STACK equ 0x9000

BOOT_DRV db 0

%include "./functions/print_char.asm"
%include "./functions/print_cstring.asm"
%include "./functions/clear_screen.asm"
%include "./functions/load_sectors.asm"
%include "./functions/load_kernel.asm"

BOOT_MSG: db "Booted.", 0

times 510-($-$$) db 0	; padding
dw 0xaa55		        ; bootable word
