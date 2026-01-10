;charLive.exe:     file format elf64-x86-64

0000000000001189 <main>:
    1189:	55                   	push   rbp
;firstly, it "saves" the base pointer into the stack- from my knowledge this is 
;how the program can return to the place that called it after execution. It's also
;used for organized stack frame- so different parts of a program aren't all
;co-mingling.

    118a:	48 89 e5             	mov    rbp,rsp
    118d:	48 81 ec 90 00 00 00 	sub    rsp,0x90
;then, it defines a new frame by subtracting (stack grows down) 90 hex for space- 
;this will be used for the termios structure and print statements 

    1194:	c7 45 fc 00 00 00 00 	mov    DWORD PTR [rbp-0x4],0x0
;store 32 bits (dword) into memory loc. in stack- rbp-0x4. The value is 0. This
;might be for the tcgetattr call- maybe a read value or delay value.
;NOPE! this is the int count, which is 4 bytes in length and initialized with
;0, that makes sense. 

    119b:	48 8d 45 c0          	lea    rax,[rbp-0x40]
;loading the memory location, probably the termios structure for tcgetattr
;to store the terminals setting into. 

    119f:	48 89 c6             	mov    rsi,rax
;rsi is the second argument in the tcgetattr call, we are loading the 
;previously loaded memory address into rsi for the call.

    11a2:	bf 00 00 00 00       	mov    edi,0x0
;stdin fd 

    11a7:	e8 c4 fe ff ff       	call   1070 <tcgetattr@plt>
;here it is! the moment we've been waiting for! and its a complete mess!!!

    11ac:	48 8b 45 c0          	mov    rax,QWORD PTR [rbp-0x40]
    11b0:	48 8b 55 c8          	mov    rdx,QWORD PTR [rbp-0x38]
    11b4:	48 89 45 80          	mov    QWORD PTR [rbp-0x80],rax
    11b8:	48 89 55 88          	mov    QWORD PTR [rbp-0x78],rdx
    11bc:	48 8b 45 d0          	mov    rax,QWORD PTR [rbp-0x30]
    11c0:	48 8b 55 d8          	mov    rdx,QWORD PTR [rbp-0x28]
    11c4:	48 89 45 90          	mov    QWORD PTR [rbp-0x70],rax
    11c8:	48 89 55 98          	mov    QWORD PTR [rbp-0x68],rdx
    11cc:	48 8b 45 e0          	mov    rax,QWORD PTR [rbp-0x20]
    11d0:	48 8b 55 e8          	mov    rdx,QWORD PTR [rbp-0x18]
    11d4:	48 89 45 a0          	mov    QWORD PTR [rbp-0x60],rax
    11d8:	48 89 55 a8          	mov    QWORD PTR [rbp-0x58],rdx
    11dc:	48 8b 45 ec          	mov    rax,QWORD PTR [rbp-0x14]
    11e0:	48 8b 55 f4          	mov    rdx,QWORD PTR [rbp-0xc]
    11e4:	48 89 45 ac          	mov    QWORD PTR [rbp-0x54],rax
    11e8:	48 89 55 b4          	mov    QWORD PTR [rbp-0x4c],rdx
;what a mess huh!? All this is doing is taking the flags from the old 
;terminal and putting them into the new one. The old one is 0x40-0xC.
;the new one is 0x80 - 0x4c. To me, this is beautiful.

    11ec:	8b 45 8c             	mov    eax,DWORD PTR [rbp-0x74]
    11ef:	83 e0 f5             	and    eax,0xfffffff5
;go check my assembly program- I literally typed something really similar. 
;it is very cool to see- 0x80 - 0x12 bytes down to get to the c_l flags.
;(see https://man7.org/linux/man-pages/man3/termios.3.html and go to c_l flag
;constants). 

;using grep (in /usr/include) you can find that ECHO and ICANON are bytes
;1010, respectively. That is why there is a 5 at the ending! because we want
;only those flags turned off before applying tcsetattr. 

    11f2:	89 45 8c             	mov    DWORD PTR [rbp-0x74],eax
;loading the modified flags back into the termios strcut

    11f5:	48 8d 45 80          	lea    rax,[rbp-0x80]
    11f9:	48 89 c2             	mov    rdx,rax
;rdx loaded with termios struct in stack

    11fc:	be 00 00 00 00       	mov    esi,0x0
    1201:	bf 00 00 00 00       	mov    edi,0x0
;one is stdin fd, the other is delay- 0.

    1206:	e8 75 fe ff ff       	call   1080 <tcsetattr@plt>
;set new terminal settings! The main focus of the program.

    120b:	ba 23 00 00 00       	mov    edx,0x23
;I know what this is- 0x23 should be 35 in decimal? yup it is- this is the mesg. size.

    1210:	48 8d 05 f1 0d 00 00 	lea    rax,[rip+0xdf1]        # 2008 <_IO_stdin_used+0x8>
    1217:	48 89 c6             	mov    rsi,rax
