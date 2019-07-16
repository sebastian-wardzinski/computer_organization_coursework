#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <math.h>

volatile int pixel_buffer_start;

void draw_pixel(int x, int y, short int line_color) {

  
  *((short int *) (pixel_buffer_start + (y << 10) + (x << 1))) = line_color;

}

void clear_screen () {
  
  int a = 0;
  int b = 0;
  
  for (b = 0; b < 240; ++b) {
    for (a = 0; a < 320; ++a) {
      draw_pixel(a,b,0);
    }
  }  
}

void swap (int* first, int* second) {

  int temp = *first;
  *first = *second;
  *second = temp;
  

}

void draw_line (int x0, int y0, int x1, int y1, int color) {

  bool is_steep = abs(y1 - y0) > abs(x1 - x0);

  int * x0_p = & x0;
  int * x1_p = & x1;
  int * y0_p = & y0;
  int * y1_p = & y1;
  
  if (is_steep) {

    swap(x0_p, y0_p);
    swap(x1_p, y1_p);
    
  }

  if (x0 > x1) {

    swap(x0_p, x1_p);
    swap(y0_p, y1_p);
  
  }

    int dx = x1 - x0;
    int dy = abs(y1 - y0);
    int error = -1 * (dx/2);

    int y = y0;
    int y_step = 0;
  
    int x = x0;
    
    if (y0 < y1) y_step = 1;
    else y_step = -1;

  for (x = x0; x < x1 + 1; ++x) {
    if (is_steep) 
      draw_pixel (y,x,color);
    else
      draw_pixel (x,y,color);

    error += dy;

    if (error >= 0) {
      y += y_step;
      error -= dx;
    }
  }
}

int main(void) {
  volatile int * pixel_ctrl_ptr = (int *)0xFF203020;  
  /* Read location of the pixel buffer from the pixel buffer controller */
  pixel_buffer_start = *pixel_ctrl_ptr;
  
  clear_screen();
  
  draw_line(0, 0, 150, 150, 0x001F);                  // this line is blue
  draw_line(150, 150, 319, 0, 0x07E0);                // this line is green
  draw_line(0, 239, 319, 239, 0xF800);                // this line is red
  draw_line(319, 0, 0, 239, 0xF81F);                  // this line is a pink color

  return 0;
 
}
