
;Yuzhe Lu
;Assembly

Include Irvine32.Inc

.data
CurrentPlayer BYTE ?

TableB BYTE 0,0,0,0
RowSize = 4
		BYTE 0,0,0,0
		BYTE 0,0,0,0
		BYTE 0,0,0,0
Player1_Wins BYTE 0
Player1TurnMessage BYTE "Turn: Player 1",0Ah,0Dh,0
Player2TurnMessage BYTE "Turn: Player 2",0Ah,0Dh,0
CPU1TurnMessage BYTE "Turn: Computer 1",0Ah,0Dh,0
CPU2TurnMessage BYTE "Turn: Computer 2",0Ah,0Dh,0

Win_Msg BYTE "Player 1 Win count: ",0

;-----PROTOS BELOW
DisplayMenu PROTO	;displays main menu
GoFirst PROTO		;determines who goes first
CommenceTurn PROTO, TableBAddr: PTR BYTE, RSize:BYTE
CheckWin PROTO, TableBAddr: PTR BYTE, RSize:BYTE
GameState PROTO, TableBAddr: PTR BYTE
GameWin PROTO		;Displays Win message and asks the user if they want to play again
GameDone PROTO 		;Displays game over message and asks the user if they want to play again
ClearBoard PROTO, TableBAddr: PTR BYTE	;clears the board
CPUTurn PROTO, TableBAddr: PTR BYTE, RSize:BYTE
PrintTable PROTO, TableBAddr: PTR BYTE

.code
main PROC

PlayAgain:
INVOKE ClearBoard, ADDR TableB
mov EAX, 0
mov EBX, 0
mov ECX, 0
mov EDX, 0
mov ESI, 0
mov EDI, 0


DisplayM:
invoke DisplayMenu	;EAX is returned as player choice
cmp EAX, 1
JE PVP
cmp EAX, 2
JE PVE
cmp EAX, 3
JE EVE
jmp GameEnd
;------------------Player vs Player starts----------
PVP:
;INVOKE PrintTable, ADDR TableB
;get turn order
INVOKE GoFirst
CMP EAX, 2
JE Player2	;otherwise it is 1 and player 1 goes first
;WHILE NO ONE HAS WON AND ALL THE SLOTS ARE NOT FILLED OUT
;THERE ARE 16 SPACES. 16 MAX TURNS
Player1:
mov EDX, offset Player1TurnMessage
call WriteString
mov EAX, 1
INVOKE CommenceTurn, ADDR TableB, RowSize
INVOKE CheckWin, Addr TableB, RowSize
cmp EAX, 1				;see if it is a winner
JNE Notyet				;jump if it does not equal 1. if it equals 1,
inc Player1_Wins		;increments player1 win count
call clrscr
INVOKE PrintTable, ADDR TableB
jmp WinGame				;jumps to WinGame

Notyet:
call clrscr 
INVOKE PrintTable, ADDR TableB
INVOKE GameState, ADDR TableB ;check game state to see if it is full
cmp EAX, 0
JE GameOver
;if not game over
jmp Player2


Player2:
mov EDX, offset Player2TurnMessage
call WriteString
mov EAX, 2
INVOKE CommenceTurn, AddR TableB, RowSize
;check win
call clrscr
INVOKE PrintTable, ADDR TableB
INVOKE CheckWin, Addr TableB, RowSize
cmp EAX, 1
JE WinGame
;check game over conditions
INVOKE GameState, ADDR TableB
cmp EAX, 0
JE GameOver
;if not game over
jmp Player1
;END PVP

;------------------------------PVE 
PVE:
INVOKE GoFirst
cmp EAX, 2
JE PVE_CPU2
PVE_Player1:
mov EDX, offset Player1TurnMessage
call WriteString
INVOKE PrintTable, ADDR TableB
mov EAX, 1
INVOKE CommenceTurn, ADDR TableB, RowSize
call clrscr
INVOKE PrintTable, ADDR TableB
INVOKE CheckWin, Addr TableB, RowSize
cmp EAX, 1				;see if it is a winner
JNE PVE_Notyet				;jump if it does not equal 1. if it equals 1,
inc Player1_Wins		;increments player1 win count
jmp WinGame				;jumps to WinGame

PVE_Notyet:
INVOKE GameState, ADDR TableB ;check game state to see if it is full
cmp EAX, 0
JE GameOver
;if not game over
jmp PVE_CPU2

