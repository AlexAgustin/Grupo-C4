----------------------
-- fichero uart.vhd --
----------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity uart is
	port(
		CLK, RESET_L: in std_logic;
	);
end uart;


architecture arq_uart of uart is

	-- DeclaraciÃÂ³n de estados
	type estados is (DAT1, WAITD1, DAT2, WAITD2, OP, CLOP, WAITOP, DAT3, WAIT3, ESTOP, WSTOP);
	signal EP, ES : estados;

	-- Declaracion de senales de control
	signal LD_DATO, LD_WAIT, DEC, LD_OP, CL_OP, LEFT, PRELEFT: std_logic := '0';
	signal WAITED, ALL, STOP;

	signal cnt_CITE: unsigned(3 downto 0);
	signal cnt_CWAIT: unsigned(12 downto 0);
	signal RDATO: unsigned(7 downto 0);
	signal OP: unsigned(1 downto 0);

	begin

	-- #######################
	-- ## UNIDAD DE CONTROL ## 
	-- #######################

	-- TransiciÃÂ³n de estados (cÃÂ¡lculo de estado siguiente)
	SWSTATE: process (EP, DEL_SCREEN, DRAW_FIG, DONE_CURSOR, DONE_COLOUR, ALL_PIX, HORIZ, VERT, DIAG, MIRROR, TRIAN, ISHORIZ, ISVERT, ISDIAG, ISTRIAN,ISMIRROR, NOTMIRROR) begin
		case EP is
			when DAT1 => 		if DEL_SCREEN = '1' then ES <= DELCURSOR;
								elsif (DRAW_FIG = '1' or HORIZ = '1' or VERT = '1' or DIAG = '1' or MIRROR = '1' or TRIAN = '1') then ES <= DRAWCURSOR;
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


	
	-- Activacion de signals de control: asignaciones combinacionales







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
		if RESET_L = '0' then LEFT <= '0';
		elsif CLK'event and CLK='1' then
			if LD_DATO = '1' then LEFT <= PRELEFT;
			end if;
		end if;
	end process RLEFT;

	-- REG OP: ROP
	ROP : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then OP <= "00";
		elsif CLK'event and CLK='1' then
			if LD_OP = '1' then OP <= "10";
			if CL_OP = '1' then OP <= "00";
			end if;
		end if;
	end process ROP;


	-- REG DESPLAZADOR: SUART
	SUART : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then RDATO <= '0';
		elsif CLK'event and CLK='1' then
			if OP = "10" then RDATO <= RDATO(6 down to 0) & LEFT;
			elif CL_DATO = '1' then RDATO <= (others =>'0')
			end if;
		end if;
	end process SUART;

	-- Contador ESPERA : CWAIT
	CWAIT : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then cnt_CWAIT <= (others =>'0'); WAITED <= '0';
		elsif CLK'event and CLK='1' then
			if LD_WAIT = '1' then
				cnt_CWAIT <= WAIT;
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

	--Comparador CMPLEFT
	STOP <= '1' when PRELEFT= '0' and LEFT = '0' else
			'0';

end arq_uart; 
