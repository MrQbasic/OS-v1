;gr_line(
;	ax = x1
;	bx = y1
;	cx = x2
;	dx = y2
;		)
;
;gr_dot(
;	ax = x
;	bx = y
;	cl = color
;		)
;gr_clear()
;gr_tri()



name:   db "GRAPICSLIB"
[bits 16]
grapics_main:
	mov ax, cs		;setup segment reg
	mov ds, ax	

	mov ax, 0x0013		;set screen mode
	int 0x10

	mov ax, 0x0017		;start pos x
	mov bx, 0x0013		;start pos y
	mov cx, 0x0000		;end pos x
	mov dx, 0x0000		;end pos y
gr_loop:

	push ax			;delay 200 ms
	mov ax, 20
	call sys_delay
	pop ax

	call gr_line

	inc word[cs:gr_line_color]

	add cx, 0x0f
	cmp cx, 0x3C
	jle gr_loop
	mov cx, 0x0000
	add dx, 0x0f
	cmp dx, 0x3C
	jle gr_loop
	mov dx, 0x0000	
	call gr_line
	
	mov ax, 100		;delay 1s = 1000ms
	call sys_delay
	call gr_clear

	call gr_tri
	
	mov ax, 100
	call sys_delay
	call gr_clear
	ret


gr_dot:
	pusha
	mov dx, ds
	mov di, 0xa000
	mov ds, di
	mov di, ax
	push cx
	mov cx, [cs:gr_screen_w]
	imul bx, cx
	pop cx
	add di, bx
	mov [di], cl
	mov ds, dx
	popa
	ret	

gr_line:
	pusha	
	mov word  [cs:gr_line_x1], ax
	mov word [cs:gr_line_y1], bx
	mov word [cs:gr_line_x2], cx
	mov word [cs:gr_line_y2], dx
	fild word [cs:gr_line_x2]		;dx = x2 - x1
	fisub word [cs:gr_line_x1]
	fist word [cs:gr_line_dx]
	fabs					;dx1 = abs(dx)
	fistp word [cs:gr_line_dx1]
	fild word [cs:gr_line_y2]		;dy = y2 - y1
	fisub word [cs:gr_line_y1]
	fist word [cs:gr_line_dy]
	fabs					;dy1 = abs(dy)
	fistp word [cs:gr_line_dy1]
	fild word [cs:gr_line_dy1]		;px = 2 * dy1 - dx1
	fiadd word [cs:gr_line_dy1]
	fisub word [cs:gr_line_dx1]
	fistp word [cs:gr_line_px]
	fild word [cs:gr_line_dx1]		;py = 2 * dx1 - dy1
	fiadd word [cs:gr_line_dx1]
	fisub word [cs:gr_line_dy1]
	fistp word [cs:gr_line_py]
	mov ax, word [cs:gr_line_dy1]		;cmp dy1, dx1
	mov bx, word [cs:gr_line_dx1]
	cmp ax, bx	
	jg gr_line_skipp
	mov ax, word [cs:gr_line_dx]		;cmp dx, 0x0000
	cmp ax, 0x0000
	jl gr_line_skipp1_1
	mov ax, [cs:gr_line_x1]			;x = x1
	mov bx, [cs:gr_line_y1]			;y = y1
	mov cx, [cs:gr_line_x2]			;xe = x2
	jmp gr_line_skipp1_2			
gr_line_skipp1_1:				;else
	mov ax, [cs:gr_line_x2]			;x = x2
	mov bx, [cs:gr_line_y2]			;y = y2
	mov cx, [cs:gr_line_x1]			;xe = x1
gr_line_skipp1_2:	
	mov [cs:gr_line_x], ax
	mov [cs:gr_line_y], bx	
	mov [cs:gr_line_xe], cx
	mov cl, [cs:gr_line_color]		;Dot(x,y,gr_line_color)
	call gr_dot
gr_line_loop1:					;loop x < xe | x++
	inc word [cs:gr_line_x]
	mov ax, [cs:gr_line_px]			;cmp px, 0
	cmp ax, 0x0000
	jge gr_line_skipp2_1
	mov ax, [cs:gr_line_dy1]		;px = dy1 + dy1 + px
	add ax, [cs:gr_line_dy1]
	add ax, [cs:gr_line_px]
	mov [cs:gr_line_px], ax
	jmp gr_line_skipp2_2			;else
gr_line_skipp2_1:
	mov ax,	[cs:gr_line_dx]
	mov bx, [cs:gr_line_dy]
	cmp ax, 0x0000
	jge gr_line_skipp3_1
	cmp bx, 0x0000
	jge gr_line_skipp3_1	
	jmp gr_line_skipp3_2
gr_line_skipp3_1:
	cmp ax, 0x0000
	jle gr_line_skipp3_3
	cmp bx, 0x0000
	jle gr_line_skipp3_3
gr_line_skipp3_2:
	inc word [cs:gr_line_y]
	jmp gr_line_skipp3_4
gr_line_skipp3_3:
	dec word [cs:gr_line_y]
gr_line_skipp3_4:
	mov ax, [cs:gr_line_dy1]
	sub ax, [cs:gr_line_dx1]
	imul ax, 2
	add ax, [cs:gr_line_px]
	mov [cs:gr_line_px], ax
