library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity lcd_drawing is
	port(
		CLK, RESET_L: in std_logic;

		DEL_SCREEN, DRAW_FIG, DONE_CURSOR, DONE_COLOUR, HORIZ, VERT, DIAG, MIRROR, TRIAN, PATRON: in std_logic;
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

	-- Declaracion de senales de control
	signal SELREV, LD_X, INC_X, CL_X, LD_Y, INC_Y, CL_Y, LD_CN, DEC_NUMPIX, LD_CNPIX, DEC_CNPIX, ALL_PIX : std_logic := '0';
	signal LD_MIRROR, CL_MIRROR, ISMIRROR, LD_DIAG, CL_DIAG, ISDIAG, LD_TRIAN, CL_TRIAN, ISTRIAN, INC_JUMP, CL_JUMP, LD_VERT, CL_VERT, ISVERT, LD_HORIZ, CL_HORIZ, ISHORIZ: std_logic := '0';
	signal NOTJUMP, NOTMIRX, NOTMIRY, NOTMIRROR, SELSERV : std_logic := '0';
	
	signal DX: unsigned(7 downto 0);
	signal REVX: unsigned(7 downto 0);
	signal DY: unsigned(8 downto 0);
	signal REVY: unsigned(8 downto 0);
	signal DRGB: std_logic_vector(15 downto 0);
	signal MUX_PIX: unsigned(16 downto 0);
	signal MUX_NPIX: unsigned(16 downto 0);
	signal QJUMP: std_logic_vector(1 downto 0);
	signal MUX_LINES: unsigned (16 downto 0);
	signal SEL_DATA: std_logic_vector(1 downto 0);
	
	-- DeclaraciÃÂ³n de enteros sin signo para contadores
	signal cnt_YROW: unsigned(8 downto 0);
	signal cnt_XCOL: unsigned(7 downto 0);
	signal cnt_JUMP: unsigned(1 downto 0);
	signal cnt_NPIX: unsigned(16 downto 0);
	signal cnt_LINES: unsigned(16 downto 0);
	signal u_LINES: unsigned(16 downto 0);



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

			when DRAWREPEAT => 	if ALL_PIX = '0'  then ES <= DRAWCURSOR;
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
		if RESET_L = '0' then EP <= INICIO; -- reset asÃÂ­ncrono
		elsif CLK'event and CLK = '1'  -- flanco de reloj
			then EP <= ES;             -- Estado Presente = Estado Siguiente
		end if;
	end process SEQ;


	
	-- ActivaciÃÂ³n de seÃÂ±ales de control: asignaciones combinacionales - valor a seÃ¯Â¿Â½al
	LD_X <= '1' when (EP = INICIO and DEL_SCREEN = '0' and (DRAW_FIG = '1' or  (DRAW_FIG = '0' and HORIZ = '0' and (VERT = '1' or (VERT = '0' and DIAG = '0' and (MIRROR = '1' or (MIRROR = '0' and TRIAN = '1')))))))	 	or	 (EP = DRAWREPEAT and ALL_PIX = '1' and ISMIRROR = '1' and NOTMIRROR = '0') else 0;
	LD_Y <= '1' when (EP = INICIO and DEL_SCREEN = '0' and (DRAW_FIG = '1' or  (DRAW_FIG = '0' and (HORIZ = '1' or (HORIZ = '0' and VERT = '0' and DIAG = '0' and (MIRROR = '1' or (MIRROR = '0' and TRIAN = '1')))))))	 	or	 (EP = DRAWREPEAT and ALL_PIX = '1' and ISMIRROR = '1' and NOTMIRROR = '0') else 0;
	CL_X <= '1' when EP = INICIO and (DEL_SCREEN = '1' or (DEL_SCREEN = '0' and DRAW_FIG = '0' and (HORIZ = '1' or (HORIZ = '0' and VERT = '0' and DIAG = '1')))) else '0';
	CL_Y <= '1' when EP = INICIO and (DEL_SCREEN = '1' or (DEL_SCREEN = '0' and DRAW_FIG = '0' and HORIZ = '0' and (VERT = '1' or (VERT = '0' and DIAG = '1'))) else '0';
	
	INC_X
	LD_CNPIX
	DEC_CNPIX
	INC_JUMP
	CL_JUMP
	NOTJUMP
	SELSERV
	SELDATA

	LD_CN <= '1' when EP = INICIO and (DEL_SCREEN = '1' or DRAW_FIG = '1' or HORIZ = '1' or VERT = '1' or DIAG = '1' or MIRROR = '1' or TRIAN = '1' or PATRON = '1') else '0';
	LD_LINES <= '1' when (EP = INICIO and DEL_SCREEN = '0' and (DRAW_FIG = '1' or HORIZ = '1' or VERT = '1' or DIAG = '1' or MIRROR = '1' or TRIAN = '1' or PATRON = '1'))	or	(EP = DRAWREPEAT and ALL_PIX = '1' and ISMIRROR = '1' and NOTMIRROR = '0') else '0';
	DEC_LINES <= '1' when EP = DRAWCOLOUR and DONE_COLOUR = '1' else '0';
	INC_Y <= '1' when EP = DRAWREPEAT and ALL_PIX = '0' else '0';
	DEC_NUMPIX <= '1' when EP = DRAWREPEAT and ALL_PIX = '0' and ISTRIAN = '1' else '0';
	
	LD_HORIZ <= '1' when EP = INICIO and DEL_SCREEN = '0' and DRAW_FIG = '0' and HORIZ = '1' else '0';
	LD_VERT <= '1' when EP = INICIO and DEL_SCREEN = '0' and DRAW_FIG = '0' and HORIZ = '0' and VERT = '1' else '0';
	LD_DIAG <= '1' when EP = INICIO and DEL_SCREEN = '0' and DRAW_FIG = '0' and HORIZ = '0' and VERT = '0' and DIAG ='1' else '0';
	LD_MIRROR <= '1' when EP = INICIO and DEL_SCREEN = '0' and DRAW_FIG = '0' and HORIZ = '0' and VERT = '0' and DIAG ='0' and MIRROR = '1' else '0';
	LD_TRIAN <= '1' when EP = INICIO and DEL_SCREEN = '0' and DRAW_FIG = '0' and HORIZ = '0' and VERT = '0' and DIAG ='0' and MIRROR = '1' else '0';
	
	
	CL_HORIZ <= '1' when EP = DELWAIT and ISHORIZ = '1' and HORIZ = '0' else '0';
	CL_MIRROR <= '1' when EP = DRAWWAIT and ISMIRROR = '1' and MIRROR ='0' else  '0';
	CL_DIAG <= '1' when EP = DRAWWAIT and ISMIRROR = '0' and ISDIAG ='1' DIAG ='0' else  '0';
	CL_VERT <= '1' when EP = DRAWWAIT and ISMIRROR = '0' and ISDIAG ='0' and ISVERT = '1' and VERT ='0' else  '0';
	CL_TRIAN <= '1' when EP = DRAWWAIT and ISMIRROR = '0' and ISDIAG ='0' and ISVERT = '0' and ISTRIAN = '1' and TRIAN ='0' else  '0';
	
	SELREV <= '1' when EP = DRAWREPEAT and ALL_PIX = '1' and ISMIRROR = '1' and NOTMIRROR = '0' else '0';
	
	NOTMIRROR <= '1' when NOTMIRX or NOTMIRY else '0';
	
	OP_DRAWCOLOUR <= '1' when EP = DELCOLOUR or EP = DRAWCOLOUR else '0';
	OP_SETCURSOR <= '1' when EP = DELCURSOR or EP = DRAWCURSOR else '0';





	-- #######################
	-- ## UNIDAD DE PROCESO ##
	-- #######################

	--Multiplexor DX
	DX <= x"46" when SELSERV = '0' else
			 REVX;

	--Contador XCOL
	CX : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then cnt_XCOL <= (others =>'0');
		elsif CLK'event and CLK='1' then
			if LD_X = '1' then cnt_XCOL <= DX;
			elsif INC_X = '1' then cnt_XCOL <= cnt_XCOL + 1;
			elsif CL_X = '1' then cnt_XCOL <= (others => '0');
			end if;
		end if;
	end process CX;
	XCOL <= std_logic_vector(cnt_XCOL);	

	--Multiplexor DY
	DY <= '0' & x"6E" when SELSERV = '0' else
			 REVY;

	-- Contador YROW : CY
	CY : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then cnt_YROW <= (others =>'0');
		elsif CLK'event and CLK='1' then
			if LD_Y = '1' then cnt_YROW <= DY;
			elsif INC_Y = '1' then cnt_YROW <= cnt_YROW + 1;
			elsif CL_Y = '1' then cnt_YROW <= (others => '0');
			end if;
		end if;
	end process CY;
	YROW <= std_logic_vector(cnt_YROW);

	-- Contador JUMP : CJUMP
	CJUMP : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then cnt_YROW <= (others =>'0');
		elsif CLK'event and CLK='1' then
			if INC_JUMP = '1' then cnt_JUMP <= cnt_JUMP + 1;
			elsif CL_JUMP = '1' then cnt_JUMP <= (others => '0');
			end if;
		end if;
	end process CJUMP;
	QJUMP <= std_logic_vector(cnt_JUMP);

	-- Multiplexor para RGB   
	DRGB <= x"0000" when COLOUR_CODE = "000" else -- negro
			x"c973" when COLOUR_CODE = "001" else -- violeta
			x"427f" when COLOUR_CODE = "010" else -- azul
			x"4605" when COLOUR_CODE = "011" else -- verde
			x"f885" when COLOUR_CODE = "100" else -- rojo
			x"fca8" when COLOUR_CODE = "101" else -- naranja
			x"ffca" when COLOUR_CODE = "110" else -- amarillo
			x"ffff"; --blanco

	-- REG RGB: RC
	RC : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then RGB <= (others => '0');
		elsif CLK'event and CLK='1' then
			if LD_CN = '1' then RGB <= DRGB;
			end if;
		end if;
	end process RC;

	-- Multiplexor para MUX_NPIX   
	MUX_NPIX <= '1'&x"2C00" when SEL_DATA = "00" else
		    '0'&x"0064" when SEL_DATA = "01" else
		    '0'&x"0334" when SEL_DATA = "10" else
		    '0'&x"0005";

	-- Contador NUM_PIX : CNPIX
	CNPIX : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then cnt_NPIX <= (others =>'0');
		elsif CLK'event and CLK='1' then
			if LD_CNPIX = '1' then cnt_NPIX <= MUX_NPIX;
			elsif DEC_CNPIX = '1' then cnt_NPIX <= cnt_NPIX - 1;
			end if;
		end if;
	end process CNPIX;
	NUM_PIX <= cnt_NPIX;

	-- Multiplexor para MUX_LINES   
	MUX_LINES <= '0'&x"0000" when SEL_DATA = "00" else
		    '0'&x"0064" when SEL_DATA = "01" else
		    '0'&x"0000" when SEL_DATA = "10" else
		    '0'&x"0140";

	-- Contador NUM_PIX : CLINES
	CLINES : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then cnt_LINES <= (others =>'0'); ALL_PIX <= '0';
		elsif CLK'event and CLK='1' then
			if LD_CNPIX = '1' then
				cnt_LINES <= MUX_LINES;
				ALL_PIX <= '0';
			elsif DEC_CNPIX='1' and cnt_LINES="00000000000000001" then 
				cnt_LINES<= cnt_LINES-1;
				ALL_PIX <= '1';
			elsif DEC_CNPIX='1' and cnt_LINES="00000000000000000" then 
				cnt_LINES<= "11111111111111111";
				ALL_PIX <= '0';
			elsif DEC_CNPIX = '1' then 
				cnt_LINES <= cnt_LINES - 1;
				ALL_PIX <= '0';
			end if;
		end if;
	end process CLINES;
	u_LINES <= cnt_LINES;

	-- REG MIRROR: RMIRROR
	RMIRROR : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then ISMIRROR <= '0';
		elsif CLK'event and CLK='1' then
			if LD_MIRROR = '1' then ISMIRROR <= '1';
			elsif CL_MIRROR = '1' then ISMIRROR <= '0';
			end if;
		end if;
	end process RMIRROR;

	-- REG DIAG: RDIAG
	RDIAG : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then ISDIAG <= '0';
		elsif CLK'event and CLK='1' then
			if LD_DIAG = '1' then ISDIAG <= '1';
			elsif CL_DIAG = '1' then ISDIAG <= '0';
			end if;
		end if;
	end process RDIAG;

	-- REG TRIAN: RTRIAN
	RTRIAN : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then ISTRIAN <= '0';
		elsif CLK'event and CLK='1' then
			if LD_TRIAN = '1' then ISTRIAN <= '1';
			elsif CL_TRIAN = '1' then ISTRIAN <= '0';
			end if;
		end if;
	end process RTRIAN;

	-- REG VERT: RVERT
	RVERT : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then ISVERT <= '0';
		elsif CLK'event and CLK='1' then
			if LD_VERT = '1' then ISVERT <= '1';
			elsif CL_VERT = '1' then ISVERT <= '0';
			end if;
		end if;
	end process RVERT;

	-- REG HORIZ: RHORIZ
	RHORIZ : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then ISHORIZ <= '0';
		elsif CLK'event and CLK='1' then
			if LD_HORIZ = '1' then ISHORIZ <= '1';
			elsif CL_HORIZ = '1' then ISHORIZ <= '0';
			end if;
		end if;
	end process RHORIZ;

	--Restador para REVX
	REVX <= x"8C" - cnt_XCOL;

	--Restador para REVX
	REVY <= x"DC" - cnt_XCOL;

	--Comparador NOTJUMP
	NOTJUMP <= '1' when cnt_JUMP = "10" else
			'0';

	--Comparador NOTMIRX
	NOTMIRX <= '1' when cnt_XCOL > x"8B" else
			'0';

	--Comparador NOTMIRY
	NOTMIRY <= '1' when cnt_YROW > '0'&x"DB" else
			'0';

	--Puerta OR NOTMIRROR
	NOTMIRROR <= NOTMIRX or NOTMIRY;
	

end arq_lcd_drawing; 
