;SMASHING
org 0x7E00
jmp 0x0000:start

titulo db 'GNIHSAMS', 13
Bricks db ' Bricks', 13
iniciar db ' Iniciar Jogo', 13
guia db ' Help', 13
tituloGuia db '-- HELP --', 13
introducao1 db 'Mova a plataforma para acertar', 13
introducao2 db 'os Blocos que sao destruidos', 13
introducao3 db 'em sequencia!', 13
mecanica db '<-A      D->', 13
surpresa db 'Surpresas podem acontecer!', 13

start:
	mov ah, 0   ;set display mode
	mov al, 13h ;13h = 320x200
	int 0x10

	call telaInicial

	jmp exit
ret

telaInicial:
	call drawImage ;draw image

	call printTitulo

	mov ah, 02h
	mov bh, 00h
	mov dh, 09h
	mov dl, 10h
	int 10h

	mov si, Bricks
	call printBricks

	call menu

	cmp cx, 2
	je telaRegras

	call jogo
ret

telaRegras:
	mov ah, 0   ;set display mode
	mov al, 13h ;13h = 320x200
	int 0x10

	mov ah, 0xb  
	mov bh, 0     
	mov bl, 4   
	int 10h

	mov ah, 02h
	mov bh, 00h
	mov dh, 02h
	mov dl, 0fh
	int 10h

	mov bl, 0xf
	mov si, tituloGuia
	call printString

	mov ah, 02h
	mov bh, 00h
	mov dh, 05h
	mov dl, 05h
	int 10h
	mov si, introducao1
	call printString

	mov ah, 02h
	mov bh, 00h
	mov dh, 07h
	mov dl, 06h
	int 10h
	mov si, introducao2
	call printString

	mov ah, 02h
	mov bh, 00h
	mov dh, 09h
	mov dl, 0dh
	int 10h
	mov si, introducao3
	call printString

	mov ah, 02h
	mov bh, 00h
	mov dh, 0fh
	mov dl, 0eh
	int 10h
	mov si, mecanica
	call printString

	mov ah, 02h
	mov bh, 00h
	mov dh, 14h
	mov dl, 0dh
	int 10h
	mov si, iniciar
	call printString

	mov ah, 02h
	mov bh, 00h
	mov dh, 11h
	mov dl, 07h
	int 10h
	mov si, surpresa
	call printString

	esperaEnter:
		mov ah, 0
		int 16h
		
		cmp al, 13
		jne esperaEnter
	
	call jogo
ret	

printTitulo:
	mov si, titulo

	mov cl, 23

	printTitulo2:
		lodsb

		mov dl, 0
		printTitulo3:
			;Setando o cursor.
			mov ah, 02h
			mov bh, 00h
			mov dh, 07h
			int 10h
			
			push ax
			mov al, ''
			mov ah, 0xe
			mov bh, 0
			mov bl, 0xf
			int 10h
			pop ax

			;Setando o cursor.
			mov ah, 02h
			mov bh, 00h
			mov dh, 07h
			inc dl
			int 10h

			mov ah, 0xe
			mov bh, 0
			mov bl, 0xf
			int 10h

			call delay

			cmp dl, cl
		jne printTitulo3
		dec cl
		cmp al, 13
	jne printTitulo2
ret

menu:
	mov ah, 02h
	mov bh, 00h
	mov dh, 10h
	mov dl, 0xc
	int 10h

	mov ah, 0xe
	mov al, '>'
	mov bh, 0
	mov bl, 0xf
	int 10h

	mov si, iniciar
	call printString

	mov ah, 02h
	mov bh, 00h
	mov dh, 12h
	mov dl, 0xd
	int 10h

	mov si, guia
	call printString

	mov cx, 1 ;CX contém a posição da seta.
	call mudancaSeta

	
ret

mudancaSeta:
	
	mov ah, 0
	int 16h

	cmp al, 's'
	je Baixo

	cmp al, 'w'
	je Cima

	cmp al, 13
	jne mudancaSeta

	ret

	Baixo:
		cmp cx, 2
		je Cima

		;Os 4 grupos de instruções abaixo deslocam a seta para baixo.

		mov ah, 02h
		mov bh, 00h
		mov dh, 10h
		mov dl, 0xc
		int 10h

		mov ah, 0xe
		mov al, 0
		mov bh, 0
		mov bl, 0xf
		int 10h

		mov ah, 02h
		mov bh, 00h
		mov dh, 12h
		mov dl, 0xc
		int 10h

		mov ah, 0xe
		mov al, '>'
		mov bh, 0
		mov bl, 0xf
		int 10h

		mov cx, 2
		jmp mudancaSeta

	Cima:
		cmp cx, 1
		je Baixo

		;Os 4 grupos de instruções abaixo deslocam a seta para cima.

		mov ah, 02h
		mov bh, 00h
		mov dh, 10h
		mov dl, 0xc
		int 10h

		mov ah, 0xe
		mov al, '>'
		mov bh, 0
		mov bl, 0xf
		int 10h

		mov ah, 02h
		mov bh, 00h
		mov dh, 12h
		mov dl, 0xc
		int 10h

		mov ah, 0xe
		mov al, 0
		mov bh, 0
		mov bl, 0xf
		int 10h

		mov cx, 1
		jmp mudancaSeta
