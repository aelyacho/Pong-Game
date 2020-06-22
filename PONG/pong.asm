; -------------------------------------------------------------------
; 80386
; 32-bit x86 assembly language
; TASM
;
; author: Daniel Boustani, Abdoullah El Yachouti 
; program:	Pong! update 23/12
; -------------------------------------------------------------------

IDEAL
P386
MODEL FLAT, C
ASSUME cs:_TEXT,ds:FLAT,es:FLAT,fs:FLAT,gs:FLAT

INCLUDE "procs.inc"

; -------------------------------------------------------------------
; CODE
; -------------------------------------------------------------------
CODESEG

start:
     sti            ; set The Interrupt Flag => enable interrupts
     cld            ; clear The Direction Flag
		
	push ds 
	pop es
	
main:
	call printWelcome
	
	menu: ; get keystroke
		mov ah, 07h
	 	int 21h
		
		special_key: ;check if its a special character (arrows)
		cmp al, 0
		jne check_menu ;if not, go straight to skip to compare the key 
		
		mov ah, 07h ; else, ask again for keystroke to get the real value
	 	int 21h
		
		check_menu:
		cmp al, 13 ; press two times on enter
		jz drawGame
		
		cmp al, 27 ; press two times on esc
		jz terminate
		
		jmp menu
	
	
	
	
drawGame:
	call waitForVBI
	call clearScreen
	
	call drawRectangle, playerX, [playerY], playerWidth, [playerHeight], 10 ;teken speler
	call drawRectangle, computerX, [computerY], computerWidth, [computerHeight], 10 ;teken computer
	call drawRectangle, [ballX], [ballY], [ballWidth], [ballHeight], 15 ;teken bal
		
	call printScore, 0, 95, [scorePlayer] 
	call printScore, 0, 104, [scoreComputer] 
	
	call drawRectangle, lineX, lineY, lineWidth, lineHeight, 10

	mov ah, 01h ;check for key stroke
	int 16h
	
	jz computerMoves ;als geen toets ingedrukt werd, kan de paddle van de computer ter beweging gebracht worden. 
	
	compare: ;anders werd er een toets ingedrukt en moeten er verschillende gevallen gecheckt worden.
		
		get_key: ; get keystroke
		mov ah, 07h
	 	int 21h
		
		check_zero: ;check if its a special character (arrows)
		cmp al, 0
		jne skip ;if not, go straight to skip to compare the key 
		
		mov ah, 07h ; else, ask again for keystroke to get the real value
	 	int 21h
		
		skip:
		cmp al, 50h
		jz downArrow
		
		cmp al, 48h
		jz upArrow
		
		cmp al, 1Bh
		jz terminate
		
		jmp computerMoves ; een willekeurige toets dat niet van belang is werd ingedrukt. We kunnen verder gaan met de beweging van de paddle van de computer	
	
	upArrow:
		call playersMove, UPPERBOUND, -PLAYERVEL
		jmp computerMoves
		
	downArrow:
		call playersMove, LOWERBOUND, PLAYERVEL
		jmp computerMoves
				
	computerMoves:
		cmp [hasToGoUp], TRUE ;hasToGoUp geeft aan ofdat de computer naar boven moet of niet(initiële waarde = 1)
		jz up
		jmp down
				
		up:
			call moveComputer, UPPERBOUND, -COMPUTERVEL, FALSE
			jmp ballMoves
			
		down: 
			call moveComputer, LOWERBOUND, COMPUTERVEL, TRUE
			jmp ballMoves
	
	ballMoves:
		cmp [switchSide], TRUE ;switchSides geeft aan of de bal van richting moet veranderen (initiële waarde = 1)
		jz goRight
		jmp goLeft
		
		goRight:
			call moveBall, computerX-padEdge, [computerY], BALLHORVEL, RIGHTBOUND, RIGHT
			cmp [playerScored], 1
			jnz upDown
			mov [playerScored], 0
			jmp pointToPlayer

		
		goLeft: ;idem als goRight, maar nu voor de racket van de speler
			call moveBall, playerX+padEdge, [playerY], -BALLHORVEL, LEFTBOUND, LEFT
			cmp [computerScored], 1
			jnz upDown
			mov [computerScored], 0
			jmp pointToComputer
			
		upDown:
			cmp [ballHasToGoUp], TRUE ;ballHasToGoUp geeft aan of de bal naar boven of naar beneden moet bewegen (intitiële waarde = 1)
			jz goUp
			jmp goDown
			
		goUp:
			call verMove, UPPERBOUND, -BALLVERVEL, UP
			jmp drawGame
		
		goDown:
			call verMove, 190, BALLVERVEL, DOWN
			jmp drawGame
				
		pointToPlayer:  ; punt voor de speler
			call addPoint, offset scorePlayer
			cmp [scorePlayer], MAXPOINT
			jz printPlayerVictory
			jmp ballOut
			
		printPlayerVictory:
			call printVictory, offset userWin
			jmp main
		
		pointToComputer: ; punt voor de computer
			call addPoint, offset scoreComputer			
			cmp [scoreComputer], MAXPOINT
			jz printComputerVictory
			jmp ballOut
			
		printComputerVictory: ;overwinningsscherm voor computer 
			call printVictory, offset computerWin
			jmp main
			
		ballOut:
			call resetPos
			jmp drawGame
		
terminate:       ;Switch terug naar 03h video
	call exitGame
	
; -------------------------------------------------------------------
; STACK
; -------------------------------------------------------------------
STACK 100h

END start 