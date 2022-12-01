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
	type estados is (INICIO, DELCURSOR, DELCOLOUR, DELWAIT, DRAWCURSOR, DRAWCOLOUR, DRAWREPEAT, DRAWWAIT);
	signal EP, ES : estados;

	-- DeclaraciÃÂ³n de seÃÂ±ales de control
	signal SELREV, LD_X, INC_X, CL_X, LD_Y, INC_Y, CL_Y, LD_CN, DEC_NUMPIX, LD_CNPIX, DEC_CNPIX, ALL_PIX : std_logic := '0';
	signal LD_MIRROR, CL_MIRROR, ISMIRROR, LD_DIAG, CL_DIAG, ISDIAG, LD_TRIAN, CL_TRIAN, ISTRIAN, INC_JUMP, CL_JUMP, LD_VERT, CL_VERT, ISVERT, LD_HORIZ, CL_HORIZ, ISHORIZ: std_logic := '0';
	signal RESX, RESY, NOTJUMP, NOTMIRX, NOTMIRY, NOTMIRROR : std_logic := '0';
	
	signal DX: unsigned(7 downto 0);
	signal RESX: unsigned(7 downto 0);
	signal DY: unsigned(8 downto 0);
	signal RESY: unsigned(8 downto 0);
	signal DRGB: std_logic_vector(15 downto 0);
	signal MUX_PIX: unsigned(16 downto 0);
	signal QJUMP: std_logic_vector(1 downto 0);
	
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
			when INICIO => 		if DEL_SCREEN = '1' then ES <= DELCURSOR;
								elsif (DRAW_FIG = '1' or HORIZ = '1' or VERT = '1' or DIAG = '1' or MIRROR = '1' or TRIAN = '1' or PATRON = '1') then ES <= DRAWCURSOR;
								else ES <= INICIO;
								end if;
			
			when DELCURSOR =>	if DONE_CURSOR = '0' then ES <= DELCURSOR;
								else ES <= DELCOLOUR;
								end if;

			when DELCOLOUR =>	if DONE_COLOUR = '0' then ES <= DELCOLOUR;
								else ES <= DELWAIT;
								end if;

			when DELWAIT =>		if ISHORIZ = '1' and HORIZ = '0' then ES <= INICIO;
								elsif ISHORIZ = '1' and HORIZ = '1' then ES <= DELWAIT;
								elsif DEL_SCREEN = '1' then ES <= DELWAIT;
								else ES <= INICIO;
								end if;
					
			when DRAWCURSOR => 	if DONE_CURSOR = '0' then ES <= DRAWCURSOR;
								else ES <= DRAWCOLOUR;
								end if;
			
			when DRAWCOLOUR => 	if DONE_COLOUR = '0' then ES <= DRAWCOLOUR;
								else ES <= DRAWREPEAT;
								end if;

			when DRAWREPEAT => 	if ALL_PIX = '0' then ES <= DRAWCURSOR;
								elsif MIRROR = '1' and NOTMIRROR = '0' then ES <= DRAWCURSOR;
								else ES <= DRAWWAIT;
								end if;

			when DRAWWAIT =>	if    ISMIRROR = '1' and MIRROR = '1' then ES <= DRAWWAIT;
								elsif ISMIRROR = '1' and MIRROR = '0' then ES <= DRAWCURSOR;
								elsif ISDIAG = '1' and DIAG = '1' then ES <= DRAWWAIT;
								elsif ISVERT = '1' and VERT = '1' then ES <= DRAWWAIT;
								elsif ISTRIAN = '1' and TRIAN = '1' then ES <= DRAWWAIT;								
								elsif DRAW_FIG = '1' then ES <= DRAWWAIT;
								else ES <= INICIO;
								end if;

			when others =>  	ES <= INICIO; -- inalcanzable
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
	
	DEC_CNPIX <= '1' when EP = E5 and DONE_COLOUR = '1' else '0';
	INC_Y <= '1' when EP = E6 and ALL_PIX = '0' else '0';
	OP_DRAWCOLOUR <= '1' when EP = E2 or EP = E5 else '0';
	OP_SETCURSOR <= '1' when EP = E1 or EP = E4 else '0';



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
