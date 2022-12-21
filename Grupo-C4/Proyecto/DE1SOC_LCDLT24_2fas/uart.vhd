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
		DONE_ORDER: in std_logic;--RTS,
		LED,DRAW_FIG,DEL_SCREEN, DIAG, VERT: out std_logic;--CTS,
		COLOUR_CODE: out std_logic_vector(2 downto 0)
	);
end uart;


architecture arq_uart of uart is

	-- DeclaraciÃÂ³n de estados
	type estados is (WTTRAMA, MIDVEL, LDDATA, ADDLEFT, PREWAIT, WTDATA, PRELED, WTLED, SIGNALS, WTORDER); 
	signal EP, ES : estados;

	-- Declaracion de senales de control
	signal LD_DATO, LD_WAIT, LD_ITE, LD_DRECV, LD_FIG, LD_DEL, LD_VERT, LD_DIAG, LD_COLOUR, LD_PARITY, DEC_WAIT, DEC_ITE, LD_OP, CL_OP, CL_DATO, LFT, PRELEFT: std_logic := '0';
	signal WAITED, ALL_ITE, STOP, OK: std_logic :='0';
	signal PARITY, RPARITY: std_logic; --, DOWN_CTS, UP_CTS
	signal ISCOLOUR,ISDEL,ISFIG, ISVERT, ISDIAG, CL_SIGS: std_logic;
	signal DONE_LED, LD_LED, DEC_LED, CL_LED, SEL, OKEND, OKSTART: std_logic;

	signal cnt_CITE: unsigned(3 downto 0);
	signal cnt_CWAIT: unsigned(12 downto 0);
	signal cnt_LED: unsigned (26 downto 0);
	signal RDATO: std_logic_vector(10 downto 0);
	signal OP: unsigned(1 downto 0);
	signal WAITC1, WAITC2, WAITCNT: unsigned (12 downto 0);

	begin

	-- #######################
	-- ## UNIDAD DE CONTROL ## 
	-- #######################

	-- TransiciÃÂ³n de estados (cÃÂ¡lculo de estado siguiente)
	SWSTATE: process (EP, Rx, WAITED, ALL_ITE, OK, DONE_ORDER, ISCOLOUR, DONE_LED) begin --, RTS
		case EP is
			when WTTRAMA =>			if Rx='0' then ES<=MIDVEL;
											else ES<=WTTRAMA;
											end if;

			when MIDVEL =>			if WAITED='1' then ES<=LDDATA;
											else ES<=MIDVEL;
											end if; 

			when LDDATA =>			ES<=ADDLEFT;

			when ADDLEFT =>			ES<=PREWAIT;

			when PREWAIT =>			ES<=WTDATA;

			when WTDATA =>		if WAITED='0' then ES<=WTDATA;
											elsif WAITED='1' and ALL_ITE='0' then ES<=LDDATA;
											elsif WAITED='1' and ALL_ITE='1' and OK='0' then ES<=PRELED;
											else ES<=SIGNALS;
											end if;

			when PRELED =>			ES<=WTLED;

			when WTLED =>			if DONE_LED='1' then ES<=WTTRAMA;
											else ES<=WTLED;
											end if;

			when SIGNALS =>			if ISCOLOUR='1' then ES<=WTTRAMA;
											else ES<=WTORDER;
											end if;
	
			when WTORDER =>			if DONE_ORDER='1' then ES<=WTTRAMA;
											else ES<=WTORDER;
											end if;
	
			when others =>  		ES <= WTTRAMA; -- inalcanzable
		end case;
	end process SWSTATE;



	-- Actualizacion de EP en cada flanco de reloj (sequential)
	SEQ: process (CLK, RESET_L) begin
		if RESET_L = '0' then EP <= WTTRAMA; -- reset asincrono
		elsif CLK'event and CLK = '1'  -- flanco de reloj
			then EP <= ES;             -- Estado Presente = Estado Siguiente
		end if;
	end process SEQ;


	
	-- Activacion de signals de control: asignaciones combinacionales

	--UP_CTS	<= '1' when EP=WTRTS and RTS='1' else '0';

	LD_WAIT <= '1' when (EP=WTTRAMA and Rx='1') or (EP=PREWAIT) else '0';
	DEC_WAIT<= '1' when EP=MIDVEL or EP=WTDATA else '0';
	LD_ITE	<= '1' when EP=MIDVEL and WAITED='1' else '0';
	LD_DATO	<= '1' when EP=LDDATA else '0';
	LD_OP	<= '1' when EP=ADDLEFT else '0';
	CL_OP	<= '1' when EP=PREWAIT else '0';
	DEC_ITE	<= '1' when EP=WTDATA and WAITED='1' and ALL_ITE='0' else '0';
	CL_DATO	<= '1' when (EP=WTTRAMA and Rx='0') else '0';
	LED	<= '1' when EP=WTLED else '0';
	LD_COLOUR<= '1' when EP=SIGNALS and ISCOLOUR='1' else '0';
	LD_FIG	<= '1' when EP=SIGNALS and ISCOLOUR='0' and ISFIG='1' else '0';
	LD_DEL	<= '1' when EP=SIGNALS and ISCOLOUR='0' and ISFIG='0' and ISDEL='1' else '0';
	LD_VERT	<= '1' when EP=SIGNALS and ISCOLOUR='0' and ISFIG='0' and ISDEL='0' and ISVERT = '1' else '0';
	LD_DIAG	<= '1' when EP=SIGNALS and ISCOLOUR='0' and ISFIG='0' and ISDEL='0' and ISVERT = '0' and ISDIAG = '1' else '0';
	CL_SIGS	<= '1' when EP=WTORDER and DONE_ORDER='1' else '0';
	LD_LED	<= '1' when EP=PRELED else '0';
	DEC_LED	<= '1' when EP=WTLED else '0';
	CL_LED	<=	'1' when EP=WTLED and DONE_LED = '1' else '0';
	--LD_PARITY<= '1' when EP=ADDLEFT else '0';


	-- #######################
	-- ## UNIDAD DE PROCESO ##
	-- #######################
	
	-- REG LEFT: RLEFT
	RLEFT : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then LFT <= '0';
		elsif CLK'event and CLK='1' then
			if LD_DATO = '1' then LFT <= PRELEFT;
			elsif CL_DATO='1' then LFT<='0';
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
			if OP = "10" then RDATO <= LFT & RDATO(10 downto 1);
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
				cnt_CWAIT <= WAITCNT;
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
				cnt_CITE <= "1011";
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

	-- Contador  LED: CLED
	CLED : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then cnt_LED <= (others =>'0'); DONE_LED <= '0';
		elsif CLK'event and CLK='1' then
			if LD_ITE = '1' then
				cnt_LED <= "101111101011110000100000000";
				DONE_LED <= '0';
			elsif CL_LED='1' then 
				cnt_LED<=(others=>'0');
				DONE_LED <= '0';
			elsif DEC_ITE='1' and cnt_LED="00000000000000000000000001" then 
				cnt_LED<= cnt_LED-1;
				DONE_LED <= '1';
			elsif DEC_ITE='1' and cnt_LED="00000000000000000000000001" then
				cnt_LED<= "111111111111111111111111111";
				DONE_LED <= '0';
			elsif DEC_ITE = '1' then 
				cnt_LED <= cnt_LED - 1;
				DONE_LED <= '0';
			end if;
		end if;
	end process CLED;


	--Multiplexor MUXWAIT1
	WAITC1	<= "1010001011001" when VEL = "00" else
		   "0010100010111" when VEL = "01" else
		   "0000110110011" when VEL = "10" else
		   "0000000110111";

	--Multiplexor MUXWAIT2
	WAITC2	<= "0101000101101" when VEL = "00" else
		   "0001010001100" when VEL = "01" else
		   "0000011011010" when VEL = "10" else
		   "0000000011100";

		--Multiplexor MUXSEL
	WAITCNT	<= WAITC1 when SEL = '0' else
		   WAITC2;

	--Comparador DEL_SCREEN
	ISDEL <= '1' when RDATO(8 downto 1) = x"62" else '0';

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
	ISFIG <= '1' when RDATO(8 downto 1) = x"66" else '0';

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
	ISVERT <= '1' when RDATO(8 downto 1) = x"76" else '0';
	
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
	ISDIAG <= '1' when RDATO(8 downto 1) = x"64" else '0';
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
	ISCOLOUR <= '1' when RDATO(8 downto 4) = "00110" else '0';
	
	--Registro COLOUR_CODE
	RCOLOUR : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then COLOUR_CODE <= (others => '0');
		elsif CLK'event and CLK='1' then
			if LD_COLOUR = '1' then COLOUR_CODE <= std_logic_vector(RDATO(3 downto 1));
			end if;
		end if;
	end process RCOLOUR;

	--Comparador CMPEND
	OKEND <= '1' when RDATO(10 downto 9)="11" else '0';

	--Comparador CMPSTART
	OKSTART <= '1' when RDATO(0 downto 0)="0" else '0';

	--Puerta AND para el OK
	OK <= '1' when OKEND='1' and OKSTART='1' else '0';
	
	 --Registro LED: RLED
	RLED : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then LED <= '0';
		elsif CLK'event and CLK='1' then
			if LD_LED = '1' then LED <= '1';
			elsif CL_LED = '1' then LED <='0';
			end if;
		end if;
	end process RLED;

end arq_uart; 
