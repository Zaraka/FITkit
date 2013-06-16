/*******************************************************************************

*******************************************************************************/

#include <fitkitlib.h>
#include <lcd/display.h>
#include <string.h>
#include <stdbool.h>

/**
 * calls after Terminal message "help"
 */
void print_user_help(void){ 
}


/**
 * decode_user_cmd
 * 
 * @param cmd_ucase
 * @param cmd
 * @return 
 */
unsigned char decode_user_cmd(char *cmd_ucase, char *cmd)
{

}


/**
 * 
 */
void fpga_initialized(){

}


int main(void)
{

  initialize_hardware();
  set_led_d6(1);
  set_led_d5(0);

  while (1)
  {
      delay_ms(10);
      flip_led_d6();
      flip_led_d5();
		terminal_idle(); 
  }
  
}
