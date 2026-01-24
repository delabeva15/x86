;a vertical slot machine for linux terminals, win detection
;and great graphics utilizing the █ character. Very cool!
;
;
;author Evan Delabarre
;1/24/2026
STDIN equ 0		;stdin value
SYS_READ equ 0		;syscall num for read
STDOUT equ 1		;stdout value
SYS_WRITE equ 1		;syscall num for write

BALANCE equ 220	    	;$220
MONEY_PER_SPIN equ 5	;bet size

MATCHES_START equ 0     ;if match=3, reward user- so start with 0.
			;if you modify this to 1, you'd only need 2 matches
			;to win, but will not be rewarded for 3.

SYS_NANOSLEEP equ 35	;syscall num for delay
DELAY equ 100000000 	;100 milliseconds (100 million nanoseconds)

SYS_GETRANDOM equ 318	;getrandom number syscall
SYS_EXIT equ 60		;exit
RETURN_VAL equ 0	;return value of 0, equal to return 0; (in c)

NUMBER_OF_SLOTS equ 3	;DO NOT CHANGE THIS ONE- the program only supports 3.
			;not 2, nor 1. Only 3.

global _start

section .text

_start:

main_loop:	
	call flash		;main animation

	call random		;calls GETRANDOM and fills numBuffer with an
				;8-digit random number 	
	mov al,MATCHES_START
	mov byte [zMatch],al	;clear matches per spin
	mov byte [oMatch],al	;ensures correct win detection
	mov byte [fMatch],al	

	mov al,NUMBER_OF_SLOTS	;number of slots- program is only designed for 3
	mov [countVal],al
	
	mov rax,[numBuffer]	;displaying the slot symbols using random 
	call divide_and_print	;number in numBuffer

user_input:		;starts with money stuff and user input for next spin
	call check_if_win

	xor rax,rax
	mov rax,[money]
	sub rax,MONEY_PER_SPIN
	mov [money],rax
	cmp rax,0
	je exit

	call money_count
	call show_winnings

	mov rsi,readVal
	mov rdx,2
	call read

	call clearing_screen

analyze_user_input:	;if user input isn't ENTER, quit
	mov al,[readVal]
	cmp al,0xa
	je main_loop

exit:
	mov rax,SYS_EXIT
	mov rsi,RETURN_VAL
	syscall

money_count:
	xor rcx,rcx
	mov rcx,7	
	call clearMoney
	xor rax,rax
	mov rax,[money]
	xor rcx,rcx
	mov rcx,7
	call divide_money
	ret

clearMoney:
	mov dl,0
	mov [moneyDisplay+rcx],dl
	dec rcx
	cmp rcx,0
	jne clearMoney
	ret

show_winnings:
	mov rsi,moneyLabel	
	mov rdx,moneyLabelSize
	call write

	mov rsi,moneyDisplay
	mov rdx,9
	call write
	ret

divide_money:
	xor rdx,rdx
	xor rbx,rbx
	mov rbx,10
	div rbx
	add dl,'0'
	mov [moneyDisplay+rcx],dl
	dec rcx
	cmp rax,0
	jne divide_money
	ret
	
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

	xor rax,rax
	mov rax,[money]
	add rax,25
	mov [money],rax
	xor rax,rax

	mov rsi,readVal
	mov rdx,2
	call read
	ret

ones_matched:
	mov rsi,winDisplayOne
	mov rdx,winOneLen
	call write

	xor rax,rax
	mov rax,[money]
	add rax,50
	mov [money],rax
	xor rax,rax

	mov rsi,readVal
	mov rdx,2
	call read
	ret

fours_matched:
	mov rsi,winDisplayFour
	mov rdx,winFourLen
	call write

	xor rax,rax
	mov rax,[money]
	add rax,500
	mov [money],rax
	xor rax,rax

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
	mov rax,SYS_GETRANDOM
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
	mov rax,SYS_NANOSLEEP
	lea rdi,[timed_delay]
	xor rsi,rsi
	syscall
	ret

write:
	mov rax,SYS_WRITE
	mov rdi,STDOUT
	syscall
	ret

read:
	mov rax,SYS_READ
	mov rdi,STDIN
	syscall
	ret

section .bss
	numBuffer resb 8
	readVal resb 2
	countVal resb 2

section .data
	money db BALANCE
	moneyDisplay db 0,0,0,0,0,0,0,0,0xa

	zMatch db 0
	oMatch db 0
	fMatch db 0

	moneyLabel db "Balance: $"
	moneyLabelSize equ $-moneyLabel

	winDisplayZero db "You matched 3 zeros! Congrats!",0xa,"You've won $25!",0xa
	winZeroLen equ $-winDisplayZero
	
	winDisplayOne db "You matched 3 ones! Excellent!",0xa,"You've won $50!",0xa
	winOneLen equ $-winDisplayOne

	winDisplayFour db "You matched 3 fours! Incredible!",0xa,"Jackpot +$500!",0xa
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

timed_delay:
	dq 0
	dq DELAY
