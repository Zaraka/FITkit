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

  signal vgaRow: std_logic_vector(11 downto 0);
  signal vgaCol: std_logic_vector(11 downto 0);

  signal keyboard		: std_logic_vector(15 downto 0);

  signal fps: std_logic;
	
  type six is 
  record
	r : std_logic_vector(1 downto 0);
	g : std_logic_vector(1 downto 0);
	b : std_logic_vector(1 downto 0);
  end record;
  --constant of record black color
  constant BLUE_SIX : six := (
	r => "00",
	g => "00",
	b => "11"
  );
  
  signal bgColor: six := ("00", "00", "00");
	
  type rectangle is
  record
   x : std_logic_vector(9 downto 0);
	y : std_logic_vector(9 downto 0);
	w : std_logic_vector(7 downto 0);
	h : std_logic_vector(7 downto 0);
	color : six;
	end record;
  constant END_RECTANGLE : rectangle := (
	x => "0000000000",
	y => "0000000000",
	w => "00000000",
	h => "00000000",
	color => (r => "00", g => "00", b => "00")
  );
  
  --number of rectangle entities
  constant num_entities : integer := 5;
  
  type list is array (1 to num_entities) of rectangle;
  
  signal entity_list : list := (
																1 => ( --player1
																		x => std_logic_vector(to_unsigned(10, x'length)), 
																		y => std_logic_vector(to_unsigned(100, 10)), 
																		w => std_logic_vector(to_unsigned(10, 8)), 
																		h => std_logic_vector(to_unsigned(50, 8)), 
																		color => (r => "00", g => "00", b => "11")
																		), 
																2 => ( --computer
																		x => std_logic_vector(to_unsigned(620, x'length)), 
																		y => std_logic_vector(to_unsigned(10, 10)), 
																		w => std_logic_vector(to_unsigned(10, 8)), 
																		h => std_logic_vector(to_unsigned(50, 8)), 
																		color => (r => "11", g => "00", b => "00")
																	  ),
															   3 => ( --ball
																		x => std_logic_vector(to_unsigned(320, x'length)), 
																		y => std_logic_vector(to_unsigned(240, 10)), 
																		w => std_logic_vector(to_unsigned(10, 8)), 
																		h => std_logic_vector(to_unsigned(10, 8)), 
																		color => (r => "11", g => "11", b => "11")
																	  ),
																others => (END_RECTANGLE)
																);
  
  --drawing functions / procedures
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
	
	if(input.g = 0) then
		tmp(5 downto 3) := "000";
	else
		tmp(5 downto 4) := input.g;
		tmp(3) := '1';
	end if;
	
	if(input.b = 0) then
		tmp(2 downto 0) := "000";
	else
		tmp(2 downto 1) := input.b;
		tmp(0) := '1';
	end if;
	
	return tmp;
end function;

function getMiddleY(input : rectangle) return std_logic_vector is
	variable tmp : integer;
	variable result : std_logic_vector(9 downto 0);
begin
	tmp := conv_integer(input.h) / 2;
	result := conv_std_logic_vector(tmp, 10) + input.y;
	return result;
end function;

component keyboard_controller
	port(
		CLK      : in std_logic;
		RST      : in std_logic;
		
		DATA_OUT : out std_logic_vector(15 downto 0);
		DATA_VLD : out std_logic;
		
		KB_KIN   : out std_logic_vector(3 downto 0);
		KB_KOUT  : in  std_logic_vector(3 downto 0)
	);
end component;

begin

kbrd_ctrl: entity work.keyboard_controller(arch_keyboard)
port map (
	CLK => CLK,
	RST => RESET,
	
	DATA_OUT => keyboard,
	DATA_VLD => open,
	
	KB_KIN   => KIN,
	KB_KOUT  => KOUT
);


fps_generator: entity work.engen generic map ( MAXVALUE => 80000) port map ( CLK => CLK, ENABLE => '1', EN => fps );

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

-- user code here!
app_logic: process(fps)
	variable clock_miss : integer := 2;
	variable clock_counter : integer := 0;
	variable direction_right : bit := '0';
	variable direction_up : bit := '1';
	variable player_move_up : bit := '0';
	variable computer_move_up : bit := '0';
	variable restart : bit := '0';
begin
	if(fps'event and fps = '1') then
		if(keyboard(0) = '1') then
			if(entity_list(1).y > 0) then
				entity_list(1).y <= entity_list(1).y - std_logic_vector(to_unsigned(1, 10));
				player_move_up := '1';
			end if;
		elsif(keyboard(1) = '1') then
			if(entity_list(1).y < 430) then
				entity_list(1).y <= entity_list(1).y + std_logic_vector(to_unsigned(1, 10));
				player_move_up := '0';
			end if;
		end if;


	--computer paddle moves
		if(getMiddleY(entity_list(3)) < getMiddleY(entity_list(2))) then
			if(entity_list(2).y > 0) then
				entity_list(2).y <= entity_list(2).y - std_logic_vector(to_unsigned(1, 10));
				computer_move_up := '1';
			end if;
		elsif(getMiddleY(entity_list(3)) > getMiddleY(entity_list(2))) then
			if(entity_list(2).y < 430) then
				entity_list(2).y <= entity_list(2).y + std_logic_vector(to_unsigned(1, 10));
				computer_move_up := '0';
			end if;
		end if;
		
		if (clock_counter >= clock_miss) then
			clock_counter := 0;
			
			if(entity_list(3).x = 1) then
			--computer wins!
				entity_list(3).x <= std_logic_vector(to_unsigned(320, 10));
				entity_list(3).y <= std_logic_vector(to_unsigned(240, 10));
				clock_miss := 2;
				restart := '1';
				direction_right := '1';
			elsif(entity_list(3).x = 630) then
			--player wins!
				entity_list(3).x <= std_logic_vector(to_unsigned(320, 10));
				entity_list(3).y <= std_logic_vector(to_unsigned(240, 10));
				clock_miss := 2;
				restart := '1';
				direction_right := '1';
			end if;
			
			if(restart = '0') then
				if(entity_list(3).y = 1) then
					direction_up := '0';
					clock_miss := clock_miss + 1;
				elsif(entity_list(3).y = 469) then
					direction_up := '1';
					clock_miss := clock_miss - 1;
				end if;
				
				--check player collision
				if(entity_list(3).x = 20) then
					if(getMiddleY(entity_list(3)) >= entity_list(1).y and getMiddleY(entity_list(3)) <= (entity_list(1).y + entity_list(1).h)) then
						direction_right := '1';
						if(player_move_up = '1') then
							direction_up := '1';
						else
							direction_up := '0';
						end if;
					end if;
				end if;
				--check computer collision
				if(entity_list(3).x = 610) then
						if(getMiddleY(entity_list(3)) >= entity_list(2).y and getMiddleY(entity_list(3)) <= (entity_list(2).y + entity_list(2).h)) then
							direction_right := '0';
							if(computer_move_up = '1') then
								direction_up := '1';
							else
								direction_up := '0';
							end if;
						end if;
				end if;
				
				if (direction_right = '1') then				
					entity_list(3).x <= entity_list(3).x + std_logic_vector(to_unsigned(1, 10));
				else
					entity_list(3).x <= entity_list(3).x - std_logic_vector(to_unsigned(1, 10));
				end if;
				
				if (direction_up = '1') then
					entity_list(3).y <= entity_list(3).y - std_logic_vector(to_unsigned(1, 10));
				else
					entity_list(3).y <= entity_list(3).y + std_logic_vector(to_unsigned(1, 10));
				end if;
			else
				restart := '0';
			end if;
		else
			clock_counter := clock_counter + 1;
		end if;
	end if;
end process;

-- DO NOT CHANGE THIS
draw: process(CLK)
begin
	if(CLK'event and CLK = '1') then
		if(vgaRow < 479 and vgaCol < 639) then
				rgb <= RGB_6to9(bgColor);
				for i_object in 1 to num_entities loop
					if(entity_list(i_object) = END_RECTANGLE) then
						exit;
					end if;
					
					if(vgaCol >= entity_list(i_object).x and vgaCol <= (entity_list(i_object).x + entity_list(i_object).w)) then					
						if(vgaRow >= entity_list(i_object).y and vgaRow <= (entity_list(i_object).y + entity_list(i_object).h)) then					
							rgb <= RGB_6to9(entity_list(i_object).color);
						end if;
					end if;
				end loop;
		else
			rgb <= RGB_6to9(bgColor);
		end if;

	end if;
end process;

red <= rgb(8 downto 6);
green <= rgb(5 downto 3);
blue <= rgb(2 downto 0);

end tools_arch;
