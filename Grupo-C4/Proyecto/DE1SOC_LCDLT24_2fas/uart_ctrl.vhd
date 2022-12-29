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
		DONE_OP,DRAW_FIG,DEL_SCREEN, DIAG, VERT, HORIZ, EQUIL, ROMBO, ROMBOIDE, TRAP, TRIAN, LED_POS, LED_SIG,DEFAULT: out std_logic;
		COLOUR_CODE: out std_logic_vector(2 downto 0);
		UART_XCOL: out std_logic_vector(7 downto 0);
		UART_YROW: out std_logic_vector(8 downto 0)
	);
end uart_ctrl;


architecture arq_uart_ctrl of uart_ctrl is

	-- Declaracion de estados
	type estados is (INICIO, SIGNALS, LDLEDSIG, WTLEDSIG, FORMINGXCOL, WTNOOPX, WTXBIT, FORMINGYROW, WTNOOPY, WTNOOPDEF, WTYBIT, LDLEDPOS, WTLEDPOS, WTORDER, SNDONE, LDDATX, LDDATY); 
	signal EP, ES : estados;

	-- Declaracion de senales de control
	signal LD_FIG, LD_DEL, LD_COLOUR, LD_DIAG, LD_VERT, LD_HORIZ, LD_ROMBO, LD_EQUIL, LD_ROMBOIDE, LD_TRAP, LD_TRIAN, LD_LENX, LD_LENY, LD_XCOL, LD_YROW: std_logic := '0';
	signal ISVERT, ISDEL, ISFIG, ISCOLOUR, ISDIAG, ISHORIZ, ISEQUIL, ISROMBO, ISROMBOIDE, ISTRAP, ISTRIAN, ISX, ISY: std_logic :='0';

	signal LD_LEDSIG, DEC_LEDSIG, DONE_LEDSIG, CL_LEDSIG: std_logic := '0';
	signal LD_LEDPOS, DEC_LEDPOS, DONE_LEDPOS, CL_LEDPOS: std_logic := '0';
	signal DEC_LENX, DEC_LENY, DONE_X, DONE_Y, ISDEF, LD_DEF, CL_DEF, ISa0, ISa1, XBIT, YBIT: std_logic := '0';
	signal CL_SIGS, LD_DAT : std_logic := '0'; --CL_DAT
	signal RDATO: std_logic_vector(7 downto 0);

	signal OPX: std_logic_vector(1 downto 0);
	
	signal OPY: std_logic_vector(1 downto 0);

	signal cnt_LENX: unsigned (3 downto 0);
	signal cnt_LENY: unsigned (3 downto 0);
	signal cnt_LEDPOS: unsigned (26 downto 0);
	signal cnt_LEDSIG: unsigned (26 downto 0);
	
	signal UART_XCOL_buf :  std_logic_vector(7 downto 0);
	signal UART_YROW_buf :  std_logic_vector(8 downto 0);
	begin

	-- #######################
	-- ## UNIDAD DE CONTROL ## 
	-- #######################

	-- Transicion de estados (calculo de estado siguiente)
	SWSTATE: process (EP, ISCOLOUR, ISDIAG, ISVERT, ISFIG, ISDEL, ISHORIZ, ISEQUIL, ISROMBO, ISROMBOIDE, ISTRAP, ISTRIAN, ISX, ISY, ISDEF, DONE_X, DONE_Y, ISa0, ISa1, DONE_LEDPOS, DONE_LEDSIG, DONE_ORDER, NEWOP) begin
		case EP is
			when INICIO =>		if NEWOP='1' then ES<=SIGNALS;
									else ES<=INICIO;
									end if;

			when SIGNALS =>		if ISCOLOUR='1' then ES<=SNDONE;
									elsif ISCOLOUR = '0' and ISFIG = '0' and ISDEL = '0' and ISVERT = '0' and ISDIAG = '0' and ISHORIZ = '0' and ISEQUIL = '0' and ISROMBO = '0' and ISROMBOIDE = '0' and ISTRAP = '0' and ISTRIAN = '0'  and ISX = '0' and  ISY = '0' then ES <=LDLEDSIG;
									elsif ISCOLOUR = '0' and ISFIG = '0' and ISDEL = '0' and ISVERT = '0' and ISDIAG = '0' and ISHORIZ = '0' and ISEQUIL = '0' and ISROMBO = '0' and ISROMBOIDE = '0' and ISTRAP = '0' and ISTRIAN = '0'  and ISX = '1' then ES <=FORMINGXCOL;
									elsif ISCOLOUR = '0' and ISFIG = '0' and ISDEL = '0' and ISVERT = '0' and ISDIAG = '0' and ISHORIZ = '0' and ISEQUIL = '0' and ISROMBO = '0' and ISROMBOIDE = '0' and ISTRAP = '0' and ISTRIAN = '0'  and ISX = '0' and  ISY = '1' then ES <=FORMINGYROW;
									else ES<=WTORDER;
									end if; 
			when LDLEDSIG =>	ES <= WTLEDSIG;
			when WTLEDSIG =>	if DONE_LEDSIG = '1' then ES <= INICIO;
									else ES <= WTLEDSIG;
									end if;
									
			when FORMINGXCOL =>	if DONE_X = '1' then ES <= INICIO;
									else ES <= WTNOOPX;
									end if;
									
			when WTNOOPX =>	if NEWOP='1' then ES <= WTNOOPX;
									else ES <= WTXBIT;
									end if;
									
			when WTXBIT =>		if NEWOP = '0' then ES <= WTXBIT;
									else ES<=LDDATX;
									end if;

			when LDDATX =>		if ISDEF = '1' then ES <= WTNOOPDEF;
									elsif ISDEF='0' and  ISa0 = '1' then ES <= FORMINGXCOL;
									elsif ISDEF='0' and  ISa0 = '0' and ISa1 = '1' then ES <= FORMINGXCOL;
									else ES <= LDLEDPOS;
									end if;

			when WTNOOPDEF =>	if NEWOP='1' then ES<=WTNOOPDEF;
						else ES<=INICIO;
						end if;
									
			when FORMINGYROW =>	if DONE_Y = '1' then ES <= INICIO;
									else ES <= WTNOOPY;
									end if;
									
			when WTNOOPY =>	if NEWOP='1' then ES <= WTNOOPY;
									else ES <= WTYBIT;
									end if;		
									
			when WTYBIT =>		if NEWOP = '0' then ES <= WTYBIT;
									else ES<=LDDATY;
									end if;

			when LDDATY =>		if ISDEF = '1' then ES <= WTNOOPDEF;
									elsif ISDEF='0' and  ISa0 = '1' then ES <= FORMINGYROW;
									elsif ISDEF='0' and  ISa0 = '0' and ISa1 = '1' then ES <= FORMINGYROW;
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
	LD_DAT <= '1' when (EP=INICIO and NEWOP = '1') or (EP=WTXBIT and NEWOP='1') or (EP=WTYBIT and NEWOP='1') else '0';
	LD_COLOUR<= '1' when EP=SIGNALS and ISCOLOUR='1' else '0';
	LD_FIG	<= '1' when EP=SIGNALS and ISCOLOUR='0' and ISFIG='1' else '0';
	LD_DEL	<= '1' when EP=SIGNALS and ISCOLOUR='0' and ISFIG='0' and ISDEL='1' else '0';
	LD_VERT	<= '1' when EP=SIGNALS and ISCOLOUR='0' and ISFIG='0' and ISDEL='0' and ISVERT = '1' else '0';
	LD_DIAG	<= '1' when EP=SIGNALS and ISCOLOUR='0' and ISFIG='0' and ISDEL='0' and ISVERT = '0' and ISDIAG = '1' else '0';
	LD_HORIZ<= '1' when EP=SIGNALS and ISCOLOUR='0' and ISFIG='0' and ISDEL='0' and ISVERT = '0' and ISDIAG = '0' and ISHORIZ='1' else '0';
	LD_EQUIL<= '1' when EP=SIGNALS and ISCOLOUR='0' and ISFIG='0' and ISDEL='0' and ISVERT = '0' and ISDIAG = '0' and ISHORIZ='0' and ISEQUIL = '1'  else '0';
	LD_ROMBO<= '1' when EP=SIGNALS and ISCOLOUR='0' and ISFIG='0' and ISDEL='0' and ISVERT = '0' and ISDIAG = '0' and ISHORIZ='0' and ISEQUIL = '0' and ISROMBO = '1'  else '0';
	LD_ROMBOIDE<= '1' when EP=SIGNALS and ISCOLOUR='0' and ISFIG='0' and ISDEL='0' and ISVERT = '0' and ISDIAG = '0' and ISHORIZ='0' and ISEQUIL = '0' and ISROMBO = '0' and ISROMBOIDE = '1'  else '0';
	LD_TRAP	<= '1' when EP=SIGNALS and ISCOLOUR='0' and ISFIG='0' and ISDEL='0' and ISVERT = '0' and ISDIAG = '0' and ISHORIZ='0' and ISEQUIL = '0' and ISROMBO = '0' and ISROMBOIDE = '0' and ISTRAP = '1'  else '0';
	LD_TRIAN<= '1' when EP=SIGNALS and ISCOLOUR='0' and ISFIG='0' and ISDEL='0' and ISVERT = '0' and ISDIAG = '0' and ISHORIZ='0' and ISEQUIL = '0' and ISROMBO = '0' and ISROMBOIDE = '0' and ISTRAP = '0' and ISTRIAN = '1'  else '0';
	CL_SIGS	<= '1' when EP=WTORDER and DONE_ORDER='1' else '0';
	DONE_OP	<='1' when EP=SNDONE or EP=FORMINGXCOL or EP=FORMINGYROW or (EP=WTLEDPOS and DONE_LEDPOS='1') or (EP=WTLEDSIG and DONE_LEDSIG='1') else '0';
	LD_LENX	<='1' when EP=SIGNALS and ISCOLOUR='0' and ISFIG='0' and ISDEL='0' and ISVERT = '0' and ISDIAG = '0' and ISHORIZ='0' and ISEQUIL = '0' and ISROMBO = '0' and ISROMBOIDE = '0' and ISTRAP = '0' and ISTRIAN = '0'  and ISX='1' else '0';
	LD_LENY	<='1' when EP=SIGNALS and ISCOLOUR='0' and ISFIG='0' and ISDEL='0' and ISVERT = '0' and ISDIAG = '0' and ISHORIZ='0' and ISEQUIL = '0' and ISROMBO = '0' and ISROMBOIDE = '0' and ISTRAP = '0' and ISTRIAN = '0'  and ISX='0' and ISY='1' else '0';
	DEC_LENX<='1' when (EP=LDDATX and ISDEF='0' and ISa0='1') or (EP=LDDATX and ISDEF='0' and ISa0='0' and ISa1='1') else '0';
	DEC_LENY<='1' when EP=FORMINGYROW else '0';
	LD_DEF	<='1' when (EP=WTXBIT and NEWOP='1' and ISDEF='1') or (EP=WTYBIT and NEWOP='1' and ISDEF='1') else '0';
	CL_DEF	<='1' when (EP=WTXBIT and NEWOP='1' and ISDEF='0') or (EP=WTYBIT and NEWOP='1' and ISDEF='0') else '0';
	OPX	<="10" when (EP=LDDATX and ISDEF='0' and ISa0='1') or (EP=LDDATX and ISDEF='0' and ISa0='0' and ISa1='1') else "00";
	XBIT	<='1' when EP=LDDATX and ISDEF='0' and ISa0='0' and ISa1='1' else '0';
	OPY	<="10" when (EP=LDDATY and ISDEF='0' and ISa0='1') or (EP=LDDATY and ISDEF='0' and ISa0='0' and ISa1='1') else "00";
	YBIT	<='1' when EP=LDDATY and ISDEF='0' and ISa0='0' and ISa1='1' else '0';
	LD_LEDPOS<='1' when EP=LDLEDPOS else '0';
	--LED_POS	<='1' when EP=WTLEDPOS else '0';
	DEC_LEDPOS<='1' when EP=WTLEDPOS else '0';
	CL_LEDPOS<='1' when EP=WTLEDPOS and DONE_LEDPOS='1' else '0';
	LD_LEDSIG<='1' when EP=LDLEDSIG else '0';
	--LED_SIG	<='1' when EP=WTLEDSIG else '0';
	DEC_LEDSIG<='1' when EP=WTLEDSIG else '0';
	CL_LEDSIG<='1' when EP=WTLEDSIG and DONE_LEDSIG='1' else '0';
	LD_XCOL	<='1' when EP=FORMINGXCOL and DONE_X='1' else '0';
	LD_YROW	<='1' when EP=FORMINGYROW and DONE_Y='1' else '0';



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

	--Comparador X: CMPX
	ISX <= '1' when RDATO = x"78" else '0';

	--Comparador Y: CMPY
	ISY <= '1' when RDATO = x"79" else '0';

	--Comparador 0: CMPCERO
	ISa0 <= '1' when RDATO = x"30" else '0';

	--Comparador 1: CMPUNO
	ISa1 <= '1' when RDATO = x"31" else '0';

	--Comparador d: CMPDEF
	ISDEF <= '1' when RDATO = x"44" else '0';
	
	
	-- REG DESPLAZADOR: SXCOL
	SXCOL : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then UART_XCOL_buf <= (others => '0');
		elsif CLK'event and CLK='1' then
			if OPX = "10" then UART_XCOL_buf <= UART_XCOL_buf(6 downto 0) & XBIT;
			elsif OPX="00" then UART_XCOL_buf <= UART_XCOL_buf;
			end if;
		end if;

	end process SXCOL;
	
	--Registro UART_XCOL_buf
	RUARTXCOL : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then UART_XCOL <= (others => '0');
		elsif CLK'event and CLK='1' then
			if LD_XCOL = '1' then UART_XCOL <= UART_XCOL_buf;
			end if;
		end if;
	end process RUARTXCOL;

	-- Contador  CLENX: CLENX
	CLENX : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then cnt_LENX <= (others =>'0'); DONE_X <= '0';
		elsif CLK'event and CLK='1' then
			if LD_LENX = '1' then
				cnt_LENX <= "1000";
				DONE_X <= '0';
			elsif DEC_LENX='1' and cnt_LENX="0001" then 
				cnt_LENX<= cnt_LENX-1;
				DONE_X <= '1';
			elsif DEC_LENX='1' and cnt_LENX="0000" then
				cnt_LENX<= "1111";
				DONE_X <= '0';
			elsif DEC_LENX = '1' then 
				cnt_LENX <= cnt_LENX - 1;
				DONE_X <= '0';
			end if;
		end if;
	end process CLENX;	
	
	
	-- REG DESPLAZADOR: SYROW
	SYROW : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then UART_YROW_buf <= (others => '0');
		elsif CLK'event and CLK='1' then
			if OPY = "10" then UART_YROW_buf <= UART_YROW_buf(7 downto 0) & YBIT;
			elsif OPY="00" then UART_YROW_buf <= UART_YROW_buf;
			end if;
		end if;
	end process SYROW;
	
	--Registro UART_YROW_buf
	RUARTYROW : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then UART_YROW <= (others => '0');
		elsif CLK'event and CLK='1' then
			if LD_YROW = '1' then UART_YROW <= UART_YROW_buf;
			end if;
		end if;
	end process RUARTYROW;
	
	-- Contador  CLENY: CLENY
	CLENY : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then cnt_LENY <= (others =>'0'); DONE_Y <= '0';
		elsif CLK'event and CLK='1' then
			if LD_LENY = '1' then
				cnt_LENY <= "1001";
				DONE_Y <= '0';
			elsif DEC_LENY='1' and cnt_LENY="0001" then 
				cnt_LENY<= cnt_LENY-1;
				DONE_Y <= '1';
			elsif DEC_LENY='1' and cnt_LENY="0000" then
				cnt_LENY<= "1111";
				DONE_Y <= '0';
			elsif DEC_LENY = '1' then 
				cnt_LENY <= cnt_LENY - 1;
				DONE_Y <= '0';
			end if;
		end if;
	end process CLENY;		
	
	--Registro DEFAULT
	RDEF : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then DEFAULT <= '0';
		elsif CLK'event and CLK='1' then
			if LD_DEF = '1' then DEFAULT <= '1';
			elsif CL_DEF = '1' then DEFAULT <= '0';
			end if;
		end if;
	end process RDEF;



	-- Contador  LEDPOS: CLEDPOS
	CLEDPOS : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then cnt_LEDPOS <= (others =>'0'); DONE_LEDPOS <= '0';
		elsif CLK'event and CLK='1' then
			if LD_LEDPOS = '1' then
				cnt_LEDPOS <= "101111101011110000100000000";
				DONE_LEDPOS <= '0';
			elsif CL_LEDPOS='1' then 
				cnt_LEDPOS<=(others=>'0');
				DONE_LEDPOS <= '0';
			elsif DEC_LEDPOS='1' and cnt_LEDPOS="00000000000000000000000001" then 
				cnt_LEDPOS<= cnt_LEDPOS-1;
				DONE_LEDPOS <= '1';
			elsif DEC_LEDPOS='1' and cnt_LEDPOS="00000000000000000000000000" then
				cnt_LEDPOS<= "111111111111111111111111111";
				DONE_LEDPOS <= '0';
			elsif DEC_LEDPOS = '1' then 
				cnt_LEDPOS <= cnt_LEDPOS - 1;
				DONE_LEDPOS <= '0';
			end if;
		end if;
	end process CLEDPOS;

	--Registro LEDPOS: RLEDPOS
	RLEDPOS : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then LED_POS <= '0';
		elsif CLK'event and CLK='1' then
			if LD_LEDPOS = '1' then LED_POS <= '1';
			elsif CL_LEDPOS = '1' then LED_POS <='0';
			end if;
		end if;
	end process RLEDPOS;

	-- Contador  LEDSIG: CLEDSIG
	CLEDSIG : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then cnt_LEDSIG <= (others =>'0'); DONE_LEDSIG <= '0';
		elsif CLK'event and CLK='1' then
			if LD_LEDSIG = '1' then
				cnt_LEDSIG <= "101111101011110000100000000";
				DONE_LEDSIG <= '0';
			elsif CL_LEDSIG='1' then 
				cnt_LEDSIG<=(others=>'0');
				DONE_LEDSIG <= '0';
			elsif DEC_LEDSIG='1' and cnt_LEDSIG="00000000000000000000000001" then 
				cnt_LEDSIG<= cnt_LEDSIG-1;
				DONE_LEDSIG <= '1';
			elsif DEC_LEDSIG='1' and cnt_LEDSIG="00000000000000000000000000" then
				cnt_LEDSIG<= "111111111111111111111111111";
				DONE_LEDSIG <= '0';
			elsif DEC_LEDSIG = '1' then 
				cnt_LEDSIG <= cnt_LEDSIG - 1;
				DONE_LEDSIG <= '0';
			end if;
		end if;
	end process CLEDSIG;

	--Registro LEDSIG: RLEDSIG
	RLEDSIG : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then LED_SIG <= '0';
		elsif CLK'event and CLK='1' then
			if LD_LEDSIG = '1' then LED_SIG <= '1';
			elsif CL_LEDSIG = '1' then LED_SIG <='0';
			end if;
		end if;
	end process RLEDSIG;

end arq_uart_ctrl; 
