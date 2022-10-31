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

--Inicializacion de las se�ales de entrada y salida
signal CLK: std_logic :='1';
signal RESET_L: std_logic :='0';
signal LCD_Init_Done: std_logic :='0';
signal OP_SETCURSOR: std_logic :='0';
SIgnal OP_DRAWCOLOUR: std_logic :='0';
signal XCOL: std_logic_vector(7 downto 0) :="00000000";
signal YROW: std_logic_vector(8 downto 0) :="000000000";
signal RGB: std_logic_vector(15 downto 0) :="0000000000000000";
signal NUM_PIX: unsigned(16 downto 0) :="00000000000000000";
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

CLK <= not CLK after 10 ns;

process
begin
	wait for 20 ns;

	RESET_L<='1';
	LCD_Init_Done<='1';
	OP_SETCURSOR<='1';	

	wait for 20 ns;

	OP_SETCURSOR<='0';
	LCD_Init_Done<='0';

	wait for 20 ns;

	LCD_RS<='1';
	XCOL<="01001110";
	YROW<="000101010";

	wait for 60 ns; 

	LCD_CS_N<='0';
	LCD_WR_N<='0';
	LCD_RS<='0';
			--carga 002A
	wait for 20 ns;

	LCD_CS_N<='1';
	LCD_WR_N<='1';

	wait for 40 ns;

	LCD_CS_N<='0';
	LCD_WR_N<='0';
	LCD_RS<='1';
			--carga 0000
	wait for 20 ns;

	LCD_CS_N<='1';
	LCD_WR_N<='1';

	wait for 40 ns;

	LCD_CS_N<='0';
	LCD_WR_N<='0';
			--carga 0078 (info de XCOL)
	wait for 20 ns;

	LCD_CS_N<='1';
	LCD_WR_N<='1';

	wait for 40 ns;

	LCD_CS_N<='0';
	LCD_WR_N<='0';
	LCD_RS<='0';
			--carga 002B
	wait for 20 ns;

	LCD_CS_N<='1';
	LCD_WR_N<='1';

	wait for 40 ns;

	LCD_CS_N<='0';
	LCD_WR_N<='0';
	LCD_RS<='1';
			--carga 0000 (con el bit de YCOL)
	wait for 20 ns;

	LCD_CS_N<='1';
	LCD_WR_N<='1';
	
	wait for 40 ns;

	LCD_CS_N<='0';
	LCD_WR_N<='0';

	wait for 20 ns;
	
	LCD_CS_N<='1';
	LCD_WR_N<='1';

	wait for 100 ns;
end process;

end arq_lcd_control_tb;