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
		DONE_OP: in std_logic;
		DAT: out std_logic_vector(7 downto 0);
		LED,NEWOP: out std_logic
	);
end uart;


architecture arq_uart of uart is

	-- Declaracion de estados
	type estados is (WTTRAMA, WTVEL, LDDATA, ADDLEFT, ISOK, PRELED, WTLED, WTDONE); 
	signal EP, ES : estados;

	-- Declaracion de senales de control
	signal LD_LFT, LFT,		LD_LED, CL_LED,	LD_DAT, CL_DAT	: std_logic := '0';
	signal LD_ITE, DEC_ITE, ALL_ITE, 	DEC_LED, DONE_LED, 		LD_WAIT, DEC_WAIT, WAITED, 		SEL: std_logic := '0';
	signal OKEND, OKSTART, OK: std_logic := '0';
	signal RPARITY, OKPAR, DOPAR, PARITY, LD_PARITY : std_logic :='0';

	signal cnt_CITE: unsigned(3 downto 0);
	signal cnt_CWAIT: unsigned(12 downto 0);
	signal cnt_LED: unsigned (26 downto 0);
	signal RDATO: std_logic_vector(11 downto 0);
	signal WAITC1, WAITC2, WAITCNT: unsigned (12 downto 0);
	signal OP: std_logic_vector(1 downto 0);

	begin

	-- #######################
	-- ## UNIDAD DE CONTROL ## 
	-- #######################

	-- Transicion de estados (calculo de estado siguiente)
	SWSTATE: process (EP, Rx, WAITED, ALL_ITE, OK, DONE_OP, DONE_LED) begin
		case EP is
			when WTTRAMA =>			if Rx='0' then ES<=WTVEL;
								else ES<=WTTRAMA;
								end if;

			when WTVEL =>			if WAITED='1' then ES<=LDDATA;
								else ES<=WTVEL;
								end if; 

			when LDDATA =>			ES<=ADDLEFT;

			when ADDLEFT =>			if ALL_ITE = '0' then ES<=WTVEL;
								else ES<=ISOK;
								end if;
			when ISOK =>			if OK = '1' then ES <= WTDONE;
								else ES <= PRELED;
								end if;

			when PRELED =>			ES<=WTLED;

			when WTLED =>			if DONE_LED='1' then ES<=WTTRAMA;
								else ES<=WTLED;
								end if;

	
			when WTDONE =>			if DONE_OP='1' then ES<=WTTRAMA;
								else ES<=WTDONE;
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
	--LD_OP	<= '1' when EP=ADDLEFT else '0';
	--CL_OP	<= '1' when EP=PREWAIT else '0';
	--LD_PARITY<= '1' when EP=ADDLEFT else '0';

	LD_WAIT <= '1' when (EP=WTTRAMA and Rx='0') or (EP=ADDLEFT and ALL_ITE='0') else '0';
	LD_ITE	<= '1' when EP=WTTRAMA and Rx='0' else '0';
	LD_LFT	<= '1' when EP=LDDATA else '0';
	LD_DAT	<= '1' when EP=ISOK and OK='1' else '0';
	LD_LED	<= '1' when EP=PRELED else '0';
	OP	<= "10" when EP=ADDLEFT else "00";
	DEC_ITE	<= '1' when EP=LDDATA else '0';
	DEC_WAIT<= '1' when EP=WTVEL else '0';
	DEC_LED	<= '1' when EP=WTLED else '0';
	CL_DAT	<= '1' when EP=WTDONE and DONE_OP='1' else '0';
	CL_LED	<= '1' when EP=WTLED and DONE_LED = '1' else '0';
	SEL	<= '1' when EP=WTTRAMA and Rx='0' else '0';
	NEWOP	<= '1' when EP=WTDONE else '0';
	
	LD_PARITY <= '1' when EP=WTVEL and WAITED = '1' and DOPAR = '1' else '0';
	


	-- #######################
	-- ## UNIDAD DE PROCESO ##
	-- #######################
	
	-- REG LEFT: RLEFT
	RLEFT : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then LFT <= '0';
		elsif CLK'event and CLK='1' then
			if LD_LFT = '1' then LFT <= Rx;
			elsif CL_DAT='1' then LFT<='0';
			end if;
		end if;
	end process RLEFT;

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

	 --Registro DAT: RDAT
	RDAT : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then DAT <= (others=>'0');
		elsif CLK'event and CLK='1' then
			if LD_DAT = '1' then DAT <= RDATO(8 downto 1);
			elsif CL_DAT = '1' then DAT <=(others=>'0');
			end if;
		end if;
	end process RDAT;
	
	-- REG PARITY: RPAR
	RPAR : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then RPARITY <= '0';
		elsif CLK'event and CLK='1' then
			if LD_PARITY = '1' then RPARITY <= PARITY;
			end if;
		end if;
	end process RPAR;

	-- REG DESPLAZADOR: SUART
	SUART : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then RDATO <= (others => '0');
		elsif CLK'event and CLK='1' then
			if OP = "10" then RDATO <= LFT & RDATO(11 downto 1);
			elsif CL_DAT = '1' then RDATO <= (others =>'0');
			end if;
		end if;
	end process SUART;

	-- Contador  ITE: CITE
	CITE : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then cnt_CITE <= (others =>'0'); ALL_ITE <= '0';
		elsif CLK'event and CLK='1' then
			if LD_ITE = '1' then
				cnt_CITE <= "1100";
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

	--Multiplexor MUXWAIT1
	WAITC1	<= "1010001010111" when VEL = "00" else
		   "0010100010101" when VEL = "01" else
		   "0000110110001" when VEL = "10" else
		   "0000000110101";

	--Multiplexor MUXWAIT2
	WAITC2	<= "0101000101101" when VEL = "00" else
		   "0001010001100" when VEL = "01" else
		   "0000011011010" when VEL = "10" else
		   "0000000011100";


	--Multiplexor MUXSEL
	WAITCNT	<= WAITC1 when SEL = '0' else
		   WAITC2;

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

	-- Contador  LED: CLED
	CLED : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then cnt_LED <= (others =>'0'); DONE_LED <= '0';
		elsif CLK'event and CLK='1' then
			if LD_LED = '1' then
				cnt_LED <= "101111101011110000100000000";
				DONE_LED <= '0';
			elsif CL_LED='1' then 
				cnt_LED<=(others=>'0');
				DONE_LED <= '0';
			elsif DEC_LED='1' and cnt_LED="00000000000000000000000001" then 
				cnt_LED<= cnt_LED-1;
				DONE_LED <= '1';
			elsif DEC_LED='1' and cnt_LED="00000000000000000000000000" then
				cnt_LED<= "111111111111111111111111111";
				DONE_LED <= '0';
			elsif DEC_LED = '1' then 
				cnt_LED <= cnt_LED - 1;
				DONE_LED <= '0';
			end if;
		end if;
	end process CLED;

	--Comparador CMPEND
	OKEND <= '1' when RDATO(11 downto 10)="11" else '0';

	--Comparador CMPSTART
	OKSTART <= '1' when RDATO(0)='0' else '0';
	
	--Comparador CMPPAR
	OKPAR <= '1' when RDATO(9)=RPARITY else '0';
	
	--Comparador CMPDOPAR
	DOPAR <= '1' when cnt_CITE>"0011" else '0';

	--xor
	PARITY	<= LFT xor RPARITY;

	--Puerta AND para el OK
	OK <= '1' when OKEND='1' and OKSTART='1' and OKPAR = '1' else '0';

end arq_uart; 
