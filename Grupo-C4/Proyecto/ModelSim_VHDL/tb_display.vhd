----------------------------
-- fichero tb_display.vhd --
----------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_display is
end tb_display;

architecture arq_tb_display of tb_display is

	component display
	port(
		CLK, RESET_L, LED, LED_POS, LED_SIG: in std_logic;
		DISPL: out std_logic_vector(41 downto 0)
	);
	end component;


	signal CLK : std_logic := '0';
	signal RESET_L : std_logic := '0';
	signal LED, LED_POS, LED_SIG: std_logic := '0';
	signal DISPL: std_logic_vector(41 downto 0);

	begin

	DUT: display port map(
		CLK =>CLK,
		RESET_L =>RESET_L,
		LED =>LED,
		LED_POS =>LED_POS,
		LED_SIG=>LED_SIG,
		DISPL=>DISPL
	);
		

	CLK <= not CLK after 10 ns;



	process
	begin
		wait for 20 ns;
		RESET_L <= '1';	

	-------------------------------------------------
		--prueba LED
		wait for 40 ns;
		
		LED <= '1';

		wait for 40 ns;

		LED <= '0';

		wait for 40 ns; 
	-------------------------------------------------
		--prueba LED_POS
		wait for 20 ns;
		
		LED_POS <= '1';

		wait for 40 ns;

		LED_POS <= '0';

		wait for 40 ns; 
	-------------------------------------------------
		--prueba LED_SIG
		wait for 20 ns;
		
		LED_SIG <= '1';

		wait for 40 ns;

		LED_SIG <= '0';

		wait for 40 ns; 
	-------------------------------------------------

		wait for 100 ns;

	end process;
end arq_tb_display;

