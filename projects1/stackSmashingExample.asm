;I learned about stack smashing via the endbr64 intruction. Stack smashing is
;a hacking method- quite historical by now- that involves executing outside 
;code by using tools to put it those instructions into the stack. 
;
;later, after security implementations, return oriented programming and jump
;oriented programming took use of the instructions ALREADY IN THE PROGRAM in
;order to execute malicious code. It is incredibly facinating stuff, and I will
;here- make an example of stack smashing via a program and some outside tools.
;
;for now, more research is needed.
;https://developer.arm.com/documentation/102433/0200/Stack-smashing-and-execution-permissions
;
;author Evan Delabarre
;1/13/2026
