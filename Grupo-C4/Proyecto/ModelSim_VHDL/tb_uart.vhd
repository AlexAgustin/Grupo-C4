-------------------------
-- fichero tb_uart.vhd --
-------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_uart is
end tb_uart;

architecture arq_tb_uart of tb_uart is

	component uart
	port(
		CLK, RESET_L: in std_logic;
		Rx,DONE_ORDER: in std_logic;
		VEL: in std_logic_vector(1 downto 0);
		RTS: in std_logic;
		CTS,LED,DRAW_FIG,DEL_SCREEN: out std_logic;
		COLOUR_CODE: out std_logic_vector(2 downto 0)
	);
	end component;


	signal CLK : std_logic := '0';
	signal RESET_L : std_logic := '0';
	signal Rx: std_logic := '1';
	signal VEL: std_logic_vector (1 downto 0);
	signal RTS,CTS,DRAW_FIG,DEL_SCREEN,DONE_ORDER : std_logic := '0';
	signal LED: std_logic;
	signal COLOUR_CODE: std_logic_vector(2 downto 0);

	begin

	DUT: uart port map(
		CLK =>CLK,
		RESET_L =>RESET_L,
		Rx =>Rx,
		VEL =>VEL,
		RTS =>RTS,
		DRAW_FIG =>DRAW_FIG,
		DEL_SCREEN =>DEL_SCREEN,
		COLOUR_CODE =>COLOUR_CODE,
		CTS =>CTS,
		DONE_ORDER=>DONE_ORDER,
		LED =>LED
	);
		

	CLK <= not CLK after 10 ns;



	process
	begin
		-- reset
		--RESET_L <= '0';
		VEL<="11";
		wait for 20 ns;
		RESET_L <= '1';	

	-------------------------------------------------
		--prueba trama 1
		wait for 40 ns;
		RTS <= '1';
		
		wait for 60 ns;
		
		Rx <= '0';

		wait for 80 ns;

		RTS <= '0';
		Rx <='1'; --dato 1

		wait for 140 ns; --procesa dato 1

		Rx <='0'; --dato 2

		wait for 140 ns; --procesa dato 2

		Rx <='0'; --dato 3

		wait for 140 ns; --procesa dato 3

		Rx <='0'; --dato 4

		wait for 140 ns; --procesa dato 4

		Rx <='0'; --dato 5

		wait for 140 ns; --procesa dato 5

		Rx <='0'; --dato 6

		wait for 140 ns; --procesa dato 6

		Rx <='0'; --dato 7

		wait for 140 ns; --procesa dato 7

		Rx <='0'; --dato 8

		wait for 140 ns; --procesa dato 8

		Rx <='1'; --parity

		wait for 460 ns;

		DONE_ORDER<='1';
	
	-------------------------------------------------
		--prueba trama 2
		wait for 100 ns;
		
		DONE_ORDER <= '0';

		wait for 60 ns;
		
		Rx <= '0';

		wait for 80 ns;

		RTS <= '0';
		Rx <='0'; --dato 1

		wait for 140 ns; --procesa dato 1

		Rx <='1'; --dato 2

		wait for 140 ns; --procesa dato 2

		Rx <='1'; --dato 3

		wait for 140 ns; --procesa dato 3

		Rx <='0'; --dato 4

		wait for 140 ns; --procesa dato 4

		Rx <='0'; --dato 5

		wait for 140 ns; --procesa dato 5

		Rx <='1'; --dato 6

		wait for 140 ns; --procesa dato 6

		Rx <='1'; --dato 7

		wait for 140 ns; --procesa dato 7

		Rx <='0'; --dato 8

		wait for 140 ns; --procesa dato 8

		Rx <='1'; --parity

		wait for 540 ns;
	
		DONE_ORDER<='1';
	
	-------------------------------------------------

	end process;
end arq_tb_uart;
