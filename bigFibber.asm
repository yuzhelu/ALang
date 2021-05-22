
Include Irvine32.inc

ClrEAX TEXTEQU <mov EAX, 0>
ClrEBX TEXTEQU <mov EBX, 0>
ClrECX TEXTEQU <mov ECX, 0>
ClrEDX TEXTEQU <mov EDX, 0>

.data

;compute fib(n) for n = 2,3,4,5,6

fibA BYTE 0				;Initial values given
fibB BYTE 1		
FibArray BYTE 4 DUP(0)	;creates the array to hold completed fib values


.code
main PROC
	
	;first fib 0,1
	ClrEAX	;store first
	ClrEBX	;reserve EBX for final
	ClrECX	;store second
	ClrEDX	;add first and second

	;I will use ECX and EDX registers store values

	mov al, fibA			;al = 0
	mov cl, fibB			;cl = 1
	add dl, al				;adds the first value (n-2)
	add dl, cl				;adds the second value (n-1)
	

	;second fib, 1,1
	mov al, fibB			;sets the second initial to al (al = 1)
	;mov cl, fibArray		;puts the new sum into cl as n-1
	mov cl, dl				;moves value of dl into cl
	ClrEDX					;clears the register for next computation
	add dl, al				;adds n-2
	add dl, cl				;adds n-1
	mov [fibArray], dl

	;third fib 1,2
	ClrEDX					;clears register for computation
	mov ESI, OFFSET fibArray	;sets ESI pointer to the first element in fibArray
	mov al, [ESI]			;sets first element of array to al. al = 1
;	inc ESI					;moves ESI to second element
;	mov cl, [ESI]			;secs second to cl. cl = 2
	add dl, al
	add dl, cl
	mov [FibArray + TYPE fibArray], dl

	;forth fib, 2,3
	ClrEDX
	mov al, [ESI]		;al = 2
	inc ESI
	mov cl, [ESI]		;cl = 3
	add dl, al
	add dl, cl
	mov [FibArray + (TYPE FibArray + TYPE FibArray)], dl

	;fifth, 3,5

	ClrEDX
	mov al, [ESI]	;al = 3
	inc ESI
	mov cl, [ESI]	;cl = 5
	add dl, al
	add dl, cl		;dl = 8
	mov [FibArray + (TYPE fibArray + TYPE FibArray + Type FibArray)], dl
	;FibArray = [1, 2, 3, 5, 8]
	; need to put to EBX

	mov EBX, DWORD PTR fibArray	;sets values into EBX register

	mov ESI, 0	;clear esi

	
	clrEDX
	clrEAX
	call dumpregs

	exit
	main ENDP
	END main
