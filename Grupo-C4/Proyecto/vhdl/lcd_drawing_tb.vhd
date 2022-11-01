library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity lcd_drawing_tb_draw is
end lcd_drawing_tb_draw;

architecture arq_lcd_drawing_tb_draw of lcd_drawing_tb_draw is

component lcd_drawing
port(
	CLK, RESET_L: in std_logic;

	DEL_SCREEN, DRAW_FIG, DONE_CURSOR, DONE_COLOUR: in std_logic;
	COLOUR_CODE: in std_logic_vector(2 downto 0);

	OP_SETCURSOR, OP_DRAWCOLOUR: out std_logic;
	XCOL: out std_logic_vector(7 downto 0);
	YROW: out std_logic_vector(8 downto 0);
	RGB: out std_logic_vector(15 downto 0);
	NUM_PIX: out std_logic_vector(16 downto 0)
);
end component;


    signal CLK : std_logic := '1';
    signal RESET_L : std_logic := '0';
    signal DONE_CURSOR : std_logic := '0';
    signal DONE_COLOUR : std_logic := '0';
    signal DEL_SCREEN : std_logic := '0';
    signal DRAW_FIG : std_logic := '0';

    signal COLOUR_CODE : std_logic_vector(2 downto 0):= "000";

    signal XCOL : std_logic_vector(7 downto 0) := "00000000";
    signal YROW : std_logic_vector(8 downto 0):= "000000000";
    signal RGB : std_logic_vector(15 downto 0):= "0000000000000000";
    signal NUM_PIX : std_logic_vector(16 downto 0) := "00000000000000000";

    signal OP_SETCURSOR : std_logic := '0';
    signal OP_DRAWCOLOUR : std_logic := '0';


begin

DUT: lcd_drawing port map(
    CLK => CLK,
    RESET_L => RESET_L,
    DONE_CURSOR => DONE_CURSOR,
    DONE_COLOUR => DONE_COLOUR,
    DEL_SCREEN => DEL_SCREEN,
    DRAW_FIG => DRAW_FIG,
    COLOUR_CODE => COLOUR_CODE,
    XCOL => XCOL,
    YROW => YROW,
    RGB => RGB,
    NUM_PIX => NUM_PIX,
    OP_SETCURSOR => OP_SETCURSOR,
    OP_DRAWCOLOUR => OP_DRAWCOLOUR);

CLK <= not CLK after 10 ns;



process
begin
	-- reset
	wait for 10 ns;
	RESET_L <= '0';

	wait for 20 ns;
	RESET_L <= '1';	

	--prueba dibujar figura
	DRAW_FIG <= '1';

	wait for 40 ns;
	DONE_CURSOR <= '1';
	DRAW_FIG <= '0';

	wait for 60 ns;
	DONE_COLOUR <= '1';

	wait for 200 ns;
		
	-- prueba borrar pantalla	
	DEL_SCREEN <= '1';

	wait for 40 ns;
        DONE_CURSOR <= '1';

	wait for 20 ns;
	DEL_SCREEN <= '0';

	wait for 60 ns;
	DONE_COLOUR <= '1';
    
	wait for 200 ns;


end process;
end arq_lcd_drawing_tb_draw;

