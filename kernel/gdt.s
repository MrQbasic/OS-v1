;gdt_set       eax = Base / ebx = Limit / cl = Access Byte / ch = Flags / dx = ID  => al = Error code
;gdt_get	   ax = ID                                                             => eax = low ebx = high
;gdt_reg_set   ax = num of GDTE to use											   => al = Error code
;-------------------------------------------------------------------------------------------
gdt_set:
	push ebx
	push ecx
	push edx
	cmp dx, 0					;check if ID = 0
	je .error0
	mov [V_BASE], eax			;save eax 
	and ebx, 0x000FFFFF			;get lower 20 bits of ebx
	mov [V_LIMIT], ebx			;save ebx
	mov [V_ACB], cl				;save cl
	and ch, 0b00001111			;get lower 3 bits of ch
	mov [V_FLAGS], ch			;save ch
	;ebx is low part of GDTE
	;eax is high part of GDTE
	;LOW PART OF GDTE
	and ebx, 0xFFFF				;keep low part of ebx(bit 0-15 of LIMIT)
	shl eax, 16					;base at offset (bit 0-15 starting at bit 16)
	or ebx, eax					;and both together
	;HIGH PART OF GDTE
	mov eax, [V_BASE]			;get Base
	and eax, 0xFF0000			;get part of Base we want
	shr eax, 16					;position it at start of HIGH_PART
	shl ecx, 8					;position ACB
	or ax, cx					;add ACB and rest of HIGH_PART lower half
	and ecx, 0x00FF0000			;get only flags part of ecx
	shl ecx, 4					;position ecx
	or eax, ecx					;add Flags to rest of HIGH_PART
	mov ecx, [V_BASE]			;get BASE
	and ecx, 0xFF000000			;get relevant part of BASE
	or eax, ecx					;add part of BASE and HIGH_PART
	mov ecx, [V_LIMIT]			;get LIMIT
	and ecx, 0x000F0000			;get relevant part of LIMIT
	or eax, ecx					;and part of LIMIT and HIGH_PART
	;ENTRY PREP END
	push eax
	and edx, 0x1FFF				;get relevant part from ID
	mov eax, 8					;set len of 1 entry (8 Bytes)
	mul edx						;get OFFSET
	mov edx, eax
	pop eax
	;GET ENTRY POSITION IN RAM
	mov ecx, [GDT_BASE]			;get BASE ADDR of GDT
	add ecx, edx				;add offset
	;WRITE ENTRY
	mov [ecx], ebx				;write LOW_PART
	mov [ecx+4], eax			;write HIGH_PART
	mov al, 0					;set error to good
.exit:
	pop edx
	pop ecx
	pop ebx
	ret 
.error0:
	mov ebx, T_E_ACCESS			;print error msg
	call screen_print_string
	mov al, ACCESS_ERROR		;set error to ACCESS_ERROR
	jmp .exit


gdt_reg_set:
	cli
	push ebx
	push ecx
	push edx
	cmp ax, 0					;if num of entries is set to 0
	je .error0					;then goto error
	cmp ax, 8182				;if num of entries is set to high
	jge .error1
	and eax, 0xFFFF				;get low part of eax
	mov ecx, 8					;mul by 8
	mul ecx
	mov ebx, [GDT_BASE]			;get pointer to gdt base
	mov dword [GDTR.high], ebx	;set up GDTR (low part = GDT Base addr)
	sub eax, 1					;gdt_len -1 
	mov [GDTR.low], eax			;set up GDTR (high part = GDT lenght)

	lgdt[GDTR]					;write reg
	mov al, 0
.exit:
	pop edx
	pop ecx
	pop ebx
	sti
	ret
.error0:
	mov ebx, T_E_SIZE1			;print Error MSG
	call screen_print_string
	mov al, SIZE_ERROR			;set ERROR
	jmp .exit					;goto exit
.error1:
	mov ebx, T_E_SIZE2			;print Error MSG
	call screen_print_string
	mov al, SIZE_ERROR			;set ERROR
	jmp .exit					;goto exit
;-------------------------------------------------------------------------------------------
;Text
T_E_ACCESS:			dd "\n Access of GDT_ENTRY 0 not Possible!\e"
T_E_SIZE1:			dd "\n Can not set size of GDT to 0 entries!\e"
T_E_SIZE2:			dd "\n Can not set size of GDT to 0 entries!\e"
;CONST
GDT_BASE:			dd 0x80000800
ACCESS_ERROR equ 0x1
SIZE_ERROR equ 0x2
;Vars
V_LIMIT:			dd 0x00000000
V_BASE:				dd 0x00000000
V_ACB:				db 0x00
V_FLAGS:			db 0x00
;Struc
GDTR:
	.low:				dd 0x00000000
	.high:				dd 0x00000000