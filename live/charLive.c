#include <stdio.h>
#include <unistd.h>
#include <termios.h>

int main(void) {
	struct termios oldt, newt;	//used for oldt and newt
	char c;	
	int count = 0;

	tcgetattr(0, &oldt);	//stdin
	newt = oldt;		//new terminal carries settings of old one

	newt.c_lflag &= ~(ICANON | ECHO);	//with this removal 

	tcsetattr(0, 0, &newt);	//stdin, time (0) - now, and the newt

	write(1, "Type anything, press enter to quit\n", 35);	//stdout, mesg
								//and size
	while (read(0, &c, 1) == 1) {	//while read is operating correctly
		if (c == '\n')		//0x0A!!!!
			break;
		count++;		//count it up
		printf("\rCharacters typed: %d ", count);	//carridge ret
		fflush(stdout);	//clear string buffer
	
	}

	tcsetattr(0, 0, &oldt);		//stdin, time now, oldt
	write(1, "\nDone.\n", 7);	//I always love a good "done."
	return 0;	

}
