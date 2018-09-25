org 0x7c00 
jmp 0x0000:start

start:
	xor ax, ax
	mov ds, ax
	
	call initVideo

	.gameloop:
		; call board
		call bar
		call gameControl
		jmp .gameloop

	jmp done

gameControl:
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
	call validation
	ret

validation:
	cmp cx, 0
	jl .skip
	push ax
	mov ax, 320
	sub al, byte[player_TamX]
	cmp cx, ax
	pop ax
	jg .skip
	mov word[player_PosX], cx
	.skip:
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

board:
	mov al, 4
	mov dx, 150
	.innerloop:
		mov cx, 100
		.otherloop:
			call writePixel
			inc cx
			cmp cx, 220
			jl .otherloop
		inc dx
		cmp dx, 200
		jl .innerloop
	ret

bordas:
	mov al, 0
	mov bh, byte[player_Borda]
	.innerloop:
		mov dx, word[player_PosY]
		mov bl, byte[player_TamY]
		.otherloop:
			push bx
			call writePixel
			pop bx

			inc dx
			dec bl
			cmp bl, 0
			jg .otherloop
		dec cx
		dec bh
		cmp bh, 0
		jg .innerloop
	ret

bar:
	pusha
	mov cx, word[player_PosX]
	dec cx
	call bordas

	mov cx, word[player_PosX]
	push ax
	xor ax, ax
	add al, byte[player_TamX]
	add al, byte[player_Borda]
	add cx, ax
	pop ax
	call bordas
	popa
	
	xor bx, bx
	mov bl, byte[player_TamY]		
	mov dx, word[player_PosY]
	mov al, byte[player_Color]

	.innerloop:
		mov bh, byte[player_TamX]		
		mov cx, word[player_PosX]
		.otherloop:
			push bx
			call writePixel
			pop bx
			inc cx
			dec bh
			cmp bh, 0
			jge .otherloop
		inc dx
		dec bl
		cmp bl, 0
		jg .innerloop
	ret

;cx =x, dx = y, al = color
;usa bx
writePixel:
    mov ah, 0ch   
    mov bh, 0      
    int 10h
    ret

initVideo:
	mov ah, 0
	mov al, 13h
	int 10h
	ret

done:
    jmp $

player_PosX dw 144
player_PosY dw 182

player_TamX db 30
player_TamY db 8	

player_Color db 1

player_Borda db 5

times 510-($-$$) db 0		
dw 0xaa55			