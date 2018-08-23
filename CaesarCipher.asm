;Decription assignment 6
;Yuzhe Lu
;This program will ask user to select encrypt or decrypt, ask  them to enter a string and a key, and will encrypt or decrypt the key using a Caesar Ciper
;due 11/10/2017
;Compiled and tested on Windows 10 using VS


include irvine32.inc

maxStringLength = 51 ;51 because of a null terminator at the end

clearEAX TEXTEQU <mov eax, 0>
clearEBX TEXTEQU <mov ebx, 0>
clearECX TEXTEQU <mov ecx, 0>
clearEDX TEXTEQU <mov edx, 0>
clearESI TEXTEQU <mov esi, 0>
clearEDI TEXTEQU <mov edi, 0>

.data
UserOption BYTE 0h			; to hold an integer that the user enters
;User entered string to encrypt/decrypt
theString BYTE maxStringLength DUP (0)
theStringLength BYTE ? 	;user entered string length. NOT max length
;User Entered KEY
keyString BYTE maxStringLength DUP (0)	;a keyString of maxlength filled with 0's
keyLength BYTE ?						;to hold the length of the key
errorMessage BYTE 'Entry not vaild. returning to main menu',0

.code
main PROC

clearEAX
clearEBX
clearECX
clearEDX
clearESI
clearEDI

;call menu function
startHere:	;label
;clear the STRING each time
mov EDX, offset theString
mov ECX, maxStringLength

call DisplayMenu	;displays the menu
call ReadHex	;takes user input. Stores in EAX
mov UserOption, AL	;stores it in UserOption

;compare user options
cmp UserOption, 1
JE EOption
cmp UserOption, 2
JE DOption
cmp UserOption, 3
JE endit
jmp emsg

;---------ENCRYPTION PROCESSES--------------------
EOption:	;Encryption

;-----STRING-------
;enter the string they would like to encrypt
mov EDX, offset theString
mov ECX, maxStringLength

call EnterString	;call enter string function

mov theStringLength, AL 	;sets theString length returned in EAX

;-----KEY----------
mov EDX, offset keyString
mov ECX, maxStringLength
clearEAX	;clears EAX

;CHECK IF THERE IS A PREVIOUS STRING
mov AL, BYTE PTR [EDX]		;grabs the initial value. checks if its = to 0

cmp AL, 0
JE enterAkey	;if 0, go to key entry

;IF THERE IS, ASK IF THEY WANT TO ENTER A NEW ONE
;IF NO, JUMP TO SKIP KEY
;OTHERWISE, ENTER A NEW KEY BELOW
call keyquery
cmp AL, 0
JE skipkey
;otherwise, enter a key

enterAkey:
clearEAX
call keyEntry	;call to set up key
mov keyLength, AL ;sets keyLength to the value returned in EAX
;string and key all set. Begin encryption process

skipkey:

;------STRING EDIT------------
;remove all non lettered
movzx ECX, theStringLength
mov EDX, offset theString
mov EBX, offset theStringLength
;ESI preserved
call CharOnly	;uses ECX, EDX, ESI, PRESERVED
;change all into capitals
call Capitalize ;uses ECX, EDX, PRESERVED
mov theStringLength, AL

;all caps and only letters now. begin actual encryption
;-------ENCRYPT-------
mov EDX, offset theString	;next 4 steps as Encrypt PROC setup
mov EBX, offset keyString
movzx ECX, theStringLength
movzx EAX, keyLength

call Encrypt

;print encryption
mov EDX, offset theString	;print the encryption now
movzx ECX, thestringlength
call printString

;end encryption. Jump to startHere
call crlf
call waitmsg

jmp startHere

;------------------------------------------------
;---------DECRYPTION PROCESSES-------------------
;------------------------------------------------

DOption:	;Decryption

;begin decryption process
;----------STRING----------------------
mov EDX, offset theString
mov ECX, maxStringLength

call EnterString

mov thestringlength, AL

;----------KEY-------------
mov EDX, offset keyString
mov ECX, maxStringLength
clearEAX

;check if there is a previous string
mov AL, BYTE PTR [EDX]
cmp AL, 0
JE newKey

;if there is a key, ask if they want to re enter
call keyquery
cmp AL, 0
JE skipDkey
;otherwise enter a key


newKey:
clearEAX
call keyEntry
mov keyLength, AL

skipDkey:

;--------STRING EDIT------------
;remove all non lettered
movzx ecx, theStringLength
mov EDX, offset theString
mov EBX, offset thestringlength
call CharOnly
call Capitalize
mov thestringlength, AL

