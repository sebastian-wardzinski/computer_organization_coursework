#include <stdbool.h> 

volatile int pixel_buffer_start; // global variable

// code for subroutines (not shown)
void swap(int* num1, int* num2);
void clear_screen();
void draw_line(int x0, int x1, int y0, int y1, int color);
void plot_pixel(int x, int y, short int line_color);
void wait_for_vsync();

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
		if (steep){
			plot_pixel(y,x, color);
			plot_pixel(y,x+1, color);
		}
		else{
			plot_pixel(x,y, color);
			plot_pixel(x,y+1, color);
		}
		
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

int main(void)
{	volatile int* sw_ptr = 0xFF200040;	//switch address
	volatile int* key_ptr = 0xFF200050; //key_address
    volatile int * pixel_ctrl_ptr = (int *)0xFF203020;
    // declare other variables(not shown)
	int x[8];
	int y[8];
	int x_right[8];
	int y_up[8];
	int dx = 1;
	int dy = 1;
    // initialize location and direction of rectangles(not shown)
	for(int i = 0 ; i < 8 ; i++){
		x[i] = rand()%317+1; 	//to avoid corner cases at the start
		y[i] = rand()%237+1;
		x_right[i] = rand()%2;
		y_up[i] = rand()%2;
	}
	
    /* set front pixel buffer to start of FPGA On-chip memory */
    *(pixel_ctrl_ptr + 1) = 0xC8000000; // first store the address in the 
                                        // back buffer
    /* now, swap the front/back buffers, to set the front buffer location */
    wait_for_vsync();
    /* initialize a pointer to the pixel buffer, used by drawing functions */
    pixel_buffer_start = *pixel_ctrl_ptr;
    clear_screen(); // pixel_buffer_start points to the pixel buffer
    /* set back pixel buffer to start of SDRAM memory */
    *(pixel_ctrl_ptr + 1) = 0xC0000000;
    pixel_buffer_start = *(pixel_ctrl_ptr + 1); // we draw on the back buffer
	
    while (1)
    {
        /* Erase any boxes and lines that were drawn in the last iteration */
        clear_screen();
        // code for drawing the boxes and lines (not shown)
		int color;
		if(*sw_ptr == 0) color = 0x0F0F;
		else color = 0xF0F0;
		
		if(*(key_ptr + 3)==1){
			dx *= 2;
			*(key_ptr + 3) = 1;
		}
		else if(*(key_ptr + 3)==2){
			dy *= 2;
			*(key_ptr + 3) = 2;
		}
		else if(*(key_ptr + 3)==4){
			dx /= 2;
			dy /= 2;
			*(key_ptr + 3) = 4;
		}
		else if(*(key_ptr + 3)==8){
			dx = 1;
			dy = 1;
			*(key_ptr + 3) = 8;
		}
		
		for(int i = 0 ; i < 8 ; i++){
			
			for(int j = -2 ; j < 3 ; j++){
				for(int k = -2 ; k <3 ; k++){
					plot_pixel(x[i]+j, y[i]+k, 0xFFFF); 	//draw square with side length 5
				}
			}
			draw_line(x[i], y[i], x[(i+1)%8], y[(i+1)%8], color); 	//draw line between current node and next node
		
        // code for updating the locations of boxes (not shown)
		if(x_right[i] && x[i] >= 319-dx) x_right[i] = 0;
		if(!x_right[i] && x[i] <= dx) x_right[i] = 1;
		if(y_up[i] && y[i] >= 239-dy) y_up[i] = 0;
		if(!y_up[i] && y[i] <= dy*2) y_up[i] = 1;
		
		
		if(x_right[i]) x[i]+=dx;
		else x[i]-=dx;
		if(y_up[i]) y[i]+=dy;
		else y[i]-=dy;
		}
		
        wait_for_vsync(); // swap front and back buffers on VGA vertical sync
        pixel_buffer_start = *(pixel_ctrl_ptr + 1); // new back buffer
    }
}
