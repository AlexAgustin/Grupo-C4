--------------------------------
-- fichero tb_lcd_drawing.vhd --
--------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_lcd_drawing is
end tb_lcd_drawing;

architecture arq_tb_lcd_drawing of tb_lcd_drawing is

	component lcd_drawing
	port(
		CLK, RESET_L, DEFAULT: in std_logic;

		DEL_SCREEN, DRAW_FIG, DONE_CURSOR, DONE_COLOUR, HORIZ, VERT, DIAG, MIRROR, TRIAN, EQUIL, ROMBO, ROMBOIDE, TRAP, PATRON, HEXAG: in std_logic;
		COLOUR_CODE: in std_logic_vector(2 downto 0);
		UART_XCOL: in std_logic_vector(7 downto 0);
		UART_YROW: in std_logic_vector(8 downto 0);
		
		XCOL: out std_logic_vector(7 downto 0);
		YROW: out std_logic_vector(8 downto 0);
		OP_SETCURSOR, OP_DRAWCOLOUR: out std_logic;
		RGB: out std_logic_vector(15 downto 0);
		NUM_PIX: out unsigned(16 downto 0);
		DONE_ORDER: out std_logic
	);

	end component;


    signal CLK : std_logic := '0';
    signal RESET_L : std_logic := '0';
    signal DONE_CURSOR : std_logic := '0';
    signal DONE_COLOUR : std_logic := '0';
    signal DEL_SCREEN : std_logic := '0';
    signal DRAW_FIG : std_logic := '0';
	signal HORIZ : std_logic := '0';
	signal VERT : std_logic := '0';
	signal DIAG : std_logic := '0';
	signal TRIAN : std_logic := '0';
	signal MIRROR : std_logic := '0';
	signal EQUIL : std_logic := '0';
	signal ROMBO : std_logic := '0';
	signal ROMBOIDE : std_logic := '0';
	signal TRAP : std_logic := '0';
	signal PATRON : std_logic := '0';
	signal HEXAG : std_logic := '0';
	signal DEFAULT : std_logic := '0';
	signal UART_XCOL : std_logic_vector(7 downto 0) := (others => '0');
	signal UART_YROW : std_logic_vector(8 downto 0) := (others => '0');

    signal COLOUR_CODE : std_logic_vector(2 downto 0):= "000";

    signal XCOL : std_logic_vector(7 downto 0) := "00000000";
    signal YROW : std_logic_vector(8 downto 0):= "000000000";
    signal RGB : std_logic_vector(15 downto 0):= "0000000000000000";
    signal NUM_PIX : unsigned(16 downto 0) := "00000000000000000";

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
		OP_DRAWCOLOUR => OP_DRAWCOLOUR,
		HORIZ => HORIZ,
		VERT => VERT,
		DIAG => DIAG,
		TRIAN => TRIAN,
		MIRROR => MIRROR,
		EQUIL => EQUIL,
		ROMBO => ROMBO,
		ROMBOIDE => ROMBOIDE,
		TRAP => TRAP,
		PATRON => PATRON,
		HEXAG => HEXAG,
		DEFAULT => DEFAULT,
		UART_XCOL => UART_XCOL,
		UART_YROW => UART_YROW
		);
		

	CLK <= not CLK after 10 ns;



	process
	begin
		-- reset
		RESET_L <= '0';

		wait for 20 ns;
		RESET_L <= '1';	

	-------------------------------------------------
		--prueba dibujar diagonal 1
		COLOUR_CODE <= "001";
		DIAG <= '1';
		DEFAULT <='1';
		wait for 60 ns;
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';--cursor1

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';--colour1

		wait for 60 ns;	
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';--cursor2

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';--colour2

		wait for 60 ns;
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';--cursor3

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';--colour3

		wait for 60 ns;	
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';--cursor4

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';--colour4

		wait for 20 ns;
		DIAG <= '0';
		
		wait for 40 ns;
-------------------------------------------------------------------

		--prueba dibujar linea vertical 1
		COLOUR_CODE <= "110";
		VERT <= '1';

		wait for 60 ns;
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';

		wait for 60 ns;	
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';

		wait for 60 ns;
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';

		wait for 60 ns;	
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';

		wait for 20 ns;
		VERT <= '0';
		
		wait for 40 ns;	
