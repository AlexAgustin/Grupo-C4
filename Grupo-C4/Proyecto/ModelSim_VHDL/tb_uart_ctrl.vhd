
-------------------------
-- fichero tb_uart.vhd --
-------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_uart_ctrl is
end tb_uart_ctrl;

architecture arq_tb_uart_ctrl of tb_uart_ctrl is

	component uart_ctrl
	port(
		CLK, RESET_L: in std_logic;
		NEWOP, DONE_ORDER: in std_logic;
		DAT: in std_logic_vector(7 downto 0);
		DONE_OP,DRAW_FIG,DEL_SCREEN, DIAG, VERT: out std_logic;
		COLOUR_CODE: out std_logic_vector(2 downto 0)
	);
	end component;


	signal CLK : std_logic := '0';
	signal RESET_L : std_logic := '0';
	signal NEWOP: std_logic := '0';
	signal DONE_ORDER: std_logic := '0';
	signal DAT: std_logic_vector(7 downto 0) :="00000000";
	signal DONE_OP: std_logic := '0';
	signal DRAW_FIG: std_logic := '0';
	signal DEL_SCREEN: std_logic := '0';
	signal DIAG: std_logic := '0';
	signal VERT: std_logic := '0';
	signal COLOUR_CODE: std_logic_vector(2 downto 0) := "000";

	begin

	DUT: uart_ctrl port map(
		CLK=>CLK,
		RESET_L=>RESET_L,
		NEWOP=>NEWOP,
		DONE_ORDER=>DONE_ORDER,
		DAT=>DAT,
		DONE_OP=>DONE_OP,
		DRAW_FIG=>DRAW_FIG,
		DEL_SCREEN=>DEL_SCREEN,
		DIAG=>DIAG,
		VERT=>VERT,
		COLOUR_CODE=>COLOUR_CODE
	);
		

	CLK <= not CLK after 10 ns;



	process
	begin
		wait for 20 ns;
		RESET_L <= '1';	

-------------------------------------------------------------------------------------
		wait for 40 ns; --color 1
		
		DAT<="00110001";

		wait for 20 ns;

		NEWOP <= '1';

		wait for 40 ns;
	
		NEWOP <='0';

-------------------------------------------------------------------------------------
		wait for 100 ns;--borrar pantalla

		DAT<="01100010";

		wait for 20 ns;

		NEWOP<='1';

		wait for 60 ns;

		DONE_ORDER<='1';

		wait for 20 ns;

		DONE_ORDER<='0';
		NEWOP<='0';

-------------------------------------------------------------------------------------
		wait for 100 ns;--xcol default
		DAT<=x"78";
		NEWOP<='1';

		wait for 60 ns;

		NEWOP<='0';

		wait for 40 ns;

		DAT<=x"44";

		wait for 20 ns;

		NEWOP<='1';

		wait for 60 ns;

		NEWOP<='0';

-------------------------------------------------------------------------------------
		
		wait for 100 ns;--figura

		DAT<="01100110";

		wait for 20 ns;

		NEWOP<='1';

		wait for 60 ns;

		DONE_ORDER<='1';

		wait for 20 ns;

		DONE_ORDER<='0';
		NEWOP<='0';

-------------------------------------------------------------------------------------
		wait for 100 ns;--borrar pantalla

		DAT<="01100010";

		wait for 20 ns;

		NEWOP<='1';

		wait for 60 ns;

		DONE_ORDER<='1';

		wait for 20 ns;

		DONE_ORDER<='0';
		NEWOP<='0';

-------------------------------------------------------------------------------------
		wait for 100 ns;--linea vertical

		DAT<="01110110";

		wait for 20 ns;

		NEWOP<='1';

		wait for 60 ns;

		DONE_ORDER<='1';

		wait for 20 ns;

		DONE_ORDER<='0';
		NEWOP<='0';

-------------------------------------------------------------------------------------
		wait for 100 ns;--linea diagonal

		DAT<="01100100";

		wait for 20 ns;

		NEWOP<='1';

		wait for 60 ns;

		DONE_ORDER<='1';

		wait for 20 ns;

		DONE_ORDER<='0';
		NEWOP<='0';

-------------------------------------------------------------------------------------
		wait for 100 ns;--linea horizontal

		DAT<="01101000";

		wait for 20 ns;

		NEWOP<='1';

		wait for 60 ns;

		DONE_ORDER<='1';

		wait for 20 ns;

		DONE_ORDER<='0';
		NEWOP<='0';

-------------------------------------------------------------------------------------
		wait for 100 ns;--equilatero

		DAT<="01100101";

		wait for 20 ns;

		NEWOP<='1';

		wait for 60 ns;

		DONE_ORDER<='1';

		wait for 20 ns;

		DONE_ORDER<='0';
		NEWOP<='0';

-------------------------------------------------------------------------------------
		wait for 100 ns;--triangulo

		DAT<="01010100";

		wait for 20 ns;

		NEWOP<='1';

		wait for 60 ns;

		DONE_ORDER<='1';

		wait for 20 ns;

		DONE_ORDER<='0';
		NEWOP<='0';

