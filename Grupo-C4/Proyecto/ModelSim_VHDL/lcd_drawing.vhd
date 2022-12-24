-----------------------------
-- fichero lcd_drawing.vhd --
-----------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity lcd_drawing is
	port(
		CLK, RESET_L: in std_logic;

		DEL_SCREEN, DRAW_FIG, DONE_CURSOR, DONE_COLOUR, HORIZ, VERT, DIAG, MIRROR, TRIAN, EQUIL, ROMBO, ROMBOIDE, TRAP, PATRON: in std_logic;
		COLOUR_CODE: in std_logic_vector(2 downto 0);

		OP_SETCURSOR, OP_DRAWCOLOUR: out std_logic;
		XCOL: out std_logic_vector(7 downto 0);
		YROW: out std_logic_vector(8 downto 0);
		RGB: out std_logic_vector(15 downto 0);
		NUM_PIX: out unsigned(16 downto 0);
		DONE_ORDER: out std_logic
	);
end lcd_drawing;


architecture arq_lcd_drawing of lcd_drawing is

	-- Declaracion de estados
	type estados is (INICIO, DELCURSOR, DELCOLOUR, DELWAIT, DRAWCURSOR, DRAWCOLOUR, DRAWREPEAT, DRAWWAIT, UPROMB, DOWNROMB, TRAPEC, EQUILAT);
	signal EP, ES : estados;

	-- Declaracion de senales de control
	signal SELREV, LD_X, E_X, UPX, CL_X, LD_Y, INC_Y, CL_Y, LD_CN, E_NUMPIX, UPNPIX, LD_LINES, DEC_LINES, ALL_PIX : std_logic := '0';
	signal LD_TRAP, CL_TRAP, ISTRAP, LD_ROMBOIDE, CL_ROMBOIDE, ISROMBOIDE, LD_ROMBO, CL_ROMBO, ISROMBO, LD_EQUIL, CL_EQUIL, ISEQUIL, LD_PATRON, CL_PATRON, ISPATRON : std_logic := '0';
	signal LD_MIRROR, CL_MIRROR, ISMIRROR, LD_DONE, CL_DONE, ISDONE, LD_DIAG, CL_DIAG, ISDIAG, LD_TRIAN, CL_TRIAN, ISTRIAN, DEC_JUMP, LD_JUMP, LD_VERT, CL_VERT, ISVERT, LD_HORIZ, CL_HORIZ, ISHORIZ: std_logic := '0';
	signal NOTJUMP, NOTMIRX, NOTMIRY, NOTMIRROR, DROMB: std_logic := '0';
	
	signal SEL_DATA: std_logic_vector(1 downto 0);
	signal SEL_LINES: std_logic_vector(1 downto 0);
	
	signal DX: unsigned(7 downto 0);
	signal REVX: unsigned(7 downto 0);
	signal DY: unsigned(8 downto 0);
	signal REVY: unsigned(8 downto 0);
	signal PREVY: unsigned(8 downto 0);
	
	
	signal MUX_NPIX: unsigned(16 downto 0);
	signal MUX_LINES: unsigned (16 downto 0);
	signal DRGB: std_logic_vector(15 downto 0);
	
	-- Declaracion de enteros sin signo para contadores
	signal cnt_YROW: unsigned(8 downto 0);
	signal cnt_XCOL: unsigned(7 downto 0);
	signal cnt_JUMP: unsigned(1 downto 0);
	signal cnt_NPIX: unsigned(16 downto 0);
	signal cnt_LINES: unsigned(16 downto 0);



	begin

	-- #######################
	-- ## UNIDAD DE CONTROL ## 
	-- #######################

	-- Transicipn de estados (calculo de estado siguiente)
	SWSTATE: process (EP, DEL_SCREEN, DRAW_FIG, DONE_CURSOR, DONE_COLOUR, ALL_PIX, HORIZ, VERT, DIAG, MIRROR, TRIAN, ISHORIZ, ISVERT, ISDIAG, ISTRIAN,
							ISMIRROR, NOTMIRROR, ISEQUIL, ISROMBO, DROMB, ISTRAP, EQUIL, ISROMBOIDE, ROMBO, ROMBOIDE, TRAP, ISPATRON, PATRON) begin
		case EP is
			when INICIO => 		if DEL_SCREEN = '1' or (DEL_SCREEN = '0' and DRAW_FIG = '0' and HORIZ = '1') then ES <= DELCURSOR;
								elsif (DRAW_FIG = '1'  or VERT = '1' or DIAG = '1' or MIRROR = '1' or TRIAN = '1' or EQUIL ='1' or ROMBO = '1' or ROMBOIDE = '1' or TRAP = '1' or PATRON = '1') then ES <= DRAWCURSOR;
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

			when DRAWREPEAT => 	if ALL_PIX = '0' and ISTRIAN = '0' and ISDIAG = '0' and ISEQUIL = '0' and ISROMBO = '1' and DROMB = '0' then ES <= UPROMB;
								elsif ALL_PIX = '0' and ISTRIAN = '0' and ISDIAG = '0' and ISEQUIL = '0' and ISROMBO = '1' and DROMB = '1' then ES <= DOWNROMB;
								elsif ALL_PIX = '0' and ISTRIAN = '0' and ISDIAG = '0' and ISEQUIL = '0' and ISROMBO = '0' and ISTRAP = '1' then ES <= TRAPEC;
								elsif ALL_PIX = '0' and ISTRIAN = '0' and ISDIAG = '0' and ISEQUIL = '1' then ES <= EQUILAT;
								elsif ALL_PIX = '0'  then ES <= DRAWCURSOR;
								elsif MIRROR = '1' and NOTMIRROR = '0' then ES <= DRAWCURSOR;
								else ES <= DRAWWAIT;
								end if;
								
			when EQUILAT => 	ES <= DRAWCURSOR;
			
			when TRAPEC =>		ES <= DRAWCURSOR;
			
			when UPROMB =>		ES <= DRAWCURSOR;
			
			when DOWNROMB =>	ES <= DRAWCURSOR;
			

			when DRAWWAIT =>	if    ISMIRROR = '1' and MIRROR = '1' then ES <= DRAWWAIT;
								elsif ISMIRROR = '1' and MIRROR = '0' then ES <= DRAWCURSOR;
								elsif ISDIAG = '1' and DIAG = '1' then ES <= DRAWWAIT;
								elsif ISVERT = '1' and VERT = '1' then ES <= DRAWWAIT;
								elsif ISTRIAN = '1' and TRIAN = '1' then ES <= DRAWWAIT;		
								elsif ISEQUIL = '1' and EQUIL = '1' then ES <= DRAWWAIT;		
								elsif ISROMBO = '1' and ROMBO = '1' then ES <= DRAWWAIT;		
								elsif ISROMBOIDE = '1' and ROMBOIDE = '1' then ES <= DRAWWAIT;		
								elsif ISTRAP = '1' and TRAP = '1' then ES <= DRAWWAIT;			
								elsif ISPATRON = '1' and PATRON = '1' then ES <= DRAWWAIT;								
								elsif DRAW_FIG = '1' then ES <= DRAWWAIT;
								else ES <= INICIO;
								end if;

			when others =>  	ES <= INICIO; -- inalcanzable
		end case;
	end process SWSTATE;



	-- Actualizacion de EP en cada flanco de reloj (sequential)
	SEQ: process (CLK, RESET_L) begin
		if RESET_L = '0' then EP <= INICIO; -- reset asincrono
		elsif CLK'event and CLK = '1'  -- flanco de reloj
			then EP <= ES;             -- Estado Presente = Estado Siguiente
		end if;
	end process SEQ;


	
	-- Activacion de signals de control: 
	---- Relacionadas con XCOL e YROW 
	LD_X <= '1' when (EP = INICIO and DEL_SCREEN = '0' and DRAW_FIG = '1') or 
		LD_VERT = '1' or LD_MIRROR = '1' or LD_TRIAN = '1' or
		LD_EQUIL = '1' or LD_ROMBO = '1' or LD_ROMBOIDE = '1' or LD_TRAP = '1' or
		SELREV='1' else '0';
	
	LD_Y <= '1' when (EP = INICIO and DEL_SCREEN = '0' and DRAW_FIG = '1') or 	
		LD_HORIZ = '1' or LD_MIRROR = '1' or LD_TRIAN = '1' or 
		LD_EQUIL = '1' or LD_ROMBO = '1' or LD_ROMBOIDE = '1' or LD_TRAP = '1'or	 
		SELREV='1' else '0';	
	
	CL_X <= '1' when (EP = INICIO and DEL_SCREEN = '1')  or 
		LD_HORIZ = '1' or LD_DIAG = '1' or 
		LD_PATRON = '1' else '0';
	
	CL_Y <= '1' when (EP = INICIO and DEL_SCREEN = '1') or 
		LD_VERT = '1' or LD_DIAG = '1' or LD_PATRON = '1' else '0';
	
	E_X <= '1' when EP = UPROMB or UPX = '1' or EP = EQUILAT or EP = TRAPEC or 
		(EP = DRAWREPEAT and ALL_PIX = '0' and ISTRIAN = '0' and ISDIAG = '0' and ISEQUIL = '0' and ISROMBO = '0' and ISTRAP = '0' and ISROMBOIDE = '0' and ISPATRON = '1') 
		else '0';
	
	INC_Y <= '1' when EP = DRAWREPEAT and ALL_PIX = '0' else '0';
	
	UPX <= '1' when EP = DOWNROMB or (EP = DRAWREPEAT and ALL_PIX = '0' and ISTRIAN = '0' and ((ISDIAG = '1' and NOTJUMP = '0') or (ISDIAG = '0' and ISEQUIL = '0' and 
		ISROMBO = '0' and ISTRAP = '0' and ISROMBOIDE = '1'))) else '0';
	
	-- Relacionadas con el nÃºmero de pÃ­xeles y lineas
	LD_LINES <= '1' when (EP = INICIO and DEL_SCREEN = '0' and DRAW_FIG = '1') or 
		LD_VERT = '1' or LD_DIAG = '1' or LD_MIRROR = '1' or LD_TRIAN = '1' or 
		LD_EQUIL = '1' or LD_ROMBO = '1' or LD_ROMBOIDE = '1' or LD_TRAP = '1' or LD_PATRON = '1' or 
		SELREV = '1' else '0';
	
	LD_CN <= '1' when EP = INICIO and (DEL_SCREEN = '1' or DRAW_FIG = '1' or 
		HORIZ = '1' or VERT = '1' or DIAG = '1' or MIRROR = '1' or TRIAN = '1' or 
		EQUIL = '1' or ROMBO = '1' or ROMBOIDE = '1' or TRAP = '1' or PATRON = '1') 
		else '0';
	
	DEC_LINES <= '1' when EP = DRAWCOLOUR and DONE_COLOUR = '1' else '0';
	
	E_NUMPIX <= '1' when UPNPIX = '1' or EP = DOWNROMB or (EP = DRAWREPEAT and ALL_PIX = '0' and 
		(ISTRIAN = '1' or (ISTRIAN = '0' and ISDIAG = '0' and ISEQUIL = '0' and ISROMBO = '1' and DROMB = '1'))) 
		else '0';
	
	UPNPIX <= '1' when EP = EQUILAT or EP = TRAPEC or EP = UPROMB or 
		(EP = DRAWREPEAT and ALL_PIX = '0' and ISTRIAN = '0'  and ISDIAG = '0' and 
		(ISEQUIL = '1' or (ISEQUIL = '0' and ((ISROMBO = '1' and DROMB = '0') or (ISROMBO = '0' and ISTRAP = '1'))))) else '0';

	---- aux
	LD_JUMP <= '1' when LD_DIAG = '1' or (EP = DRAWREPEAT and ALL_PIX = '0' and ISTRIAN = '0' and ISDIAG = '1' and NOTJUMP = '1')  else '0';
	DEC_JUMP <= '1' when EP = DRAWREPEAT and ALL_PIX = '0' and ISTRIAN = '0' and ISDIAG = '1' and NOTJUMP = '0' else '0';
	LD_DONE <= '1' when SELREV ='1' else '0';
	CL_DONE <= '1' when CL_MIRROR ='1' else '0';
	

	---- LD opciones extra
	LD_HORIZ <= '1' when EP = INICIO and DEL_SCREEN = '0' and DRAW_FIG = '0' and HORIZ = '1' else '0';
	LD_VERT <= '1' when EP = INICIO and DEL_SCREEN = '0' and DRAW_FIG = '0' and 
		HORIZ = '0' and VERT = '1' else '0';
	LD_DIAG <= '1' when EP = INICIO and DEL_SCREEN = '0' and DRAW_FIG = '0' and 
		HORIZ = '0' and VERT = '0' and DIAG ='1' else '0';
	LD_MIRROR <= '1' when EP = INICIO and DEL_SCREEN = '0' and DRAW_FIG = '0' and 
		HORIZ = '0' and VERT = '0' and DIAG ='0' and MIRROR = '1' else '0';
	LD_TRIAN <= '1' when EP = INICIO and DEL_SCREEN = '0' and DRAW_FIG = '0' and 
		HORIZ = '0' and VERT = '0' and DIAG ='0' and MIRROR = '1' else '0';
	LD_EQUIL <= '1' when EP = INICIO and DEL_SCREEN = '0' and DRAW_FIG = '0' and 
		HORIZ = '0' and VERT = '0' and DIAG ='0' and MIRROR = '0' and EQUIL = '1' else '0';
	LD_ROMBO <= '1' when EP = INICIO and DEL_SCREEN = '0' and DRAW_FIG = '0' and 
		HORIZ = '0' and VERT = '0' and DIAG ='0' and MIRROR = '0' and EQUIL = '0' and ROMBO = '1' else '0';
	LD_ROMBOIDE <= '1' when EP = INICIO and DEL_SCREEN = '0' and DRAW_FIG = '0' and 
		HORIZ = '0' and VERT = '0' and DIAG ='0' and MIRROR = '0' and EQUIL = '0' and ROMBO = '0' and ROMBOIDE = '1' else '0';
	LD_TRAP <= '1' when EP = INICIO and DEL_SCREEN = '0' and DRAW_FIG = '0' and 
		HORIZ = '0' and VERT = '0' and DIAG ='0' and MIRROR = '0' and EQUIL = '0' and ROMBO = '0' and ROMBOIDE = '0' and TRAP = '1' else '0';
	LD_PATRON<= '1' when EP = INICIO and DEL_SCREEN = '0' and DRAW_FIG = '0' and 
		HORIZ = '0' and VERT = '0' and DIAG ='0' and MIRROR = '0' and EQUIL = '0' and ROMBO = '0' and ROMBOIDE = '0' and TRAP = '0' and PATRON = '1' else '0';

	---- CL opciones extra
	CL_HORIZ <= '1' when EP = DELWAIT and ISHORIZ = '1' and HORIZ = '0' else '0';
	CL_MIRROR <= '1' when EP = DRAWWAIT and ISMIRROR = '1' and MIRROR = '0' else  '0';
	CL_DIAG <= '1' when EP = DRAWWAIT and ISMIRROR = '0' and ISDIAG ='1' and DIAG = '0' else  '0';
	CL_VERT <= '1' when EP = DRAWWAIT and ISMIRROR = '0' and ISDIAG ='0' and ISVERT = '1' and VERT = '0' else  '0';
	CL_TRIAN <= '1' when EP = DRAWWAIT and ISMIRROR = '0' and ISDIAG ='0' and ISVERT = '0' and ISTRIAN = '1' and TRIAN = '0' else  '0';
	CL_EQUIL <= '1' when EP = DRAWWAIT and ISMIRROR = '0' and ISDIAG ='0' and ISVERT = '0' and ISTRIAN = '0' and ISEQUIL = '1' and EQUIL = '0' else  '0';
	
	CL_ROMBO <= '1' when EP = DRAWWAIT and ISMIRROR = '0' and ISDIAG ='0' and ISVERT = '0' and ISTRIAN = '0' and 
		ISEQUIL = '0' and ISROMBO = '1' and ROMBO = '0' else  '0';
	
	CL_ROMBOIDE <= '1' when EP = DRAWWAIT and ISMIRROR = '0' and ISDIAG ='0' and ISVERT = '0' and ISTRIAN = '0' and 
		ISEQUIL = '0' and ISROMBO = '0' and ISROMBOIDE = '1' and ROMBOIDE = '0' else  '0';
	
	CL_TRAP <= '1' when EP = DRAWWAIT and ISMIRROR = '0' and ISDIAG ='0' and ISVERT = '0' and ISTRIAN = '0' and 
		ISEQUIL = '0' and ISROMBO = '0' and ISROMBOIDE = '0' and ISTRAP = '1' and TRAP = '0' else  '0';
	
	CL_PATRON <= '1' when EP = DRAWWAIT and ISMIRROR = '0' and ISDIAG ='0' and ISVERT = '0' and ISTRIAN = '0' and 
		ISEQUIL = '0' and ISROMBO = '0' and ISROMBOIDE = '0' and ISTRAP = '0' and ISPATRON = '1' and PATRON = '0' else  '0';
	
	---- selectores de datos
	SELREV <= '1' when EP = DRAWREPEAT and ALL_PIX = '1' and ISMIRROR = '1' and NOTMIRROR = '0' else '0';

	SEL_DATA <= "00" when EP = INICIO and DEL_SCREEN = '1' else
				"01" when (EP = INICIO and DEL_SCREEN = '0' and DRAW_FIG = '1') or 
					LD_MIRROR = '1' or LD_TRIAN = '1' or LD_ROMBOIDE ='1' or LD_TRAP = '1' else
				"10" when LD_HORIZ = '1' else
				"11" when LD_VERT ='1' or LD_DIAG = '1' or LD_EQUIL = '1' or LD_ROMBO = '1' or LD_PATRON = '1' else
				"00"; -- inalcanzable
				
	SEL_LINES <= 	"01" when LD_VERT = '1' or LD_DIAG = '1'  else
					"10" when LD_PATRON = '1' else
					"11" when LD_ROMBOIDE = '1' or LD_EQUIL = '1' or LD_TRAP = '1' else
					"00";
	

	--NOTMIRROR <= '1' when NOTMIRX or NOTMIRY else '0';
	
	---- operaciones
	OP_DRAWCOLOUR <= '1' when EP = DELCOLOUR or EP = DRAWCOLOUR else '0';
	OP_SETCURSOR <= '1' when EP = DELCURSOR or EP = DRAWCURSOR else '0';
	DONE_ORDER <= '1' when EP = DELWAIT or EP = DRAWWAIT else '0';




	-- #######################
	-- ## UNIDAD DE PROCESO ##
	-- #######################

	--Multiplexor DX (MUXX)
	DX <= x"46" when SELREV = '0' else
			 REVX;

	--Contador XCOL
	CX : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then cnt_XCOL <= (others =>'0');
		elsif CLK'event and CLK='1' then
			if LD_X = '1' then cnt_XCOL <= DX;
			elsif E_X = '1' and UPX = '0' then cnt_XCOL <= cnt_XCOL - 1;
			elsif E_X = '1' and UPX = '1' then cnt_XCOL <= cnt_XCOL + 1;
			elsif CL_X = '1' then cnt_XCOL <= (others => '0');
			end if;
		end if;
	end process CX;
	XCOL <= std_logic_vector(cnt_XCOL);	

	--Multiplexor DY (MUXY)
	DY <= '0' & x"6E" when SELREV = '0' else
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
	
	
	-- Multiplexor para MUX_NPIX   (MUXNPIX)
	MUX_NPIX <= '1'&x"0005" when SEL_DATA = "00" else -- 76800
		    '0'&x"0002" when SEL_DATA = "01" else -- 100
		    '0'&x"0004" when SEL_DATA = "10" else 
		    '0'&x"0003"; 

	-- Contador NUM_PIX : CNPIX
	CNPIX : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then cnt_NPIX <= (others =>'0');
		elsif CLK'event and CLK='1' then
			if LD_CN = '1' then cnt_NPIX <= MUX_NPIX;
			elsif E_NUMPIX = '1' and UPNPIX = '0' then cnt_NPIX <= cnt_NPIX - 1;
			elsif E_NUMPIX = '1' and UPNPIX = '1' then cnt_NPIX <= cnt_NPIX + 1;
			end if;
		end if;
	end process CNPIX;
	NUM_PIX <= cnt_NPIX;
	
	
	-- Multiplexor para MUX_LINES   
	MUX_LINES <= '0'&x"0002" when SEL_LINES =  "00" else -- 100 
		    '0'&x"0004" when SEL_LINES =  "01" else --320
			'0'&x"0005" when SEL_LINES =  "10" else  -- 1000
			'0'&x"0003";
	-- Contador NUM_PIX : CLINES
	CLINES : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then cnt_LINES <= (others =>'0'); ALL_PIX <= '0';
		elsif CLK'event and CLK='1' then
			if LD_LINES = '1' then
				cnt_LINES <= MUX_LINES;
				ALL_PIX <= '0';
			elsif DEC_LINES='1' and cnt_LINES="00000000000000001" then 
				cnt_LINES<= cnt_LINES-1;
				ALL_PIX <= '1';
			elsif DEC_LINES='1' and cnt_LINES="00000000000000000" then 
				cnt_LINES<= "11111111111111111";
				ALL_PIX <= '0';
			elsif DEC_LINES = '1' then 
				cnt_LINES <= cnt_LINES - 1;
				ALL_PIX <= '0';
			end if;
		end if;
	end process CLINES;
	--u_LINES <= cnt_LINES;
	
	-- Contador JUMP : CJUMP
	CJUMP : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then cnt_JUMP <= (others =>'0');
		elsif CLK'event and CLK='1' then
			if LD_JUMP='1' then
				cnt_JUMP <= "10";
				NOTJUMP <= '0';
			elsif DEC_JUMP='1' and cnt_JUMP="01" then 
				cnt_JUMP<= cnt_JUMP-1;
				NOTJUMP <= '1';
			elsif DEC_JUMP='1' and cnt_JUMP="00" then 
				cnt_JUMP<= "11";
				NOTJUMP <= '0';
			elsif DEC_JUMP = '1' then 
				cnt_JUMP <= cnt_JUMP - 1;
				NOTJUMP <= '0';
			end if;
		end if;
	end process CJUMP;
	--QJUMP <= std_logic_vector(cnt_JUMP);
	

	-- Multiplexor para RGB  (MUXC) 
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
	
	-- REG PREV Y: RY
	RY : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then PREVY <= (others => '0');
		elsif CLK'event and CLK='1' then
			if LD_MIRROR = '1' then PREVY <= '0' & x"6E";
			end if;
		end if;
	end process RY;

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
	
	-- REG ROMBOIDE: RROMBOIDE
	RROMBOIDE : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then ISROMBOIDE <= '0';
		elsif CLK'event and CLK='1' then
			if LD_ROMBOIDE = '1' then ISROMBOIDE <= '1';
			elsif CL_ROMBOIDE = '1' then ISROMBOIDE <= '0';
			end if;
		end if;
	end process RROMBOIDE;
	
	
	-- REG EQUIL: REQUIL
	REQUIL : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then ISEQUIL <= '0';
		elsif CLK'event and CLK='1' then
			if LD_EQUIL = '1' then ISEQUIL <= '1';
			elsif CL_EQUIL = '1' then ISEQUIL <= '0';
			end if;
		end if;
	end process REQUIL;
	
	
	-- REG ROMBO: RROMBO
	RROMBO : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then ISROMBO <= '0';
		elsif CLK'event and CLK='1' then
			if LD_ROMBO = '1' then ISROMBO <= '1';
			elsif CL_ROMBO = '1' then ISROMBO <= '0';
			end if;
		end if;
	end process RROMBO;
	
	
	-- REG TRAP: RTRAP
	RTRAP : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then ISTRAP <= '0';
		elsif CLK'event and CLK='1' then
			if LD_TRAP = '1' then ISTRAP <= '1';
			elsif CL_TRAP = '1' then ISTRAP <= '0';
			end if;
		end if;
	end process RTRAP;
	
	-- REG PATRON: RPATRON
	RPATRON : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then ISPATRON <= '0';
		elsif CLK'event and CLK='1' then
			if LD_PATRON = '1' then ISPATRON <= '1';
			elsif CL_PATRON = '1' then ISPATRON <= '0';
			end if;
		end if;
	end process RPATRON;
	
	-- REG DONE: RDONE
	RDONE : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then ISDONE <= '0';
		elsif CLK'event and CLK='1' then
			if LD_DONE = '1' then ISDONE <= '1';
			elsif CL_DONE = '1' then ISDONE <= '0';
			end if;
		end if;
	end process RDONE;

	--Restador para REVX
	REVX <= x"8C" - cnt_XCOL;

	--Restador para REVY
	REVY <= ('0' & x"DC") - PREVY;

	--Comparador NOTMIRX
	DROMB <= '1' when cnt_LINES < x"32" else
			'0';

	--Comparador NOTMIRX
	NOTMIRX <= '1' when cnt_XCOL > x"8B" else
			'0';

	--Comparador NOTMIRY
	NOTMIRY <= '1' when cnt_YROW > '0'&x"DB" else
			'0';

	--Puerta OR NOTMIRROR
	NOTMIRROR <= (NOTMIRX or NOTMIRY) or ISDONE;
	

end arq_lcd_drawing; 
