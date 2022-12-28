-------------------------
-- fichero display.vhd --
-------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity display is
	port(
		CLK, RESET_L, LED, LED_POS, LED_SIG: in std_logic;
		DISPL: out std_logic_vector(41 downto 0)
	);
end display;

architecture arq_display of display is

	-- Declaracion de estados
	type estados is (CHOICE); 
	signal EP, ES : estados;
	
	-- Declaracion de senales de control
	signal LD_OPT: std_logic :='0';
	signal DCHOICE: std_logic_vector(41 downto 0);
	signal SEL: std_logic_vector(1 downto 0);
	
	begin

	-- #######################
	-- ## UNIDAD DE CONTROL ## 
	-- #######################

	-- Transicion de estados (calculo de estado siguiente)
	SWSTATE: process (EP) begin
		case EP is
			when CHOICE =>	ES <= CHOICE;

			when others =>  ES <= CHOICE; -- inalcanzable
		end case;
	end process SWSTATE;



	-- Actualizacion de EP en cada flanco de reloj (sequential)
	SEQ: process (CLK, RESET_L) begin
		if RESET_L = '0' then EP <= CHOICE; -- reset asincrono
		elsif CLK'event and CLK = '1'  -- flanco de reloj
			then EP <= ES;             -- Estado Presente = Estado Siguiente
		end if;
	end process SEQ;
	
	
	
	-- Activacion de signals de control: asignaciones combinacionales
	LD_OPT <= '1' when EP = CHOICE else '0';
	
	SEL <= 	"01" when LED = '1' else
				"10" when LED_POS = '1' else
				"11" when LED_SIG = '1' else
				"00";
	
	-- #######################
	-- ## UNIDAD DE PROCESO ##
	-- #######################
	
	--Multiplexor MUX
	DCHOICE	<= "100001001100010100100100001001000011001100" when SEL = "00" else
		   "001100000000101111010100111101110011000100" when SEL = "01" else
		   "111111101100010000001000000111110101000010" when SEL = "10" else
		   "110000000000101000010011000110010001111010";	
	
	-- REG OPT: ROPT
	ROPT : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then DISPL <=(others => '0');
		elsif CLK'event and CLK='1' then
			if LD_OPT = '1' then DISPL <= DCHOICE;
			end if;
		end if;
	end process ROPT;
	
end arq_display; 

	