PVE_CPU2:
mov EDX, offset CPU1TurnMessage
call WriteString
mov EAX, 2
INVOKE CPUTurn, ADDR TableB, RowSize
call clrscr
INVOKE PrintTable, ADDR TableB
push EAX
mov EAX, 2000
call Delay
pop EAX
;show screen
INVOKE CheckWin, Addr TableB, RowSize
;delay 2 seconds
cmp EAX, 1
JE WinGame
INVOKE GameState, ADDR TableB
cmp EAX, 0
JE GameOver

jmp PVE_Player1
;END PVE
;-------------COMPUTER VS Computer
EVE:
INVOKE GoFirst
cmp EAX, 2
JE EVE_CPU2

EVE_CPU1:
mov EDX, offset CPU1TurnMessage
call WriteString
mov EAX, 1
INVOKE CPUTurn, ADDR TableB, RowSize
call clrscr
INVOKE PrintTable, ADDR TableB
push EAX
mov EAX, 2000
call Delay
pop EAX
INVOKE CheckWin, Addr TableB, RowSize
;delay 2 seconds
cmp EAX, 1
JE WinGame
INVOKE GameState, ADDR TableB
cmp EAX, 0
JE GameOver
jmp EVE_CPU2

EVE_CPU2:
mov EDX, offset CPU2TurnMessage
call WriteString
mov EAX, 2
INVOKE CPUTurn, ADDR TableB, RowSize
;show screen
call clrscr
INVOKE PrintTable, ADDR TableB
push EAX
mov EAX, 2000
call Delay
pop EAX
INVOKE CheckWin, Addr TableB, RowSize
;delay 2 seconds
cmp EAX, 1
JE WinGame
INVOKE GameState, ADDR TableB
cmp EAX, 0
JE GameOver
jmp EVE_CPU1
;-----END COMPUTER VS Computer


WinGame:
mov EDX, offset Win_Msg
call WriteString
movzx EAX, Player1_Wins
call WriteDec
call crlf
INVOKE GameWin
call WriteString
cmp EAX, 1
JE PlayAgain
jmp GameEnd
GameOver:
mov EDX, offset Win_Msg
call WriteString
movzx EAX, Player1_Wins
call WriteDec
call crlf
INVOKE GameDone
cmp EAX, 1
JE PlayAgain
jmp GameEnd

GameEnd:

exit
main ENDP	;end main procedure

;---------------------------------------------------
;-------------------FUNCTIONS BEGIN HERE------------
;---------------------------------------------------

;-------------Display menu----------
DisplayMenu PROC
;----------------
;Desc: Desiplays the menu and asks the user to pick
;Takes: nothing
;Returns: User option in EAX
.DATA
MenuMessage BYTE "Please choose one of the following:", 0Ah, 0Dh,
"1. Player vs Player", 0Ah, 0Dh,
"2. Player vs Computer", 0Ah, 0Dh,
"3. Computer vs Computer", 0Ah, 0Dh,
"4. Exit", 0Ah, 0Dh, 0

MenuErrorMessage BYTE "Error. Invalid Choice", 0Ah, 0Dh,0

.CODE
MenuStart:
mov EDX, offset MenuMessage
call WriteString
call ReadDec
cmp EAX, 0
JE MErrorM
cmp EAX, 4
JA MErrorM
jmp MenuExit


MErrorM:
mov EDX, offset MenuErrorMessage
call WriteString
jmp MenuStart

MenuExit:
ret
DisplayMenu ENDP;--------EXIT Display

;--------------WHO GOES FIRST---------------
GoFirst PROC
;Desc: Randomizes who goes first
;Takes:Nothing
;Returns: 1 or 2 in EAX
.data
.code
call Randomize
mov EAX, 2		;range 0 to 1
call RandomRange
ADD EAX, 1			;increments eax, so range is 1 or 2
ret
GoFirst ENDP

;----MAJORS-------------------------------------------------------------
;-----------------------------TURN FUNCTION-----------------------------

CommenceTurn PROC USES EAX,
TableBAddr:PTR BYTE,
RSize:BYTE
;-----------------------------------------------------------
;Desc: Given whos turn it is from EAX, asks the user which column to insert.
;checks array to check if column is full, and if not, fills the next avaliable
;spot with the player number.
;Takes: offset of TableB and player number passed in EAX, ECX as RowSize
;Returns:   Row Index in ECX
;			Column Index in ESI
;			of last inserted value
.DATA
ColumnIndex BYTE ?
ColMessage BYTE "Please choose a column to insert: ", 0Ah, 0Dh,
"1. Row 1",0Ah,0Dh,
"2. Row 2",0Ah,0Dh,
"3. Row 3",0Ah,0Dh,
"4. Row 4",0Ah,0Dh,0

ColErrorMessage BYTE "Column is full. Please pick another",0Ah,0Dh,0

