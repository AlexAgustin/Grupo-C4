library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity lcd_control_tb is 
end lcd_control_tb;

architecture arq_lcd_control_tb of lcd_control_tb is

	component lcd_control
		port(
			CLK,RESET_L,LCD_Init_Done,OP_SETCURSOR,OP_DRAWCOLOUR: in std_logic;
			XCOL: in std_logic_vector(7 downto 0);
			YROW: in std_logic_vector(8 downto 0);
			RGB: in std_logic_vector(15 downto 0);
			NUM_PIX: in unsigned(16 downto 0);
			DONE_CURSOR,DONE_COLOUR,LCD_CS_N,LCD_WR_N,LCD_RS: out std_logic;
			LCD_DATA: out std_logic_vector(15 downto 0)
		);
	end component lcd_control;

	--Inicializacion de las se?ales de entrada y salida
	signal CLK: std_logic :='0';
	signal RESET_L: std_logic :='0';
	signal LCD_Init_Done: std_logic :='0';
	signal OP_SETCURSOR: std_logic :='0';
	SIgnal OP_DRAWCOLOUR: std_logic :='0';
	signal XCOL: std_logic_vector(7 downto 0) := x"00"; --"00000000";
	signal YROW: std_logic_vector(8 downto 0) :='0'&x"00"; -- "000000000";  
	signal RGB: std_logic_vector(15 downto 0) := x"0000"; -- "0000000000000000";
	signal NUM_PIX: unsigned(16 downto 0) := '0'&x"0000"; -- "00000000000000000";
	signal DONE_CURSOR: std_logic;
	signal DONE_COLOUR: std_logic;
	signal LCD_CS_N: std_logic;
	signal LCD_WR_N: std_logic;
	signal LCD_RS: std_logic;
	signal LCD_DATA: std_logic_vector(15 downto 0);

	begin

	DUT: lcd_control port map(
		CLK=>CLK,
		RESET_L=>RESET_L,
		LCD_Init_Done=>LCD_Init_Done,
		OP_SETCURSOR=>OP_SETCURSOR,
		OP_DRAWCOLOUR=>OP_DRAWCOLOUR,
		XCOL=>XCOL,
		YROW=>YROW,
		RGB=>RGB,
		NUM_PIX=>NUM_PIX,
		DONE_CURSOR=>DONE_CURSOR,
		DONE_COLOUR=>DONE_COLOUR,
		LCD_CS_N=>LCD_CS_N,
		LCD_WR_N=>LCD_WR_N,
		LCD_RS=>LCD_RS,
		LCD_DATA=>LCD_DATA
	);

	-- actualización del reloj
	CLK <= not CLK after 10 ns;

	-- simulación de ejecución
	process
	begin
		wait for 20 ns;

		RESET_L<='1';
		LCD_Init_Done<='1';
		OP_SETCURSOR<='1';	

		XCOL<="01001110";
		YROW<="000101010";

		wait for 20 ns;

		OP_SETCURSOR<='0';
		LCD_Init_Done<='0';

		wait for 420 ns;

		NUM_PIX<='0'&x"0002";
		RGB<=x"1111";
		OP_DRAWCOLOUR<='1';
		LCD_Init_Done<='1';
	
		wait for 20 ns;

		OP_DRAWCOLOUR<='0';
		LCD_Init_Done<='0';

		wait for 420 ns;

		
	end process;

end arq_lcd_control_tb;