gr_line_skipp2_2:
	mov ax, [cs:gr_line_x]
	mov bx, [cs:gr_line_y]
	mov cl, [cs:gr_line_color]
	call gr_dot
	mov ax, [cs:gr_line_x]
	mov bx, [cs:gr_line_xe]
	cmp ax, bx
	jl gr_line_loop1
	jmp gr_line_end
gr_line_skipp:	
	mov ax, word [cs:gr_line_dy]		;cmp dy, 0x0000
	cmp ax, 0x0000
	jl gr_line_skipp4_1
	mov ax, [cs:gr_line_x1]			;x = x1
	mov bx, [cs:gr_line_y1]			;y = y1
	mov cx, [cs:gr_line_y2]			;xe = x2
	jmp gr_line_skipp4_2			
gr_line_skipp4_1:				;else
	mov ax, [cs:gr_line_x2]			;x = x2
	mov bx, [cs:gr_line_y2]			;y = y2
	mov cx, [cs:gr_line_y1]			;xe = x1
gr_line_skipp4_2:	
	mov [cs:gr_line_x], ax
	mov [cs:gr_line_y], bx	
	mov [cs:gr_line_ye], cx
	mov cl, [cs:gr_line_color]		;Dot(x,y,gr_line_color)
	call gr_dot
gr_line_loop2:					;loop x < xe | x++
	inc word [cs:gr_line_y]			;inc y
	mov ax, [cs:gr_line_py]			;cmp px, 0
	cmp ax, 0x0000
	jge gr_line_skipp5_1
	mov ax, [cs:gr_line_dx1]		;px = dy1 + dy1 + px
	add ax, [cs:gr_line_dx1]
	add ax, [cs:gr_line_py]
	mov [cs:gr_line_py], ax
	jmp gr_line_skipp5_2			;else
gr_line_skipp5_1:
	mov ax,	[cs:gr_line_dx]
	mov bx, [cs:gr_line_dy]
	cmp ax, 0x0000
	jge gr_line_skipp6_1
	cmp bx, 0x0000
	jge gr_line_skipp6_1	
	jmp gr_line_skipp6_2
gr_line_skipp6_1:
	cmp ax, 0x0000
	jle gr_line_skipp6_3
	cmp bx, 0x0000
	jle gr_line_skipp6_3
gr_line_skipp6_2:
	inc word [cs:gr_line_x]
	jmp gr_line_skipp6_4
gr_line_skipp6_3:
	dec word [cs:gr_line_x]
gr_line_skipp6_4:
	mov ax, [cs:gr_line_dx1]
	sub ax, [cs:gr_line_dy1]
	imul ax, 2
	add ax, [cs:gr_line_py]
	mov [cs:gr_line_py], ax
gr_line_skipp5_2:
	mov ax, [cs:gr_line_x]
	mov bx, [cs:gr_line_y]
	mov cl, [cs:gr_line_color]
	call gr_dot
	mov ax, [cs:gr_line_y]
	mov bx, [cs:gr_line_ye]
	cmp ax, bx
	jl gr_line_loop2
gr_line_end:
	popa
	ret


gr_clear:
	pusha			;save all reg
	mov dx, ds		;save ds to dx
	mov ax, 0xa000		;make ds a000
	mov ds, ax
	mov di, 0x0000		;set di to 0
gr_clear_loop:
	mov byte [ds:di], 0x00	;write 0
	inc di			;inc pointer
	cmp di, 0xffff		;jmp if not ffff
	jne gr_clear_loop	
	mov ds, dx		;get ds back
	popa			;get all reg back
	ret			;return





gr_line_x:		dw 0x0000
gr_line_y:		dw 0x0000
gr_line_x1:		dw 0x0000
gr_line_x2:		dw 0x0000
gr_line_y1:		dw 0x0000
gr_line_y2:		dw 0x0000
gr_line_dx:		dw 0x0000
gr_line_dy:		dw 0x0000
gr_line_dx1:		dw 0x0000
gr_line_dy1:		dw 0x0000
gr_line_px:		dw 0x0000
gr_line_py:		dw 0x0000
gr_line_xe:		dw 0x0000
gr_line_ye:		dw 0x0000
gr_line_color:		db 0x01



gr_tri:
	pusha
	mov al, [gr_tri_color]		;set color
	mov [gr_line_color],al	
	mov ax, [gr_tri_v1_x]		;draw 1-2
	mov bx,	[gr_tri_v1_y]
	mov cx,	[gr_tri_v2_x]
	mov dx,	[gr_tri_v2_y]
	call gr_line
	mov cx, [gr_tri_v3_x]		;draw 1-3
	mov dx, [gr_tri_v3_y]
	call gr_line
	mov ax, [gr_tri_v2_x]		;draw 3-4
	mov bx, [gr_tri_v2_y]
	call gr_line
	popa 
	ret

gr_tri_v1_x:	dw 0x001F
gr_tri_v1_y:	dw 0x001F
gr_tri_v2_x:	dw 0x0045
gr_tri_v2_y:	dw 0x006C
gr_tri_v3_x:	dw 0x0078
gr_tri_v3_y:	dw 0x003B
gr_tri_color:	db 0x01

gr_screen_w:	dw 0x0140
gr_screen_h:	dw 0x0000