.CODE
push EAX	;saves playerNumber

columnPick:
	MOV EDX, offset ColMessage		;EDX is now table location
	call WriteString
	Call ReadDec		;EAX HOLDS COLUMN NUMBER NOW
	sub EAX, 1			;to align to zero column
	mov ColumnIndex, al	;store in variable	
;check if column avaliable
	mov EAX,0		;clear this
	mov ECX, 4		;index	always starts at 4(fill the column 4 times)

	RowcheckAtColumn:
		mov EDX, ECX	;Store ECX in EDX. EDX will be use to multiply
		dec EDX	;account for row 0
		MOV EBX, TableBAddr		;table offset
		movzx AX, RSize		;size of a row
		mul DX		;AX = AX * DX	;get the Row offset

		add EBX, EAX	;row offset
		movZX ESI, ColumnIndex	;column offset

		mov AL, BYTE PTR [EBX+ESI]
		cmp AL, 0		;check if its avaliable
		JE OpenSlot
	loop RowcheckAtColumn	;dec ECX
	Jmp ColumnFull

	OpenSlot:
		pop EAX			;returns the saved player number
		mov BYTE PTR [EBX+ESI], AL	;sets the players marker at location
		dec ECX			;adjusts so return is in the correct position
	jmp EndPlacement	;jump to ending of placement	//

	ColumnFull:
		mov EDX, offset ColErrorMessage
		call WriteString
jmp columnPick	;//

EndPlacement:
ret
CommenceTurn ENDP

;-------------------CPU TURN----------------------------
CPUTurn PROC USES EAX,
TableBAddr:PTR BYTE,
RSize:BYTE
;Desc:Functions as CPUs turn;Takes offset TableB, EAX as computer marker
;Returns Row Index in ECX, Column Index in ESI of inserted value
.data
CPU_ColumnIndeX BYTE ?

.code
push EAX	;save player number
CPU_ColumnPick:
	call randomize	;seed
	mov EAX, 4		;range from 0 to n-1 (0 to 3)
	call RandomRange
	mov CPU_ColumnIndeX, AL
	;check if avaiable
	mov EAX, 0
	mov ECX, 4	;always starts at 4
	CPU_RowCheckAtColumn:
		mov EDX, ECX	;stores ECX in EDX
		dec EDX	;account for row 0
		mov EBX, TableBAddr
		movzx AX, RSize
		mul DX
		add EBX, EAX	;row offset
		movZX ESI, CPU_ColumnIndeX
		mov AL, BYTE PTR [EBX+ESI]
		cmp AL, 0		;check if avaliable
		JE CPU_OpenSlot
	loop CPU_RowCheckAtColumn
	jmp CPU_ColumnFull
	
	CPU_OpenSlot:
		pop EAX	;restore player number
		mov BYTE PTR [EBX+ESI], AL	;set marker
		dec ECX		;adjust so return is in the correct position
	jmp CPU_EndPlacement
	
	CPU_ColumnFull:
	jmp CPU_ColumnPick
	
CPU_EndPlacement:
ret
CPUTurn ENDP

;-----------------CHECK WIN--------------------------
CheckWin PROC uses ECX EDX,
TableBAddr: PTR BYTE,
RSize:BYTE
;--------------------------------
;Takes Row of most recent insert in ECX
;Column of most recent insert in ESI
;offset of TableB
;Player Marker in EAX
;Returns EAX. 1 for win, 0 for not win
.data
Column_Input DWORD ?
Row_Input DWORD ?
PlayerMarker DWORD ?

.code
MOV Column_Input, ESI	;save original column input
mov Row_Input, ECX		;save original row input
mov PlayerMarker, EAX	;save player marker

BelowCheck:
cmp Row_Input, 3
JE SideCheck		;nothing below row 3
mov EAX, 0
mov EDX, Row_Input
inc EDX	;set to row below
mov EBX, TableBAddr
movzx AX, RSize
mul DX	;AX = AX*DX
add EBX, EAX	;Row offset
mov ESI, Column_Input	;column offset
movZX EAX, BYTE PTR [EBX+ESI]
cmp EAX, PlayerMarker
JNE SideCheck
;Belowcheck 2
mov EDX, Row_Input
add EDX, 2 ;next-next row
mov EBX, TableBAddr
movzx AX, RSize
mul DX
add EBX, EAX
movZX EAX, BYTE PTR [EBX+ESI]
cmp EAX, PlayerMarker
JE WinCondition		;3 in a row. input, belowcheck1, belowcheck2.
jmp SideCheck

