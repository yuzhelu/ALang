;Author: Yuzhe Lu
;Tested and compiled on my laptop running Windows 10, Visual Studio 2015

Include Irvine32.inc

maxStringLength = 51d	;51 because of a null terminator at the end

clearEAX TEXTEQU <mov eax, 0>
clearEBX TEXTEQU <mov ebx, 0>
clearECX TEXTEQU <mov ecx, 0>
clearEDX TEXTEQU <mov edx, 0>
clearESI TEXTEQU <mov esi, 0>
clearEDI TEXTEQU <mov edi, 0>
;cannot use string operations other than readstring/writestring

.data

UserOption BYTE 0h			; to hold an integer that the user enters
theString BYTE maxStringLength DUP (0)
theStringLength BYTE ? 	;user entered string length. NOT max length
errorMessage BYTE 'Entry not vaild. returning to main menu',0
stringMessage BYTE 'First ',0

.code
;need copy procedure
;clear procedure
;need a working string
;can use read string, write string

main PROC
clearEAX
clearEBX
clearECX	
clearEDX
clearEDI
clearESI

startHere:
call DisplayMenu
call ReadHex	;irvine library. Stores in EAX
mov UserOption, al

mov edx, Offset theString
mov ecx, lengthof theString


cmp UserOption, 6		;compares to 6
JE opt6			;jump if equals to option 6 (exit)
;its not 6, now see if there is a string yet


opt1:
cmp UserOption, 1
Jne	opt2	;jump if NOT equal, to option 2
call clrscr
mov ecx, maxStringLength
call option1	;this IS equal (Jne ignored)
mov theStringLength, al	;moves new length into theStringLength
jmp startHere	;return to menu

opt2:
;added this
mov al, byte ptr [EDX]	;move the first element of the array al
cmp al, 0		;check if its equal to 0 (empty)
jne gogogo		;if its not equal, jump to go, continuing the process
;else
call emsg		;call error message print
jmp startHere	;go to menu
;to this

gogogo:
cmp UserOption, 2	;compare to option 2
jne Opt3			;if not equal, jupt to 3
movzx ecx, theStringLength	;if equal, move length into ECX, call function
call option2
mov theStringLength, CL	;move the new length into the string
jmp startHere	;start over

opt3:
cmp UserOption, 3
jne Opt4
movzx ECX, theStringLength
call clrscr
call option3
jmp startHere

opt4:	;palindrome
cmp UserOption, 4
jne Opt5
movzx ecx, theStringLength
call option4
;mov theStringLength, al
jmp StartHere

opt5:	;print
cmp UserOption, 5
jne Opt6
;movzx ECX, theStringLength
call option5
jmp StartHere

opt6:	;quit
cmp UserOption, 6
je quitit
call oops
jmp StartHere

emessage:
call emsg

quitit:
exit	;exit of main
main ENDP

;---------------------------------
displayMenu PROC uses EDX
;---------------------------------
;Discription: displays menu
;recieves: nothing
;returns: nothing

.data
Menuprompt1 BYTE 'MAIN MENU', 0Ah, 0Dh,
'=========', 0Ah, 0Dh,
'1. Enter a string', 0Ah, 0Dh,
'2. Convert the string to lower case', 0Ah, 0Dh,
'3. Remove all non-letter elements', 0Ah, 0Dh,
'4. Is the string a palindrome?', 0Ah, 0Dh,
'5. Print the string', 0Ah, 0Dh,
'6. Quit', 0Ah, 0Dh, 0h

.code
call clrscr
mov edx, Offset Menuprompt1
call WriteString
ret

displayMenu ENDP

;------------------------------
option1 PROC uses ecx
;------------------------------
;Description: get string from user
;Recieves: offsete of string in edx, maxlength in ecx
;Returns: user entered string Offset not changed
;		length of string returned in EAX
.data

userPrompt1 BYTE "Enter your string -->",0

.code
push edx	;saves string location
mov edx, offset userPrompt1		;get ready to print message
call writeString	;reads userPrompt1
pop edx			;restores offset of string	reset edx
call ReadString	;get user input,
ret			;return
option1 ENDP

;-------------------------------
option2 PROC uses edx ecx edi
;-------------------------------
;Discription:	converts string to lowercase
;Recieves:		offset of string in edx, maxlength in ecx
;Returns:		Original string with all captial letters
;				converted to lowercase in EDX

;you want to change the values from 41h ('A') and 5Ah ('Z')
;if its in that range, do something, otherwise move to the next character
;aka ifh 40 <= x <= 5Ah
;x[i]20
;else i++

