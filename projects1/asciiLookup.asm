;ascii lookup- this program takes in an integer from the user and
;converts it into hexidecimal into the register and outputs it to
;display the ascii value.
;
;author Evan Delabarre
;1/13/2026

global _start

section .text

_start:

prompt_and_input:
	mov rsi,label1		;"Input number: "
	mov rdx,label1_size	
	call write

	mov rsi,base10_storage	
	mov rdx,3
	call read

	xor rax,rax
	mov rax,[base10_storage+2]
	sub rax,'0'
	add [total],rax

	xor rax,rax	
	mov rax,[base10_storage+1]
	sub rax,'0'
	mov bl,10
	mul bl
	add [total],rax

	xor rax,rax
	mov rax,[base10_storage]
	sub rax,'0'
	mov bl,100
	mul bl
	add [total],rax

	mov rsi,label2
	mov rdx,label2_size
	call write

	mov rsi,total
	mov rdx,1
	call write

	mov rsi,label3
	mov rdx,label3_size
	call write

exit:
	mov rax,60
	mov rsi,0
	syscall

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
	base10_storage resb 3
	total resb 1	

section .data
	label1 db "Input number (000-127) for ascii lookup: "
	label1_size equ $-label1

	label2 db "That value is "
	label2_size equ $-label2

	label3 db " in ascii!",0xa
	label3_size equ $-label3
