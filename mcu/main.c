/*******************************************************************************

*******************************************************************************/

#include <fitkitlib.h>
#include "vga.h"

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
    /*
  if (strcmp(cmd_ucase, "FLASH W TEX") == 0)
  {
    FLASH_WriteFile(TEXTURE_PAGE,"Textura (8192B)","*.bin",32); //max 8291B
    return USER_COMMAND;
  }
  else if (strcmp(cmd_ucase, "FLASH W MASK") == 0)
  {
    FLASH_WriteFile(MASK_PAGE,"Maska (1024B)","*.bin",4); //max 1024B
    return USER_COMMAND;
  }
  else if (strcmp(cmd_ucase, "UPDATE TEX") == 0)
  {
    TEX_Flash_FPGA();
    return USER_COMMAND;
  }
  else
    return CMD_UNKNOWN;
     */
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
  }
  terminal_idle();                   // obsluha terminalu
}
