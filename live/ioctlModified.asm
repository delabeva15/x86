;ioctl modified changes the terminal mode from canonical to not, and also disables echo. 
;in short, what this does is disable text from being output onto the keyboard, and canonical mode,
;when disabled, reads input by char instead of per newline. Really cool and will be useful for
;live char counts and maybe a wacky keyboard program :)
;
;for now ive compiled this program into typeResetToFixTerminal.exe, and its exactly what it sounds like
;REALLY COOL. (you can only run this in a terminal, I don't know how windows would react to it but i'm going to find out).
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
