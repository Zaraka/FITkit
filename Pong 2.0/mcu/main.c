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
  term_send_str_crlf(" Ovladani");
  term_send_str_crlf(" 1 - nahoru");
  term_send_str_crlf(" 4 - dolu");
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
  term_send_str_crlf("Let us play Pong!");
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
