;creating a few random numbers with syscall 318
;ssize_t getrandom(void *buf, size_t buflen, unsigned flags)
;
;this program relies on the read syscall for user input and prints
;out numbers in a slot-machine format every time enter is pressed
;if any other key and then enter is pressed, it closes.
;
;TODO work on win detection
;
;author Evan Delabarre
;1/20/2026

global _start

section .text

_start:


prep:
	mov rcx,3
	push rcx	

main_loop:
	call random

	mov al,0xa
	mov [displayBuffer+7],al

	mov rax,[numBuffer]
	mov rcx,6
	call divide_and_print
	
	xor rcx,rcx
	pop rcx
	dec rcx
	push rcx
	cmp rcx,0
	jne main_loop

	pop rcx

	call win_detection

user_input:
	mov rsi,readVal
	mov rdx,2
	call read

clearing_screen:
	mov rsi,clearTerminal
	mov rdx,clearLen
	call write

analyze_user_input:
	mov al,[readVal]
	cmp al,0xa
	je prep

exit:
	mov rax,60
	mov rsi,0
	syscall

win_detection:
	mov al,[numBuffer]
	mov ah,[numBuffer+2]
	mov bl,[numBuffer+4]
	mov bh,[numBuffer+6]

	cmp al,bl
	jne user_input

	mov rsi,winner
	mov rdx,winnerLen
	call write
	ret

random:
	mov rax,318
	mov rdi,numBuffer
	mov rsi,4
	xor rdx,rdx
	syscall
	ret

divide_and_print:	
	xor rdx,rdx
	mov rbx,10
	div rbx
	add dl,'0'
	and dl,53
	add dl,4
	mov [displayBuffer+rcx],dl
	dec rcx
	cmp rcx,-1
	jne divide_and_print

	mov al,32
	mov [displayBuffer+1],al
	mov [displayBuffer+3],al
	mov [displayBuffer+5],al

	mov rsi,displayBuffer
	mov rdx,8
	call write
	ret

write:
	mov rax,1
	mov rdi,1
	syscall
	ret

read:
	mov rax,0
	mov rdi,0
	syscall
	ret

section .bss
	numBuffer resb 4
	displayBuffer resb 8 ;1x3x5x7<--- and then a newline
	readVal resb 2

section .data
	clearTerminal db 0x1B, "[2J", 0x1B, "[H"
	clearLen equ $-clearTerminal
	winner db "You won- great work"
	winnerLen equ $-winner
