;charCounting255 counts the amount of chars in an input message and can
;go beyond a length of 9 charecters- up to 255. I have yet to figure out 
;how to go further than this, but I will figure it out soon.
;
;author: Evan Delabarre
;1/2/2026

global _start			;having a global _start is required for ld

section .text			;having a section .text is required for ld

_start:
	mov rcx,inputLabel	;load input label and write to screen
	mov rdx,inputLabelSize
	call write		;syscall write
	call read		;syscall read, size of string returned into rax
	dec rax			;if you enter nothing it should contain 0
				;if we didn't decrement rax, it would contain 1
				;That's because entering nothing is actually entering 
				;the newline charecter, 0xa

	mov rcx,0xa		;speaking of newline... 
	mov [numberOfChars+3],rcx	;you'll notice how we load this up "backwards"
	mov rcx,2			;that's because we print it out forwards
					;and extract high numbers first using div 10
	mov rbx,10		;divisor

count:
	xor rdx,rdx		;clearing rdx ensures no overflow or errors occur in 
				;repeated division, because remainders are stored in rdx
	div rbx			;dividing by 10
	add dl,'0'		;adding the value of '0' to the remainder (a single
				;digit hexidecimal number) to convert it into a number
				;ready to print.
	mov [numberOfChars+rcx],dl	;storage area
	dec rcx				
	cmp rax,0		;if rax=0, division is done, if it does not, keep going
	jnz count
	
countOutput:
	mov rcx,numberOfChars	;load location in memory where numberOfChars is located
	mov rdx,4		;size four
	call write		;write syscall

exit:
	mov rax,0x1		;exit safely
	mov rbx,0
	int 0x80

write:
	mov rax,0x4
	mov rbx,1
	int 0x80
	ret

read:
	mov rax,0x3
	mov rbx,0
	mov rcx,stringBuffer
	mov rdx,256			;segmentation fault occurs if no size is provided
	int 0x80
	ret

section .bss
	numberOfChars resb 4		;newline plus 3 numbers
	stringBuffer resb 0		;we wont need to store the actual message

section .data
	inputLabel db "Enter text: "
	inputLabelSize equ $ - inputLabel  
