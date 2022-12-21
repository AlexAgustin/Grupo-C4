----------------------
-- fichero uart.vhd --
----------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity uart is
	port(
		CLK, RESET_L: in std_logic;
		Rx: in std_logic;
		VEL: in std_logic_vector(1 downto 0);
		RTS,DONE_ORDER: in std_logic;
		LED,DRAW_FIG,DEL_SCREEN, DIAG, VERT: out std_logic;--CTS,
		COLOUR_CODE: out std_logic_vector(2 downto 0)
	);
end uart;


architecture arq_uart of uart is

	-- DeclaraciÃÂ³n de estados
	type estados is (WTDATA, STARTBIT, LDDATA, ADDLEFT, PREWAIT, WAITDATA, PARITYBIT, WAITPARITY, SIGNALS, USEDATA, 
			WAITEND1, WAITEND2, WAITERR,WTORDER); --WTRTS, 
	signal EP, ES : estados;

	-- Declaracion de senales de control
	signal LD_DATO, LD_WAIT, LD_ITE, LD_DRECV, LD_FIG, LD_DEL, LD_VERT, LD_DIAG, LD_COLOUR, DEC_WAIT, DEC_ITE, LD_OP, CL_OP, CL_DATO, LFT, PRELEFT: std_logic := '0';
	signal WAITED, ALL_ITE, STOP, OK: std_logic :='0';
	signal PARITY, RPARITY: std_logic; --, DOWN_CTS, UP_CTS
	signal DATARECV: unsigned (7 downto 0);
	signal ISCOLOUR,ISDEL,ISFIG, ISVERT, ISDIAG, CL_SIGS: std_logic;

	signal cnt_CITE: unsigned(3 downto 0);
	signal cnt_CWAIT: unsigned(12 downto 0);
	signal RDATO: unsigned(7 downto 0);
	signal OP: unsigned(1 downto 0);
	signal WAITC: unsigned (12 downto 0);

	begin

	-- #######################
	-- ## UNIDAD DE CONTROL ## 
	-- #######################

	-- TransiciÃÂ³n de estados (cÃÂ¡lculo de estado siguiente)
	SWSTATE: process (EP, RTS, Rx, WAITED, ALL_ITE, STOP, OK, DONE_ORDER, ISCOLOUR) begin
		case EP is
 			--when WTRTS => 			if RTS='1' then ES<=WTDATA;
			--								else ES<=WTRTS;
			--								end if;

			when WTDATA =>			if Rx='0' then ES<=STARTBIT;
											else ES<=WTDATA;
											end if;

			when STARTBIT =>		if WAITED='1' then ES<=LDDATA;
											else ES<=STARTBIT;
											end if;

			when LDDATA =>			ES<=ADDLEFT;

			when ADDLEFT =>		ES<=PREWAIT;

			when PREWAIT =>		ES<=WAITDATA;

			when WAITDATA =>		if WAITED='0' then ES<=WAITDATA;
											elsif WAITED='1' and ALL_ITE='0' then ES<=LDDATA;
											else ES<=PARITYBIT;
											end if;

			when PARITYBIT =>		ES<=WAITPARITY;

			when WAITPARITY =>	if WAITED='0' then ES<=WAITPARITY;
											else ES<=USEDATA;
											end if;

			

			when USEDATA =>		ES<=WAITEND1;

			when WAITEND1 =>		if WAITED='0' then ES<=WAITEND1;
											else ES<=WAITEND2;
											end if;

			when WAITEND2 =>		if WAITED='0' then ES<=WAITEND2;
											elsif WAITED='1' and STOP='0' then ES<=WAITERR;
											else ES<=SIGNALS;
											end if;

			when SIGNALS =>		if ISCOLOUR='1' then ES<=WTDATA;
											else ES<=WTORDER;
											end if;
	
			when WTORDER =>		if DONE_ORDER='1' then ES<=WTDATA;
											else ES<=WTORDER;
											end if;

			when WAITERR =>		if WAITED='0' then ES<=WAITERR;
											else ES<=WTDATA;
											end if;
	
			when others =>  		ES <= WTDATA; -- inalcanzable
		end case;
	end process SWSTATE;



	-- Actualizacion de EP en cada flanco de reloj (sequential)
	SEQ: process (CLK, RESET_L) begin
		if RESET_L = '0' then EP <= WTDATA; -- reset asincrono
		elsif CLK'event and CLK = '1'  -- flanco de reloj
			then EP <= ES;             -- Estado Presente = Estado Siguiente
		end if;
	end process SEQ;


	
	-- Activacion de signals de control: asignaciones combinacionales

	--UP_CTS	<= '1' when EP=WTRTS and RTS='1' else '0';

	LD_WAIT <= '1' when (EP=WTDATA and Rx='0') or EP=PREWAIT or EP=USEDATA or (EP=WAITEND1 and WAITED='1') or (EP=WAITEND2 and WAITED='1' and STOP='0') OR EP=PARITYBIT else '0';

	DEC_WAIT<= '1' when EP=STARTBIT or EP=WAITDATA or EP=WAITEND1 or EP=WAITEND2 or EP=WAITERR OR EP=WAITPARITY else '0';
	LD_ITE	<= '1' when EP=STARTBIT and WAITED='1' else '0';
	LD_DATO	<= '1' when EP=LDDATA or EP=USEDATA or (EP=WAITEND1 and WAITED='1') OR EP=PARITYBIT else '0';
	LD_OP	<= '1' when EP=ADDLEFT else '0';
	CL_OP	<= '1' when EP=PREWAIT else '0';
	DEC_ITE	<= '1' when EP=WAITDATA and WAITED='1' and ALL_ITE='0' else '0';
	LD_DRECV<= '1' when EP=WAITPARITY and WAITED='1' and OK='1' else '0';
	CL_DATO	<= '1' when EP=WAITPARITY and WAITED='1' and OK='0' else '0';
	LED	<= '1' when EP=WAITERR else '0';
	LD_COLOUR<= '1' when EP=SIGNALS and ISCOLOUR='1' else '0';
	LD_FIG	<= '1' when EP=SIGNALS and ISCOLOUR='0' and ISFIG='1' else '0';
	LD_DEL	<= '1' when EP=SIGNALS and ISCOLOUR='0' and ISFIG='0' and ISDEL='1' else '0';
	LD_VERT	<= '1' when EP=SIGNALS and ISCOLOUR='0' and ISFIG='0' and ISDEL='0' and ISVERT = '1' else '0';
	LD_DIAG	<= '1' when EP=SIGNALS and ISCOLOUR='0' and ISFIG='0' and ISDEL='0' and ISVERT = '0' and ISDIAG = '1' else '0';
	CL_SIGS	<= '1' when EP=WTORDER and DONE_ORDER='1' else '0';


	-- #######################
	-- ## UNIDAD DE PROCESO ##
	-- #######################
	
	-- REG PRELEFT: RPRELEFT
	RPRELEFT : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then PRELEFT <= '0';
		elsif CLK'event and CLK='1' then
			if LD_DATO = '1' then PRELEFT <= Rx;
			end if;
		end if;
	end process RPRELEFT;

	-- REG LEFT: RLEFT
	RLEFT : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then LFT <= '0';
		elsif CLK'event and CLK='1' then
			if LD_DATO = '1' then LFT <= PRELEFT;
			end if;
		end if;
	end process RLEFT;

	-- REG OP: ROP
	ROP : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then OP <= "00";
		elsif CLK'event and CLK='1' then
			if LD_OP = '1' then OP <= "10";
			elsif CL_OP = '1' then OP <= "00";
			end if;
		end if;
	end process ROP;

	-- REG DESPLAZADOR: SUART
	SUART : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then RDATO <= (others => '0');
		elsif CLK'event and CLK='1' then
			if OP = "10" then RDATO <= LFT & RDATO(7 downto 1);
			elsif CL_DATO = '1' then RDATO <= (others =>'0');
			end if;
		end if;
	end process SUART;

	-- Contador ESPERA : CWAIT
	CWAIT : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then cnt_CWAIT <= (others =>'0'); WAITED <= '0';
		elsif CLK'event and CLK='1' then
			if LD_WAIT = '1' then
				cnt_CWAIT <= WAITC;
				WAITED <= '0';
			elsif DEC_WAIT='1' and cnt_CWAIT="0000000000001" then 
				cnt_CWAIT<= cnt_CWAIT-1;
				WAITED <= '1';
			elsif DEC_WAIT='1' and cnt_CWAIT="0000000000000" then 
				cnt_CWAIT<= "1111111111111";
				WAITED <= '0';
			elsif DEC_WAIT = '1' then 
				cnt_CWAIT <= cnt_CWAIT - 1;
				WAITED <= '0';
			end if;
		end if;
	end process CWAIT;

	-- Contador  ITE: CITE
	CITE : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then cnt_CITE <= (others =>'0'); ALL_ITE <= '0';
		elsif CLK'event and CLK='1' then
			if LD_ITE = '1' then
				cnt_CITE <= "1000";
				ALL_ITE <= '0';
			elsif DEC_ITE='1' and cnt_CITE="0001" then 
				cnt_CITE<= cnt_CITE-1;
				ALL_ITE <= '1';
			elsif DEC_ITE='1' and cnt_CITE="0000" then 
				cnt_CITE<= "1111";
				ALL_ITE <= '0';
			elsif DEC_ITE = '1' then 
				cnt_CITE <= cnt_CITE - 1;
				ALL_ITE <= '0';
			end if;
		end if;
	end process CITE;

	--Comparador CMPSTOP
	STOP <= '1' when PRELEFT= '1' and LFT = '1' else
			'0';

	--Comparador CPARITY
	OK	<= '1' when RPARITY = LFT else '0';

	--Sumador
	PARITY	<= LFT xor RPARITY;

	--Registro REGPARITY
	REGPARITY : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then RPARITY <= '0';
		elsif CLK'event and CLK='1' then
			if LD_DATO = '1' then RPARITY <= PARITY;
			end if;
		end if;
	end process REGPARITY;

	--Multiplexor MUXWAIT
	WAITC	<= "1010001011001" when VEL = "00" else
		   "0010100010111" when VEL = "01" else
		   "0000110110011" when VEL = "10" else
		   "0000000110111";

	--Registro RCTS
	--RCTS : process(CLK, RESET_L)
	--begin
	--	if RESET_L = '0' then CTS <= '0';
	--	elsif CLK'event and CLK='1' then
	--		if UP_CTS = '1' then CTS <= '1';
			--elsif DOWN_CTS = '1' then CTS <='0';
	--		end if;
	--	end if;
	--end process RCTS;

	--Registro RDATA
	RDATA : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then DATARECV <= (others => '0');
		elsif CLK'event and CLK='1' then
			if LD_DRECV = '1' then DATARECV <= RDATO;
			elsif CL_DATO = '1' then DATARECV <= (others => '0');
			end if;
		end if;
	end process RDATA;

	--Comparador DEL_SCREEN
	ISDEL <= '1' when DATARECV = x"62" else '0';

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

	--Comparador DRAW_FIG
	ISFIG <= '1' when DATARECV = x"66" else '0';

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
	ISVERT <= '1' when DATARECV = x"76" else '0';
	
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
	ISDIAG <= '1' when DATARECV = x"64" else '0';
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

	--Comparador Ceros, para comprobar que es un codigo de color
	ISCOLOUR <= '1' when DATARECV(7 downto 3) = "00110" else '0';
	
	--Registro COLOUR_CODE
	RCOLOUR : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then COLOUR_CODE <= (others => '0');
		elsif CLK'event and CLK='1' then
			if LD_COLOUR = '1' then COLOUR_CODE <= std_logic_vector(DATARECV(2 downto 0));
			end if;
		end if;
	end process RCOLOUR;

end arq_uart; 
