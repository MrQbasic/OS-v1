;pic_remap      eax=offset1 / ebx=offset2
[bits 32]

pic_remap:
    pushad
    push ebx
    push eax
    mov dx, PIC1_COMMAND
    mov al, 0x11
    out dx, al
    mov dx, PIC2_COMMAND
    out dx, al
    ;save marks
    in al, PIC1_DATA
    mov cl, al
    in al, PIC2_DATA
    mov ch, al
    ;starts the initialization sequence (in cascade mode)
    mov dx, PIC1_COMMAND
    mov al, (ICW1_INIT | ICW1_ICW4)
    out dx, al
    mov dx, PIC2_COMMAND
    out dx, al 
    ;ICW2: Master PIC vector offset
    mov dx, PIC1_DATA
    pop eax
    out dx, al
    ;ICW2: Slave PIC vector offset
    mov dx, PIC2_DATA
    pop eax
    out dx, al
    ;ICW3: tell Master PIC that there is a slave PIC at IRQ2 (0000 0100)
    mov dx, PIC1_DATA
    mov al, 4
    out dx, al
    ;ICW3: tell Slave PIC its cascade identity (0000 0010)
    mov dx, PIC2_DATA
    mov al, 2
    out dx, al
    ;----
    mov dx, PIC1_DATA
    mov al, ICW4_8086
    out dx, al
    ;----
    mov dx, PIC2_DATA
    out dx, al
    ;restore saved masks.
    mov dx, PIC1_DATA
    mov al, cl
    out dx, al
    ;
    mov dx, PIC2_DATA
    mov al, ch
    out dx, al

    popad
    ret

;-------------------------------------------------------------------------------------------
;Text
;Const
PIC1               equ 0x20
PIC2               equ 0xA0
PIC1_COMMAND       equ (PIC1)
PIC1_DATA          equ (PIC1+1)
PIC2_COMMAND       equ (PIC2)
PIC2_DATA          equ (PIC2+1)

ICW1_ICW4          equ 0x01
ICW1_SINGEL        equ 0x02
ICW1_INTERVAL4     equ 0x04
ICW1_LEVEL         equ 0x08
ICW1_INIT          equ 0x10

ICW4_8086          equ 0x01
ICW4_AUTO          equ 0x02
ICW4_BUF_SLAVE     equ 0x08
ICW4_BUF_MASTER    equ 0x0C
ICW4_SFNM          equ 0x10