;String to decrypt is all letters and CAPS now
;----------Decrypt--------------
mov EDX, offset theString 
mov EBX, offset keyString
movzx ECX, theStringLength
movzx EAX, keyLength

call Decrypt

;print
mov EDX, offset thestring
movzx ECX, thestringlength
call printString

;end Decryption process
call crlf
call waitmsg

jmp startHere

;--------ERROR MESSAGES-------------------------
emsg:
mov EDX, offset errorMessage
call WriteString;
jmp startHere

;-------END-------------------------------------

endit:
exit
main ENDP

;----------END MAIN--------------------------------------------------------------------------------------------





;--------------FUNCTIONS------------------------------------------------------------------------------------------

;----------MENU DISPLAY-------------------------
DisplayMenu PROC USES EDX
;-----------------------------------
;Desc: Displays the menu for the user to enter their string. Asks the user
;if they want to encrypt or decrypt a string
;Takes: Nothing
;Returns: Nothing
;-----------------------------------
.data
menuPrompt BYTE "Main Menu", 0Ah, 0Dh,	;Display menu
"===============", 0Ah, 0Dh,
"Would you like to: ", 0Ah, 0Dh,
"1. Encrypt", 0Ah, 0Dh,
"2. Decrypt", 0Ah, 0Dh,
"3. Quit", 0Ah, 0Dh, 0h
.code
call clrscr		;clear screen
mov EDX, offset menuPrompt
call WriteString
ret
DisplayMenu ENDP


;--------------STRING ENTRY----------------------
EnterString PROC uses ECX
;------------------------------------
;Disc: Asks the user to enter a string to encrypt/decrytpt. This will store the value into theString
;Takes: EDX as offset of theString array
;Returns: the length of the string in EAX. PROC will also fill theString array with values
;------------------------------------
.Data
stringMsg BYTE "Please enter the string: ",0
.code
;push ECX
push EDX ;save EDX
mov EDX, offset stringMsg	;assign for WriteString
call WriteString		;print out stringMsg
pop EDX		;restore to offset theString
call ReadString	;Irvine
;pop ECX
ret		;returns length of theString as EAX
EnterString ENDP

;-----------KEY QUERY-------------------------------------

keyquery PROC uses EDX
;Desc: Asks user if they want to enter a new key
;Takes: nothing
;returns in EAX 1 if they want to enter a new key, 0 if they do not
.data
message BYTE "Would you like to enter a new key? 1 = yes, 0 = no", 0Ah, 0Dh, 0
Emesg BYTE "Invalid answer",0
.code
start:
mov EDX, offset message	;ask if they would like to enter a new key
call WriteString
call ReadInt
;check to see response
cmp AL, 0
JE contin
cmp AL, 1
JE contin
;if its not 1 or 0
mov EDX, offset Emesg
call WriteString
jmp start

contin:
ret
keyquery ENDP

;----------------KEY ENTRY-----------------------
keyEntry PROC uses ECX
;------------------------------------
;Desc: Ask the user the enter a key
;Takes the offset of EDX as the array to the key
;returns: size of the key in EAX
;====================================
.data
keyMsg BYTE "Please enter the key: ",0Ah, 0Dh, 0

.code
;push ECX
push EDX	;saves offset location
mov EDX, offset keyMsg	;assign for WriteString
call WriteString		;print out keyMsg
pop EDX		;restore offset location
call ReadString	;Irvine. Reads user input and puts it in the array keyString
;pop ECX
ret
keyEntry ENDP


;--------SET CHARACTERS ONLY--------------------
CharOnly PROC USES ecx edx esi
;// Description:  Removes all non-letter elements
;// Receives:  ecx - length of string
;//            edx - offset of string
;//            ebx - offset of string length variable
;//            esi preserved
;// Returns: string with all non-letter elements removed
.data
tempstr BYTE 50 dup(0)        ;// hold string while working - 
.code
;// preserve edx, ecx
push edx
push ecx
mov ESI, 0
;// clear tempstr for repeated calls from main
mov edx, offset tempstr
mov ecx, 50
call ClearString
;// restore ecx, edx
pop ecx
pop edx
push ecx                      ;// save value of ecx for next loop
clearEDI                      ;// use edi as index to step through the string
L3:
mov al, byte ptr [edx + esi]  ;// grab an element of the string
;// check to see if the element is a letter.  
cmp al, 5Ah
ja lowercase    ;// if above 5Ah has a chance of being lowercase
cmp al, 41h     ;// if below 41h will not be a letter so skip this element
jb skipit
jmp addit       ;// otherwise it is a capital letter and should be added to our temporary string
lowercase:
cmp al, 61h     
jb skipit       ;// if below then is not a letter but is in the range 5Bh and 60h
cmp al, 7Ah     ;// if above then it is not a letter, otherwise it is a lowercase letter
ja skipit
addit:          ;// if determined to be a letter, then it must be added to the temp string
mov tempstr[edi], al
inc edi         ;// move to next element of theString
inc esi         ;// move to next element of temp string
jmp endloop     ;// go to the end of the loop
skipit:         ;// skipping the element 
inc esi         ;// go to next element of theString
endloop:
loopnz L3
;mov [ebx], edi   ;// updates length of string
pop ecx         ;// restores original value of ecx for the next loop

