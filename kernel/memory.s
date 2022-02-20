;find_space	eax=amount of bytes			==>			ebx=pointer to memory
;free_space	eax=pointer to memory
;table_dump	al=numbr of entrys to list
;sysvar_get	al=index of sysvar			==>			edx=val
;sysvar_set	al=index of sysvar	edx=val 
;copy		eax=start ebx=destination ecx=len
;struc_make	eax=entrysize ebx=entry			==>			ebx=table_position
;struc_get

[bits 32]
struc_make:
	push eax
	imul eax, ebx
	mov eax, ebx
	call find_space
	pop eax 
	ret

sysvar_get:
	push eax		;save eax
	and eax, 0xF		;get relevant part
	imul eax, 4		;every 4. byte is beginning
	mov edx, [eax]		;read d into edx
	pop eax			;get eax back
	ret			;return

sysvar_set:
	push eax		;save eax
	and eax, 0xF		;get relevant part
	imul eax, 4		;every 4. byte is beginning
	mov [eax], edx		;write edx into position of eax
	pop eax			;get eax back
	ret			;return

table_dump:
	call screen_nl
	pusha
	xor ecx, ecx
	inc al
table_dump_loop:
	mov dl, cl
	call screen_print_hex_b
	call screen_space
	mov ebx, ecx
	imul ebx, 16
	add ebx, TABLE
	mov edx, [ebx]
	call screen_print_hex_d
	call screen_space
	mov edx, [ebx+8]
	call screen_print_hex_d
	call screen_space
	mov ebx, TABLE_2
	add ebx, ecx
	mov dl, [ebx]
	call screen_print_hex_b
	call screen_nl
	inc edx
	add ebx, 16
	inc cl
	cmp cl, al
	jne table_dump_loop
	popa
	call screen_nl
	ret

find_space:
	cmp eax, 0				;error ot if size = 0
	je find_error_4
	push eax				;save reg
	push edx
	push ecx
	xor ecx, ecx				;reset counter
	add ebx, 8				;get offset to high part
find_space_loop_1:
	mov ebx, TABLE_2			;get pointer to TABLE_2
	add ebx, ecx				;add offset
	mov dl, [ebx]				;if used status bit is false
	and dl, 0x01
	cmp dl, 0x00
	jne find_space_skipp_1
	mov ebx, ecx				;get "id" * 16
	imul ebx, 16
	add ebx, TABLE				;add TABLE position to pointer
	mov edx, [ebx+8]
	cmp edx, 0				;if the found size is 0 then skipp
	je find_space_skipp_1
	cmp eax, edx				;compare found val to given
	je find_space_exit_1	
	jl find_space_exit_2
find_space_skipp_1:
	inc cl					;count up to 256
	jnz find_space_loop_1
	xor ecx, ecx				;reset counter
	mov ebx, TABLE				;get pointer to TABLE
find_space_loop_2:
	cmp dword [ebx+8], 0			;get size of table entry at position of pointer to 0
	jne find_space_skipp_2			;if ne skipp
	mov edx, [TABLE_HIGHEST_ENTRY]
	mov [ebx], edx 
	add edx, eax
	mov [TABLE_HIGHEST_ENTRY],edx		;<<<<<<<< TODO! CHECK IF HIGHEST ENTRY BIGGERN THEN MAX MEM THEN ERROR OUT
	jmp find_space_exit_1
find_space_skipp_2:
	add ebx, 16				;get next entry of TABLE	
	inc cl					;count up to 256 
	jnz find_space_loop_2
	call find_error_2

find_space_exit_2:
	mov edx, [ebx]				;get low part(start address)
	push edx				;save it
	mov edx, [ebx+8]			;get high part(size)
	mov [ebx+8],eax				;set high part(size) to needed val
	sub edx, eax				;calc left over free space
	push edx
	mov ebx, TABLE_2			;set used status to true
	add ebx, ecx
	or byte [ebx], 0x01
	xor ecx, ecx
	mov ebx, TABLE
find_space_exit_2_loop_1:
	cmp dword [ebx+8],0			;if entry undef ?
	jne find_space_exit_2_skipp_1		;no then skipp
	pop edx					;set size to left over size
	mov [ebx+8], edx
	pop edx					;get old start adress
	add edx, eax				;add new val
	mov [ebx], edx				;write new start addess
	mov ebx, TABLE_2			;set used status to true
	add ebx, ecx
	or byte [ebx], 0x01
	sub edx, eax				;get start position of old
	mov ebx, edx
	pop ecx					;exit
	pop edx
	pop eax
	ret	

find_space_exit_2_skipp_1:
	add ebx, 16				;set pointer to next position
	inc cl					;set counter to next position
	jnz find_space_exit_2_loop_1		;conter 0 ?
	jmp find_error_2			;yes? -> error out
		
find_space_exit_1:
	mov ebx, TABLE_2			;set pointer to status table
	add ebx, ecx				;add offset
	or byte [ebx], 0x01			;set used status bit to true
	mov ebx, ecx
	imul ebx, 16
	add ebx, TABLE
	mov [ebx+8], eax
	mov edx, [ebx]
	mov ebx, edx	
	pop ecx					;get reg back
	pop edx
	pop eax
	ret					;return

free_space:
	pusha					;save all reg
	mov ebx, TABLE				;set up tale pointer
	xor ecx, ecx				;clear counter
free_space_loop:
	mov edx, [ebx]				;get table entry
	cmp edx, eax				;is table entry given value
	je free_space_found			;if yes then exit loop
	inc cx					;inc table counter
	add ebx, 16				;inc table pointer to next table entry(next Qword)
	cmp cx, 0xff				;if table at max ?
	jne free_space_loop			;if not loop
	jmp find_error_3			;if nothing is found then error
free_space_found:
	mov ebx, TABLE_2			;get status table
	add ebx, ecx				;add offset
	and byte [ebx], 0xfe			;set used status bit to false
	popa					;get all reg back
	ret					;return

find_error_1:
	call screen_nl
	mov ebx, T_ERROR_FIND_1
	call screen_print_string
	call screen_nl
	mov edx, [TABLE_HIGHEST_ENTRY]
	call screen_print_hex_d
	call screen_nl
	mov edx, END_OF_SYSTEM
	call screen_print_hex_d
	jmp $	

find_error_2:
	mov ebx, T_ERROR_FIND_2
	call screen_nl
	call screen_print_string
	call screen_debug_hex
	jmp $

find_error_3:
	mov ebx, T_ERROR_FIND_3
	call screen_nl
	call screen_print_string
	call screen_debug_hex
	jmp $

find_error_4:
	mov ebx, T_ERROR_FIND_4
	call screen_nl
	call screen_print_string
	call screen_debug_hex	
	jmp $


copy:
	pusha
copy_loop1:
	mov dl, [eax]
	mov [ebx], dl
	inc ebx
	inc eax	
	loop copy_loop1
	popa
	ret


;--------------------------------------------------------------------------------------------------------------------------
T_ERROR_FIND_1:
	db "ERROR CAN'T FIND ENOUGH MEMORY!",0xff
T_ERROR_FIND_2:
	db "ERROR TABLE IF FULL!",0xff
T_ERROR_FIND_3:
	db "ERROR CAN'T FIND TABLE ENTRY!",0xff
T_ERROR_FIND_4:
	db "ERROR SIZE OF 0 BYTE!",0xff

SYSVAR:
	resd	256
TABLE_HIGHEST_ENTRY:
	dd	END_OF_SYSTEM
TABLE:
	resq	500		;low = start position	high = end position	---> DATA
TABLE_2:
	resb	256		;0 = not in use 1=in use default 2=table	---> STATUS
