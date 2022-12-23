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
		Rx: in std_logic;
		VEL: in std_logic_vector(1 downto 0);
		DONE_OP: in std_logic;
		DAT: out std_logic_vector(7 downto 0);
		LED,NEWOP: out std_logic
	);
	end component;


	signal CLK : std_logic := '0';
	signal RESET_L : std_logic := '0';
	signal Rx: std_logic := '1';
	signal VEL: std_logic_vector (1 downto 0):="00";
	signal LED: std_logic;
	signal DONE_OP: std_logic:='0';
	signal NEWOP: std_logic;
	signal DAT: std_logic_vector(7 downto 0);

	begin

	DUT: uart port map(
		CLK =>CLK,
		RESET_L =>RESET_L,
		Rx =>Rx,
		VEL =>VEL,
		LED =>LED,
		DONE_OP=>DONE_OP,
		NEWOP=>NEWOP,
		DAT=>DAT
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
		--prueba trama 1 : color 1 (00110010)
		wait for 40 ns;
		
		Rx <= '0';

		wait for 120 ns;

		Rx <='1'; --dato 1

		wait for 120 ns; --procesa dato 1

		Rx <='0'; --dato 2

		wait for 120 ns; --procesa dato 2

		Rx <='0'; --dato 3

		wait for 120 ns; --procesa dato 3

		Rx <='0'; --dato 4

		wait for 120 ns; --procesa dato 4

		Rx <='1'; --dato 5

		wait for 120 ns; --procesa dato 5

		Rx <='1'; --dato 6

		wait for 120 ns; --procesa dato 6

		Rx <='0'; --dato 7

		wait for 120 ns; --procesa dato 7

		Rx <='0'; --dato 8

		wait for 120 ns; --procesa dato 8

		Rx<='1';--parity bit

		wait for 120 ns; --procesa parity bit

		Rx <='1'; --stop

		wait for 120 ns; --procesa stop

		Rx <='1'; --stop2

		wait for 200 ns;

		DONE_OP<='1';

		wait for 20 ns;

		DONE_OP<= '0';
	
	-------------------------------------------------
		--prueba trama 2 : draw fig (0110110)

		wait for 60 ns;
		
		Rx <= '0';

		wait for 120 ns;

		Rx <='0'; --dato 1

		wait for 120 ns; --procesa dato 1

		Rx <='1'; --dato 2

		wait for 120 ns; --procesa dato 2

		Rx <='1'; --dato 3

		wait for 120 ns; --procesa dato 3

		Rx <='0'; --dato 4

		wait for 120 ns; --procesa dato 4

		Rx <='0'; --dato 5

		wait for 120 ns; --procesa dato 5

		Rx <='1'; --dato 6

		wait for 120 ns; --procesa dato 6

		Rx <='1'; --dato 7

		wait for 120 ns; --procesa dato 7

		Rx <='0'; --dato 8

		wait for 120 ns; --procesa dato 8

		Rx<='0';--parity bit

		wait for 120 ns; --procesa parity bit

		Rx <='1'; --stop

		wait for 120 ns; --procesa stop

		Rx <='1'; --stop2

		wait for 100 ns;

		DONE_OP<='1';

		wait for 20 ns;
		
		DONE_OP<= '0';

		wait for 200 ns;

	end process;
end arq_tb_uart;