-------------------------------------------------------------------------------------
		wait for 100 ns;--trapecio

		DAT<="01110100";

		wait for 20 ns;

		NEWOP<='1';

		wait for 60 ns;

		DONE_ORDER<='1';

		wait for 20 ns;

		DONE_ORDER<='0';
		NEWOP<='0';

-------------------------------------------------------------------------------------
		wait for 100 ns;--rombo

		DAT<="01110010";

		wait for 20 ns;

		NEWOP<='1';

		wait for 60 ns;

		DONE_ORDER<='1';

		wait for 20 ns;

		DONE_ORDER<='0';
		NEWOP<='0';

-------------------------------------------------------------------------------------
		wait for 100 ns;--romboide

		DAT<="01010010";

		wait for 20 ns;

		NEWOP<='1';

		wait for 60 ns;

		DONE_ORDER<='1';

		wait for 20 ns;

		DONE_ORDER<='0';
		NEWOP<='0';

-------------------------------------------------------------------------------------
		
		wait for 100 ns;--yrow default
		DAT<=x"79";
		NEWOP<='1';

		wait for 60 ns;

		NEWOP<='0';

		wait for 40 ns;

		DAT<=x"44";

		wait for 20 ns;

		NEWOP<='1';

		wait for 60 ns;

		NEWOP<='0';

-------------------------------------------------------------------------------------
		wait for 100 ns;--xcol d'200'
		
		DAT<=x"78";
		
		wait for 20 ns;

		NEWOP<='1';

		wait for 60 ns;

		NEWOP<='0';

		wait for 40 ns;

		DAT<=x"31"; -- primer bit

		wait for 20 ns;

		NEWOP<='1';

		wait for 60 ns;

		NEWOP<='0';
		DAT<=x"31"; -- segundo bit

		wait for 20 ns;

		NEWOP<='1';

		wait for 60 ns;

		NEWOP<='0';
		DAT<=x"30"; -- tercer bit

		wait for 20 ns;

		NEWOP<='1';

		wait for 60 ns;

		NEWOP<='0';
		DAT<=x"30"; -- cuarto bit

		wait for 20 ns;

		NEWOP<='1';

		wait for 60 ns;

		NEWOP<='0';
		DAT<=x"31"; -- quinto bit

		wait for 20 ns;

		NEWOP<='1';

		wait for 60 ns;

		NEWOP<='0';
		DAT<=x"30"; -- sexto bit

		wait for 20 ns;

		NEWOP<='1';

		wait for 60 ns;

		NEWOP<='0';
		DAT<=x"30"; -- septimo bit

		wait for 20 ns;

		NEWOP<='1';

		wait for 60 ns;

		NEWOP<='0';
		DAT<=x"30"; -- octavo bit

		wait for 20 ns;

		NEWOP<='1';

		wait for 60 ns;

		NEWOP<='0';

-------------------------------------------------------------------------------------
		wait for 100 ns;--yrow d'200'
		
		DAT<=x"79";
		
		wait for 20 ns;

		NEWOP<='1';

		wait for 60 ns;

		NEWOP<='0';

		wait for 40 ns;

		DAT<=x"30"; -- primer bit

		wait for 20 ns;

		NEWOP<='1';

		wait for 60 ns;

		NEWOP<='0';
		DAT<=x"31"; -- segundo bit

		wait for 20 ns;

		NEWOP<='1';

		wait for 60 ns;

		NEWOP<='0';
		DAT<=x"31"; -- tercer bit

		wait for 20 ns;

		NEWOP<='1';

		wait for 60 ns;

		NEWOP<='0';
		DAT<=x"30"; -- cuarto bit

		wait for 20 ns;

		NEWOP<='1';

		wait for 60 ns;

		NEWOP<='0';
		DAT<=x"30"; -- quinto bit

		wait for 20 ns;

		NEWOP<='1';

		wait for 60 ns;

		NEWOP<='0';
		DAT<=x"31"; -- sexto bit

		wait for 20 ns;

		NEWOP<='1';

		wait for 60 ns;

		NEWOP<='0';
		DAT<=x"30"; -- septimo bit

		wait for 20 ns;

		NEWOP<='1';

		wait for 60 ns;

		NEWOP<='0';
		DAT<=x"30"; -- octavo bit

		wait for 20 ns;

		NEWOP<='1';

		wait for 60 ns;

		NEWOP<='0';
		DAT<=x"30"; -- noveno bit

		wait for 20 ns;

		NEWOP<='1';

		wait for 60 ns;

		NEWOP<='0';

-------------------------------------------------------------------------------------
		DAT<=x"7A"; --comprobacion de que salta el del con un comando desconocido

		wait for 20 ns;

		NEWOP<='1';

		wait for 60 ns;

		NEWOP<='0';
-------------------------------------------------------------------------------------
		wait for 100 ns;--yrow wring coord
		DAT<=x"79";

		wait for 20 ns;

		NEWOP<='1';

		wait for 60 ns;

		NEWOP<='0';

		wait for 40 ns;

		DAT<=x"73";

		wait for 20 ns;

		NEWOP<='1';

		wait for 60 ns;

		NEWOP<='0';



-------------------------------------------------------------------------------------
		wait for 100 ns;

	end process;
end arq_tb_uart_ctrl;
