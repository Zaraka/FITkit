library IEEE;
use IEEE.std_logic_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.vga_controller_cfg.all;

architecture tools_arch of tlv_pc_ifc is

  --vga control
  signal vga_mode: std_logic_vector(60 downto 0);
  signal red: std_logic_vector(2 downto 0);
  signal green: std_logic_vector(2 downto 0);
  signal blue: std_logic_vector(2 downto 0);
  signal rgb : std_logic_vector(8 downto 0);
  
  signal vgaRow: std_logic_vector(11 downto 0);
  signal vgaCol: std_logic_vector(11 downto 0);
  
  ---keyboard control
  signal keyboard		: std_logic_vector(15 downto 0);
  
  --procedures signals
  --signal fps : std_logic;
  
  type six is 
  record
	r : std_logic_vector(1 downto 0);
	g : std_logic_vector(1 downto 0);
	b : std_logic_vector(1 downto 0);
  end record;
  --constant of record black color
  constant BLACK_SIX : six := (
	r => "00",
	g => "00",
	b => "00"
  );
  
  --drawing layer
  type row is array (9 downto 0) of six;
  type layer is array(9 downto 0) of row;
  type mask is array(5 downto 0) of std_logic_vector(5 downto 0);
  
  signal layer1 : layer;
  
  --drawing functions / procedures
--Clear Screen to a black color procedure
procedure ClearScreen (
   signal return_layer : out layer) is
begin
	--layer1 <= ((others=>(BLACK_SIX)),(others=>(BLACK_SIX)),(others=>(BLACK_SIX)),(others=>(BLACK_SIX)),(others=>(BLACK_SIX)),(others=>(BLACK_SIX)),(others=>(BLACK_SIX)),(others=>(BLACK_SIX)),(others=>(BLACK_SIX)),(others=>(BLACK_SIX)));
	return_layer <= (others => (others => (BLACK_SIX)));
end ClearScreen;
--convert function from 2-2-2 rgb to 3-3-3
function RGB_6to9(input : six) return std_logic_vector is
	variable tmp : std_logic_vector(8 downto 0); 
begin
	if(input.r = 0) then
		tmp(8 downto 6) := "000";
	else
		tmp(8 downto 7) := input.r;
		tmp(6) := '1';
	end if;
	
	if(input.r = 0) then
		tmp(5 downto 3) := "000";
	else
		tmp(5 downto 4) := input.r;
		tmp(3) := '1';
	end if;
	
	if(input.r = 0) then
		tmp(2 downto 0) := "000";
	else
		tmp(2 downto 1) := input.r;
		tmp(0) := '1';
	end if;
	
	return tmp;
end function;
begin

--fps_generator: entity work.engen generic map ( MAXVALUE => 50000) port map ( CLK => CLK, ENABLE => '1', EN => fps );

--kbrd_ctrl: entity work.keyboard_controller(arch_keyboard)
--port map (
--	CLK => CLK,
--	RST => RESET,
--	
--	DATA_OUT => keyboard,
--	DATA_VLD => open,
--	
--	KB_KIN   => KIN,
--	KB_KOUT  => KOUT
--);


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

--user code inside!

--app_logic: process(fps)
--begin
--	ClearScreen(layer1);
--end process;


draw: process(CLK)
begin
	if(CLK'event and CLK = '1') then
		if(vgaRow < 480 and vgaCol < 640) then
			-- display layer
			--rgb <= RGB_6to9(layer1 (conv_integer(vgaRow(9 downto 0))) (conv_integer(vgaCol(9 downto 0))));
		end if;
		
	end if;
end process;

rgb <= "000"&"101"&"000";

red <= rgb(8 downto 6);
green <= rgb(5 downto 3);
blue <= rgb(2 downto 0);

end tools_arch;