SideCheck:
;reset registers
mov ESI, Column_Input
mov ECX, Row_Input
CheckLeft:	;---------------------
cmp ECX, 0		;see if it is at beginging
JE CheckRight	;if it is at column 0, nothing to the left. check right
mov EDX, Row_Input
mov EBX, TableBAddr
movzx AX, RSize
mul DX
add EBX, EAX	;row is now correct
mov ESI, Column_Input
dec ESI	;next column to the left
movZX EAX, BYTE PTR [EBX+ESI]
CMP EAX, PlayerMarker
JNE CheckRight
add EDI, 1			;
dec ESI	;next next left
movZX EAX, BYTE PTR [EBX+ESI]
cmp EAX, PlayerMarker
JE WinCondition
jmp CheckRight

CheckRight:	;------
cmp Column_Input, 3
JA CheckSideEnd
mov EDX, Row_Input
mov EBX, TableBAddr
movzx AX, RSize
mul DX
add EBX, EAX	;row is now correct
mov ESI, Column_Input
inc ESI	;next column to the right
movZX EAX, BYTE PTR [EBX+ESI]
cmp EAX, PlayerMarker
JNE CheckSideEnd
cmp EDI, 1		;check if the first left is a winning. if so
JE WinCondition	; 3 in a row (Left, middle, right)

inc ESI	;next next column to the right
movZX EAX, BYTE PTR [EBX+ESI]
cmp EAX, PlayerMarker
JE WinCondition

CheckSideEnd:
mov EDI, 0	;clear out EDI counter again
mov ECX, 0
CheckLowerLeft:	;-----
cmp Row_Input, 3
JE NotWin
mov EAX, 0
mov EDX, Row_Input
inc EDX		;set to row below
mov EBX, TableBAddr
movzx AX, RSize
mul DX
add EBX, EAX	;row offset
mov ESI, Column_Input
dec ESI		;left 1
movzx EAX, BYTE PTR [EBX+ESI]
cmp EAX, PlayerMarker
JNE CheckLowerRight
mov CH, 1			;lower left is a match
;lower lower left
mov EDX, Row_Input
sub EDX, 2	;next next row
mov EBX, TableBAddr
movzx AX, RSize
mul DX
add EBX, EAX	;row offset
mov ESI, Column_Input
sub ESI, 2
movzx EAX, BYTE PTR [EBX+ESI]
cmp EAX, PlayerMarker
JE WinCondition

CheckLowerRight:;-----------
mov EAX, 0
mov EDX, Row_Input
inc EDX		;set to row below
mov EBX, TableBAddr
movzx AX, RSize
mul DX
add EBX, EAX	;row offset
mov ESI, Column_Input
inc ESI	;right 1
movzx EAX, BYTE PTR [EBX+ESI]
cmp EAX, PlayerMarker
JNE CheckUpperLeft
mov CL, 1		;lower right is a match
;lower lower right check
add EBX, 4	;next row
inc ESI	;next column
movzx EAX, BYTE PTR [EBX+ESI]
cmp EAX, PlayerMarker
JE WinCondition

CheckUpperLeft:;------
cmp Row_Input, 0
JE NotWin
mov EAX, 0
mov EDX, Row_Input
dec Row_Input ;go up a row
mov EBX, TableBAddr
movzx AX, RSize
mul DX
add EBX, EAX	;row offset
mov ESI, Column_Input
dec ESI		;left one column
cmp ESI, 0
JB CheckUpperRight		;out of bounds
movzx EAX, BYTE PTR [EBX+ESI]
cmp EAX, PlayerMarker
JNE CheckUpperRight	;jump if it isnt a marker
cmp CL, 1			;otherwise, check diagonal, stored in CL
JE WinCondition		;3 in a row
;check upper upper left
sub EBX, 4	;next row up
dec ESI
movzx EAX, BYTE PTR [EBX+ESI]
cmp EAX, PlayerMarker
JE WinCondition
;otherwise, check the right side

CheckUpperRight:
mov EAX, 0		;reset
mov EDX, Row_Input
dec Row_Input	;up a row
mov EBX, TableBAddr	
movzx AX, RSize
mul DX
add EBX, EAX	;row offset
mov ESI, Column_Input
inc ESI		;right one column
cmp ESI, 4
JA	NotWin
movzx EAX, BYTE PTR [EBX+ESI]
cmp EAX, PlayerMarker
JNE NotWin
cmp CH, 1
JE WinCondition
;check upper upper right
sub EBX, 4		;next row up
inc ESI	;next column right
movzx EAX, BYTE PTR [EBX+ESI]
cmp EAX, PlayerMarker
JE WinCondition
jmp Notwin

