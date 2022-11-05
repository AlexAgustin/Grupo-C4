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
	signal SEL_DATA, LD_XY, LD_RGB, CL_XY, INC_Y, LD_NPIX, LD_CNPIX, DEC_CNPIX, ALL_PIX: std_logic :='0';

	-- Declaración de enteros sin signo para contadores
	signal cnt_YROW: unsigned(8 downto 0);
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

			when E1 =>  	ES <= E2;
			
			when E2 =>	if DONE_CURSOR = '0' then ES <= E2;
					else ES <= E3;
					end if;
					
			when E3 => 	ES <= E4;

			when E4 =>	if DONE_COLOUR = '0' then ES <= E4;
					else ES <= E5;
					end if;

			when E5 =>	if DEL_SCREEN = '1' then ES <= E5;
					else ES <= E0;
					end if;
					
			when E6 => 	ES <= E7;

			when E7 => 	if DONE_CURSOR = '0' then ES <= E7;
					else ES <= E8;
					end if;

			when E8 => 	ES <= E9;
			
			when E9 => 	if DONE_COLOUR = '0' then ES <= E9;
					else ES <= E10;
					end if;

			when E10 => 	if ALL_PIX = '0' then ES <= E6;
					else ES <= E11;
					end if;

			when E11 =>	if DRAW_FIG = '1' then ES <= E11;
					else ES <= E0;
					end if;

			when others =>  ES <= E0; -- inalcanzable
		end case;
	end process SWSTATE;



	-- Actualización de EP en cada flanco de reloj (sequential)
	SEQ: process (CLK, RESET_L) begin
		if RESET_L = '0' then EP <= E0; -- reset asíncrono
		elsif CLK'event and CLK = '1'  -- flanco de reloj
			then EP <= ES;             -- Estado Presente = Estado Siguiente
		end if;
	end process SEQ;


	-- Activación de señales de control: asignaciones combinacionales - valor a se�al
	SEL_DATA <= '1' when EP = E0 and DEL_SCREEN = '0' and DRAW_FIG = '1' else '0';
	LD_XY <= '1' when SEL_DATA = '1' else '0';
	LD_CNPIX <= '1' when SEL_DATA = '1' else '0';
	CL_XY <= '1' when EP = E0 and DEL_SCREEN = '1' else '0';
	LD_NPIX <= '1' when SEL_DATA = '1' or CL_XY = '1' and else '0';
	LD_RGB <= '1' when LD_NPIX = '1' and else '0';
	
	DEC_CNPIX <= '1' when EP = E9 and DONE_COLOUR = '1' else '0';
	INC_Y <= '1' when EP = E10 and ALL_PIX = '0' else '0';
	OP_DRAWCOLOUR <= '1' when EP = E3 or EP = E7 else '0';
	OP_SETCURSOR <= '1' when EP = E1 or EP = E5 else '0';


	-- #######################
	-- ## UNIDAD DE PROCESO ##
	-- #######################

	-- REG XCOL: RX
	RX : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then XCOL <= (others => '0'); -- clear registro con seÃ±al reset
		elsif CLK'event and CLK='1' then 			   -- flanco de reloj
			if LD_XY = '1' then XCOL <= "01000110";
			elsif CL_XY = '1' then XCOL <= (others => '0');
			end if;
		end if;
	end process RX;

	-- REG RGB: RC
	RC : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then RGB <= (others => '0'); -- clear registro con seÃ±al reset
		elsif CLK'event and CLK='1' then 			   -- flanco de reloj
			if LD_XY = '1' then RGB <= DRGB;
			end if;
		end if;
	end process RC;


	-- Contador YROW : CY
	CY : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then cnt_YROW <= (others =>'0');
		elsif CLK'event and CLK='1' then
			if LD_XY = '1' then cnt_YROW <= "001101110";
			elsif INC_Y = '1' then cnt_YROW <= cnt_YROW + 1;
			elsif CL_XY = '1' then cnt_YROW <= (others => '0');
			end if;
		end if;
	end process CY;
	YROW <= std_logic_vector(cnt_YROW);

	--Multiplexor para número de píxels
	MUX_PIX <= (others => '0') when RESET_L='0' else
			"10010110000000000" when SEL_DATA='0' else
			"00000000000000010";
			-- "00000000001100100";


	-- REG NUM_PIX: RNPIX
	RNPIX : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then NUM_PIX <= (others => '0'); -- clear registro con seÃ±al reset
		elsif CLK'event and CLK='1' then 			   -- flanco de reloj
			if LD_NPIX = '1' then NUM_PIX <= MUX_PIX;
			end if;
		end if;
	end process RNPIX;

	--contador píxeles restantes: CNPIX 
	CNPIX : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then u_QPIX <= (others =>'0');
		elsif CLK'event and CLK='1' then
			if LD_CNPIX = '1' then u_QPIX <= MUX_PIX;
			elsif DEC_CNPIX = '1' then u_QPIX <= u_QPIX - 1;
			end if;
		end if;
	end process CNPIX;
	ALL_PIX <= '1' when u_QPIX="00000000" else
		   '0';

	-- Multiplexor para RGB   
	DRGB <= (others => '0') when RESET_L='0' else
	       col_0 when COLOUR_CODE = "000" else
	       col_1 when COLOUR_CODE = "001" else
	       col_2 when COLOUR_CODE = "010" else
	       col_3 when COLOUR_CODE = "011" else
	       col_4 when COLOUR_CODE = "100" else
	       col_5 when COLOUR_CODE = "101" else
	       col_6 when COLOUR_CODE = "110" else
	       col_7;

end arq_lcd_drawing; 
