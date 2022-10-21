library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity lcd_control is
port(
	CLK,RESET_L,LCD_Init_Done,OP_SETCURSOR,OP_DRAWCOLOUR: in std_logic;
	XCOL: in std_logic_vector(7 downto 0);
	YROW: in std_logic_vector(8 downto 0);
	RGB: in std_logic_vector(15 downto 0);
	NUM_PIX: in unsigned(16 downto 0);
	DONE_CURSOR,DONE_COLOUR,LCD_CS_N,LCD_WR_N,LCD_RS: out std_logic;
	LCD_DATA: out std_logic_vector(15 downto 0)
);
end lcd_control;

architecture arq_lcd_control of lcd_control is

type ESTADOS is (E0,E1,E2,E3,E4,E5,E6,E7,E8,E9,E10,E11,E12);

signal EP, ES: ESTADOS;
signal LD_INF,DEC_PIX,END_PIX,RS_DAT,RS_COM,CL_DAT,INC_DAT,LD_2C,CL_MUX: std_logic;
signal D0,D1,D2,D3,D4,D5,D6,D7: std_logic;
signal DAT: unsigned(2 downto 0);
signal RXCOL: std_logic_vector(7 downto 0);
signal RYROW: std_logic_vector(8 downto 0);
signal RRGB: std_logic_vector(15 downto 0);

signal AUX: std_logic;
signal Q_PIX: unsigned(16 downto 0);

begin

--Control de estado presente y siguiente
COMB: process (EP, LCD_Init_done, OP_SETCURSOR, OP_DRAWCOLOUR, D0,D1,D2,D3,D4,D5,D6,D7, END_PIX) begin 
	case EP is
		when E0 => 	if LCD_Init_Done = '1' then 
					if OP_SETCURSOR = '1' then ES<=E1;
					else
						if OP_DRAWCOLOUR = '1' then ES<=E12;
						else ES<=E0;
						end if;
					end if;
				else ES <= E0;
				end if; 
		when E1 =>	ES<=E2;
		when E2 =>	ES<=E3;
		when E3 =>	if D0='1' OR D1='1' OR D3='1' OR D4='1' then ES<=E11;
				else
					if D2='1' then ES<=E10;
					else
						if D5='1' then ES<=E9;
						else ES<=E4;
						end if;
					end if;
				end if;
		when E4 =>	ES<=E5;
		when E5 =>	ES<=E6;
		when E6 =>	ES<=E7;
		when E7 =>	if END_PIX ='0' then ES<=E5;
				else ES<=E8;
				end if;
		when E8 =>	ES<=E0;
		when E9 =>	ES<=E0;
		when E10 =>	ES<=E2;
		when E11 =>	ES<=E2;
		when E12 =>	ES<=E2;

		end case;
end process COMB;

--Cambio de estado con flanco de reloj
SEC: process (CLK, RESET_L) begin
	if RESET_L = '0' then EP <= E0; -- reset as�ncrono
	elsif CLK'event and CLK='1' -- flanco de reloj
		then EP <= ES; -- Estado Presente = Estado Siguiente
	end if;	
end process SEC;

--Activacion de se�ales de cada estado
CL_MUX   <='1' when EP=E0 or EP=E1 or EP=E12;
CL_DAT   <='1' when EP=E1;
LD_INF   <='1' when EP=E1 or EP=E12;
RS_COM   <='1' when EP=E1 or EP=E10 or EP=E12;
LCD_CS_N <='0' when EP=E2 or EP=E5;
LCD_WR_N <='0' when EP=E2 or EP=E5;
INC_DAT  <='1' when EP=E4 or EP=E10 or EP=E11;
RS_DAT   <='1' when EP=E4 or EP=E11;
DONE_CURSOR<='1' when EP=E9;
LD_2C    <='1' when EP=E12;
DEC_PIX  <='1' when EP=E6;
DONE_COLOUR <='1' when EP=E8;

--REG XCOL
process(CLK, LD_INF)
begin
	if RESET_L = '0' then RXCOL <= (others => '0');
	elsif CLK'event and CLK='1' then
		if LD_INF = '1' then RXCOL <= XCOL;
		end if;
	end if;
end process;

--REG YROW
process(CLK, LD_INF)
begin
	if RESET_L = '0' then RYROW <= (others => '0');
	elsif CLK'event and CLK='1' then
		if LD_INF = '1' then RYROW <= YROW;
		end if;
	end if;
end process;

--REG RGB
process(CLK, LD_INF)
begin
	if RESET_L = '0' then RRGB <= (others => '0');
	elsif CLK'event and CLK='1' then
		if LD_INF = '1' then RRGB <= RGB;
		end if;
	end if;
end process;

-- JK LCD_RS
process (CLK, RS_COM, RS_DAT)
begin
	if RESET_L = '0' then LCD_RS <= '0';
	elsif CLK'event and CLK='1' then
		if (RS_DAT = '1' and RS_COM = '0') then AUX <= '1';
		elsif (RS_DAT = '0' and RS_COM = '1') then AUX <= '0';
		elsif (RS_DAT = '1' and RS_COM = '1') then AUX <= not AUX;
		end if;
	end if;
	LCD_RS<=AUX;
end process;

--CONTADOR DECREMENTAL
process(CLK,LD_INF,DEC_PIX)
begin
	if clk'event and clk='1' then
		if LD_INF='1' then Q_PIX<=NUM_PIX;
			elsif DEC_PIX='1' then Q_PIX<= Q_PIX-1;
		end if;
	end if;
	if Q_PIX = "0000000000000000" then
		END_PIX<='1';
	end if;
end process;

--CONTADOR INCREMENTAL
process(CLK,LD_2C,INC_DAT,CL_DAT)
begin
	if CLK'event and CLK='1' then
		if LD_2C='1' then DAT<="110";
			elsif INC_DAT='1' then DAT<= DAT+1;
			elsif CL_DAT='0' then DAT <= "000";
		end if;
	end if;
end process;

--DECODIFICADOR
D0 <= '1' when DAT="000" else '0';
D1 <= '1' when DAT="001" else '0';
D2 <= '1' when DAT="010" else '0';
D3 <= '1' when DAT="011" else '0';
D4 <= '1' when DAT="100" else '0';
D5 <= '1' when DAT="101" else '0';
D6 <= '1' when DAT="110" else '0';
D7 <= '1' when DAT="111" else '0';

--MULTIPLEXOR
LCD_DATA <= x"002A" when DAT="000" else
		x"0000" when DAT="001" else
		x"00"&RXCOL when DAT="010" else
		x"002B" when DAT="011" else
		x"000"&"000"&RYROW(8) when DAT="100" else
		x"00"&RYROW(7 downto 0) when DAT="101" else
		x"002C" when DAT="110" else
		RRGB when DAT="111" else
		x"0000";

end arq_lcd_control;
