---------------------------
-- fichero uart_ctrl.vhd --
---------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity uart_ctrl is
	port(
		CLK, RESET_L: in std_logic;
		NEWOP, DONE_ORDER: in std_logic;
		DAT: in std_logic_vector(7 downto 0);
		DONE_OP,DRAW_FIG,DEL_SCREEN, DIAG, VERT, HORIZ, EQUIL, ROMBO, ROMBOIDE, TRAP, TRIAN, PATRON, HEXAG, LED_POS, LED_SIG: out std_logic;
		COLOUR_CODE: out std_logic_vector(2 downto 0);
		UART_XCOL: out std_logic_vector(7 downto 0);
		UART_YROW: out std_logic_vector(8 downto 0)
	);
end uart_ctrl;


architecture arq_uart_ctrl of uart_ctrl is

	-- Declaracion de estados
	type estados is (INICIO, SIGNALS, LDLEDSIG, WTLEDSIG, FORMINGXCOL, WTXBIT, FORMINGYROW, WTYBIT, LDLEDPOS, WTLEDPOS, WTORDER, SNDONE); 
	signal EP, ES : estados;

	-- Declaracion de senales de control
	signal LD_FIG, LD_DEL, LD_COLOUR, LD_DIAG, LD_VERT, LD_HORIZ, LD_ROMBO, LD_EQUIL, LD_ROMBOIDE, LD_TRAP, LD_TRIAN, LD_PATRON, LD_HEXAG, LD_LENX, LD_LENY: std_logic := '0';
	signal ISVERT, ISDEL, ISFIG, ISCOLOUR, ISDIAG, ISHORIZ, ISEQUIL, ISROMBO, ISROMBOIDE, ISTRAP, ISTRIAN, ISPATRON, ISHEXAG, ISX, ISY: std_logic :='0';

	signal LD_LEDSIG, DEC_LEDSIG, DONE_LEDSIG, CL_LEDSIG: std_logic := '0';
	signal LD_LEDPOS, DEC_LEDPOS, DONE_LEDPOS, CL_LEDPOS: std_logic := '0';
	signal DEC_LENX, DEC_LENY, DONE_X, DONE_Y, ISDEF, LD_DEF, DEFAULT, CL_DEF, ISa0, ISa1, XBIT, YBIT: std_logic := '0';
	signal CL_SIGS, LD_DAT, CL_DAT: std_logic := '0';
	signal RDATO: std_logic_vector(7 downto 0);

	signal OPX: std_logic_vector(1 downto 0);
	
	signal OPY: std_logic_vector(1 downto 0);
	

	begin

	-- #######################
	-- ## UNIDAD DE CONTROL ## 
	-- #######################

	-- Transicion de estados (calculo de estado siguiente)
	SWSTATE: process (EP, ISCOLOUR, ISDIAG, ISVERT, ISFIG, ISDEL, ISHORIZ, ISEQUIL, ISROMBO, ISROMBOIDE, ISTRAP, ISTRIAN, ISPATRON, ISHEXAG, ISX, ISY, ISDEF, DONE_X, DONE_Y, ISa0, ISa1, DONE_LEDPOS, DONE_LEDSIG, DONE_ORDER, NEWOP) begin
		case EP is
			when INICIO =>		if NEWOP='1' then ES<=SIGNALS;
									else ES<=INICIO;
									end if;

			when SIGNALS =>		if ISCOLOUR='1' then ES<=SNDONE;
									elsif ISCOLOUR = '0' and ISFIG = '0' and ISDEL = '0' and ISVERT = '0' and ISDIAG = '0' and ISHORIZ = '0' and ISEQUIL = '0' and ISROMBO = '0' and ISROMBOIDE = '0' and ISTRAP = '0' and ISTRIAN = '0' and ISPATRON = '0' and ISHEXAG = '0' and ISX = '0' and  ISY = '0' then ES <=LDLEDSIG;
									elsif ISCOLOUR = '0' and ISFIG = '0' and ISDEL = '0' and ISVERT = '0' and ISDIAG = '0' and ISHORIZ = '0' and ISEQUIL = '0' and ISROMBO = '0' and ISROMBOIDE = '0' and ISTRAP = '0' and ISTRIAN = '0' and ISPATRON = '0' and ISHEXAG = '0' and ISX = '1' then ES <=FORMINGXCOL;
									elsif ISCOLOUR = '0' and ISFIG = '0' and ISDEL = '0' and ISVERT = '0' and ISDIAG = '0' and ISHORIZ = '0' and ISEQUIL = '0' and ISROMBO = '0' and ISROMBOIDE = '0' and ISTRAP = '0' and ISTRIAN = '0' and ISPATRON = '0' and ISHEXAG = '0' and ISX = '0' and  ISY = '1' then ES <=FORMINGYROW;
									else ES<=WTORDER;
									end if; 
			when LDLEDSIG =>	ES <= WTLEDSIG;
			when WTLEDSIG =>	if DONE_LEDSIG = '1' then ES <= INICIO;
									else ES <= WTLEDSIG;
									end if;
									
			when FORMINGXCOL =>	if DONE_X = '1' then ES <= INICIO;
									else ES <= WTXBIT;
									end if;
									
			when WTXBIT =>		if NEWOP = '0' then ES <= WTXBIT;
									elsif ISDEF = '1' then ES <= INICIO;
									elsif ISa0 = '1' then ES <= FORMINGXCOL;
									elsif ISa1 = '1' then ES <= FORMINGXCOL;
									else ES <= LDLEDPOS;
									end if;
									
			when FORMINGYROW =>	if DONE_Y = '1' then ES <= INICIO;
									else ES <= WTYBIT;
									end if;		
									
									
			when WTYBIT =>		if NEWOP = '0' then ES <= WTYBIT;
									elsif ISDEF = '1' then ES <= INICIO;
									elsif ISa0 = '1' then ES <= FORMINGYROW;
									elsif ISa1 = '1' then ES <= FORMINGYROW;
									else ES <= LDLEDPOS;
									end if;
			when LDLEDPOS => 	ES <= WTLEDPOS;
			
			when WTLEDPOS => 	if DONE_LEDPOS = '0' then ES <= WTLEDPOS;
									else ES <= INICIO;
									end if;
			
			when WTORDER =>		if DONE_ORDER = '0' then ES<=WTORDER;
									else ES <= SNDONE;
									end if;

			when SNDONE =>		ES<=INICIO;
	
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


	
	-- Activacion de signals de control: asignaciones combinacionales
	LD_DAT <= '1' when EP=INICIO and NEWOP = '1' else '0';
	LD_COLOUR<= '1' when EP=SIGNALS and ISCOLOUR='1' else '0';
	LD_FIG	<= '1' when EP=SIGNALS and ISCOLOUR='0' and ISFIG='1' else '0';
	LD_DEL	<= '1' when EP=SIGNALS and ISCOLOUR='0' and ISFIG='0' and ISDEL='1' else '0';
	LD_VERT	<= '1' when EP=SIGNALS and ISCOLOUR='0' and ISFIG='0' and ISDEL='0' and ISVERT = '1' else '0';
	LD_DIAG	<= '1' when EP=SIGNALS and ISCOLOUR='0' and ISFIG='0' and ISDEL='0' and ISVERT = '0' and ISDIAG = '1' else '0';
	LD_HORIZ	<= '1' when EP=SIGNALS and ISCOLOUR='0' and ISFIG='0' and ISDEL='0' and ISVERT = '0' and ISDIAG = '0' and ISHORIZ='1' else '0';
	LD_EQUIL	<= '1' when EP=SIGNALS and ISCOLOUR='0' and ISFIG='0' and ISDEL='0' and ISVERT = '0' and ISDIAG = '0' and ISHORIZ='0' and ISEQUIL = '1'  else '0';
	LD_ROMBO	<= '1' when EP=SIGNALS and ISCOLOUR='0' and ISFIG='0' and ISDEL='0' and ISVERT = '0' and ISDIAG = '0' and ISHORIZ='0' and ISEQUIL = '0' and ISROMBO = '1'  else '0';
	LD_ROMBOIDE	<= '1' when EP=SIGNALS and ISCOLOUR='0' and ISFIG='0' and ISDEL='0' and ISVERT = '0' and ISDIAG = '0' and ISHORIZ='0' and ISEQUIL = '0' and ISROMBO = '0' and ISROMBOIDE = '1'  else '0';
	LD_TRAP	<= '1' when EP=SIGNALS and ISCOLOUR='0' and ISFIG='0' and ISDEL='0' and ISVERT = '0' and ISDIAG = '0' and ISHORIZ='0' and ISEQUIL = '0' and ISROMBO = '0' and ISROMBOIDE = '0' and ISTRAP = '1'  else '0';
	LD_TRIAN	<= '1' when EP=SIGNALS and ISCOLOUR='0' and ISFIG='0' and ISDEL='0' and ISVERT = '0' and ISDIAG = '0' and ISHORIZ='0' and ISEQUIL = '0' and ISROMBO = '0' and ISROMBOIDE = '0' and ISTRAP = '0' and ISTRIAN = '1'  else '0';
	CL_SIGS	<= '1' when EP=WTORDER and DONE_ORDER='1' else '0';
	DONE_OP<='1' when EP=SNDONE else '0';
	


	-- #######################
	-- ## UNIDAD DE PROCESO ##
	-- #######################

	--Comparador DEL_SCREEN : CMPDEL
	ISDEL <= '1' when RDATO(7 downto 0) = x"62" else '0';

	--Registro RDEL
	RDEL : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then DEL_SCREEN <= '0';
		elsif CLK'event and CLK='1' then
			if LD_DEL = '1' then DEL_SCREEN <= '1';
			elsif CL_SIGS = '1' then DEL_SCREEN <='0';
			end if;
		end if;
	end process RDEL;

	--Comparador DRAW_FIG :CMPFIG
	ISFIG <= '1' when RDATO(7 downto 0) = x"66" else '0';

	--Registro RFIG
	RFIG : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then DRAW_FIG <= '0';
		elsif CLK'event and CLK='1' then
			if LD_FIG = '1' then DRAW_FIG <= '1';
			elsif CL_SIGS = '1' then DRAW_FIG <='0';
			end if;
		end if;
	end process RFIG;
	
	--Comparador VERT
	ISVERT <= '1' when RDATO(7 downto 0) = x"76" else '0';
	
	--Registro RVERT
	RVERT : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then VERT <= '0';
		elsif CLK'event and CLK='1' then
			if LD_VERT = '1' then VERT <= '1';
			elsif CL_SIGS = '1' then VERT <='0';
			end if;
		end if;
	end process RVERT;
	
	--Comparador DIAG
	ISDIAG <= '1' when RDATO(7 downto 0) = x"64" else '0';
	
	--Registro RDIAG
	RDIAG : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then DIAG <= '0';
		elsif CLK'event and CLK='1' then
			if LD_DIAG = '1' then DIAG <= '1';
			elsif CL_SIGS = '1' then DIAG <='0';
			end if;
		end if;
	end process RDIAG;


	--Comparador HORIZ: CMPHORIZ
	ISHORIZ <= '1' when RDATO(7 downto 0) = x"68" else '0';
	
	--Registro RHORIZ
	RHORIZ : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then HORIZ <= '0';
		elsif CLK'event and CLK='1' then
			if LD_HORIZ = '1' then HORIZ <= '1';
			elsif CL_SIGS = '1' then HORIZ <='0';
			end if;
		end if;
	end process RHORIZ;


	--Comparador EQUIL: CMPEQUIL
	ISEQUIL <= '1' when RDATO(7 downto 0) = x"65" else '0';
	
	--Registro REQUIL
	REQUIL : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then EQUIL <= '0';
		elsif CLK'event and CLK='1' then
			if LD_EQUIL = '1' then EQUIL <= '1';
			elsif CL_SIGS = '1' then EQUIL <='0';
			end if;
		end if;
	end process REQUIL;
	
	
	--Comparador ROMBO: CMPROMBO
	ISROMBO <= '1' when RDATO(7 downto 0) = x"72" else '0';
	
	--Registro RROMBO
	RROMBO : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then ROMBO <= '0';
		elsif CLK'event and CLK='1' then
			if LD_ROMBO = '1' then ROMBO <= '1';
			elsif CL_SIGS = '1' then ROMBO <='0';
			end if;
		end if;
	end process RROMBO;
	
	
	--Comparador ROMBOIDE: CMPROMBOIDE
	ISROMBOIDE <= '1' when RDATO(7 downto 0) = x"52" else '0';
	
	--Registro RROMBOIDE
	RROMBOIDE : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then ROMBOIDE <= '0';
		elsif CLK'event and CLK='1' then
			if LD_ROMBOIDE = '1' then ROMBOIDE <= '1';
			elsif CL_SIGS = '1' then ROMBOIDE <='0';
			end if;
		end if;
	end process RROMBOIDE;
	
	
	--Comparador TRAP: CMPTRAP
	ISTRAP <= '1' when RDATO(7 downto 0) = x"74" else '0';
	
	--Registro RTRAP
	RTRAP : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then TRAP <= '0';
		elsif CLK'event and CLK='1' then
			if LD_TRAP = '1' then TRAP <= '1';
			elsif CL_SIGS = '1' then TRAP <='0';
			end if;
		end if;
	end process RTRAP;
	
	--Comparador TRIAN: CMPTRIAN
	ISTRIAN <= '1' when RDATO(7 downto 0) = x"54" else '0';
	
	--Registro RTRIAN
	RTRIAN : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then TRIAN <= '0';
		elsif CLK'event and CLK='1' then
			if LD_TRIAN = '1' then TRIAN <= '1';
			elsif CL_SIGS = '1' then TRIAN <='0';
			end if;
		end if;
	end process RTRIAN;
	

	--Comparador Ceros, para comprobar que es un codigo de color
	ISCOLOUR <= '1' when RDATO(7 downto 3) = "00110" else '0';
	
	--Registro COLOUR_CODE
	RCOLOUR : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then COLOUR_CODE <= (others => '0');
		elsif CLK'event and CLK='1' then
			if LD_COLOUR = '1' then COLOUR_CODE <= std_logic_vector(RDATO(2 downto 0));
			end if;
		end if;
	end process RCOLOUR;
	
	 --Registro DAT
	RDAT : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then RDATO <= (others => '0');
		elsif CLK'event and CLK='1' then
			if LD_DAT = '1' then RDATO <= DAT;
			end if;
		end if;
	end process RDAT;

end arq_uart_ctrl; 