loop2:
mov al, byte PTR [edx+edi]	;offset of the string + edi(initially 0 because we cleared it. initially grabs first element
;check if out of range
cmp al, 41h
jb keepgoing	;if its below, jump to keep going
cmp al, 5Ah
ja keepgoing	;if its above

;now you are within range
add al, 20h		;adds 20h to get into lowercase range
mov byte ptr [edx+edi], al	;move the value into edi
;we use ptr because offset has NO SIZE AFFILIATED WITH IT
keepgoing:
inc edi	;increment to the next value
loop loop2

ret

option2 ENDP

;-------------------------------------------
option3 PROC 
;-------------------------------------------
;Description: remove all non letter elements
;Recieves: ECX as string length
;Uses: EBX as second string location, ecx as counter, EDX as the offset of theString,
;			edi as traveling pointer of theString, esi pointer for newString

;Returns: string with all non character values removed
;			length of string returned in EAX

;check if below 41h
;if yes, remove it
	;if its a letter, copy it to another string (copy function must be WRITTEN)
	;maintain 2 strings with 2 different indicides
	;length of string is the index
	;copy back to original
	;original one needs to be cleared first
	;they have to be null terminated!
	;could use a stack, but it takes 32B
	

;check if above 5Ah, chance its lowercase
.data
newString BYTE maxStringLength DUP(0)
;newLength BYTE ? ;length of new string
counter BYTE 0	;to hold count of new string
slength BYTE 0	;holds the passed in ECX value

.code

mov EBX, OFFSET newString	;moves eax to the offset of newString
mov slength, CL				;moves the size of the string into memory for later use

clearESI	;set ESI to 0
clearEDI	;seet EDI to 0

loop3:	;traverse array and see if the value is a character
		;characters are 41h to 5Ah, and 61h to 7Ah
		;uses ECX as a counter. ECX is equal to the length of theString
		
mov al, byte ptr [edx+edi]	;grab element of string
cmp al, 41h		;compare to 'A'
jb keepgoing	;increment to next if below
cmp al, 5Ah		;compare to 'Z'
jle found		;al is greater than 'A' or less/equal to "Z". This is a letter
;else
cmp al, 61h		;compare to 'a'
jl keepgoing	;this is less than 'a', but greater than 'Z'
cmp al, 7Ah		;compare to 'z'
jg keepgoing	;jump if greater

;else, character found between 61h and 7Ah, move on to 'found:"

;copy the value at [edx+edi] into [ebx+esi], increment edi and esi
FOUND:
mov byte ptr [EBX+ESI], al	;puts the value of al into dereferenced EBX+ESI
inc ESI	;moves to the next value of newString
inc EDI	;moves to the next value of theString
add counter, 1	;tracking
;this loop is skipped if not found
loop loop3
jmp nxt

;This was not found
keepgoing:
inc edi		;next value
loop loop3

nxt:
;now we need to clear the old string before copying in the new one
clearESI
clearEDI	;sets travelers back to beginging

movzx ECX, slength	;resets counter to length of original
mov al, 0	;set to 0 for clearing
clearloop:
mov byte ptr [EDX+EDI], al	;moves 0 into the byte
inc EDI				;next value
loop clearloop		
;now all of theString should be equal to 0

mov CL, counter	;moves the counter, length of new string, into the ECX counter
mov ESI, 0		;resets ESI

loop3b:	;copy elements back into array
;take the element in newString and put it in 
mov al, byte ptr [EBX+ESI]	;grab first element in newString
mov byte ptr [EDX+ESI],al	;move it into the first element of theString
inc ESI
loop loop3b

movzx ECX, counter

ret
option3 ENDP

;--------------------------
option4 PROC uses EDX ECX
;-----------------------------
;Description: checks if the string is a palindrome. Prints to screen
;if it is or isnt.
;Receives offset of theString in EDX, and length of string into ECX
;Returns nothing

.data
count byte 0
equalMessage BYTE "The string is a palindrome",0
nEqualMessage BYTE "The string is not a palindrome",0

.code
clearEAX
clearEBX

mov ESI, 0
mov count, cl

loop4:
mov al, byte ptr [EDX+ESI]	;grab element of a string
push EAX		;push that value on the stack
inc ESI
loop loop4
;now the stack will contain the array

mov CL, count

mov ESI, 0	;reset ESI

;loop through array, each time popping EAX to compare the values in reverse order
loop4A:
mov BL, byte ptr [EDX+ESI]	;moves the value of the new string into BL
pop EAX						;pops back the last value on stack
cmp AL, BL					;compares it with BL
jne notEqual				;if not equal, jump to location
;otherwise
inc ESI						;its equal, check next value
loop loop4A


;loop completed without jne to notEqual, aka loop equals
mov EDX, offset equalMessage	;print equal message
call writeString
call crlf
call waitmsg

jmp qit	;jump to exit

;cleans out stack
notEqual:
dec ECX		;decreases ECX by one. because math
dumpEAX:	;dumps the stack for the amount in ECX, so ret will return the right EIP
pop EAX
loop dumpEAX

mov EDX, offset nEqualMessage	;print not equal message
call writeString
call crlf
call waitmsg

qit:
ret
option4 ENDP

;--------------------
option5 PROC uses EDX	
;--------------------
;Description: Prints out the string
;Uses EDX as offset of theString
;returns nothing
.data

.code
mov EDX, offset theString	;sets EDX to the string offset
call WriteString
call crlf
call waitmsg

ret

option5 ENDP

;-------------------
oops PROC uses EDX
;-------------------
;Description: Prints error message
;Recieves: nothing
;Returns: nothing

.data
oopsmessage BYTE 'Please enter a vaild choice',0

.code
mov EDX, offset oopsmessage
call writeString

ret
oops endp

;-------------
emsg PROC uses EDX
;-------------
;Description: prints string is empty message
;Recieves: nothing
;Returns: nothing

.data

message BYTE 'String is empty',0

.code

mov EDX, offset message
call WriteString
call crlf
call waitmsg
ret
emsg endp
;--------------

end main ;exit program