; ? this is confusing me- I know it is the mesg. location- but i've never seen it defined
;in this way. I guess it makes sense- the text being defined at the bottom of the program.
;I suppose it would help if this memory location was available via objdump but its not :(

    121a:	bf 01 00 00 00       	mov    edi,0x1
;stdout fd 

    121f:	e8 0c fe ff ff       	call   1030 <write@plt>
;call it!

    1224:	eb 37                	jmp    125d <main+0xd4>
;this is when we enter a while loop. 

    1226:	0f b6 85 7f ff ff ff 	movzx  eax,BYTE PTR [rbp-0x81]
;cool to see that the next character read in is always just one byte past the new termios
;struct. This is one of the reasons I love assembly- it is just SO PRECISE! Just note that
;we have no yet read in a char if you are looking at this in a linear fashion. This will
;be for later when we jump back up here.

    122d:	3c 0a                	cmp    al,0xa
;This is the compaison (cmp) of the value read in with the newline char. Good old oxa, 
;you love to see it.

    122f:	74 4d                	je     127e <main+0xf5>
;jump if equal

    1231:	83 45 fc 01          	add    DWORD PTR [rbp-0x4],0x1
; ? I'm clueless for this one- im not gonna lie. Looking back- this exact location
;was used near the beginning of main maybe as a parameter, so what I assume here is 
;stdout file descriptor? I'm not entirely sure- it is odd.
;NOPE STOP!! I KNOW WHAT IT IS! This is "count" in the C program- I should've looked.
;that is why it is incrementing by one.

    1235:	8b 45 fc             	mov    eax,DWORD PTR [rbp-0x4]
;moved into eax. 

    1238:	89 c6                	mov    esi,eax
;ok??

    123a:	48 8d 05 eb 0d 00 00 	lea    rax,[rip+0xdeb]        # 202c <_IO_stdin_used+0x2c>
;I see what is happening here. It was a strange strucutre because we are printing something,
;just not with the stdout that i am used to- write. We are using printf for this, which requires
;more lines to prepare for it looks like.

    1241:	48 89 c7             	mov    rdi,rax
;moving mesg. here.

    1244:	b8 00 00 00 00       	mov    eax,0x0
;? something to do with printf- maybe the fact that it is printing out count? 

    1249:	e8 f2 fd ff ff       	call   1040 <printf@plt>
;call it

    124e:	48 8b 05 eb 2d 00 00 	mov    rax,QWORD PTR [rip+0x2deb]        # 4040 <stdout@GLIBC_2.2.5>
    1255:	48 89 c7             	mov    rdi,rax
    1258:	e8 03 fe ff ff       	call   1060 <fflush@plt>
;all we are doing here is clearing the string buffer :)

    125d:	48 8d 85 7f ff ff ff 	lea    rax,[rbp-0x81]
;read incomming- loading char buffer

    1264:	ba 01 00 00 00       	mov    edx,0x1
;size

    1269:	48 89 c6             	mov    rsi,rax
;mesg. location

    126c:	bf 00 00 00 00       	mov    edi,0x0
;stdin fd

    1271:	e8 da fd ff ff       	call   1050 <read@plt>
;read it!

    1276:	48 83 f8 01          	cmp    rax,0x1
    127a:	74 aa                	je     1226 <main+0x9d>
    127c:	eb 01                	jmp    127f <main+0xf6>
;did read operate correctly? if it did (equal), continue loop, otherwise,
;quit

    127e:	90                   	nop
;no operation :) I love nop. same with xchg rax,rax

    127f:	48 8d 45 c0          	lea    rax,[rbp-0x40]
;old terminal location

    1283:	48 89 c2             	mov    rdx,rax
    1286:	be 00 00 00 00       	mov    esi,0x0
    128b:	bf 00 00 00 00       	mov    edi,0x0
;delay or stdin. change the behavior of stdin basically.

    1290:	e8 eb fd ff ff       	call   1080 <tcsetattr@plt>
;call it

    1295:	ba 07 00 00 00       	mov    edx,0x7
;size of done. (has two newlines on either size)

    129a:	48 8d 05 a2 0d 00 00 	lea    rax,[rip+0xda2]        # 2043 <_IO_stdin_used+0x43>
;mesg.

    12a1:	48 89 c6             	mov    rsi,rax
    12a4:	bf 01 00 00 00       	mov    edi,0x1
;stdout fd

    12a9:	e8 82 fd ff ff       	call   1030 <write@plt>
;call it

    12ae:	b8 00 00 00 00       	mov    eax,0x0
;return 0, get it? look below, its so cool to see! 

    12b3:	c9                   	leave
    12b4:	c3                   	ret

;alright, thats main! This is why some say that everything is open source when you
;know assembly. It's a little funky but it's true.

;there's a lot to look at via objdump, one of my favorite commands- as it ties
;into my cyberseucirty interests - is the endbr64 command. I highly encourage anyone
;interested to look it up and just read through the amazing history of this.
;It is seriously so cool- and I learned a bit about jump oriented programming,
;return oriented programming, stack smashing, and ROPgadget. Super facinating.
;endbr64 doesnt appear in this section of the program because it's just main, but
;if you use objdump on this to view everything- you'll see it.

;Anyways, that was an adventure that sidetracked me from my task at hand-
;creating a live character counter- which isn't as bad as I first realized,
;it just takes a lot of researching around and asking chatbots and head-scratching.
