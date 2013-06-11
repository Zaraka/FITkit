library IEEE;
use IEEE.std_logic_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.vga_controller_cfg.all;

architecture tools_arch of tlv_pc_ifc is

  signal vga_mode: std_logic_vector(60 downto 0);
  signal red: std_logic_vector(2 downto 0);
  signal green: std_logic_vector(2 downto 0);
  signal blue: std_logic_vector(2 downto 0);
  signal rgb : std_logic_vector(8 downto 0);
  signal rgbf : std_logic_vector(8 downto 0);

  signal vgaRow: std_logic_vector(11 downto 0);
  signal vgaCol: std_logic_vector(11 downto 0);
  
  signal fps : std_logic;
  
  type six is 
  record
	r : std_logic_vector(1 downto 0);
	g : std_logic_vector(1 downto 0);
	b : std_logic_vector(1 downto 0);
  end record;
  
  type layer is array(639 downto 0, 479 downto 0) of six;
  type mask is array(5 downto 0) of std_logic_vector(5 downto 0);
  
  signal cross : mask :=  ("001100",
									"001100",
									"111111",
									"111111",
									"001100",
									"001100");
	signal red_color: std_logic_vector(8 downto 0) := "111000000";
begin

function RGB_6to9(input : six) return std_logic_vector is
	variable tmp : std_logic_vector(8 downto 0); 
begin
	if(six.r = 0) then
		tmp(8 downto 6) = "000";
	else
		tmp(8 downto 7) = six.r;
		tmp(6) = '1';
	end if;
	
	if(six.r = 0) then
		tmp(5 downto 3) = "000";
	else
		tmp(5 downto 4) = six.r;
		tmp(3) = '1';
	end if;
	
	if(six.r = 0) then
		tmp(2 downto 0) = "000";
	else
		tmp(2 downto 1) = six.r;
		tmp(0) = '1';
	end if;
	
	return tmp;
end function;

fps_generator: entity work.engen generic map ( MAXVALUE => 50000) port map ( CLK => CLK, ENABLE => '1', EN => fps )

vga: entity work.vga_controller(arch_vga_controller)
  port map(
    CLK => CLK,
    RST => RESET,
    ENABLE => '1',
    MODE => vga_mode,
    DATA_RED => red,
    DATA_GREEN => green,
    DATA_BLUE => blue,
    ADDR_COLUMN => vgaCol,
    ADDR_ROW => vgaRow,
    VGA_RED => RED_V,
    VGA_GREEN => GREEN_V,
    VGA_BLUE => BLUE_V,
    VGA_HSYNC => HSYNC_V,
    VGA_VSYNC => VSYNC_V
  );
  
setmode(r640x480x60, vga_mode);

app_logic: process(fps)
begin
	
end process;


draw: process(CLK)
begin
	if(CLK'event and CLK = '1') then
		if(vgaRow < 7 and vgaCol < 7) then
			if(cross (conv_integer(vgaRow(5 downto 0))) (conv_integer(vgaCol(5 downto 0))) = '1') then
				rgb <= "111000000";
			else
				rgb <= "000111000";
			end if;
		else
			rgb <= "000111000";
		end if;
	end if;
end process;

red <= rgb(8 downto 6);
green <= rgb(5 downto 3);
blue <= rgb(2 downto 0);

end tools_arch;
