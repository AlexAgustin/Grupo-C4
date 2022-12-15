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
		CLK, RESET_L, RTS, Rx: in std_logic;
		CTS: out std_logic;

	);
	end component;


    signal CLK : std_logic := '0';
    signal RESET_L : std_logic := '0';
    signal RTS : std_logic := '0';
    signal Rx : std_logic := '1';


	begin

	DUT: uart port map(
		CLK => CLK,
		RESET_L => RESET_L
		
		);
		

	CLK <= not CLK after 10 ns;



	process
	begin
		-- reset
		RESET_L <= '0';

		wait for 20 ns;
		RESET_L <= '1';	

	-------------------------------------------------
		--prueba trama 1
		wait for 20 ns;
		RTS <= '1';
		
		wait for 20 ns;
		Rx <= '0';

		wait for 40 ns;
		RTS <= '0';
		Rx <='1'
		wait for 1000 ns;
	
	-------------------------------------------------
		--prueba trama 2
		wait for 20 ns;
		RTS <= '1';
		
		wait for 20 ns;
		Rx <= '0';

		wait for 40 ns;
		RTS <= '0';
		Rx <='1'
		
		wait for 1000 ns;
	
	-------------------------------------------------

	end process;
end arq_tb_uart;
