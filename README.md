Hello! I'm Evan and this is my hobby repository where I upload x86 code via my Debian virtual machine using the vim editor. 

On here you can expect some surface level programs as well as some helpful tips and resources.

Note: run programs at your own risk in a VIRTUAL MACHINE- I do not reccomend risking any damage to your computer running these locally in case of hardware or software differences between my device and yours. I am running these programs in a terminal- it does not work on windows terminals- use linux if you'd like to run any of these.

compile using:

nasm -f elf64 -o outputfile.o inputfile.asm

ld -o outputfile.exe outputfile.o

some programs have already been compiled into executables for you to test and run yourself if desired-
./outputfile.exe to run the program.