------------------------------------------------------------------
		--prueba dibujar diagonal 2
		COLOUR_CODE <= "001";
		DIAG <= '1';

		wait for 60 ns;
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';--cursor1

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';--colour1

		wait for 60 ns;	
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';--cursor2

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';--colour2

		wait for 60 ns;
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';--cursor3

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';--colour3

		wait for 60 ns;	
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';--cursor4

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';--colour4

		wait for 20 ns;
		DIAG <= '0';
		
		wait for 40 ns;
--------------------------------------------------------------------------

		--prueba dibujar linea vertical 2
		COLOUR_CODE <= "110";
		VERT <= '1';

		wait for 60 ns;
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';

		wait for 60 ns;	
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';

		wait for 60 ns;
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';

		wait for 60 ns;	
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';

		wait for 20 ns;
		VERT <= '0';
		
		wait for 40 ns;
-------------------------------------------------------------------

		--prueba dibujar figura 1
		COLOUR_CODE <= "001";
		DRAW_FIG <= '1';

		wait for 60 ns;
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';

		wait for 60 ns;	
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';

		wait for 20 ns;
		DRAW_FIG <= '0';
		
		wait for 40 ns;

-----------------------------------------------------------------------

		--prueba dibujar figura 2
		COLOUR_CODE <= "010";
		DRAW_FIG <= '1';

		wait for 60 ns;
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';

		wait for 60 ns;	
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';

		wait for 20 ns;
		DRAW_FIG <= '0';

		wait for 40 ns;
-------------------------------------------------------------------------

		-- prueba borrar pantalla 1
		
		COLOUR_CODE <= "011";
		DEL_SCREEN <= '1';

		wait for 40 ns;
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		
		DONE_COLOUR <= '0';

		wait for 40 ns;

		DEL_SCREEN <= '0';
		
		wait for 20 ns;
-----------------------------------------------------------------------------------
		--prueba borrar pantalla 2
		COLOUR_CODE <= "100";
		DEL_SCREEN <= '1';

		wait for 40 ns;
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';

		wait for 40 ns;
		DEL_SCREEN <= '0';
		
		wait for 200 ns;
--------------------------------------------------------------------------------------
		--prueba dibujar linea horizontal 1
		COLOUR_CODE <= "101";
		HORIZ <= '1';

		wait for 40 ns;
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';

		wait for 20 ns;

		HORIZ <= '0';

		wait for 40 ns;
-------------------------------------------------------------------

		
		--prueba dibujar linea horizontal 2
		COLOUR_CODE <= "000";
		HORIZ <= '1';

		wait for 40 ns;
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';

		wait for 20 ns;
		HORIZ <= '0';
		
		wait for 40 ns;
-----------------------------------------------------------------------

		--prueba dibujar triangulo 1
		COLOUR_CODE <= "011";
		TRIAN <= '1';

		wait for 60 ns;
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';

		wait for 60 ns;	
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';

		wait for 20 ns;
		TRIAN <= '0';
		
		wait for 40 ns;
-------------------------------------------------------------

		--prueba dibujar espejo 1
		DEFAULT <='0';
		UART_XCOL <= "01100100";
		UART_YROW <= "001100100";
		COLOUR_CODE <= "100";
		MIRROR <= '1';

		-- figura 1
		wait for 60 ns;
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';

		wait for 60 ns;	
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';
		
		-- figura 2
		wait for 60 ns;
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';

		wait for 60 ns;	
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';

		wait for 20 ns;
		MIRROR <= '0';
		
		wait for 40 ns;
----------------------------------------------------------------------

		--prueba dibujar triangulo 2
		COLOUR_CODE <= "101";
		TRIAN <= '1';

		wait for 60 ns;
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';

		wait for 60 ns;	
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';

		wait for 20 ns;
		TRIAN <= '0';
		
		wait for 40 ns;
-------------------------------------------------------------------------

		--prueba dibujar espejo 2
		COLOUR_CODE <= "110";
		MIRROR <= '1';

		-- figura 1
		wait for 60 ns;
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';

		wait for 60 ns;	
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';
		
		-- figura 2
		wait for 60 ns;
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';

		wait for 60 ns;	
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';

		wait for 20 ns;
		MIRROR <= '0';
		
		wait for 40 ns;
---------------------------------------------------------------------

		--prueba dibujar equilatero 1
		COLOUR_CODE <= "111";
		EQUIL <= '1';

		wait for 60 ns;
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';

		wait for 80 ns;	
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';

		wait for 80 ns;	
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';

		wait for 40 ns;
		EQUIL <= '0';
		
		wait for 40 ns;
