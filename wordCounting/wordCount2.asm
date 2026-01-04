;wordCount2.asm is a vast improvement over wordCount.asm, it regonizes a sequence of 
;spaces as NOT a word, but a char, and has less repeated lines of code than wordCount.asm
;
;HOWEVER- wordCount2.asm still recognizes a string such as " . . . ]" as being 4 words
;this is because it does not interpret simply alphabetical chars as words- it interprets
;all chars (minus 0x0A and strings of spaces) as words. Here's a fun fact though- microsoft word 
;ALSO does this. So for now- this is at least up to microsoft's standards of a "word" counter, as
;words are somtimes subjective (as seen in finnegan's wake).
;
;wordCount2.asm could also use some further organizing- such as moving clearNumPrep
;and clearNumDisplay as calls at the bottom, and figuring how to change things like
;the noExtraWord label to make more sense. 
;
;author Evan Delabarre
;1/4/2026

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
	mov al,[stringBuffer+rcx]
	cmp al,bl			;if two spaces in a row, no word
	jz noWord
	cmp al,bh			;space followed by 0x0A is not a valid "word."
	jz noWord
	inc rdx				;if genuine space, word count

noWord:
	cmp al,bh			;checking for newline
	jnz countRaw			;if no newline- continue loop

	;after completion rcx contains char count, rdx contains word count

charCountPrep:	
	dec rcx		;newline not counted as char in char count
	mov rax,rcx	;char count
	
	mov rcx,stringBuffer	;checking first char, if it's a space, no word.
	cmp [rcx],bl
	jz noExtraWord
	cmp [rcx],bh		;checking first char, if it's 0x0A, no word.
	jz noExtraWord
	inc rdx

noExtraWord:
	mov r9,rdx	;word count	

	mov rcx,0x0A
	mov [numDisplay+8],rcx
	mov rcx,7	
	call countCalc
	
charCountDisplay:
	mov rcx,charCountLabel
	mov rdx,charCountLabelSize
	call write

	mov rcx,numDisplay
	mov rdx,9
	call write

clearNumPrep:
	mov rcx,numDisplay
	mov bl,0x00
	mov al,0x0A

clearNumDisplay:
	cmp [rcx],al
	jz wordCountPrep
	mov [rcx],bl
	inc rcx
	jmp clearNumDisplay
			
wordCountPrep:
	mov rax,r9
	mov rcx,7	
	call countCalc

wordCountDisplay:
	mov rcx,wordCountLabel
	mov rdx,wordCountLabelSize
	call write	

	mov rcx,numDisplay
	mov rdx,9
	call write

exit:
	mov rax,0x1
	mov rbx,0
	int 0x80

;calls below

countCalc:
	mov rbx,10
	xor rdx,rdx
	div rbx
	add dl,'0'
	mov [numDisplay+rcx],dl
	dec rcx
	cmp rax,0
	jnz countCalc
	ret

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
