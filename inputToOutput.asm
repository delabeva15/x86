;input to output
;
;12/30/2025
;author Evan Delabarre

global _start

section .text
_start:
	;print out prompt label
	mov rax,0x4		;syscall write
	mov rbx,1		;fd for stdout
	mov rcx,prompt		;load the prompt
	mov rdx,promptLen	;prompt length 
	int 0x80		;call

	;start read syscall
	mov rax,0x3		;syscall read
    	mov rbx,0		;fd for stdin
    	mov rcx,buffer		;load the buffer (memory location)
    	mov rdx,256		;a length of 256 because sure
	int 0x80		;call
	mov rsi,rax		;save the return value # of bytes 

	;print out output label
	mov rax,0x4		;syscall write
	mov rbx,1		;fd for stdin (again)
	mov rcx,output		
	mov rdx,outputLen
	int 0x80

	;print out buffer 
	mov rax,0x4		;syscall write		
	mov rbx,1		;fd for stdin
	mov rcx,buffer		;load buffer
	mov rdx,rsi		;load buffer len (saved previously)
	int 0x80

	;exit gracefully
	mov rax,0x1		;exit syscall
	mov rbx,0		;0
	int 0x80		;call

section .bss
        buffer resb 256

section .data
        prompt db "Enter text: "
        promptLen equ $ - prompt ;$ means the current line MINUS the length of prompt
        output db "You entered: "
        outputLen equ $ - output ;$ means the current line MINUS the length of output

;bss instead of .data allocates data as needed in memory during runtime
;resb for space of 256
