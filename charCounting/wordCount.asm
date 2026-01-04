;wordCount.asm counts both words and charecters in an input, kind of like what you would find in google docs or microsoft word- with one exception. It assumes you won't have multiple spaces in a row, because it counts each space as the beginning of a new word. This problem will be addressed soon. Might be a bit challenging. 
;
;wordCount.asm could also use further optimization.
;
;author Evan Delabarre
;1/3/2026

global _start

section .text

_start:
	mov rcx,inputLabel
	mov rdx,inputLabelSize
	call write
	call read
	
	mov bl,' '
	mov bh,0x0A
	xor rcx,rcx
	xor rdx,rdx

countRaw:
	mov al,[stringBuffer+rcx]
	inc rcx				;char count
	cmp al,bl			;checking for space
	jnz noWord			;if no space, no word
	inc rdx				;if space, ++word count

noWord:
	cmp al,bh			;checking for newline
	jnz countRaw			;if no newline- continue loop

	;after completion rcx contains char count, rdx contains word count

charCountPrep:	
	dec rcx		;newline not counted as char in char count
	inc rdx		;word count off by one bc first word has no space before it
	mov rax,rcx	;char count
	mov r9,rdx	;word count	

	mov rcx,0x0A
	mov [charDisplay+8],rcx
	mov rcx,7	

charCountCalc:	
	mov rbx,10
	xor rdx,rdx

	div rbx
	add dl,'0'
	mov [charDisplay+rcx],dl
	dec rcx
	cmp rax,0
	jnz charCountCalc
	
charCountDisplay:
	mov rcx,charCountLabel
	mov rdx,charCountLabelSize
	call write

	mov rcx,charDisplay
	mov rdx,9
	call write

wordCountPrep:
	mov rax,r9
	mov rcx,0x0A
	mov [wordDisplay+6],rcx
	mov rcx,5	

wordCountCalc:
	mov rbx,10
	xor rdx,rdx
	div rbx
	add dl,'0'
	mov [wordDisplay+rcx],dl
	dec rcx
	cmp rax,0
	jnz wordCountCalc

wordCountDisplay:
	mov rcx,wordCountLabel
	mov rdx,wordCountLabelSize
	call write	

	mov rcx,wordDisplay
	mov rdx,7
	call write

exit:
	mov rax,0x1
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
	mov rdx,10000000
	int 0x80
	ret	

section .bss
	stringBuffer resb 10000000		;10MB in size
	charDisplay resb 9			;space for 8 digits + newline
	wordDisplay resb 7			;space for 6 digits + newline

section .data
	inputLabel db "Enter text: "
	inputLabelSize equ $ - inputLabel

	charCountLabel db 0x0A, "Charecter count: "
	charCountLabelSize equ $ - charCountLabel
	
	wordCountLabel db "Word count: "
	wordCountLabelSize equ $ - wordCountLabel