---------------------------------------------------------------------

		--prueba dibujar romboide 1
		COLOUR_CODE <= "000";
		ROMBOIDE <= '1';

		wait for 60 ns;
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';

		wait for 60 ns;	
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';

		wait for 80 ns;	
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';

		wait for 20 ns;
		ROMBOIDE <= '0';
		
		wait for 40 ns;
----------------------------------------------------------------------------

		--prueba dibujar equilatero 2
		COLOUR_CODE <= "001";
		EQUIL <= '1';

		wait for 60 ns;
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';

		wait for 80 ns;	
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';

		wait for 80 ns;	
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';

		wait for 40 ns;
		EQUIL <= '0';
		
		wait for 40 ns;
--------------------------------------------------------------------

		--prueba dibujar romboide 2
		COLOUR_CODE <= "010";
		ROMBOIDE <= '1';

		wait for 60 ns;
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';

		wait for 60 ns;	
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';

		wait for 80 ns;	
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';

		wait for 20 ns;
		ROMBOIDE <= '0';
		
		wait for 40 ns;
-----------------------------------------------------------------------------------

		--prueba dibujar trapecio 1
		COLOUR_CODE <= "011";
		TRAP <= '1';

		wait for 60 ns;
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';

		wait for 80 ns;	
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';

		wait for 80 ns;	
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';

		wait for 40 ns;
		TRAP <= '0';
		
		wait for 40 ns;		
--------------------------------------------------------------------

		--prueba dibujar rombo 1
		COLOUR_CODE <= "100";
		ROMBO <= '1';

		wait for 60 ns;
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';

		wait for 80 ns;	
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';

		wait for 40 ns;
		ROMBO <= '0';
		
		wait for 40 ns;
-----------------------------------------------------------------------

		--prueba dibujar trapecio 2
		COLOUR_CODE <= "101";
		TRAP <= '1';

		wait for 60 ns;
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';

		wait for 80 ns;	
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';

		wait for 80 ns;	
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';

		wait for 40 ns;
		TRAP <= '0';
		
		wait for 40 ns;
--------------------------------------------------------------------------

		--prueba dibujar rombo 2
		COLOUR_CODE <= "110";
		ROMBO <= '1';

		wait for 60 ns;
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';

		wait for 80 ns;	
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';

		wait for 40 ns;
		ROMBO <= '0';
		
		wait for 40 ns;
--------------------------------------------------------------------------------

		--prueba dibujar patron 1                son 5 lineas
		COLOUR_CODE <= "111";
		PATRON <= '1';

		wait for 60 ns;
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0'; --cursor 1

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0'; --colour 1

		wait for 80 ns;	
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0'; --cursor 2

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0'; --colour 2

		wait for 60 ns;
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0'; --cursor 3

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0'; --colour 3

		wait for 80 ns;	
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0'; --cursor 4

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0'; --colour 4

		wait for 80 ns;	
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0'; --cursor 5

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0'; --colour 5

		wait for 40 ns;
		PATRON <= '0';
		
		wait for 40 ns;
		
	-------------------------------------------------

		--prueba dibujar patron 2
		COLOUR_CODE <= "000";
		PATRON <= '1';

		wait for 60 ns;
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0'; --cursor 1

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0'; --colour 1

		wait for 80 ns;	
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0'; --cursor 2

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0'; --colour 2

		wait for 60 ns;
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0'; --cursor 3

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0'; --colour 3

		wait for 80 ns;	
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0'; --cursor 4

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0'; --colour 4

		wait for 80 ns;	
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0'; --cursor 5

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0'; --colour 5

		wait for 40 ns;
		PATRON <= '0';
		wait for 40 ns;
		
----------------------------------------------------------------------------------

		--hexagono 1
		COLOUR_CODE <= "001";
		HEXAG <= '1';

		wait for 60 ns;
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';

		wait for 60 ns;	
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';

		wait for 20 ns;
		HEXAG <= '0';
		
		wait for 40 ns;

-----------------------------------------------------------------------

		--hexagono 2
		COLOUR_CODE <= "011";
		HEXAG <= '1';

		wait for 60 ns;
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';

		wait for 60 ns;	
		DONE_CURSOR <= '1';

		wait for 20 ns;
		DONE_CURSOR <= '0';

		wait for 60 ns;
		DONE_COLOUR <= '1';

		wait for 20 ns;
		DONE_COLOUR <= '0';

		wait for 20 ns;
		HEXAG <= '0';
		
		wait for 40 ns;

		UART_XCOL <= "00000000";
		UART_YROW <= "000000000";

-----------------------------------------------------------------------
		
		wait for 40 ns;
	end process;
end arq_tb_lcd_drawing;
