;-------------------------------------------------------------------
; pong procedures declarations + macros
;-------------------------------------------------------------------

WINWIDTH equ 320
WINHEIGHT equ 200
VIDMEMADR equ 0A0000h

playerX equ 10 ;kolom speler
playerWidth equ 15 ;breedte van de speler 
computerX equ 300 ;kolom van de computer
computerWidth equ computerX+5 ;breedte van de computer
 
padInitY equ 70 ; paddles initiele y positie
padInitH equ padInitY+40 ; paddles initiele hoogte
padEdge equ 6

lineX equ 160
lineWidth equ 162
lineY equ 0
lineHeight equ 199

UPPERBOUND equ 5
LOWERBOUND equ 155
LEFTBOUND equ 0
RIGHTBOUND equ 310
MAXPOINT equ 5

TRUE equ 1
FALSE equ 0

PLAYERVEL equ 5 ;snelheid speler
COMPUTERVEL equ 1 ;snelheid computer
BALLVERVEL equ 1 ;Verticale snelheid van de bal 
BALLHORVEL equ 3 ;Horizontale snelheid van de bal

LEFT equ 0
RIGHT equ 1
UP equ 1
DOWN equ 0

GLOBAL waitForVBI:PROC
GLOBAL switchMode:PROC
GLOBAL printString:PROC
GLOBAL printWelcome:PROC
GLOBAL clearScreen:PROC
GLOBAL drawRectangle:PROC
GLOBAL printScore:PROC
GLOBAL resetPos:PROC
GLOBAL getKeystroke:PROC
GLOBAL printVictory:PROC
GLOBAL playersMove:PROC
GLOBAL moveComputer:PROC
GLOBAL moveBall:PROC
GLOBAL exitGame:PROC
GLOBAL addPoint:PROC
GLOBAL verMove:PROC

GLOBAL welcoming:BYTE
GLOBAL userWin:BYTE
GLOBAL computerWin:BYTE

GLOBAL playerY:DWORD
GLOBAL playerHeight:DWORD
GLOBAL computerY:DWORD
GLOBAL computerHeight:DWORD
GLOBAL ballX:DWORD
GLOBAL ballY:DWORD
GLOBAL ballHeight:DWORD
GLOBAL ballWidth:DWORD
GLOBAL hasToGoUp:DWORD
GLOBAL ballHasToGoUp:DWORD
GLOBAL switchSide:DWORD
GLOBAL scoreComputer:DWORD
GLOBAL scorePlayer:DWORD
GLOBAL playerScored:DWORD
GLOBAL computerScored:DWORD