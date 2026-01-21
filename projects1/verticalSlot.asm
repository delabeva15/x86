;a vertical slot machine for linux terminals, no win detection
;but great graphics utilizing the █ character. Very cool!
;
;TODO work on win detection for this one too, figure it out
;
;author Evan Delabarre
;1/21/2026

global _start

section .text

_start:

main_loop:
	call flash

	call random
	
	mov al,3
	mov [countVal],al

	mov rax,[numBuffer]
	call divide_and_print

user_input:
	mov rsi,readVal
	mov rdx,2
	call read

	call clearing_screen

analyze_user_input:
	mov al,[readVal]
	cmp al,0xa
	je main_loop

exit:
	mov rax,60
	mov rsi,0
	syscall

flash:
	call print_empty1
	call print_empty1
	call print_empty1
	
	call delay
	call clearing_screen

	call print_empty2
	call print_empty2
	call print_empty2

	call delay
	call clearing_screen

	call print_full
	call print_full
	call print_full
	
	call delay
	call clearing_screen

	call print_empty2
	call print_empty2
	call print_empty2

	call delay
	call clearing_screen

	call print_empty1
	call print_empty1
	call print_empty1

	call delay
	call clearing_screen

	ret

clearing_screen:
	mov rsi,clearTerminal
	mov rdx,clearLen
	call write
	ret

random:
	mov rax,318
	mov rdi,numBuffer
	mov rsi,8
	xor rdx,rdx
	syscall
	ret

divide_and_print:
	xor rdx,rdx
	mov rbx,10
	div rbx
	push rax
	add dl,'0'
	
	cmp dl,52
	je print_zero
	
	cmp dl,53
	je print_zero
	
	cmp dl,54
	je print_zero

	cmp dl,55
	je print_one
	
	cmp dl,56
	je print_one

	cmp dl,57
	je print_four 	

	jmp print_empty

post_print:
	pop rax
	mov rcx,[countVal]
	dec rcx
	mov [countVal],rcx
	cmp rcx,0
	jne divide_and_print
	ret

print_empty:
	mov rsi,empty
	mov rdx,emptyLen
	call write
	jmp post_print

print_empty1:
	mov rsi,empty1
	mov rdx,empty1Len
	call write
	ret

print_empty2:
	mov rsi,empty2
	mov rdx,empty2Len
	call write
	ret

print_full:
	mov rsi,full
	mov rdx,fullLen
	call write
	ret

print_zero:
	mov rsi,symbolZero
	mov rdx,zeroLen
	call write
	jmp post_print

print_one:
	mov rsi,symbolOne
	mov rdx,oneLen
	call write
	jmp post_print

print_four:
	mov rsi,symbolFour
	mov rdx,fourLen
	call write
	jmp post_print

delay:
	mov rax,35
	lea rdi,[ts]
	xor rsi,rsi
	syscall
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
	numBuffer resb 8
	readVal resb 2
	countVal resb 2

section .data
	clearTerminal db 0x1B, "[2J", 0x1B, "[H"
	clearLen equ $-clearTerminal

	empty db \
	"████████████", 0xa, \
	"██        ██", 0xa, \
	"██        ██", 0xa, \
	"██        ██", 0xa, \
	"██        ██", 0xa, \
	"██        ██", 0xa, \
	"████████████", 0xa
	emptyLen equ $-empty

	empty1 db \
	"████████████", 0xa, \
	"████████████", 0xa, \
	"███      ███", 0xa, \
	"███      ███", 0xa, \
	"███      ███", 0xa, \
	"████████████", 0xa, \
	"████████████", 0xa
	empty1Len equ $-empty1
	
	empty2 db \
	"████████████", 0xa, \
	"████████████", 0xa, \
	"████████████", 0xa, \
	"████    ████", 0xa, \
	"████████████", 0xa, \
	"████████████", 0xa, \
	"████████████", 0xa
	empty2Len equ $-empty2

	
	full db \
	"████████████", 0xa, \
	"████████████", 0xa, \
	"████████████", 0xa, \
	"████████████", 0xa, \
	"████████████", 0xa, \
	"████████████", 0xa, \
	"████████████", 0xa
	fullLen equ $-full
	
	symbolZero db \
	"████████████", 0xa, \
	"██        ██", 0xa, \
	"██  ████  ██", 0xa, \
	"██  █  █  ██", 0xa, \
	"██  ████  ██", 0xa, \
	"██        ██", 0xa, \
	"████████████", 0xa
	zeroLen equ $-symbolZero
	
	symbolOne db \
	"████████████", 0xa, \
	"██        ██", 0xa, \
	"██   ██   ██", 0xa, \
	"██    █   ██", 0xa, \
	"██   ███  ██", 0xa, \
	"██        ██", 0xa, \
	"████████████", 0xa
	oneLen equ $-symbolOne
	
	symbolFour db \
	"████████████", 0xa, \
	"██        ██", 0xa, \
	"██  █  █  ██", 0xa, \
	"██  ████  ██", 0xa, \
	"██     █  ██", 0xa, \
	"██        ██", 0xa, \
	"████████████", 0xa
	fourLen equ $-symbolFour

ts:
	dq 0
	dq 100000000