mov EAX, EDI
push EAX
;// copies the temp string to theString will all non-letter elements removed
clearEDI
L3a:     
mov al, tempstr[edi]
mov byte ptr [edx + edi], al
inc edi
loop L3a
pop EAX

ret
CharOnly ENDP


;---------------CAPTIAL LETTERS--------------------
Capitalize PROC uses ECX EDX
;Desc: Given a string, turn all letters into capital letters
;Takes: EDX as offset of the string ECX as the length of the string
;Returns:The passed in string will be capitals
.data
.code
L1:
	AND BYTE PTR [EDX], 11011111b	;clear bit 5
	inc EDX
	loop L1
ret
Capitalize ENDP

;----------------CLEAR STRING----------------------
ClearString PROC USES EDX ECX ESI
;Description:  Clears a byte array given offset in edx and length in ecx
;Receives: Offset of string to be cleared in edx
;          length of string to be cleared in ecx
;Returns: nothing
;// increment through the passed array and set every element to zero
clearESI
ClearIt:
mov byte ptr [edx + esi], 0
inc esi
loop ClearIt
ret
ClearString ENDP


;-------------PRINT STRING--------------------------
PrintString PROC uses EBX ECX EDX
;Desc: print out the string passed in.
;Takes: EDX as the offset of a string
;		ECX as the size of the string
;Returns: nothing
.data
quotent BYTE 0	;the number of big loops
remainder BYTE 0	;characters remaining after big loops
.code
;I will use DIV to divide the string length by 5. the quotent will be
;used as a counter to loop. within the loop, it will print out five characters
;and then a space. this will loop 'quotent' times. then I will push into ECX the
;remainder and print out the last remaining characters.

;push EDX	;saves EDX offset location
;mov EDX, 0	;clear the register
mov EAX, 0	;clear the EAX register
mov ESI, 0	;for traversal later

;get the quotent and remainder for the loop
mov ax, cx	;dividend, high
mov bl, 5	;divisor
div bl		;AL = quotent, AH = remainder

mov quotent, AL
mov remainder, AH
;pop EDX ; returns the string offset

movzx ECX, quotent ;set number of big loops
loop1:	;print string big loop
		push ECX	;saves the big loop counter
		mov ECX, 5	;to loop next loop 5 times
		loop2:	;print a character, increment ESI
			mov AL, BYTE PTR [EDX+ESI]
			call WriteChar
			inc ESI
			loop loop2
		;print a space
		mov AL, 20h
		call WriteChar
		pop ECX	;restore original ECX counter, then decrement in loop
loop loop1
;check if there are any remaining letters to print out of the groupings
cmp remainder, 0
JE endit	;to skip remainder printing

;print remainder
movzx ECX, remainder
loop3:
	mov AL, BYTE PTR [EDX+ESI]
	call WriteChar
	inc ESI
loop loop3

endit:

ret
PrintString ENDP

;-------------------ENCRYPTION FUNCTIONS----------------------------------
Encrypt PROC uses EDX ECX ESI EDI EBX
;Desc: Encrypts the string passed in by EDX with the string passed in by ECX
;Takes: offset of theString - EDX
;		offset of keyString - EBX
;		size of theString in - ECX
;		size of keyString in EAX

;		uses EDI to traverse theString
;		uses ESI to traverse keyString

.data
Ssize BYTE ? 	;holds the string size
keySize DWORD ? 	;holds key size

shift BYTE ?

.code
mov ESI, 0		;clear travelers
mov EDI, 0

mov keySize, EAX ;store keySize
mov Ssize,  CL

