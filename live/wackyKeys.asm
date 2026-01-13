;wackyKeys.asm is a program that outputs the wrong charecters as you type them.
;TODO- add wacky key value modifiers (not just one)
;
;author Evan Delabarre
;1/12/2025

global _start

section .text

_start:

get_terminal: ;ioctl(int fd, TCGETS, memory)
	mov rax,16	;syscall number
	mov rdi,0	;modifying read
	mov rsi,0x5401 ;TCGETS
	mov rdx,termios_struct	;memory location
	syscall
	
modify_terminal:	;xxxx 0x0x <-- turn those flags off!
	and dword [termios_struct+12], 0xFFFFFFF5 ;0x0x - ICANON, ECHO - off
	mov rax,16	;syscall number
	mov rdi,0	;modifying read
	mov rsi,0x5402 ;TCSETS
	mov rdx,termios_struct	;memory location
	syscall
	
wacky_keys_label:
	mov rsi,label1		
	mov rdx,label1_size
	call write

	mov rcx,0 

read_in_char:
	push rcx
	lea rsi,[char_storage]
	mov rdx,1
	call read

interpret_char:
	cmp rax,1	 
	jne count_wacky_keys 
	mov rax,[char_storage]

	cmp al,0x0A
	je count_wacky_keys
	
	inc rax
	mov [char_storage],rax
	 
continued:	
	lea rsi,[char_storage]
	mov rdx,1
	call write

	pop rcx
	inc rcx ;keeping count	

	jmp read_in_char	
	
count_wacky_keys:
	mov rsi,label2
	mov rdx,label2_size
	call write

	xor rax,rax
	pop rcx ;pop count into rax
	mov rax,rcx
	mov rcx,4
	call calc_number	

	lea rsi,[wacky_keys_display]
	mov rdx,5
	call write

	mov rsi,label3
	mov rdx,label3_size
	call write

restore_and_exit:		;exit safely
	or dword [termios_struct+12],0x0000000a ;we want 1x1x
	mov rax,16		;syscall for ioctl
	mov rdi,0		;read is being modified 
	mov rsi,0x5402		;TCSETS - setting terminal settings
	mov rdx,termios_struct	;yup
	syscall	;do it
	
	mov rax,60	;exit syscall
	mov rsi,0	;return 0
	syscall	

calc_number:
	xor rdx,rdx
	mov rbx,10
	div rbx
	add dl,'0'
	mov [wacky_keys_display+rcx],dl
	dec rcx
	cmp rax,0
	jne calc_number
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
	termios_struct resb 60	;is plenty
	char_storage resb 1
	wacky_keys_display resb 5	;able to type up to 99,999 wacky keys!

section .data
	label1 db "Wacky keys enabled - press ENTER to quit",0x0A
	label1_size equ $-label1

	label2 db 0xa,"You typed "
	label2_size equ $-label2
	
	label3 db " Wacky keys!",0xa
	label3_size equ $-label3
