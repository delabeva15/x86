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
	
	mov al,0
	mov byte [zMatch],al
	mov al,0
	mov byte [oMatch],al
	mov al,0
	mov byte [fMatch],al	

	mov al,3
	mov [countVal],al
	
	mov rax,[numBuffer]
	call divide_and_print

user_input:			
	call check_if_win
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

check_if_win:
	mov al,[zMatch]
	cmp al,3
	je zeros_matched
	mov al,[oMatch]
	cmp al,3
	je ones_matched
	mov al,[fMatch]
	cmp al,3
	je fours_matched
	
	ret

zeros_matched:
	mov rsi,winDisplayZero
	mov rdx,winZeroLen
	call write
	mov rsi,readVal
	mov rdx,2
	call read
	ret

ones_matched:
	mov rsi,winDisplayOne
	mov rdx,winOneLen
	call write
	mov rsi,readVal
	mov rdx,2
	call read
	ret

fours_matched:
	mov rsi,winDisplayFour
	mov rdx,winFourLen
	call write
	mov rsi,readVal
	mov rdx,2
	call read
	ret

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

	mov al,[zMatch]
	inc al
	mov [zMatch],al
	xor rax,rax

	jmp post_print

print_one:
	mov rsi,symbolOne
	mov rdx,oneLen
	call write

	mov al,[oMatch]
	inc al
	mov [oMatch],al
	xor rax,rax

	jmp post_print

print_four:
	mov rsi,symbolFour
	mov rdx,fourLen
	call write

	mov al,[fMatch]
	inc al
	mov [fMatch],al
	xor rax,rax	
	
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
	zMatch db 0
	oMatch db 0
	fMatch db 0

	winDisplayZero db "You matched 3 zeros! Congrats!",0xa
	winZeroLen equ $-winDisplayZero
	
	winDisplayOne db "You matched 3 ones! Excellent!",0xa
	winOneLen equ $-winDisplayOne

	winDisplayFour db "You matched 3 fours! Incredible!",0xa
	winFourLen equ $-winDisplayFour



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
