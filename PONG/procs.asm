IDEAL
P386
MODEL FLAT, C
ASSUME cs:_TEXT,ds:FLAT,es:FLAT,fs:FLAT,gs:FLAT

INCLUDE "procs.inc"		
; -------------------------------------------------------------------
; PROCEDURES
; -------------------------------------------------------------------
CODESEG

PROC printWelcome
	call switchMode, 13h
	call printString, 2, 11, offset welcoming
	call printString, 10, 10, offset startmsg
	call printString, 12, 11, offset exitmsg
	call getKeystroke
	ret
ENDP printWelcome

PROC waitForVBI
	USES EDX, EAX
	mov dx, 03dah
	@@waitForEnd:
		in al, dx
		and al, 8
		jnz @@waitForEnd
	
	@@waitForBegin:
		in al, dx
		and al, 8
		jz @@waitForBegin
	ret
ENDP waitForVBI

PROC switchMode
	ARG @@vmode: BYTE
	USES EAX
		
	mov ah, 0h
	mov al, [@@vmode] ; video mode (13h or 3h)
	int 10h
	ret
ENDP switchMode

PROC printString 
	ARG @@row:DWORD, @@column:DWORD, @@offset:DWORD
	USES EAX, EBX, EDX
	mov edx, [@@row]
	mov ebx, [@@column]
	mov ah, 02h
	shl edx, 08h
	mov dl, bl
	mov bh, 0h
	int 10h
	mov ah, 09h 
	mov edx, [@@offset]
	int 21h
	ret
ENDP printString

PROC clearScreen
	USES EDI, ECX, EAX

	mov edi, VIDMEMADR 
	mov al, 0H
	mov ecx, WINWIDTH*WINHEIGHT ;64000
	rep stosb
	ret 
ENDP clearScreen

PROC getKeystroke
	USES EAX
	
	mov ah,00h
	int 16h
	ret
	
ENDP getKeystroke

;---------------------------------------------------------------------

PROC drawRectangle ;
	ARG @@col: WORD, @@row: WORD,  @@w: WORD, @@h: WORD, @@pxlcol: BYTE
	USES EAX, ECX, EDX 
	
	mov cx, [@@col]  ;kolom
	mov dx, [@@row]  ;rij
	mov al, [@@pxlcol]  ;pixel color
	mov ah, 0ch
	;//teken eerste rij
@@colcount:
	inc cx
	int 10h
	cmp cx, [@@w] ;breedte (width)
	JNE @@colcount

	;//teken volgende rij (incrementeer dx)
	mov cx, [@@col]  
	inc dx
	cmp dx, [@@h] ;height
	JNE @@colcount
	
@@return:
	ret
ENDP drawRectangle

PROC printScore ;Procedure bestanden uit twee andere procedures overgenomen van de WPO's 
	USES EAX, EBX, ECX
	ARG @@row: DWORD, @@column: DWORD, @@number: DWORD 
	mov eax, [@@number]
	
	cmp eax, 0
	jge @@positive
	push eax
	
@@positive:
	mov ebx, 10
	mov ecx, 0
	
@@not_done:
	xor edx, edx
	div ebx
	push edx 
	inc ecx
	cmp eax, 0
	jnz @@not_done
		
	mov edx, [@@row]
	mov ebx, [@@column]
	mov ah, 02h
	shl edx, 08h
	mov dl, bl
	mov bh, 0
	int 10h
	
@@print_digits:
	mov ah, 02h
	pop edx
	add edx, '0'
	
	int 21h
	loop @@print_digits
	
	ret
ENDP printScore



PROC resetPos
	mov [ballX], 160
	mov [ballY], 92
	mov [ballWidth], 164
	mov [ballHeight], 96
	mov [ballHasToGoUp], 1
	mov [switchSide], 1
	mov [playerY], padInitY
	mov [playerHeight], padInitH
	mov [computerY], padInitY
	mov [computerHeight], padInitH
	mov [hasToGoUp], 1
	ret
ENDP resetPos

;----------------------------------------------

PROC printVictory
	ARG @@msg: DWORD ;adress
	call switchMode, 13h
	call printString, 9, 5, [@@msg]
	call getKeystroke
	mov [scoreComputer], 0
	mov [scorePlayer], 0
	call resetPos
	ret