WinCondition:
mov EAX, 1
jmp ExitCheckWin

NotWin:
mov EAX, 0

ExitCheckWin:
ret
CheckWin ENDP
;----------------------------GAME STATE------------
GameState PROC,
TableBAddr: PTR BYTE
;Desc: Checks if every slot is full, thus ending the game
;Takes: Offset of TableB
;Returns: in EAX, 0 if game is over
.data
.code
mov EAX, 0		;comparer
mov EBX, 0		;counter
mov EDX, TableBAddr	;offset
mov ESI, 0		;traveler
mov ECX, 4		;4 rows
countLoop:
movZX EAX, BYTE PTR [EDX+ESI]
cmp EAX, 0
JE nextvalue
inc EBX		;if it has a value other than 0, incrememnt EBX
nextvalue:
inc ESI
loop countLoop

cmp EBX, 4
JAE EndGame
mov EAX, 1		;set gamestate to true
jmp ExitGameState	;not equal to 4. Return

EndGame:
mov EAX, 0

ExitGameState:

ret
GameState ENDP
;---------------Game Win--------------
GameWin PROC
;Desc: Displays a winning message and asks if user wants to play again
;Takes: nothing
;Returns: EAX 1 if play again, anything else is no
.data
WinnerMessage BYTE "You win! Would you like to play again?",0Ah,0Dh,
"1. Yes",0Ah,0Dh,
"2. No",0Ah,0Dh,0

.code
mov EDX, offset WinnerMessage
call WriteString
call ReadDec
ret
GameWin ENDP


;--------------clear board------------
;This is the one time I will treat tableB as an array to stay sane
ClearBoard PROC uses EDX ESI,
TableBAddr: PTR BYTE
;Desc: Clears the board and sets it to 0s
;Takes: offset of TableB
;Returns: nothing
.data
.code
mov EBX, TableBAddr
mov ESI, 0
mov ECX, 16

cleaner:
mov BYTE PTR [EBX+ESI], 0
inc ESI
loop cleaner
ret
ClearBoard ENDP

;-------------------GAME OVER-----------------
GameDone PROC
;Desc: Displays game over. Asks if you would like to play again
;Takes nothing
;Returns EAX 1 if you want to play again. anything else is no
.data
GameOverMessage BYTE "Game Over. Would you like to play again?",0Ah,0Dh,
"1. Yes",0Ah,0Dh,
"2. No",0Ah,0Dh,0

.code
mov EDX, offset GameOverMessage
call WriteString
call ReadDec

ret
GameDone ENDP

;----------------------EVERYTHING FOR PRINTING IS HERE------------
PrintTable PROC,
TableBAddr:PTR BYTE
;Desc:Prints the board
;Takes:offset of TableB
;returns:nothing. Prints board
.DATA
PrintLine BYTE "---------",0aH,0DH, 0

.CODE
pushad
mov EDX, offset PrintLine
call WriteString

mov ECX, 4
mov EDX, TableBAddr
PrintRow:
	push ECX	;saves counter for COLUMNS
	;print first edge
	mov AL, 7Ch		;"|"
	call WriteChar
	mov ECX, 4
	mov ESI, 0

	PrintCol:
		movZX EBX, BYTE PTR [EDX+ESI]		;first value of array
		cmp EBX, 0
		JE PBlack
		cmp EBX, 1
		JE PBlue
		cmp EBX, 2
		JE PYellow
	
		PBlack:
		call PrintBlack
		jmp Nexter
		PBlue:
		call PrintBlue
		jmp Nexter
		PYellow:
		call PrintYellow
		jmp Nexter
	
		Nexter:
		mov EAX, white (black*16)
		call SetTextColor
		;another border
		mov AL, 7Ch	
		call WriteChar
		inc ESI		;next value in TableB
	loop PrintCol
	pop ECX
	call CRLF
	mov ESI, 0		;reset ESI
	add EDX, 4		;move 4 bytes, now its next row
loop PrintRow

mov EDX, offset PrintLine
call WriteString
popad
ret
PrintTable ENDP
;---------------FOR PRINT-------------------------
PrintYellow PROC
.data
.code
mov eax, yellow + (yellow*16)
call SetTextColor
mov EAX, EBX
call WriteChar

ret
PrintYellow ENDP

PrintBlack PROC
.code
mov eax, black + (black*16)
call setTextColor
mov EAX, EBX
call WriteChar
ret
PrintBlack ENDP

PrintBlue PROC
.code
mov eax, blue + (blue*16)
call setTextColor
mov EAX, EBX
call WriteChar
ret
PrintBlue ENDP


END main	;exit program