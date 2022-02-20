;exception_init
[bits 32]

exception_init:
    pusha
    ;initial setup
    xor eax, eax
    mov ah, 0x8E                    ;setup Gate descriptop(INT32)
    mov cx, CODE_SEG                ;setup segment
    ;setup all IDTE
    mov al, 0
    mov ebx, exception_isr_0
    call idt_set_isr
    mov al, 1
    mov ebx, exception_isr_1
    call idt_set_isr
    mov al, 3
    mov ebx, exception_isr_3
    call idt_set_isr
    mov al, 4
    mov ebx, exception_isr_4
    call idt_set_isr
    mov al, 5
    mov ebx, exception_isr_5
    call idt_set_isr
    mov al, 6
    mov ebx, exception_isr_6
    call idt_set_isr
    mov al, 7
    mov ebx, exception_isr_7
    call idt_set_isr
    mov al, 8
    mov ebx, exception_isr_8
    call idt_set_isr
    mov al, 10
    mov ebx, exception_isr_10
    call idt_set_isr
    mov al, 11
    mov ebx, exception_isr_11
    call idt_set_isr
    mov al, 12
    mov ebx, exception_isr_12
    call idt_set_isr
    mov al, 13
    mov ebx, exception_isr_13
    call idt_set_isr
    mov al, 14
    mov ebx, exception_isr_14
    call idt_set_isr
    mov al, 16
    mov ebx, exception_isr_16
    call idt_set_isr
    mov al, 17
    mov ebx, exception_isr_17
    call idt_set_isr
    mov al, 18
    mov ebx, exception_isr_18
    call idt_set_isr
    mov al, 19
    mov ebx, exception_isr_19
    call idt_set_isr
    mov al, 20
    mov ebx, exception_isr_20
    call idt_set_isr
    mov al, 21
    mov ebx, exception_isr_21
    call idt_set_isr
    mov al, 28
    mov ebx, exception_isr_28
    call idt_set_isr
    mov al, 29
    mov ebx, exception_isr_29
    call idt_set_isr
    mov al, 30
    mov ebx, exception_isr_30
    call idt_set_isr
    popa 
    ret


exception_isr_0:
    pusha
    mov ebx, T_E_0
    call screen_print_string
    jmp isr_exit

exception_isr_1:
    pusha
    mov ebx, T_E_1
    call screen_print_string
    jmp isr_exit

exception_isr_3:
    pusha
    mov ebx, T_E_3
    call screen_print_string
    jmp isr_exit

exception_isr_4:
    pusha
    mov ebx, T_E_4
    call screen_print_string
    jmp isr_exit

exception_isr_5:
    pusha
    mov ebx, T_E_5
    call screen_print_string
    jmp isr_exit

exception_isr_6:
    pusha
    mov ebx, T_E_6
    call screen_print_string
    jmp isr_exit

exception_isr_7:
    pusha
    mov ebx, T_E_7
    call screen_print_string
    jmp isr_exit

exception_isr_8:
    pusha
    mov ebx, T_E_8
    call screen_print_string
    jmp isr_exit

exception_isr_10:
    pusha
    mov ebx, T_E_10
    call screen_print_string
    jmp isr_exit

exception_isr_11:
    pusha
    mov ebx, T_E_11
    call screen_print_string
    jmp isr_exit

exception_isr_12:
    pusha
    mov ebx, T_E_12
    call screen_print_string
    jmp isr_exit

exception_isr_13:
    pusha
    mov ebx, T_E_13
    call screen_print_string
    jmp isr_exit

exception_isr_14:
    pusha
    mov ebx, T_E_14
    call screen_print_string
    jmp isr_exit

exception_isr_16:
    pusha
    mov ebx, T_E_16
    call screen_print_string
    jmp isr_exit

exception_isr_17:
    pusha
    mov ebx, T_E_17
    call screen_print_string
    jmp isr_exit

exception_isr_18:
    pusha
    mov ebx, T_E_18
    call screen_print_string
    jmp isr_exit

exception_isr_19:
    pusha
    mov ebx, T_E_19
    call screen_print_string
    jmp isr_exit

exception_isr_20:
    pusha
    mov ebx, T_E_20
    call screen_print_string
    jmp isr_exit

exception_isr_21:
    pusha
    mov ebx, T_E_21
    call screen_print_string
    jmp isr_exit

exception_isr_28:
    pusha
    mov ebx, T_E_28
    call screen_print_string
    jmp isr_exit

exception_isr_29:
    pusha
    mov ebx, T_E_29
    call screen_print_string
    jmp isr_exit

exception_isr_30:
    pusha
    mov ebx, T_E_30
    call screen_print_string
    jmp isr_exit


isr_exit:
	popa
    mov ebx, T_CAUSE
    call screen_print_string
    pop edx
    call screen_print_hex_d

    jmp $

;-------------------------------------------------------------------------------------------
;Text
T_E_0:          db "\nERROR-> Divide by zero\e"
T_E_1:          db "\nERROR-> Debug\e"
T_E_3:          db "\nERROR-> Breakpoint\e"
T_E_4:          db "\nERROR-> Overflow\e"
T_E_5:          db "\nERROR-> Bound Range Exceeded\e"
T_E_6:          db "\nERROR-> Invalid Opcode\e"
T_E_7:          db "\nERROR-> Device Not Available"
T_E_8:          db "\nERROR-> Double Fault\e"
T_E_10:         db "\nERROR-> Invalid TSS\e"
T_E_11:         db "\nERROR-> Segment Not Present\e"
T_E_12:         db "\nERROR-> Stack-Segment Fault\e"
T_E_13:         db "\nERROR-> General Protection Fault\e"
T_E_14:         db "\nERROR-> Page Fault\e"
T_E_16:         db "\nERROR-> x87 Floating-Point Exception\e"
T_E_17:         db "\nERROR-> Alignment Check\e"
T_E_18:         db "\nERROR-> Machine Check\e"
T_E_19:         db "\nERROR-> SIMD Floating-Point Exception\e"
T_E_20:         db "\nERROR-> Virtualization Exception\e"
T_E_21:         db "\nERROR-> Control Protection Exception\e"
T_E_28:         db "\nERROR-> Hypervisor Injection Exception\e"
T_E_29:         db "\nERROR-> VMM Communication Exception\e"
T_E_30:         db "\nERROR-> Security Exception\e"

T_CAUSE:      db "\nCaused by: \e"