ENDP printVictory

PROC playersMove
	USES EAX, ECX
	ARG @@bound:DWORD, @@vel:DWORD	

	mov ecx, [@@bound]
	mov eax, [@@vel]	
	cmp [playerY], ecx
	jz @@return
@@movePaddle:
	add [playerY], eax
	add [playerHeight], eax
@@return: 
	ret
ENDP playersMove
		
PROC moveComputer
	USES ECX
	ARG @@bound:DWORD, @@vel:DWORD, @@boolean:DWORD
	mov ecx, [@@bound]
	cmp [computerY], ecx
	jz @@change

	mov ecx, [@@vel]
	add [computerY], ecx ;Anders decrementeren de rij van de computer
	add [computerHeight], ecx
	jmp @@return
		
@@change:
	mov ecx, [@@boolean]
	mov [hasToGoUp], ecx
	jmp @@return
		
@@return:
	ret
ENDP moveComputer

PROC moveBall
	USES ECX, EBX
	ARG @@xPos:DWORD, @@yPos: DWORD, @@ballvel:DWORD, @@bound: DWORD, @@direction:DWORD
	mov ecx, [@@xPos]
	mov ebx, [@@bound]
	cmp [@@direction], RIGHT
	jz @@goRight
	jmp @@goLeft

@@goRight:
	cmp [ballX], ecx
	jle @@continue
	cmp [ballX], ebx
	jge SHORT @@pScore
	jmp @@same
			
@@goLeft:
	cmp [ballX], ecx
	jge @@continue
	cmp [ballX], ebx
	jle	@@cScore
	jmp @@same
			
@@same:
	mov ecx, [@@yPos]
	cmp [ballY], ecx
	jle @@continue
	add ecx, 40
	cmp [ballY], ecx
	jle @@switch
			
@@continue:
	mov ecx, [@@ballvel]
	add [ballX], ecx
	add [ballWidth], ecx
	jmp @@return
		
@@switch:
	cmp [@@direction], RIGHT 
	jnz left
	mov [switchSide], FALSE
	jmp @@return
	left:
	mov [switchSide], TRUE
	jmp @@return
				
@@pScore:
	mov [playerScored], 1
	jmp @@return 
		
@@cScore:
	mov [computerScored], 1
	jmp @@return 
			
@@return:
	ret
ENDP moveBall

PROC addPoint
	USES EAX
	ARG @@destination:DWORD
	
	mov eax, [@@destination]
	inc [DWORD PTR EAX]
	mov [@@destination], eax
	ret
ENDP addPoint

PROC exitGame
	call switchMode, 3h 
	mov ah, 4Ch  ;Terminate process 
	mov al, 0h   ;return 0
	int 21h
	ret
ENDP exitGame

PROC verMove
	USES ECX
	ARG @@bound:DWORD, @@velocity:DWORD, @@direction:DWORD 
	mov ecx, [@@bound]
	cmp [ballY], ecx
	jz  @@switch
	mov ecx, [@@velocity]
	add [ballY], ecx
	add [ballHeight], ecx
	jmp @@return
			
@@switch:
	cmp [@@direction], UP
	jnz goUp
	mov [ballHasToGoUp], FALSE
	jmp @@return
	goUp:
	mov [ballHasToGoUp], TRUE
	jmp @@return
	
@@return:
	ret
ENDP verMove

DATASEG
	
	playerY dd 70
	playerHeight dd 110
	
	computerY dd 70
	computerHeight dd 110
	
	ballX dd 160
	ballY dd 92
	ballWidth dd 164
	ballHeight dd 96
	
	hasToGoUp dd 1
	ballHasToGoUp dd 1
	switchSide dd 1
	
	scorePlayer dd 0
	scoreComputer dd 0
	
	playerScored dd 0
	computerScored dd 0 
	
	welcoming db "Welcome to Pong! $"
	startmsg db "Press ENTER to start$"
	exitmsg db "Press ESC to exit$"
	userWin db "Congratulations, you have won!$"
	computerWin db "The computer has won, you lose!$"
	
END 

