library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity lcd_drawing is
	port(
		CLK, RESET_L: in std_logic;

		DEL_SCREEN, DRAW_FIG, DONE_CURSOR, DONE_COLOUR: in std_logic;
		COLOUR_CODE: in std_logic_vector(2 downto 0);

		OP_SETCURSOR, OP_DRAWCOLOUR: out std_logic;
		XCOL: out std_logic_vector(7 downto 0);
		YROW: out std_logic_vector(8 downto 0);
		RGB: out std_logic_vector(15 downto 0);
		NUM_PIX: out unsigned(16 downto 0)
	);
end lcd_drawing;


architecture arq_lcd_drawing of lcd_drawing is

	-- Declaración de estados
	type estados is (E0, E1, E2, E3, E4, E5, E6, E7, E8, E9);
	signal EP, ES : estados;

	-- Declaración de señales de control
	signal SEL_DATA, LD_YROW, LD_CONT, INC, DEC, ALL_PIX: std_logic :='0';

	-- Declaración de enteros sin signo para contadores
	signal u_YROW, cnt_YROW: unsigned(8 downto 0);
	signal u_QPIX: unsigned(7 downto 0);


	-- Valores de entrada constantes

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

	-- Transición de estados (cálculo de estado siguiente)
SWSTATE: process (EP, DEL_SCREEN, DRAW_FIG, DONE_CURSOR, DONE_COLOUR) begin
		case EP is
			when E0 => 	if DEL_SCREEN = '1' then ES <= E1;
					elsif DRAW_FIG = '1' then ES <= E5;
					else ES <= E0;
					end if;

			when E1 =>  ES <= E2;
			
			when E2 =>	if DONE_CURSOR = '1' then ES <= E3;
					else ES <= E2;
					end if;
					
			when E3 => ES <= E4;

			when E4 =>	if DONE_COLOUR = '0' then ES <= E4;
					elsif DEL_SCREEN = '1' then ES <= E4;
					else ES <= E0;
					end if;
					
			when E5 => ES <= E6;

			when E6 => 	if DONE_CURSOR = '1' then ES <= E7;
					else ES <= E6;
					end if;

			when E7 => ES <= E8;
			
			when E8 => 	if DONE_COLOUR = '1' and ALL_PIX = '1' then ES <= E9;
					elsif  DONE_COLOUR = '1' and ALL_PIX = '0' then ES <= E5;
					else ES <= E8;
					end if;

			when E9 =>	if DRAW_FIG = '1' then ES <= E9;
					else ES <= E0;
					end if;

			when others    =>      ES <= E0; -- inalcanzable
		end case;
	end process SWSTATE;



	-- Actualización de EP en cada flanco de reloj (sequencia)
	SEQ: process (CLK, RESET_L) begin
		if RESET_L = '0' then EP <= E0; -- reset asíncrono
		elsif CLK'event and CLK = '1'  -- flanco de reloj
			then EP <= ES;             -- Estado Presente = Estado Siguiente
		end if;
	end process SEQ;


	-- Activación de señales de control: asignaciones combinacionales - valor a se�al
	LD_YROW <= '1' when EP = E0 and (DEL_SCREEN = '1' or  (DEL_SCREEN = '0' and DRAW_FIG = '1')) else '0';
	SEL_DATA <=  '1' when LD_CONT = '1' or INC = '1' else '0';
	LD_CONT <= '1' when EP = E0 and (DEL_SCREEN = '0' and DRAW_FIG = '1') else '0';
	INC <=  '1' when EP = E8 and DONE_COLOUR = '1' and ALL_PIX = '0' else '0';
	DEC <=   '1' when EP = E8 and DONE_COLOUR = '1' and ALL_PIX = '0' else '0';
	OP_DRAWCOLOUR <= '1' when EP = E3 or EP = E7 else '0';
	OP_SETCURSOR <= '1' when EP = E1 or EP = E5 else '0';


	-- #######################
	-- ## UNIDAD DE PROCESO ##
	-- #######################

	--MUX para NUM_PIX
	NUM_PIX <= (others => '0') when RESET_L='0' else
			"10010110000000000" when SEL_DATA='0' else
			"00000000001100100";

	--MUX para XCOL
	XCOL <= (others => '0') when RESET_L='0' else
			(others => '0') when SEL_DATA='0' else
			"01000110";

	--MUX para YROW
	u_YROW <= (others => '0') when RESET_L='0' else
			(others => '0') when SEL_DATA='0' else
			"001101110";

	-- CNYROW     contador YROW
	CNYROW : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then cnt_YROW <= (others =>'0');
		elsif CLK'event and CLK='1' then
			if LD_CONT = '1' then cnt_YROW <= unsigned(u_YROW);
			elsif DEC = '1' then cnt_YROW <= cnt_YROW - 1;
			end if;
		end if;
	end process CNYROW;
	YROW <= std_logic_vector(cnt_YROW);

	--CNPIX
	CNPIX : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then u_QPIX <= (others =>'0');
		elsif CLK'event and CLK='1' then
			--if LD_CONT = '1' then u_QPIX <= "01100011";
			if LD_CONT = '1' then u_QPIX <= "00000001";
			elsif DEC = '1' then u_QPIX <= u_QPIX - 1;
			end if;
		end if;
	end process CNPIX;
	ALL_PIX <= '1' when u_QPIX="00000000" else
		   '0';

	-- RGB   
	RGB <= (others => '0') when RESET_L='0' else
	       col_0 when COLOUR_CODE = "000" else
	       col_1 when COLOUR_CODE = "001" else
	       col_2 when COLOUR_CODE = "010" else
	       col_3 when COLOUR_CODE = "011" else
	       col_4 when COLOUR_CODE = "100" else
	       col_5 when COLOUR_CODE = "101" else
	       col_6 when COLOUR_CODE = "110" else
	       col_7;

end arq_lcd_drawing; 
