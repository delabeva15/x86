; hello_world.asm
;
; Author: Evan Delabarre
; Date: 10/2/2025
;
; hello world program first learned from John Hammond
; He has execellent explanation.
; https://www.youtube.com/watch?v=HgEGAaYdABA


global _start

section .text:

_start:
	mov eax, 0x4			;use write syscall
	mov ebx, 1			;use stdout as fd
	mov ecx, message		;use message as buffer
	mov edx, message_length		;use message length
	int 0x80

	;exit gracefully

	mov eax, 0x1
	mov ebx, 0
	int 0x80


section .data:
	message: db "Hello World!", 0xA
	message_length equ 13
