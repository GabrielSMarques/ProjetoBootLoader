org 0x7c00 
jmp 0x0000:start
; bits 16

start:
	xor ax, ax
	mov ds, ax
	
	call initGraphics
	
	gameloop:
		call resetBuffer
		call drawPlayer
		call bufferToScreen
		call gameControl
	jmp gameloop

	jmp done

resetBuffer:
	pusha
	mov cx, 320*200/2 		;dividido por dois pq uso do sw e não o sb
	xor ax, ax
	mov di, [screenBuffer]
	rep stosw
	popa
	ret

drawPlayer:
	pusha
	mov di, word[screenBuffer]
	mov cx, word [player_PosX]
	mov dx, word [player_PosY]
	mov al, byte [player+2]    		;cor do player

	mov bl, byte [player+1]			;cont tam y
	.loop:
		mov bh, byte [player] 		;cont tam x
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
	jg .loop
	popa
	ret


gameControl:
	mov di, player
	call checkKey
	mov cx, word[player_PosX]
	cmp ah, 0x20
	jne .n1
	add cx, 4
	.n1:
	cmp ah, 0x1e
	jne .n2
	sub cx, 4
	.n2:
	mov word[player_PosX], cx
	ret

checkKey:
	mov ah, 1
	int 0x16
	jz .end
	mov ax, 0
	int 0x16
	ret
	.end:
	mov ax, 0
	ret

bufferToScreen:
	pusha
	push es
	mov es, word[graphicMemory]
	xor di, di
	mov si, word[screenBuffer]
	mov cx, 320*200/2
	.loop:
		lodsw
		stosw
		dec cx
		jg .loop
	pop es
	popa
	ret

; drawScreen:
; 	pusha
; 	push es
; 	mov es, word[graphicMemory]
; 	xor di, di
; 	xor dx, dx
; 	mov al, 1
; 	.loop:
; 		xor cx, cx
; 		mov di, dx
; 		imul di, 320
; 		.loop2:
; 			stosb
; 			inc cx
; 			cmp cx, 320
; 		jl .loop2
; 		inc dx
; 		cmp dx, 200
; 	jl .loop
; 	pop es
; 	popa
; 	ret


; _drawPlayer:
; 	pusha
; 	push es
; 	mov es, word [graphicMemory]
; 	xor di, di

; 	mov cx, word [player_PosX]
; 	mov dx, word [player_PosY]
; 	mov al, byte [player+2]

; 	mov bl, byte [player+1]			;tam y
; 	.loop:
; 		mov bh, byte [player] 		;tam x
; 		mov di, dx
; 		imul di, 320
; 		add di, cx
; 		.loop2:
; 			stosb
; 			dec bh
; 			cmp bh, 0
; 		jne .loop2
; 		inc dx
; 		dec bl
; 		cmp bl, 0
; 	jg .loop
; 	pop es
; 	popa
; 	ret

initGraphics:
	mov ah, 0   ;set display mode
	mov al, 13h ;13h = 320x200
	int 10h
	ret

done:
    jmp $

player:
	db 30	;tam x (0<=x<=255)
	db 8	;tam y (0<=y<=255)
	db 1	;color

player_PosX dw 144
player_PosY dw 182

graphicMemory dw 0xA000
screenBuffer dw 0x0500

; %warning [usedMemory/usableMemory] Bytes used

times 510-($-$$) db 0 ;kernel must have size multiple of 512 so let's pad it to the correct size
dw 0xaa55			