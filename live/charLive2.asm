;charLive2.asm displays test and counts backspaces as backspaces! However, it only works for one line of text
;since carridge return only works for one line at a time. I also need to implement a num_buffer clear call to
;prevent false counts when backspacing from 10 to 1, as it will display 9 as 19. Makes sense, just need a way 
;to clear it.
;
;author Evan Delabarre
;1/10/2025

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
	
post_modify_label:
	mov rsi,label1		
	mov rdx,label1_size
	call write 
	
	mov rcx,0	
	push rcx	

	mov rax,32
	mov [number_buffer+5],rax

	mov rax,0x0D
	mov [char_storage+999],rax	

read_in_char:
	pop rcx
	lea rsi,[char_storage+rcx]
	push rcx	
	mov rdx,1
	call read

interpret_char:
	cmp rax,1	 
	jne restore_and_exit	;something wrong happend with read call 
	pop rcx
	mov rax,[char_storage+rcx]
	push rcx
	
	cmp al,0x0A
	je restore_and_exit
	
	cmp al,127
	je backspace
	
	pop rcx
	inc rcx
	push rcx

continued:		
	mov rax,rcx	;moving into rax for division 	
	
	xor rdi,rdi 	;will be used for num buffer
	mov rdi,4	;4-3-2-1-0 - 5 spots for numbers
	call count_calc	;to change 0x01 
	
	mov rsi,char_storage
	mov rdx,1000
	call write
	
	jmp read_in_char	
	
restore_and_exit:		;exit safely
	or dword [termios_struct+12],0x0000000a ;we want 1x1x
	mov rax,16		;syscall for ioctl
	mov rdi,0		;read is being modified 
	mov rsi,0x5402		;TCSETS - setting terminal settings
	mov rdx,termios_struct	;yup
	syscall	;do it
 	
	mov rsi,label3	
	mov rdx,label3_size
	call write	;"Done"
	
	mov rax,60	;exit syscall
	mov rsi,0	;return 0
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

count_calc:		
	mov rbx,10	;divisor		
	xor rdx,rdx	;clear this before dividing- important
	div rbx		;rax contains quotient, remainder in dl
	add dl,'0'	;remainder + value of '0'
	mov [number_buffer+rdi],dl	
	dec rdi		
	cmp rax,0	
	jne count_calc	;if not equal to zero, continue loop
	
display_count:
	mov rsi,label2		
	mov rdx,label2_size	
	call write	;"Characters typed: " message

	mov rax,32
	mov [number_buffer+5],rax
	mov rsi,number_buffer
	mov rdx,6
	call write	;the actual number of chars typ
	ret		;return
	
backspace:
	pop rcx
	mov rax,rcx
	cmp rax,0
	push rcx
	je continued
	
	pop rcx
	dec rcx 
	push rcx

	mov rax,32
	mov [char_storage+rcx],rax
	jmp continued

section .bss
	termios_struct resb 60	;is plenty
	char_storage resb 1000	;just one char at a time
	number_buffer resb 6	;supports up to 99,999 chars

section .data
	label1 db "Type something - press ENTER to quit",0x0A
	label1_size equ $-label1

 	label2 db "Characters typed: "
	label2_size equ $-label2

	label3 db 0xa,"Done",0xa
	label3_size equ $-label3
