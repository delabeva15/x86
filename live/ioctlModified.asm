;liveCharCount1.asm is a program that counts your key presses LIVE! 
;meaning- normal operation of the terminal is replaced with a new 
;terminal using tcgetattr() and tcsetattr(), disabling canonical mode
;and echo mode. 
;
;author Evan Delabarre
;1/7/2025

global _start

section .text

_start:	;write(fd, buffer, size)
	mov rax,1
	mov rdi,1
	mov rsi,label1
	mov rdx,label1_size
	syscall

get_terminal: ;ioctl(int fd, TCGETS, memory)
	mov rax,16
	mov rdi,0
	mov rsi,0x5401 ;TCGETS
	mov rdx,termios_struct
	syscall
	
modify_terminal:	;xxxx 0x0x <-- turn those flags off!
	and dword [termios_struct+12], 0xFFFFFFF5 ;0x0x - ICANON, ECHO - off
	mov rax,16
	mov rdi,0
	mov rsi,0x5402 ;TCSETS
	mov rdx,termios_struct
	syscall

post_modify_label:
	mov rsi,label2
	mov rdx,label2_size
	call write 	

exit:	;exit safely 
	mov rax,60
	mov rsi,0
	syscall

write:
	mov rax,1
	mov rdi,1
	syscall
	ret

section .bss
	termios_struct resb 60	;is plenty

section .data
	label1 db "Before terminal change",0x0A
	label1_size equ $-label1
	label2 db "Post terminal change - try typing",0x0A
	label2_size equ $-label2 