loop1:
	push EAX		;push the keysize location to save and free EAX
	EDICheck:
	cmp EDI, EAX	;see if EDI has reached the keyString limit
	JB cont		;if not, jump to continue
	mov EDI, 0			;if it has, reset EDI
	
	cont:

	movzx EAX, BYTE PTR [EBX+EDI]	;move zero extend a byte in the keyString to AX, the dividend
	call FindShift	;call function. should return in EAX, the value of the quotent and remainder
	mov shift, AH	;move the remainder into the shift (this is equal to x mod 26
	;we have the shift now, now see if it exceeds bounds
	inc EDI	;increment to the next value of the key
	
	mov EAX, 0
	mov AL, BYTE PTR [EDX+ESI]	;put the byte value in the array into al
	add AL, shift				;add shift to AL, then test the value
	
	cmp AL, 5Ah	;compare to 'Z'
	JBE keepgoing	;if the added value is below 'Z', jump to keep going

	;OUT OF BOUNDS BELOW
	;we need to find the difference between Z, and the letter we are at now. 
	;Then subtract the difference from the shift value, and finally add the remaining shift value from 41h, the begining of the capital alphabet
	push ECX	;save count
	mov ECX, 0
	sub AL, shift	;return AL to the original byte value from array
	mov CL, 5Ah	;moves final value into C
	sub CL, AL	;finds the difference from final
	mov AH, shift
	sub AH, CL ;shift is now the value that needs to be added from the beginging (41h)
	mov al, 41h 	;set al at the beginging
	add al, AH	;al is now at the new value
	sub AL, 1	;because math
	mov BYTE PTR [EDX+ESI], AL	;move to the byte pointed to at ESI, the value in AL. This is the new value
	pop ECX ;returns the count value
	inc ESI	;next theString location
	pop EAX	;returns the keysize
	loop loop1
	;out of bounds done, exit
	jmp ex1t
	;IN BOUNDS BELOW
	keepgoing:
	add AL, AH
	mov BYTE PTR [EDX+ESI], AL
	inc ESI
	pop EAX
	loop loop1

	ex1t:

ret
Encrypt ENDP

;--------------------------------------------------
;--------------DECRYPTION--------------------------
Decrypt PROC uses EDX ECX ESI EDI EBX
;Desc: Decrypts the string bassed in by EDX with the key passed in by EBX
;Takes: Offset of theString - EDX
;		offset of keyString - EBX
;		size of theString	- ECX
;		size of keyString	- EAX
;		traverse theString  - EDI
;		traverse keystring 	- ESI
.data
Lshift BYTE ?

.code

mov ESI, 0
mov EDI, 0	;clears traversals


LooD:
	push EAX	;saves keystring size
	EDIChk:
	cmp EDI, EAX	;see if EDI has reached the keyString limit
	JB contine
	mov EDI,0		;if its reached limit, reset
	
	contine:
	movzx EAX, BYTE PTR [EBX+EDI]	;move byte in the key to AX, the divinend
	call FindShift	;find shift value, returns in EAX
	mov Lshift, AH	;move it to the shift value
	inc EDI	;increment to next value
	
	mov EAX, 0
	mov AL, BYTE PTR [EDX+ESI]	;moves byte value of theString into al
	sub AL, Lshift	;subtracts the shift amount from AL
	
	cmp AL, 41h	;compare to 'Z'
	JAE keepitup	;if the subtracted value is 'A' or above, jump to keepitup
	
	;out of bounds below
	push ECX	;save count
	mov ECX, 0
	add AL, Lshift	;returns the value of theString byte
	mov CL, 41h		;puts "A" into CL
	sub AL, CL		;Al becomes the difference between the current location and 41h
	mov AH, Lshift
	sub AH, AL		;subtract from shift, the difference. difference in AH
	mov AL, 5Ah		;sets it at 'Z'
	sub AL, AH		;subtract from 'Z', the shift value (left shift)
	add AL, 1		;because math
	
	mov BYTE PTR [EDX+ESI], AL	;move the AL value into theString location
	pop ECX 	;return the count value
	inc ESI		;next value in thestringlength
	pop EAX		;returns keystringSize
	loop LooD
	;in bounds below
	jmp eit	;exit

	keepitup:
	mov BYTE PTR [EDX+ESI], AL	;move the left shifted value into the key
	inc ESI	;next string value
	pop EAX	;return the keystringSize
	loop LooD

	eit:
ret
Decrypt ENDP


FindShift PROC uses EBX ECX
;takes the value passed in EAX, and finds the shift value associated with it
;Takes: value passed in EAX
;Returns in EAX, the shift value

.data
.code
;EAX contains the key value
mov ECX, 0	;clear ECX to use
mov CX, AX	;moves the value in AX, into CX
mov EAX, 0
mov AX, CX	;i think this is redundant, but im following the book example to set up the right registers

mov bl, 26d	;Divisor
DIV bl	; AL = quotent, AH = Remainder
ret
FindShift ENDP

end main