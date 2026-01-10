;without character display- this program outputs the total count of chars typed
;up to 99,999. Pressing enter restores and exits the terminal.
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
	call write 	;"press ENTER to exit"

	mov rcx,0	;count
	push rcx	;save in stack for later

	mov rax,0x0D	;carridge return 
	mov [number_buffer+5],rax	;put at end of number buffer

read_in_char:
	mov rsi,char_storage	;read time
	mov rdx,1
	call read

interpret_char:
	cmp rax,1	;after reading in a char- rax contains the return
			;value. If it was successful- it is one. 
	jne restore_and_exit	;something wrong happend with read call 
	
	mov rax,[char_storage]	;if enter is pressed- restore terminal + exit
	cmp al,0xa
	je restore_and_exit

	pop rcx		;this is a little messy- but this is "count"
	inc rcx		
	mov rax,rcx	;moving into rax for division 
	push rcx	
	
	xor rdi,rdi 	;will be used for num buffer
	mov rdi,4	;4-3-2-1-0 - 5 spots for numbers
	call count_calc	;to change 0x01 
	
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

	mov rsi,number_buffer
	mov rdx,6
	call write	;the actual number of chars typed

	ret		;return
	
section .bss
	termios_struct resb 60	;is plenty
	char_storage resb 1	;just one char at a time
	number_buffer resb 6	;supports up to 99,999 chars

section .data
	label1 db "Type something - press ENTER to quit",0x0A
	label1_size equ $-label1
 	label2 db "Characters typed: "
	label2_size equ $-label2
	label3 db 0xa,"Done",0xa
	label3_size equ $-label3
