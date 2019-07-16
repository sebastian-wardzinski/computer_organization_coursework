#include <stdbool.h> 

volatile int pixel_buffer_start;

void swap(int* num1, int* num2);
void clear_screen();
void draw_line(int x0, int x1, int y0, int y1, int color);
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

void wait_for_vsync(){
	volatile int* pixel_ctrl_ptr = 0xFF203020;	//pixel controller
	register int status;
	
	*pixel_ctrl_ptr = 1;	//start the synchronization process
	
	status = *(pixel_ctrl_ptr + 3);
	while((status & 0x01) != 0){
		status = *(pixel_ctrl_ptr + 3);
	}
}

int main(void){
	volatile int* pixel_ctrl_ptr = (int*) 0xFF203020;
	/*Read location of the pixel buffer from the pixel buffer controller*/
	pixel_buffer_start = *pixel_ctrl_ptr;
	
	clear_screen();
	int y = 0;
	draw_line(0, y, 319, y, 0x001F);
	int y_old = y;
	y++;
	bool y_increasing = true;
	
	while(1){ 
		draw_line(0, y_old, 319, y_old, 0x0000);
		draw_line(0, y, 319, y, 0x001F);   //blue line
		
		if(y == 239) y_increasing = false;
		else if(y == 0) y_increasing = true;
		
		y_old = y;
		if(y_increasing) y++;
		else y--;
		
		wait_for_vsync();
	}
}
