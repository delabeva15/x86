;input to output with charecter counting up to 9 digits
;10+ coming soon
;
;12/31/2025
;author Evan Delabarre

global _start

section .text
_start:

promptLabel:
	mov rcx,prompt		;load the prompt "Enter text: "
	mov rdx,promptLen	;load prompt length 
	call write		;call write (mov rax,0x4 & mov rbx,1)

readInput:
	mov rax,0x3		;syscall read
    	mov rbx,0		;fd for stdin
    	mov rcx,stringBuffer	;load the buffer (memory location)
    	mov rdx,10		;a length of 10 to avoid big inputs
	int 0x80		;syscall
	mov rsi,rax		;save the return value # of bytes
 
outputLabel:
	mov rcx,output		;"You entered: "		
	mov rdx,outputLen	;size
	call write		

writeOutput:
	mov rcx,stringBuffer	;load buffer
	mov rdx,rsi		;load buffer len (saved previously)
	call write		;the buffer len will also be used later

countOutputLabel:
	mov rcx,countLabel	;"Which is this many charecters long: "
	mov rdx,countLen	;size
	call write

countConvert:			;nice aliteration- count convert, yeah
	xor rdx,rdx		;clear rdx, it will contain the remainder

	;STOP!! we decrease rsi here because it is basically gonna be all 1-10 stuff
	;we want it 0-9 instead.
	;also if we didnt do this, entering nothing would say you entered something.
	;(which technically you did, a newline charecter)
	;but we aren't focused on that, so it will say 0 instead
	;whew

	dec rsi			
	mov rax,rsi		;prepare for division
	mov rbx,10		;dividing by 10

	div rbx			;output: rdx:rax, with rdx containing the remainder

	;STOP AGAIN!!
	;did you see that? using div, the remainder is put into rdx
	;thats why we are using the low byte of rdx to get the single
	;integer for the purpose of printing.

	;but before printing, we have to turn this into an integer that can
	;actually be printed out. By adding '0', we take the ascii value of '0'
	;and add it to the current integer (0-9), turning it into an ascii int!

	add dl,'0'		;adding 0 in order to form a digit for printing
	mov [countBuffer],dl	;move it into the buffer location
	
countWrite:
	mov rcx,countBuffer	;prepare for write
	mov rdx,1		;size 1 (for now)
	call write
	
	;STOP!! Here's a quirk: when you enter something greater than 9 charecters,
	;the newline disapears. Why? I don't know, but its probably not good.
	;another funny thing, entering more than 10 chars put the rest into your
	;terminal and tries to enter them as a command.
	;for example, if I entered:
	;	x86AssemblyIsGreat!
	;it would output into my terminal AFTER the programs completion:
	;	yIsGreat!
	;which is correct, I like the letter y.
	
	mov rax,0xa		;newline
	mov [message],rax
	mov rcx,message
	mov rdx,1
	call write

exit:
	;exit gracefully
	mov rax,0x1		;exit syscall
	mov rbx,0		;0
	int 0x80		;call

write:
	mov rax,0x4
	mov rbx,1
	int 0x80
	ret
	
section .bss
        stringBuffer resb 10
	countBuffer resb 1		;We only need one for this program
	
section .data
        prompt db "Enter text: "
        promptLen equ $ - prompt ;$ means the current line MINUS the length of prompt
        
	output db "You entered: "
        outputLen equ $ - output ;$ means the current line MINUS the length of output
	
	countLabel db "Which is this many charecters long: "
	countLen equ $ - countLabel	

	message db ""
	

;bss instead of .data allocates data as needed in memory during runtime
;resb for necessary space
