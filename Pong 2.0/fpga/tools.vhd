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
  
  signal score_player : std_logic_vector(3 downto 0);
  signal score_computer : std_logic_vector(3 downto 0);
	
  function score2char(input : std_logic_vector(3 downto 0)) return character is
  variable result : character;
  begin
  
  case input is
	when "0000" =>
		result := '0';
	when "0001" =>
		result := '1';
	when "0010" =>
		result := '2';
	when "0011" =>
		result := '3';
	when "0100" =>
		result := '4';
	when "0101" =>
		result := '5';
	when "0110" =>
		result := '6';
	when "0111" =>
		result := '7';
	when "1000" =>
		result := '8';
	when "1001" =>
		result := '9';
	when others =>
		result := '0';
	end case;
	return result;
  end function;
	
  type six is 
  record
	r : std_logic_vector(1 downto 0);
	g : std_logic_vector(1 downto 0);
	b : std_logic_vector(1 downto 0);
  end record;
  
    type nine is
  record
	r : std_logic_vector(2 downto 0);
	g : std_logic_vector(2 downto 0);
	b : std_logic_vector(2 downto 0);
  end record;
  
  signal bgColor: six := ("00", "00", "00");
  
  --lets have 4 colors... and they will be GREEN!
  type pallete is array (0 to 15) of nine;
  constant colorPallete : pallete := (
	0 => ("000", "000", "000"),
	1 => ("000", "101", "000"),
	2 => ("000", "110", "000"),
	3 => ("000", "111", "000"),
	others => ("000", "000", "000")
  );
  
  function repairPos(input : integer) return integer is
  variable result : integer range 0 to 14;
  begin
	if(input > 14) then
		result := 14;
	else
		result := input;
	end if;
	return result;
  end function;
  
  function pallete2color(input : std_logic_vector(1 downto 0)) return nine is
  variable result : nine;
  begin
    case input is
		when "00" =>
			result := colorPallete(0); 
		when "01" =>
			result := colorPallete(1);
		when "10" =>
			result := colorPallete(2);
		when "11" =>
			result := colorPallete(3);
		when others =>
			result := colorPallete(0);
	 end case;
	 return result;
  end function;
  
  function color2nine(input : nine) return std_logic_vector is
  variable tmp : std_logic_vector(8 downto 0);
  begin
   tmp := input.r & input.g & input.b;
	return tmp;
  end function;
  
  function numberBitmap(input : character) return integer is
  variable result : integer range 0 to 9;
  begin
    case input is
		when '0' =>
			result := 0;
		when '1' =>
			result := 1;
		when '2' =>
			result := 2;
		when '3' =>
			result := 3;
		when '4' =>
			result := 4;
		when '5' =>
			result := 5;
		when '6' =>
			result := 6;
		when '7' =>
			result := 7;
		when '8' =>
			result := 8;
		when '9' =>
			result := 9;
		when others => result := 0;
	end case;
	return result;
  end function;
	
  type rectangle is
  record
   x : std_logic_vector(9 downto 0);
	y : std_logic_vector(9 downto 0);
	w : std_logic_vector(7 downto 0);
	h : std_logic_vector(7 downto 0);
	color : nine; --need moar colors!
	end record;
  constant END_RECTANGLE : rectangle := (
	x => "0000000000",
	y => "0000000000",
	w => "00000000",
	h => "00000000",
	color => (r => "000", g => "000", b => "000")
  );
  
  type bitmap2 is array(0 to 224) of std_logic_vector(1 downto 0);
  
  constant LETTER_SIZE : integer := 14;
  
  type num_entity is
  record
    x : std_logic_vector(9 downto 0);
	 y : std_logic_vector(9 downto 0);
    c : character;
  end record;	 
  constant END_NUMBER : num_entity := (
    x => "0000000000",
	 y => "0000000000",
	 c => ' '
  );
  
  type numbers is array (1 to 2) of num_entity;
  signal number_entity : numbers := ( others => (END_NUMBER));
  
  type number_list is array (0 to 9) of bitmap2;
  
  signal number_rom : number_list := (
  0 => (
"00", "11", "11", "11", "11", "11", "11", "11", "11", "11", "11", "11", "11", "11", "00", 
"11", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "10", 
"11", "00", "00", "10", "10", "10", "10", "10", "10", "10", "10", "01", "00", "00", "10", 
"11", "00", "00", "10", "00", "00", "00", "00", "00", "00", "11", "00", "00", "00", "10", 
"11", "00", "00", "10", "00", "00", "00", "00", "00", "11", "00", "00", "00", "00", "10", 
"11", "00", "00", "10", "00", "00", "00", "00", "11", "00", "00", "01", "00", "00", "10", 
"11", "00", "00", "10", "00", "00", "00", "11", "00", "00", "10", "11", "00", "00", "10", 
"11", "00", "00", "10", "00", "00", "11", "00", "00", "10", "00", "11", "00", "00", "10", 
"11", "00", "00", "10", "00", "11", "00", "00", "10", "00", "00", "11", "00", "00", "10", 
"11", "00", "00", "10", "11", "00", "00", "10", "00", "00", "00", "11", "00", "00", "10", 
"11", "00", "00", "01", "00", "00", "10", "00", "00", "00", "00", "11", "00", "00", "10", 
"11", "00", "00", "00", "00", "10", "00", "00", "00", "00", "00", "11", "00", "00", "10", 
"11", "00", "00", "00", "01", "11", "11", "11", "11", "11", "11", "11", "00", "00", "10", 
"11", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "10", 
"00", "10", "10", "10", "10", "10", "10", "10", "10", "10", "10", "10", "10", "10", "00"
), 
1 => (
"00", "00", "00", "00", "00", "00", "00", "00", "00", "11", "11", "11", "01", "00", "00", 
"00", "00", "00", "00", "00", "00", "00", "00", "11", "00", "00", "00", "10", "00", "00", 
"00", "00", "00", "00", "00", "00", "00", "11", "00", "00", "00", "00", "10", "00", "00", 
"00", "00", "00", "00", "00", "00", "01", "10", "10", "01", "00", "00", "10", "00", "00", 
"00", "00", "00", "00", "00", "00", "00", "00", "00", "11", "00", "00", "10", "00", "00", 
"00", "00", "00", "00", "00", "00", "00", "00", "00", "11", "00", "00", "10", "00", "00", 
"00", "00", "00", "00", "00", "00", "00", "00", "00", "11", "00", "00", "10", "00", "00", 
"00", "00", "00", "00", "00", "00", "00", "00", "00", "11", "00", "00", "10", "00", "00", 
"00", "00", "00", "00", "00", "00", "00", "00", "00", "11", "00", "00", "10", "00", "00", 
"00", "00", "00", "00", "00", "00", "00", "00", "00", "11", "00", "00", "01", "11", "01", 
"00", "00", "00", "00", "00", "00", "00", "00", "00", "11", "00", "00", "00", "00", "10", 
"00", "00", "00", "00", "00", "00", "11", "11", "11", "11", "00", "00", "00", "00", "10", 
"00", "00", "00", "00", "00", "00", "11", "00", "00", "00", "00", "00", "00", "00", "10", 
"00", "00", "00", "00", "00", "00", "11", "00", "00", "00", "00", "00", "00", "00", "10", 
"00", "00", "00", "00", "00", "00", "01", "10", "10", "10", "10", "10", "10", "10", "10"
), 
2 => (
"00", "11", "11", "11", "11", "11", "11", "11", "11", "11", "11", "11", "11", "11", "00", 
"11", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "10", 
"11", "00", "00", "10", "10", "10", "10", "10", "10", "10", "10", "01", "00", "00", "10", 
"01", "10", "10", "10", "00", "00", "00", "00", "00", "00", "00", "11", "00", "00", "10", 
"00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "11", "00", "00", "10", 
"00", "11", "11", "11", "11", "11", "11", "11", "11", "11", "11", "11", "00", "00", "10", 
"11", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "10", 
"11", "00", "00", "01", "10", "10", "10", "10", "10", "10", "10", "10", "10", "10", "00", 
"11", "00", "00", "10", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", 
"11", "00", "00", "01", "11", "01", "00", "00", "00", "00", "00", "11", "11", "11", "01", 
"11", "00", "00", "00", "00", "10", "00", "00", "00", "00", "00", "11", "00", "00", "10", 
"11", "00", "00", "00", "00", "10", "00", "00", "00", "00", "00", "11", "00", "00", "10", 
"11", "00", "00", "00", "00", "01", "11", "11", "11", "11", "11", "11", "00", "00", "10", 
"11", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "10", 
"01", "10", "10", "10", "10", "10", "10", "10", "10", "10", "10", "10", "10", "10", "10" 
), 
3 => (
"00", "11", "11", "11", "11", "11", "11", "11", "11", "11", "11", "11", "11", "11", "00", 
"11", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "10", 
"11", "00", "00", "10", "10", "10", "10", "10", "10", "10", "10", "01", "00", "00", "10", 
"01", "10", "10", "10", "00", "00", "00", "00", "00", "00", "00", "11", "00", "00", "10", 
"00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "11", "00", "00", "10", 
"00", "00", "00", "00", "00", "00", "11", "11", "11", "11", "11", "11", "00", "00", "10", 
"00", "00", "00", "00", "00", "00", "11", "00", "00", "00", "00", "00", "00", "10", "00", 
"00", "00", "00", "00", "00", "00", "01", "10", "10", "10", "10", "01", "00", "00", "10", 
"00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "11", "00", "00", "10", 
"11", "11", "11", "11", "11", "01", "00", "00", "00", "00", "00", "11", "00", "00", "10", 
"11", "00", "00", "00", "00", "10", "00", "00", "00", "00", "00", "11", "00", "00", "10", 
"11", "00", "00", "00", "00", "10", "00", "00", "00", "00", "00", "11", "00", "00", "10", 
"11", "00", "00", "00", "00", "01", "11", "11", "11", "11", "11", "11", "00", "00", "10", 
"11", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "10", 
"00", "10", "10", "10", "10", "10", "10", "10", "10", "10", "10", "10", "10", "10", "00"
), 
4 => (
"11", "11", "11", "01", "00", "00", "00", "00", "00", "00", "00", "11", "11", "11", "01", 
"11", "00", "00", "10", "00", "00", "00", "00", "00", "00", "00", "11", "00", "00", "10", 
"11", "00", "00", "10", "00", "00", "00", "00", "00", "00", "00", "11", "00", "00", "10", 
"11", "00", "00", "10", "00", "00", "00", "00", "00", "00", "00", "11", "00", "00", "10", 
"11", "00", "00", "10", "00", "00", "00", "00", "00", "00", "00", "11", "00", "00", "10", 
"11", "00", "00", "01", "11", "11", "11", "11", "11", "11", "11", "11", "00", "00", "10", 
"11", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "10", 
"01", "10", "10", "10", "10", "10", "10", "10", "10", "10", "10", "01", "00", "00", "10", 
"00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "11", "00", "00", "10", 
"00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "11", "00", "00", "10", 
"00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "11", "00", "00", "10", 
"00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "11", "00", "00", "10", 
"00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "11", "00", "00", "10", 
"00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "11", "00", "00", "10", 
"00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "01", "10", "10", "10"
), 
5 => (
"11", "11", "11", "11", "11", "11", "11", "11", "11", "11", "11", "11", "11", "11", "01", 
"11", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "10", 
"11", "00", "00", "10", "10", "10", "10", "10", "10", "10", "10", "01", "00", "00", "10", 
"11", "00", "00", "10", "00", "00", "00", "00", "00", "00", "00", "01", "10", "10", "10", 
"11", "00", "00", "10", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", 
"11", "00", "00", "01", "11", "11", "11", "11", "11", "11", "11", "11", "11", "11", "00", 
"11", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "10", 
"01", "10", "10", "10", "10", "10", "10", "10", "10", "10", "10", "01", "00", "00", "10", 
"00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "11", "00", "00", "10", 
"11", "11", "11", "11", "11", "01", "00", "00", "00", "00", "00", "11", "00", "00", "10", 
"11", "00", "00", "00", "00", "10", "00", "00", "00", "00", "00", "11", "00", "00", "10", 
"11", "00", "00", "00", "00", "10", "00", "00", "00", "00", "00", "11", "00", "00", "10", 
"11", "00", "00", "00", "00", "01", "11", "11", "11", "11", "11", "11", "00", "00", "10", 
"11", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "10", 
"00", "10", "10", "10", "10", "10", "10", "10", "10", "10", "10", "10", "10", "10", "00"
), 
6 => (
"00", "11", "11", "11", "11", "11", "11", "11", "11", "11", "11", "11", "11", "11", "00", 
"11", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "01", 
"11", "00", "00", "10", "10", "10", "10", "10", "10", "10", "10", "01", "00", "00", "10", 
"11", "00", "00", "10", "00", "00", "00", "00", "00", "00", "00", "01", "10", "10", "10", 
"11", "00", "00", "10", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", 
"11", "00", "00", "01", "11", "11", "11", "11", "11", "11", "11", "11", "11", "11", "00", 
"11", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "10", 
"11", "00", "00", "01", "10", "10", "10", "10", "10", "10", "10", "01", "00", "00", "10", 
"11", "00", "00", "10", "00", "00", "00", "00", "00", "00", "00", "11", "00", "00", "10", 
"11", "00", "00", "01", "11", "01", "00", "00", "00", "00", "00", "11", "00", "00", "10", 
"11", "00", "00", "00", "00", "10", "00", "00", "00", "00", "00", "11", "00", "00", "10", 
"11", "00", "00", "00", "00", "10", "00", "00", "00", "00", "00", "11", "00", "00", "10", 
"11", "00", "00", "00", "00", "01", "11", "11", "11", "11", "11", "11", "00", "00", "10", 
"11", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "10", 
"00", "10", "10", "10", "10", "10", "10", "10", "10", "10", "10", "10", "10", "10", "00"
), 
7 => (
"11", "11", "11", "11", "11", "11", "11", "11", "11", "11", "11", "11", "11", "11", "00", 
"11", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "10", 
"11", "00", "00", "10", "10", "10", "10", "10", "10", "10", "10", "01", "00", "00", "10", 
"01", "10", "10", "10", "00", "00", "00", "00", "00", "00", "00", "11", "00", "00", "10", 
"00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "11", "00", "00", "10", 
"00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "11", "00", "00", "10", 
"00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "11", "00", "00", "10", 
"00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "11", "00", "00", "10", 
"00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "11", "00", "00", "10", 
"00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "11", "00", "00", "10", 
"00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "11", "00", "00", "10", 
"00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "11", "00", "00", "10", 
"00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "11", "00", "00", "10", 
"00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "11", "00", "00", "10", 
"00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "01", "10", "10", "10"
), 
8 => (
"00", "11", "11", "11", "11", "11", "11", "11", "11", "11", "11", "11", "11", "11", "00", 
"11", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "01", 
"11", "00", "00", "10", "10", "10", "10", "10", "10", "10", "10", "01", "00", "00", "10", 
"11", "00", "00", "10", "00", "00", "00", "00", "00", "00", "00", "11", "00", "00", "10", 
"11", "00", "00", "10", "00", "00", "00", "00", "00", "00", "00", "11", "00", "00", "10", 
"11", "00", "00", "01", "11", "11", "11", "11", "11", "11", "11", "01", "00", "00", "10", 
"00", "11", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "10", "00", 
"11", "00", "00", "01", "10", "10", "10", "10", "10", "10", "10", "01", "00", "00", "10", 
"11", "00", "00", "10", "00", "00", "00", "00", "00", "00", "00", "11", "00", "00", "10", 
"11", "00", "00", "01", "11", "01", "00", "00", "00", "00", "00", "11", "00", "00", "10", 
"11", "00", "00", "00", "00", "10", "00", "00", "00", "00", "00", "11", "00", "00", "10", 
"11", "00", "00", "00", "00", "10", "00", "00", "00", "00", "00", "11", "00", "00", "10", 
"11", "00", "00", "00", "00", "01", "11", "11", "11", "11", "11", "11", "00", "00", "10", 
"11", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "10", 
"00", "10", "10", "10", "10", "10", "10", "10", "10", "10", "10", "10", "10", "10", "00"
), 
9 => (
"00", "11", "11", "11", "11", "11", "11", "11", "11", "11", "11", "11", "11", "11", "00", 
"11", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "10", 
"11", "00", "00", "10", "10", "10", "10", "10", "10", "10", "10", "01", "00", "00", "10", 
"11", "00", "00", "10", "00", "00", "00", "00", "00", "00", "00", "11", "00", "00", "10", 
"11", "00", "00", "10", "00", "00", "00", "00", "00", "00", "00", "11", "00", "00", "10", 
"11", "00", "00", "01", "11", "11", "11", "11", "11", "11", "11", "01", "00", "00", "10", 
"11", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "10", 
"00", "10", "10", "10", "10", "10", "10", "10", "10", "10", "10", "01", "00", "00", "10", 
"00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "11", "00", "00", "10", 
"11", "11", "11", "11", "11", "01", "00", "00", "00", "00", "00", "11", "00", "00", "10", 
"11", "00", "00", "00", "00", "10", "00", "00", "00", "00", "00", "11", "00", "00", "10", 
"11", "00", "00", "00", "00", "10", "00", "00", "00", "00", "00", "11", "00", "00", "10", 
"11", "00", "00", "00", "00", "01", "11", "11", "11", "11", "11", "11", "00", "00", "10", 
"11", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "00", "10", 
"00", "10", "10", "10", "10", "10", "10", "10", "10", "10", "10", "10", "10", "10", "00"
)
  );
  
  --number of rectangle entities
  constant num_entities : integer := 5;
  
  type list is array (1 to num_entities) of rectangle;
  
  signal entity_list : list := (
																1 => ( --player1
																		x => std_logic_vector(to_unsigned(15, 10)), 
																		y => std_logic_vector(to_unsigned(100, 10)), 
																		w => std_logic_vector(to_unsigned(5, 8)), 
																		h => std_logic_vector(to_unsigned(50, 8)), 
																		color => (r => "000", g => "110", b => "000")
																		), 
																2 => ( --computer
																		x => std_logic_vector(to_unsigned(625, 10)), 
																		y => std_logic_vector(to_unsigned(10, 10)), 
																		w => std_logic_vector(to_unsigned(5, 8)), 
																		h => std_logic_vector(to_unsigned(50, 8)), 
																		color => (r => "000", g => "110", b => "000")
																	  ),
															   3 => ( --ball
																		x => std_logic_vector(to_unsigned(320, 10)), 
																		y => std_logic_vector(to_unsigned(240, 10)), 
																		w => std_logic_vector(to_unsigned(10, 8)), 
																		h => std_logic_vector(to_unsigned(10, 8)), 
																		color => (r => "000", g => "110", b => "000")
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
	variable init : bit := '1';
	variable divider_player : bit := '0';
	variable divider_computer : bit := '0';
begin
	if(fps'event and fps = '1') then
		if(init = '1') then
			number_entity(1).x <= std_logic_vector(to_unsigned(153, 10));
			number_entity(1).y <= std_logic_vector(to_unsigned(5, 10));
			number_entity(1).c <= '0';
			
			number_entity(2).x <= std_logic_vector(to_unsigned(473, 10));
			number_entity(2).y <= std_logic_vector(to_unsigned(5, 10));
			number_entity(2).c <= '0';
			init := '0';
		end if;
		
		--convert vector to character
		number_entity(1).c <= score2char(score_player);
		number_entity(2).c <= score2char(score_computer);
	
		if(keyboard(0) = '1') then
			if(divider_player = '1')then
				if(entity_list(1).y > 0) then
					entity_list(1).y <= entity_list(1).y - std_logic_vector(to_unsigned(1, 10));
					player_move_up := '1';
				end if;
				divider_player := '0';
			else
				divider_player := '1';
			end if;
		elsif(keyboard(1) = '1') then
			if(divider_player = '1')then
				if(entity_list(1).y < 430) then
					entity_list(1).y <= entity_list(1).y + std_logic_vector(to_unsigned(1, 10));
					player_move_up := '0';
				end if;
				divider_player := '0';
			else
				divider_player := '1';
			end if;
		end if;


	--computer paddle moves
		if(getMiddleY(entity_list(3)) < getMiddleY(entity_list(2))) then
			if(divider_computer = '1') then
				if(entity_list(2).y > 0) then
					entity_list(2).y <= entity_list(2).y - std_logic_vector(to_unsigned(1, 10));
					computer_move_up := '1';
				end if;
				divider_computer := '0';
			else
				divider_computer := '1';
			end if;
		elsif(getMiddleY(entity_list(3)) > getMiddleY(entity_list(2))) then
			if(divider_computer = '1') then
				if(entity_list(2).y < 430) then
					entity_list(2).y <= entity_list(2).y + std_logic_vector(to_unsigned(1, 10));
					computer_move_up := '0';
				end if;
				divider_computer := '0';
			else
				divider_computer := '1';
			end if;
		end if;
		
		if (clock_counter >= clock_miss) then
			clock_counter := 0;
			
			if(entity_list(3).x = 1) then
			--computer wins!
				entity_list(3).x <= std_logic_vector(to_unsigned(320, 10));
				entity_list(3).y <= std_logic_vector(to_unsigned(240, 10));
				clock_miss := 2;
				score_computer <= score_computer + std_logic_vector(to_unsigned(1, 4));
				if(score_computer = 9) then
					score_computer <= "0000";
					score_player <= "0000";
				end if;
				restart := '1';
				direction_right := '1';
			elsif(entity_list(3).x = 630) then
			--player wins!
				entity_list(3).x <= std_logic_vector(to_unsigned(320, 10));
				entity_list(3).y <= std_logic_vector(to_unsigned(240, 10));
				clock_miss := 2;
				score_player <= score_player + std_logic_vector(to_unsigned(1, 4));
				if(score_player = 9) then
					score_computer <= "0000";
					score_player <= "0000";
				end if;
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
					if(entity_list(3).y >= entity_list(1).y and entity_list(3).y <= (entity_list(1).y + entity_list(1).h)) then
						direction_right := '1';
						if(player_move_up = '1') then
							direction_up := '1';
						else
							direction_up := '0';
						end if;
					elsif((entity_list(3).y + entity_list(3).h) >= entity_list(1).y and (entity_list(3).y + entity_list(3).h) <= (entity_list(1).y + entity_list(1).h)) then
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
	variable pos_x : integer range 0 to 14;
	variable pos_y  : integer range 0 to 14;
	variable pos_c : integer range 0 to 224;
	variable letter_number : integer range 1 to 27;
	variable tmp_vector : std_logic_vector(1 downto 0);
	variable tmp_nine : nine;
	variable tmp_letter : bitmap2;
begin
	if(CLK'event and CLK = '1') then
		if(vgaRow < 479 and vgaCol < 639) then
				rgb <= RGB_6to9(bgColor);
				-- rectangle drawing
				for i_object in 1 to num_entities loop
					if(entity_list(i_object) = END_RECTANGLE) then
						exit;
					end if;
					
					if(vgaCol >= entity_list(i_object).x and vgaCol <= (entity_list(i_object).x + entity_list(i_object).w)) then					
						if(vgaRow >= entity_list(i_object).y and vgaRow <= (entity_list(i_object).y + entity_list(i_object).h)) then					
							rgb <= color2nine(entity_list(i_object).color);
						end if;
					end if;
				end loop;
				
					for i_object in 1 to 2 loop
						if(number_entity(i_object) = END_NUMBER) then
							exit;
						end if;
						
						if(vgaCol >= number_entity(i_object).x and vgaCol <= (number_entity(i_object).x + LETTER_SIZE)) then					
							if(vgaRow >= number_entity(i_object).y and vgaRow <= (number_entity(i_object).y + LETTER_SIZE)) then	
								pos_x := repairPos(conv_integer(vgaCol(9 downto 0) - number_entity(i_object).x));
								pos_y := repairPos(conv_integer(vgaRow(9 downto 0) - number_entity(i_object).y));
								letter_number := numberBitmap(number_entity(i_object).c);
								tmp_letter := number_rom(letter_number);
								pos_c := pos_x + (pos_y * 15);
								tmp_vector := tmp_letter(pos_c);
								rgb <= color2nine(pallete2color(tmp_vector));
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
