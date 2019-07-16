/******************************************************************************

                            Online C Compiler.
                Code, Compile, Run and Debug C program online.
Write your code in this editor and press "Run" button to compile and execute it.

*******************************************************************************/

volatile int pixel_buffer_start; // global variable

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>

void plot_pixel(int x, int y, short int line_color);
void draw_line(int x0, int y0, int x1, int y1, int color);
void swap(int* num1, int* num2);
void wait_for_vsync();
void clear_screen(int x0, int y0, int x1, int y1);

int main(int argc, char** argv){
    volatile int* sw_ptr = 0xFF200040;	    //switch address
    volatile int* key_ptr = 0xFF200050;     //key address
    volatile int* ledr_ptr = 0xFF200000;    //ledr address
	volatile int* keyboard = 0xFF200100;
    int getLEDR;
    *ledr_ptr = 0b0;        //scoreboard blank at the start
    
    volatile int* pixel_ctrl_ptr = (int*) 0xFF203020;
	/*Read location of the pixel buffer from the pixel buffer controller*/
	pixel_buffer_start = *pixel_ctrl_ptr;
	clear_screen(0, 0, 322, 242);
    
    bool grid[320][240];	
	for(int i=0 ; i<320 ; i++) 
        for (int j=0; j<240 ; j++) 
            grid[i][j] = 0;   //reset the grid
    int x1, y1, x2, y2, xleft, xright, ylower, yupper;  //position variables for the two players
    int dx1, dy1, dx2, dy2;     //direction vectors for both players
    int p1score = 0;		//p1 out of bounds, p2 etc.
    int p2score = 0;
    
	x1 = 100;     
	y1 = 120;
	x2 = 220;
	y2 = 120;
	
    int gameLength;
    int color1, color2;         //color for each player
    bool newGameNeeded = true;
    bool p1OFB = false;
	bool p2OFB = false;
	
    int delay = 3;         //number of frames before the players actually move
    int delayCount = 0;
	int wallDelay = 20;
	int wallCount = 0;
	int speedTimer1 = 0;
	int speedTimer2 = 0;
	int speedDuration1 = 0;
	int speedDuration2 = 0;
	
	*(key_ptr+3) = 0b1111; 
	
	while(1){
		if(*(key_ptr+3) != 0){
			*(key_ptr+3) = 0b1111;
			wait_for_vsync();
			break;
		}
	}
	
    while(1){     //inital setup, players
        //choose color (using switches), ideally their color is shown on the screen while they are choosing
        if((*sw_ptr & 0x1) == 1) color1 = 0x1111;
        else if((*sw_ptr & 0x2) == 2) color1 = 0x2222;
        else if((*sw_ptr & 0x4) == 4) color1 = 0x3333;
        else if((*sw_ptr & 0x8) == 8) color1 = 0x4444;
		else color1 = 0x9999;
        
		for(int i=-3 ; i<4 ; i++)
			for(int j=-3 ; j<4 ; j++)
				plot_pixel(100+i, 100+j, color1);
		
        if((*sw_ptr && 0x10) == 16) color2 = 0x5555;
        else if((*sw_ptr & 0x20) == 32) color2 = 0x6666;
        else if((*sw_ptr & 0x40) == 64) color2 = 0x7777;
        else if((*sw_ptr & 0x80) == 128) color2 = 0x8888;
        else color2 = 0xaaaa;
		
		for(int i=-3 ; i<4 ; i++)
			for(int j=-3 ; j<4 ; j++)
				plot_pixel(220+i, 100+j, color2);
		
        //choose length of game (bo3, bo5), based on key pressed
        if(*(key_ptr+3) !=0){ 
			draw_line(0, 20, 319, 20, 0xFFFF);
			if(*(key_ptr+3)==1){            //key 0 pressed, bo1
				gameLength = 1;
				draw_line(6, 5, 6, 15, 0xCCCC);
				draw_line(312, 5, 312, 15, 0xCCCC);
			} else if(*(key_ptr+3)==2){     //key 1 pressed, bo3
				gameLength = 2;
				draw_line(6, 5, 6, 15, 0xCCCC);
				draw_line(10, 5, 10, 15, 0xCCCC);
				draw_line(312, 5, 312, 15, 0xCCCC);
				draw_line(308, 5, 308, 15, 0xCCCC);
			} else if(*(key_ptr+3)==4){     //key 2 pressed, bo5
				gameLength = 3;
				draw_line(6, 5, 6, 15, 0xCCCC);
				draw_line(10, 5, 10, 15, 0xCCCC);
				draw_line(14, 5, 14, 15, 0xCCCC);
				draw_line(312, 5, 312, 15, 0xCCCC);
				draw_line(308, 5, 308, 15, 0xCCCC);
				draw_line(304, 5, 304, 15, 0xCCCC);
			} else if(*(key_ptr+3)==8){     //key 3 pressed, bo7
				gameLength = 4;
				draw_line(6, 5, 6, 15, 0xCCCC);
				draw_line(10, 5, 10, 15, 0xCCCC);
				draw_line(14, 5, 14, 15, 0xCCCC);
				draw_line(18, 5, 18, 15, 0xCCCC);
				draw_line(312, 5, 312, 15, 0xCCCC);
				draw_line(308, 5, 308, 15, 0xCCCC);
				draw_line(304, 5, 304, 15, 0xCCCC);
				draw_line(300, 5, 300, 15, 0xCCCC);
			}
			*(key_ptr+3) = 0b1111;
			break;
		}
	}
		
    while(1){
		if(x1>xright | x1<xleft | y1 >yupper | y1 <ylower) p1OFB = true;
		if(x2>xright | x2<xleft | y2 >yupper | y2 <ylower) p2OFB = true;
	
		if((grid[x1][y1]==1 & grid[x2][y2]==1) | (p1OFB & p2OFB) | (x1 == x2 & y1 == y2)) { newGameNeeded = true; }
		else if(grid[x1][y1]==1 | p1OFB) { p2score++; newGameNeeded = true; }
		else if(grid[x2][y2]==1 | p2OFB) { p1score++; newGameNeeded = true; }
		
        if(newGameNeeded){
			while(1){
				if(*(key_ptr+3) !=0){
					*(key_ptr+3) = 0b1111;
					break;
				}
			}
			
			*ledr_ptr = 0b0000000000;
            if(p1score == 1){
				*ledr_ptr = 0b1000000000;
				draw_line(6, 5, 6, 15, 0xFFFF);
			}
            else if(p1score == 2){
				*ledr_ptr = 0b1100000000;
				draw_line(10, 5, 10, 15, 0xFFFF);
			}
            else if(p1score == 3){
				*ledr_ptr = 0b1110000000;
				draw_line(14, 5, 14, 15, 0xFFFF);
			}
			else if(p1score == 4){ 
				*ledr_ptr = 0b1111000000;
				draw_line(18, 5, 18, 15, 0xFFFF);
			}
			if(p2score == 1){
				getLEDR = *ledr_ptr; 
                getLEDR += 0b1;
                *ledr_ptr = getLEDR;
				draw_line(312, 5, 312, 15, 0xFFFF);
			}
            else if(p2score == 2){ 
                getLEDR = *ledr_ptr; 
                getLEDR += 0b11;
                *ledr_ptr = getLEDR;
				draw_line(308, 5, 308, 15, 0xFFFF);
            }
            else if(p2score == 3){
                getLEDR = *ledr_ptr; 
                getLEDR += 0b111;
                *ledr_ptr = getLEDR;
				draw_line(304, 5, 304, 15, 0xFFFF);
			}
			else if(p2score == 4){
                getLEDR = *ledr_ptr; 
                getLEDR += 0b1111;
                *ledr_ptr = getLEDR;
				draw_line(300, 5, 300, 15, 0xFFFF);
			}
			
			if(p1score >= gameLength){
				while(1){
				}
			}
            if(p2score >= gameLength){
				while(1){
				}
			}
			
			clear_screen(0,21, 323, 243);
			
			p1OFB = false;
			p2OFB = false;
			for(int i=0 ; i<320 ; i++) 
				for (int j=0; j<240 ; j++) 
					grid[i][j] = 0;   //reset the grid
				
			x1 = 100;      //players are positioned symmetrically near the center of the screen
			y1 = 120;
			x2 = 220;
			y2 = 120;
			dx1 = 1;       //players are both going towards eachother at the start of the game
			dy1 = 0; 
			dx2 = -1;   
			dy2 = 0;
			xleft = 0;
			xright = 319;
			ylower = 21;
			yupper = 239;
			
			plot_pixel(x1, y1, color1);   
            plot_pixel(x2, y2, color2);
			
			wait_for_vsync();
			
			while(1){
				if(*(key_ptr+3)!=0){				//will wait here until key is pressed
					*(key_ptr+3) = 0b1111; 
					break;
				}
			}
			
			newGameNeeded = false;
        }
        
        //player 2 is playing on the right side, player 1 is on the left near the switches
        if((*(key_ptr+3) & 0x4) == 4){    //player 2 is trying to turn right
            if(dx1==1){ dx1=0; dy1=1; }
            else if(dy1==1) { dy1=0; dx1=-1; }
            else if(dx1==-1){ dx1=0; dy1=-1; }
            else if(dy1==-1){ dy1=0; dx1=1; }
			*(key_ptr+3) = 0b0100;
        }         
        if((*(key_ptr+3) & 0x8) == 8){    //player 2 is trying to turn left
            if(dy1==1){ dy1=0; dx1=1; }
            else if(dx1==1){ dx1=0; dy1=-1; }
            else if(dy1==-1) { dy1=0; dx1=-1; }
            else if(dx1==-1){ dx1=0; dy1=1; }
			*(key_ptr+3) = 0b1000;			
        }
        if((*(key_ptr+3) & 0x1) == 1){    //player 1 is trying to turn right
            if(dx2==1){ dx2=0; dy2=1; }
            else if(dy2==1) { dy2=0; dx2=-1; }
            else if(dx2==-1){ dx2=0; dy2=-1; }
            else if(dy2==-1){ dy2=0; dx2=1; }
			*(key_ptr+3) = 0b0001;
			}
        if((*(key_ptr+3) & 0x2) == 2){    //player 1 is trying to turn left
            if(dy2==1){ dy2=0; dx2=1; }
            else if(dx2==1){ dx2=0; dy2=-1; }
            else if(dy2==-1) { dy2=0; dx2=-1; }
            else if(dx2==-1){ dx2=0; dy2=1; }
			*(key_ptr+3) = 0b0010;
        }
        
		if((*sw_ptr & 0x200) == 0x200){
			wallCount++;
			if(wallCount == wallDelay){
				draw_line(xleft, 21, xleft, 239, 0x5555);
				draw_line(xright, 21, xright, 239, 0x5555);
				draw_line(0, ylower, 319, ylower, 0x5555);
				draw_line(0, yupper, 319, yupper, 0x5555);
				wallCount = 0;
				xleft++;
				xright--;
				yupper--;
				ylower++;
			}
		}
		if(((*sw_ptr & 0x100) == 0x100) & speedTimer1 == 0){
			speedDuration1 = 20;
			speedTimer1 = 100;
		}
		if(((*sw_ptr & 0x1) == 0x1) & speedTimer2 == 0){
			speedDuration2 = 20;
			speedTimer2 = 100;
		}

		
        delayCount++;
		if(delayCount == delay/2 & speedDuration1!=0){
			grid[x1][y1] = 1;   //mark the pixel as traveled
			plot_pixel(x1, y1, color1);

			if (dx1==1) x1++;           //update p1 position
            else if (dx1==-1) x1--;
            else if (dy1==1) y1++;
            else if (dy1==-1) y1--;
			
			speedDuration1--;
		}
		if(delayCount == delay/2 & speedDuration2!=0){
			grid[x2][y2] = 1;   //mark the pixel as traveled
			plot_pixel(x2, y2, color2);
			
			if (dx2==1) x2++;           //update p2 position
            else if (dx2==-1) x2--;
            else if (dy2==1) y2++;
            else if (dy2==-1) y2--;
			
			speedDuration2--;
		}
        if(delayCount == delay){
			
			grid[x1][y1] = 1;   //mark the pixel as traveled
            grid[x2][y2] = 1;
			
			plot_pixel(x1, y1, color1);     //draw the new pixels
            plot_pixel(x2, y2, color2);
			
			if (dx1==1) x1++;           //update p1 position
            else if (dx1==-1) x1--;
            else if (dy1==1) y1++;
            else if (dy1==-1) y1--;
            if (dx2==1) x2++;           //update p2 position
            else if (dx2==-1) x2--;
            else if (dy2==1) y2++;
            else if (dy2==-1) y2--;
			
			delayCount = 0;
			if(speedTimer1!=0) speedTimer1--;
			if(speedTimer2!=0) speedTimer2--;
        }
        wait_for_vsync();
    }
        
    return (EXIT_SUCCESS);
}

