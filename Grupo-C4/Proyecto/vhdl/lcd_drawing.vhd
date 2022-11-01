library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity lcd_drawing is
	port(
		clk, reset_L: in std_logic;

		DEL_SCREEN, DRAW_FIG, DONE_CURSOR, DONE_COLOUR: in std_logic;
		COLOUR_CODE: in std_logic_vector(2 downto 0);

		OP_SETCURSOR, OP_DRAWCOLOUR: out std_logic;
		XCOL: out std_logic_vector(7 downto 0);
		YROW: out std_logic_vector(8 downto 0);
		RGB: out std_logic_vector(15 downto 0);
		NUMPIX: out std_logic_vector(16 downto 0)
	);
end lcd_drawing;


architecture arq_lcd_drawing of lcd_drawing is

	-- DeclaraciÃ³n de estados
	type estados is (E0, E1, E2, E3, E4, E5, E6, E7);
	signal EP, ES : estados;

	-- DeclaraciÃ³n de seÃ±ales de control
	signal SEL_DATA, LD_YROW, LD_CONT, INC, DEC, ALL_PIX: std_logic :='0';

	-- DeclaraciÃ³n de seÃ±ales intermedias
	signal TC_CNPIX: std_logic := '0';
	signal QPIX: std_logic_vector(16 downto 0);
	signal DMUX: std_logic_vector(16 downto 0);

	-- DeclaraciÃ³n de enteros sin signo para contadores
	signal u_YROW, cnt_YROW: unsigned(8 downto 0);
	signal u_QPIX: unsigned(7 downto 0);


	-- Valores de entrada constantes
	signal pos_x: std_logic_vector(7 downto 0) := x"8c"; -- start at x,y = 145,145; provisional
	signal pos_y: std_logic_vector(8 downto 0) := '0' & x"8c";

	signal col_0: std_logic_vector(15 downto 0) := x"0000"; -- := negro
	signal col_1: std_logic_vector(15 downto 0) := x"c973"; -- := violeta
	signal col_2: std_logic_vector(15 downto 0) := x"427f"; -- := azul
	signal col_3: std_logic_vector(15 downto 0) := x"4605"; -- := verde
	signal col_4: std_logic_vector(15 downto 0) := x"f885"; -- := rojo
	signal col_5: std_logic_vector(15 downto 0) := x"fca8"; -- := naranja
	signal col_6: std_logic_vector(15 downto 0) := x"ffca"; -- := amarillo
	signal col_7: std_logic_vector(15 downto 0) := x"ffff"; -- := blanco


	begin

	-- #######################
	-- ## UNIDAD DE CONTROL ## 
	-- #######################

	-- TransiciÃ³n de estados (cÃ¡lculo de estado siguiente)
	SWSTATE: process (EP, DEL_SCREEN, DRAW_FIG, DONE_CURSOR, DONE_COLOUR, TC_CNPIX) begin
		case EP is
			when E0 => 	if DEL_SCREEN = '1' then ES <= E1;
					elsif DRAW_FIG = '1' then ES <= E4;
					else ES <= E0;
					end if;

			when E1 =>	if DONE_CURSOR = '1' then ES <= E2;
					else ES <= E1;
					end if;

			when E2 =>	if DONE_COLOUR = '0' then ES <= E2;
					elsif DEL_SCREEN = '1' then ES <= E3;
					else ES <= E0;
					end if;

			when E3 => 	if DEL_SCREEN = '1' then ES <= E3;
					else ES <= E0;
					end if;

			when E4 => 	if DONE_CURSOR = '1' then ES <= E5;
					else ES <= E4;
					end if;

			when E5 => 	if DONE_COLOUR = '1' then ES <= E6;
					else ES <= E5;
					end if;

			when E6 =>	if TC_CNPIX = '0' then ES <= E4;
					elsif DRAW_FIG = '1' then ES <= E7;
					else ES <= E0;
					end if;

			when E7 =>	if DRAW_FIG = '1' then ES <= E7;
					else ES <= E0;
					end if;

			when others    =>      ES <= E0; -- inalcanzable
		end case;
	end process SWSTATE;


	-- ActualizaciÃ³n de EP en cada flanco de reloj (sequencia)
	SEQ: process (clk, reset_L) begin
		if reset_L = '0' then EP <= E0; -- reset asÃ­ncrono
		elsif clk'event and clk = '1'  -- flanco de reloj
			then EP <= ES;             -- Estado Presente = Estado Siguiente
		end if;
	end process SEQ;


	-- ActivaciÃ³n de seÃ±ales de control: asignaciones combinacionales - valor a señal
	LD_YROW <= '1' when DEL_SCREEN = '1' or (DEL_SCREEN = '0' and DRAW_FIG = '1') else '0';
	SEL_DATA <=  '1' when (DEL_SCREEN = '0' and DRAW_FIG = '1') or LD_CONT = '1' or INC = '1' else '0';
	LD_CONT <= '1' when EP = E6 and DONE_CURSOR = '1' else '0';
	INC <=  '1' when EP = E8 and DONE_COLOUR = '1' and ALL_PIX = '0' else '0';
	DEC <=   '1' when EP = E8 and DONE_COLOUR = '1' and ALL_PIX = '0' else '0';
	OP_DRAWCOLOUR <= '1' when EP = E3 or EP = E7 else '0';
	OP_SETCURSOR <= 1' when EP = E1 or EP = E5 else '0';


	-- #######################
	-- ## UNIDAD DE PROCESO ##
	-- #######################

	--MUX para NUM_PIX
	NUMPIX <= (others => '0') when reset_L='0' else
			"10010110000000000" when SEL_DATA='0' else
			"00000000001100100";

	--MUX para XCOL
	XCOL <= (others => '0') when reset_L='0' else
			(others => '0') when SEL_DATA='0' else
			"01000110";

	--MUX para YROW
	u_YROW <= (others => '0') when reset_L='0' else
			(others => '0') when SEL_DATA='0' else
			"001101110";

	-- CNYROW     contador YROW
	CNYROW : process(clk, reset_L)
	begin
		if reset_L = '0' then cnt_YROW <= (others =>'0');
		elsif clk'event and clk='1' then
			if LD_CONT = '1' then cnt_YROW <= unsigned(u_YROW);
			elsif DEC = '1' then cnt_YROW <= cnt_YROW - 1;
			end if;
		end if;
	end process CNYROW;
	YROW <= std_logic_vector(cnt_YROW);

	--CNPIX
	CNPIX : process(clk, reset_L)
	begin
		if reset_L = '0' then u_QPIX <= (others =>'0');
		elsif clk'event and clk='1' then
			if LD_CONT = '1' then u_QPIX <= "01100011";
			elsif DEC = '1' then u_QPIX <= u_QPIX - 1;
			end if;
		end if;
	end process CNPIX;
	ALL_PIX <= '1' when u_QPIX="00000000" else
		   '0';

	-- RGB   
	RGB <= (others => '0') when reset_L='0' else
	       col_0 when COLOUR_CODE = "000" else
	       col_1 when COLOUR_CODE = "001" else
	       col_2 when COLOUR_CODE = "010" else
	       col_3 when COLOUR_CODE = "011" else
	       col_4 when COLOUR_CODE = "100" else
	       col_5 when COLOUR_CODE = "101" else
	       col_6 when COLOUR_CODE = "110" else
	       col_7;

end arq_lcd_drawing; 
