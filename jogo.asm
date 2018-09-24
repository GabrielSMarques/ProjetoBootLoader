org 0x7c00 
jmp 0x0000:start

start:
	xor ax, ax
	mov ds, ax
	
	call initGraphics
	call drawPlayer
	jmp done

drawPlayer:
	pusha
	push es
	mov es, word [graphicMemory]
	xor di, di

	mov cx, word [player]
	mov dx, word [player+2]
	mov al, byte [player+6]

	mov bl, byte [player+5]			;tam y
	.loop:
		mov bh, byte [player+4] 		;tam x
		mov di, dx
		imul di, 320
		add di, cx
		.loop2:
			stosb
			dec bh
			cmp bh, 0
		jne .loop2
		inc dx
		dec bl
		cmp bl, 0
	jne .loop
	ret

initGraphics:
	mov ah, 0   ;set display mode
	mov al, 13h ;13h = 320x200
	int  0x10
	ret

done:
    jmp $

graphicMemory dw 0xA000

player:
	dw 10	;pos x
	dw 180	;pos y
	db 30	;tam x (0<=x<=255)
	db 8	;tam y (0<=y<=255)
	db 1	;color


times 510-($-$$) db 0		
dw 0xaa55			