void wait_for_vsync(){
	volatile int* pixel_ctrl_ptr = 0xFF203020;	//pixel controller
	register int status;
	
	*pixel_ctrl_ptr = 1;	//start the synchronization process
	
	status = *(pixel_ctrl_ptr + 3);
	while((status & 0x01) != 0){
		status = *(pixel_ctrl_ptr + 3);
	}
}

void plot_pixel(int x, int y, short int line_color){
    *(short int *)(pixel_buffer_start + (y << 10) + (x << 1)) = line_color;
}

void clear_screen(int x0, int y0, int x1, int y1){
	for(int x = x0 ; x < x1 ; x++){
		for(int y = y0 ; y < y1 ; y++){
			plot_pixel(x, y, 0); 	//color black
		}
	}
}

void draw_line(int x0, int y0, int x1, int y1, int color){
	int temp;
	bool steep = abs(y1-y0) > abs(x1-x0);
	int* x0ptr = &x0;
	int* x1ptr = &x1;
	int* y0ptr = &y0;
	int* y1ptr = &y1;
	
	if (steep){
		swap(x0ptr,y0ptr);
		swap(x1ptr,y1ptr);
	}
	if (x0>x1){
		swap(x0ptr,x1ptr);
		swap(y0ptr,y1ptr);
	}
	
	int deltax = x1-x0;
	int deltay = abs(y1-y0);
	int error = -(deltax/2);
	int y = y0;
	
	int y_step;
	
	if (y0 < y1){
		y_step = 1;
	} else {
		y_step = -1;
	}
	
	for(int x  = x0; x <= x1; x++){
		if (steep) plot_pixel(y,x, color);
		else plot_pixel(x,y, color);
		
		error = error + deltay;
		if (error >= 0){
			y = y + y_step;
			error = error - deltax;
		}
	}
}

void swap(int* num1, int* num2){
	int temp;
	temp = *num1;
	*num1 = *num2;
	*num2 = temp;
}
