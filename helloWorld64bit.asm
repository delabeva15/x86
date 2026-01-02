;hello world in 64 bits
;
;author Evan Delabarre
;1/2/2026

global _start

section .text

_start:
	
	mov rax,0x4 ;write syscall
	mov rbx,1 ;stdout
	mov rcx, message
	mov rdx, messageLen
	int 0x80

exit:
	mov rax,0x1
	mov rbx,0
	int 0x80


section .data
	message db "Hello world, it is 2016!",0xa 
	messageLen equ $ - message
