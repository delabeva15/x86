;looping through an array example 1
;
;author Evan Delabarre
;12/30/2025

global _start

section .text
	
_start:
	mov rdi, array		;load rdi with array memory location
        mov rsi, array+24	;load rsi with ending of array memory loc (this means that it is one past the end of the array, so it will also load the 0xA after it.)
loop:	
	mov rax, 0x4		;load rax with write syscall
	mov rbx, 1		;load rbx with stdout
	mov rcx, rdi		;load rcx (mess.) with value from array 
	mov rdx, 1		;load length of mess. (for now doing one at a time)
	int 0x80		;call it

	inc rdi			;increase index
	cmp rdi, rsi		;check if we at the end of array
	jnz loop 		;if we are not: continue loop

exit:
	mov rax, 0x1		;exit nicely 
	mov rbx, 0
	int 0x80

section .data:
	array db 1,"v","P","5","brat with sauekraut"
	newlinechar: db 0xA
	len equ 1
	

;using stdout you cannot print out intergers, only strings.
;that being said, 5 (surrounded by quotes) will print out. 
;to print strings with multiple chars, each char is an index in memory, hence the 23+1
