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

	-- DeclaraciÃÂ³n de estados
	type estados is (E0, E1, E2, E3, E4, E5, E6, E7, E8, E9, E10, E11);
	signal EP, ES : estados;

	-- DeclaraciÃÂ³n de seÃÂ±ales de control
	signal SEL_DATA, LD_XY, CL_XY, INC_Y, LD_CN, LD_CNPIX, DEC_CNPIX, ALL_PIX: std_logic :='0';
	signal DRGB: std_logic_vector(15 downto 0);
	signal MUX_PIX: unsigned(16 downto 0);
	
	-- DeclaraciÃÂ³n de enteros sin signo para contadores
	signal cnt_YROW: unsigned(8 downto 0);
	signal u_QPIX: unsigned(16 downto 0);



	begin

	-- #######################
	-- ## UNIDAD DE CONTROL ## 
	-- #######################

	-- TransiciÃÂ³n de estados (cÃÂ¡lculo de estado siguiente)
	SWSTATE: process (EP, DEL_SCREEN, DRAW_FIG, DONE_CURSOR, DONE_COLOUR, ALL_PIX) begin
		case EP is
			when E0 => 		if DEL_SCREEN = '1' then ES <= E1;
							elsif DRAW_FIG = '1' then ES <= E6;
							else ES <= E0;
							end if;

			when E1 =>  	ES <= E2;
			
			when E2 =>		if DONE_CURSOR = '0' then ES <= E2;
							else ES <= E3;
							end if;
					
			when E3 => 		ES <= E4;

			when E4 =>		if DONE_COLOUR = '0' then ES <= E4;
							else ES <= E5;
							end if;

			when E5 =>		if DEL_SCREEN = '1' then ES <= E5;
							else ES <= E0;
							end if;
					
			when E6 => 		ES <= E7;

			when E7 => 		if DONE_CURSOR = '0' then ES <= E7;
							else ES <= E8;
							end if;

			when E8 => 		ES <= E9;
			
			when E9 => 		if DONE_COLOUR = '0' then ES <= E9;
							else ES <= E10;
							end if;

			when E10 => 	if ALL_PIX = '0' then ES <= E6;
							else ES <= E11;
							end if;

			when E11 =>		if DRAW_FIG = '1' then ES <= E11;
							else ES <= E0;
							end if;

			when others =>  ES <= E0; -- inalcanzable
		end case;
	end process SWSTATE;



	-- ActualizaciÃÂ³n de EP en cada flanco de reloj (sequential)
	SEQ: process (CLK, RESET_L) begin
		if RESET_L = '0' then EP <= E0; -- reset asÃÂ­ncrono
		elsif CLK'event and CLK = '1'  -- flanco de reloj
			then EP <= ES;             -- Estado Presente = Estado Siguiente
		end if;
	end process SEQ;


	-- ActivaciÃÂ³n de seÃÂ±ales de control: asignaciones combinacionales - valor a seÃ¯Â¿Â½al
	SEL_DATA <= '1' when EP = E0 and DEL_SCREEN = '0' and DRAW_FIG = '1' else '0';
	LD_XY <= '1' when SEL_DATA = '1' else '0';
	LD_CNPIX <= '1' when SEL_DATA = '1' else '0';
	CL_XY <= '1' when EP = E0 and DEL_SCREEN = '1' else '0';
	LD_CN <= '1' when SEL_DATA = '1' or CL_XY = '1' else '0';
	
	DEC_CNPIX <= '1' when EP = E9 and DONE_COLOUR = '1' else '0';
	INC_Y <= '1' when EP = E10 and ALL_PIX = '0' else '0';
	OP_DRAWCOLOUR <= '1' when EP = E3 or EP = E8 else '0';
	OP_SETCURSOR <= '1' when EP = E1 or EP = E6 else '0';


	-- #######################
	-- ## UNIDAD DE PROCESO ##
	-- #######################

	-- REG XCOL: RX
	RX : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then XCOL <= (others => '0'); -- clear registro con seÃÂÃÂ±al reset
		elsif CLK'event and CLK='1' then 			   -- flanco de reloj
			if LD_XY = '1' then XCOL <= "01000110";
			elsif CL_XY = '1' then XCOL <= (others => '0');
			end if;
		end if;
	end process RX;

	-- REG RGB: RC
	RC : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then RGB <= (others => '0'); -- clear registro con seÃÂÃÂ±al reset
		elsif CLK'event and CLK='1' then 			   -- flanco de reloj
			if LD_CN = '1' then RGB <= DRGB;
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

	--Multiplexor para numero de pixels
	MUX_PIX <= "00000000000000011" when SEL_DATA='0' else -- tb modelsim
			-- "10010110000000000" when SEL_DATA='0' else -- quartus
				"00000000000000010"; -- tb modelsym
			-- "00000000001100100"; --quartus


	-- REG NUM_PIX: RNPIX
	RNPIX : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then NUM_PIX <= (others => '0');
		elsif CLK'event and CLK='1' then 			   
			if LD_CN = '1' then NUM_PIX <= MUX_PIX;
			end if;
		end if;
	end process RNPIX;

	--contador pÃÂ­xeles restantes: CNPIX 
	CNPIX : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then u_QPIX <= (others =>'0');ALL_PIX <= '0';
		elsif CLK'event and CLK='1' then
			if LD_CNPIX = '1' then u_QPIX <= MUX_PIX; ALL_PIX <= '0';
			elsif DEC_CNPIX = '1' and u_QPIX = "00000000000000001" 
			then 
				u_QPIX <= u_QPIX - 1;
				ALL_PIX <= '1';
			elsif DEC_CNPIX = '1' and u_QPIX = "00000000000000000" 
			then 
				u_QPIX <= "11111111111111111";
				ALL_PIX <= '0';
			elsif DEC_CNPIX = '1' then u_QPIX <= u_QPIX - 1; ALL_PIX<='0';
			end if;
		end if;
	end process CNPIX;
	

	-- Multiplexor para RGB   
	DRGB <= x"0000" when COLOUR_CODE = "000" else -- negro
			x"c973" when COLOUR_CODE = "001" else -- violeta
			x"427f" when COLOUR_CODE = "010" else -- azul
			x"4605" when COLOUR_CODE = "011" else -- verde
			x"f885" when COLOUR_CODE = "100" else -- rojo
			x"fca8" when COLOUR_CODE = "101" else -- naranja
			x"ffca" when COLOUR_CODE = "110" else -- amarillo
			x"ffff"; --blanco

end arq_lcd_drawing; 
