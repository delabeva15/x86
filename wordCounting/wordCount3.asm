;wordCount3.asm is the best word count and charecter counting for a terminal that my
;skills can currently manage. I have plugged the program into chatGPT to figure out any 
;improvements I can do- turns out using int 0x80 is incorrect for 64 bit- whoops!
;So i've fixed that along with some variable naming conventions, a memory leak, and some
;small things I over looked. The rest of the organization was done purely on my own-
;and I am very proud of what I have done here. I know of only one bug in the entire
;program and that is that typing ^@ is not recognized as a "word." This is because it 
;corresponds with the null charecter (from my understanding). There might be a few other
;varients of this, but besides that- it is up to microsoft word's level of character and
;word counting, functioning quite similarly. 
;
;So here we are. Time to make this live somehow- constantly updating during typing.
;This should be a major feat to take on.
;
;One other thing I can improve is consistent register usage. I will try to focus
;on that writing future programs.
;
;author Evan Delabarre
;1/4/2026

global _start

section .text

_start:
	mov rsi,inputLabel
	mov rdx,inputLabelSize
	call write
	call read
	
	mov r8,rax	;char count is returned after read- we are saving it for later	
	
	mov bl,' '
	mov bh,0x0A
	xor rcx,rcx
	xor rdx,rdx

count_loop:
	mov al,[stringBuffer+rcx]
	inc rcx				;char count doubles as memory access :)
	cmp al,bl			;checking for space
	jnz check_end			;if no space, no word

	mov al,[stringBuffer+rcx]	;if space, check next char
	cmp al,bl			;if two spaces in a row, no word
	jz check_end
		
	cmp al,bh			;if space followed by 0x0A, no word
	jz check_end

	inc rdx				;if genuine space, inc word count, continue

check_end:
	cmp rcx,r8			;checking to see if we've reached the end
	jnz count_loop			;if not- continue loop

	;after completion rcx contains char count, rdx contains word count

char_count_prep:	
	dec rcx		;newline not counted as char in char count
	mov rax,rcx	;using char count
	mov r9,rdx	;saving word count	

	mov rcx,0x0A
	mov [numDisplay+8],rcx
	mov rcx,7	
	call count_calc
	
char_count_display:
	mov rsi,charCountLabel
	mov rdx,charCountLabelSize
	call write

	mov rsi,numDisplay
	mov rdx,9
	call write

	call clear_num_display
			
check_for_beginning_word:
	mov bl,' '	;checking these two values against first character
	mov bh,0x0A

	mov rcx,stringBuffer    ;checking first char, if it's a space, no word.
        cmp [rcx],bl
        jz word_count_display_prep

        cmp [rcx],bh            ;checking first char, if it's 0x0A, no word.
        jz word_count_display_prep

        inc r9			;there is a word at the start of the input as normal

word_count_display_prep:
	mov rax,r9
	mov rcx,7	
	call count_calc

word_count_display:
	mov rsi,wordCountLabel
	mov rdx,wordCountLabelSize
	call write	

	mov rsi,numDisplay
	mov rdx,9
	call write

exit:
	mov rax,0x3C
	xor rdi,rdi
	syscall

;calls below

clear_num_display:
        mov rcx,numDisplay
        mov bl,0x00
        mov al,0x0A
	call clear_num_loop
	ret

clear_num_loop:
        cmp [rcx],al
        jz done_clearing
        mov [rcx],bl
        inc rcx
        jmp clear_num_loop

done_clearing:
	ret	

count_calc:
	mov rbx,10
	xor rdx,rdx
	div rbx
	add dl,'0'
	mov [numDisplay+rcx],dl
	dec rcx
	cmp rax,0
	jnz count_calc
	ret

write:
	mov rax,0x01
	mov rdi,1
	syscall
	ret

read:
	mov rax,0
	mov rdi,0
	mov rsi,stringBuffer
	mov rdx,10000000
	syscall
	ret	

;memory storage

section .bss
	stringBuffer resb 10000000		;10MB in size
	numDisplay resb 9			;space for 8 digits + newline

section .data
	inputLabel db "Enter text: "
	inputLabelSize equ $ - inputLabel

	charCountLabel db 0x0A, "Charecter count: "
	charCountLabelSize equ $ - charCountLabel
	
	wordCountLabel db "Word count: "
	wordCountLabelSize equ $ - wordCountLabel
