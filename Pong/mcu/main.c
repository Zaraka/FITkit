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
  term_send_str_crlf(" VER - verze programu")
  term_send_str_crlf(" DEMO - spusti demo")
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
  if(strcmp(cmd_ucase, "VER") == 0){
	term_send_str_crlf("Version 0.1");
	return USER_COMMAND;
  } else {
	return CMD_UNKNOWN;
  }
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
