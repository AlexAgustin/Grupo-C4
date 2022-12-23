
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
		NEWOP <= '1';

		wait for 20 ns;
	
		NEWOP <='0';


-------------------------------------------------------------------------------------
		wait for 200 ns;
		


	end process;
end arq_tb_uart_ctrl;
