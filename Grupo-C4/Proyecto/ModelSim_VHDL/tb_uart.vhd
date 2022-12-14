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


	);
	end component;


    signal CLK : std_logic := '0';
    signal RESET_L : std_logic := '0';


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
		--prueba  x
	
	-------------------------------------------------

	end process;
end arq_tb_uart;
