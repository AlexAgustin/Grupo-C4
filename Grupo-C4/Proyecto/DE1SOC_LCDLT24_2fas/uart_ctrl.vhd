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
		DONE_OP,DRAW_FIG,DEL_SCREEN, DIAG, VERT, HORIZ, EQUIL, ROMBO, ROMBOIDE, TRAP: out std_logic;
		COLOUR_CODE: out std_logic_vector(2 downto 0)
	);
end uart_ctrl;


architecture arq_uart_ctrl of uart_ctrl is

	-- Declaracion de estados
	type estados is (INICIO, SIGNALS, WTORDER, SNDONE); 
	signal EP, ES : estados;

	-- Declaracion de senales de control
	signal LD_FIG, LD_DEL, LD_COLOUR, LD_DIAG, LD_VERT, LD_HORIZ, LD_ROMBO, LD_EQUIL, LD_ROMBOIDE, LD_TRAP, LD_DAT: std_logic := '0';
	signal CL_SIGS: std_logic := '0';
	signal ISVERT, ISDEL, ISFIG, ISCOLOUR, ISDIAG, ISHORIZ, ISEQUIL, ISROMBO, ISROMBOIDE, ISTRAP: std_logic :='0';
	signal RDATO: std_logic_vector(7 downto 0);

	begin

	-- #######################
	-- ## UNIDAD DE CONTROL ## 
	-- #######################

	-- Transicion de estados (calculo de estado siguiente)
	SWSTATE: process (EP, ISCOLOUR, ISDIAG, ISVERT, ISFIG, ISDEL, ISHORIZ, ISEQUIL, ISROMBO, ISROMBOIDE, ISTRAP, DONE_ORDER, NEWOP) begin
		case EP is
			when INICIO =>		if NEWOP='1' then ES<=SIGNALS;
									else ES<=INICIO;
									end if;

			when SIGNALS =>		if ISCOLOUR='1' then ES<=SNDONE;
									elsif ISCOLOUR = '0' and ISFIG = '0' and ISDEL = '0' and ISVERT = '0' and ISDIAG = '0' and ISHORIZ = '0' and ISEQUIL = '0' and ISROMBO = '0' and ISROMBOIDE = '0' and ISTRAP = '0' then ES <=SNDONE;
									else ES<=WTORDER;
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

	--UP_CTS	<= '1' when EP=WTRTS and RTS='1' else '0';

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