ret

printBricks:
	lodsb

	mov ah, 0xe
	mov bh, 0
	int 10h

	cmp al, 13
	jne printBricks
ret

printString:
	lodsb

	mov ah, 0xe
	mov bh, 0
	int 10h

	cmp al, 13
	jne printString
ret

delay:
	push bx
	push dx
	mov bp, 50
	mov dx, 50
	delayloop:
		dec bp
		nop
		jnz delayloop
	dec dx
	jnz delayloop

	pop dx
	pop bx
ret

drawImage:
	mov si, imageFile

	pusha

	xor ax, ax
	lodsb
	mov cx, ax ;x-position
	add cx, 20
	lodsb
	mov dx, ax ;y-position
	add dx, 20
	.for_x1:
		push dx
		.for_y1:
			mov bh, 0  ;page number
			lodsb       ;al (color) -> next byte
			mov ah, 0xC ;write pixel at coordinate
			int 0x10 ;might "destroy" ax, si and di on some systems
		sub dx, 1  ;decrease dx by one and set flags
		cmp dx, 20
		jne .for_y1 ;repeat for y-length
		pop dx     ;restore dx
	sub cx, 1      ;decrease si by one and set flags
	cmp cx, 20
	jne .for_x1     ;repeat for x-length

	mov si, imageFile

	xor ax, ax
	lodsb
	mov cx, ax ;x-position
	add cx, 280
	lodsb
	mov dx, ax ;y-position
	add dx, 20
	.for_x2:
		push dx
		.for_y2:
			mov bh, 0  ;page number
			lodsb       ;al (color) -> next byte
			mov ah, 0xC ;write pixel at coordinate
			int 0x10 ;might "destroy" ax, si and di on some systems
		sub dx, 1  ;decrease dx by one and set flags
		cmp dx, 20
		jne .for_y2 ;repeat for y-length
		pop dx     ;restore dx
	sub cx, 1      ;decrease si by one and set flags
	cmp cx, 280
	jne .for_x2     ;repeat for x-length

	mov si, imageFile

	xor ax, ax
	lodsb
	mov cx, ax ;x-position
	add cx, 20
	lodsb
	mov dx, ax ;y-position
	add dx, 150
	.for_x3:
		push dx
		.for_y3:
			mov bh, 0  ;page number
			lodsb       ;al (color) -> next byte
			mov ah, 0xC ;write pixel at coordinate
			int 0x10 ;might "destroy" ax, si and di on some systems
		sub dx, 1  ;decrease dx by one and set flags
		cmp dx, 150
		jne .for_y3 ;repeat for y-length
		pop dx     ;restore dx
	sub cx, 1      ;decrease si by one and set flags
	cmp cx, 20
	jne .for_x3     ;repeat for x-length

	mov si, imageFile

	xor ax, ax
	lodsb
	mov cx, ax ;x-position
	add cx, 280
	lodsb
	mov dx, ax ;y-position
	add dx, 150
	.for_x4:
		push dx
		.for_y4:
			mov bh, 0  ;page number
			lodsb       ;al (color) -> next byte
			mov ah, 0xC ;write pixel at coordinate
			int 0x10 ;might "destroy" ax, si and di on some systems
		sub dx, 1  ;decrease dx by one and set flags
		cmp dx, 150
		jne .for_y4 ;repeat for y-length
		pop dx     ;restore dx
	sub cx, 1      ;decrease si by one and set flags
	cmp cx, 280
	jne .for_x4     ;repeat for x-length

	popa
ret

jogo:
;Setando a posição do disco onde kernel.asm foi armazenado(ES:BX = [0x500:0x0])
	mov ax,0x860		;0x50<<1 + 0 = 0x500
	mov es,ax
	xor bx,bx		;Zerando o offset

;Setando a posição da Ram onde o jogo será lido
	mov ah, 0x02	;comando de ler setor do disco
	mov al,8		;quantidade de blocos ocupados por jogo
	mov dl,0		;drive floppy

;Usaremos as seguintes posições na memoria:
	mov ch,0		;trilha 0
	mov cl,7		;setor 2
	mov dh,0		;cabeca 0
	int 13h
	jc jogo	;em caso de erro, tenta de novo

break:	
	jmp 0x8600 		;Pula para a posição carregada

exit:

imageFile: incbin "image.bin" ;include the image binary
