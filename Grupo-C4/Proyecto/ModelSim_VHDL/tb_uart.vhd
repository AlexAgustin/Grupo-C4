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
		RTS: in std_logic;
		DATARECV: out std_logic_vector (7 downto 0);
		CTS,LED: out std_logic
	);
	end component;


	signal CLK : std_logic := '0';
	signal RESET_L : std_logic := '0';
	signal Rx : std_logic := '1';
	signal VEL: std_logic_vector (1 downto 0);
	signal RTS,CTS : std_logic := '0';
	signal DATARECV: std_logic_vector(7 downto 0);
	signal LED: std_logic;


	begin

	DUT: uart port map(
		CLK =>CLK,
		RESET_L =>RESET_L,
		Rx =>Rx,
		VEL =>VEL,
		RTS =>RTS,
		DATARECV =>DATARECV,
		CTS =>CTS,
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

		Rx <='1'; --dato 4

		wait for 140 ns; --procesa dato 4

		Rx <='1'; --dato 5

		wait for 140 ns; --procesa dato 5

		Rx <='0'; --dato 6

		wait for 140 ns; --procesa dato 6

		Rx <='1'; --dato 7

		wait for 140 ns; --procesa dato 7

		Rx <='1'; --dato 8

		wait for 140 ns; --procesa dato 8

		Rx <='1'; --parity

		wait for 100 ns; --procesa parity

		Rx <= '0'; 

		wait for 100 ns;

		wait for 80 ns;
	
	-------------------------------------------------
		--prueba trama 2
		--wait for 20 ns;
		--RTS <= '1';
		
		--wait for 20 ns;
		--Rx <= '0';

		--wait for 40 ns;
		--RTS <= '0';
		--Rx <='1';
		
		--wait for 1000 ns;
	
	-------------------------------------------------

	end process;
end arq_tb_uart;
