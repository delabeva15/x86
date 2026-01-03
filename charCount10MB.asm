;charCountingComplete counts the amount of chars in an input message and can
;go beyond a length of 9 charecters- up to 10,000.
;
;author: Evan Delabarre
;1/2/2026

global _start

section .text

_start:
	mov rcx,inputLabel	;load input label 
	mov rdx,inputLabelSize	;size
	call write		;syscall write
	call read		;size of string returned into rax
	xor rcx,rcx		;used for char counting
	mov bl,0x0A		;newline char indicated end of message

charCount:
	mov al,[stringBuffer+rcx]	;checking one byte at a time (one char)
	inc rcx	
	cmp al,bl		;compare current char with 0x0A
	jnz charCount		;if non-zero (non-equal) goto charCount (keep counting)
	dec rcx			;newline charecter is not included in char count

postCount:
	mov rax,rcx		
	mov rcx,0xa		;adding newline to end of number display for clean output 
	mov [numberOfChars+8],rcx
	mov rcx,7		;next memory addr. (accessing "backwards" for optimal display)

divCount:
	mov rbx,10		;divisor
	xor rdx,rdx		;clearing remainder- ensures no exceptions
	div rbx			;divide rax with 10, dl is remainder
	add dl,'0'		;adding value of '0' to number 0-9
	mov [numberOfChars+rcx],dl	;put number (0-9) into display buffer
	dec rcx			;next spot in display buffer
	cmp rax,0		
	jnz divCount		;keep dividing if rax isn't 0
	
countOutput:
	mov rcx,numberOfChars	
	mov rdx,9		;size of numberOfChars
	call write		;syscall- display charecter count
	
exit:
	mov rax,0x1		;safe exit
	mov rbx,0
	int 0x80

write:
	mov rax,0x4			;write syscall
	mov rbx,1			;stdout
	int 0x80			;invoke syscall
	ret				;return

read:
	mov rax,0x3			;syscall read
	mov rbx,0			;stdin
	mov rcx,stringBuffer		;load string buffer (memory area)
	mov rdx,10000000		;storing up to 10MB of text
	int 0x80			;invoke syscall
	ret				;return

section .bss
	stringBuffer resb 10000000	;storing up to 10MB of text (during runtime)
	numberOfChars resb 9		;8 plus newline

section .data
	inputLabel db "Enter text: "
	inputLabelSize equ $ - inputLabel  
