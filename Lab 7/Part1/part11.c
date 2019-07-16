#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <math.h>

volatile int pixel_buffer_start; // global variable

void swap(int* num1, int* num2);
void clear_screen();
void draw_line(int x0, int y0, int x1, int y1, int color);
void plot_pixel(int x, int y, short int line_color);


void swap(int* num1, int* num2){
	int temp;
	temp = *num1;
	*num1 = *num2;
	*num2 = temp;
}

// code not shown for clear_screen() and draw_line() subroutines
void clear_screen(){
	for(int x = 0 ; x < 320 ; x++){
		for(int y = 0 ; y < 240 ; y++){
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

void plot_pixel(int x, int y, short int line_color){
    *(short int *)(pixel_buffer_start + (y << 10) + (x << 1)) = line_color;
}

int main(void){
    volatile int * pixel_ctrl_ptr = (int *)0xFF203020;
    /* Read location of the pixel buffer from the pixel buffer controller */
    pixel_buffer_start = *pixel_ctrl_ptr;

    clear_screen();
    draw_line(0, 0, 150, 150, 0x001F);   // this line is blue
    draw_line(150, 150, 319, 0, 0x07E0); // this line is green
    draw_line(0, 239, 319, 239, 0xF800); // this line is red
    draw_line(319, 0, 0, 239, 0xF81F);   // this line is a pink color
	
	return 0;
}