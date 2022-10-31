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

	-- Declaración de estados
	type ESTADOS is (E0,E1,E2,E3,E4,E5,E6,E7,E8,E9,E10,E11,E12);

	-- Declaración de señales
	signal EP, ES: ESTADOS;
	signal LD_INF,DEC_PIX,END_PIX,RS_DAT,RS_COM,CL_DAT,INC_DAT,LD_2C,CL_MUX: std_logic; -- END_PIX HERE??????????????????????????
	signal D0,D1,D2,D3,D4,D5,D6,D7: std_logic; -- gonzalo dijo que mejor direct por DDAT
	signal DDAT: unsigned(2 downto 0);
	signal RXCOL: std_logic_vector(7 downto 0);
	signal RYROW: std_logic_vector(8 downto 0);
	signal RRGB: std_logic_vector(15 downto 0);

	signal AUX: std_logic;
	signal Q_PIX: unsigned(16 downto 0);

	begin

	-- #######################
	-- ## UNIDAD DE CONTROL ##
	-- #######################
	
	--Control de estado presente y siguiente
	COMB: process (EP, LCD_Init_done, OP_SETCURSOR, OP_DRAWCOLOUR, D0,D1,D2,D3,D4,D5,D6,D7, END_PIX) begin 
		case EP is
			when E0 => 	if LCD_Init_Done = '1' then 
							if OP_SETCURSOR = '1' then ES<=E1;
							elsif OP_DRAWCOLOUR = '1' then ES<=E12;
							else ES<=E0;
							end if;
						
						else ES <= E0;
						end if;

			when E1 =>	ES<=E2;
			when E2 =>	ES<=E3;
			when E3 =>	if D0='1' OR D1='1' OR D3='1' OR D4='1' then ES<=E11;
						elsif D2='1' then ES<=E10;
						elsif D5='1' then ES<=E9;
						else ES<=E4;
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
		if RESET_L = '0' then EP <= E0; -- reset asíncrono
		elsif CLK'event and CLK='1'     -- flanco de reloj
			then EP <= ES;              -- Estado Presente = Estado Siguiente
		end if;	
	end process SEC;

	--Activacion de señales de control
	CL_MUX   <='1' when EP=E0 or EP=E1 or EP=E12 else '0';
	CL_DAT   <='1' when EP=E1 else '0';
	LD_INF   <='1' when EP=E1 or EP=E12 else '0';
	RS_COM   <='1' when EP=E1 or EP=E10 or EP=E12 else '0';
	INC_DAT  <='1' when EP=E4 or EP=E10 or EP=E11 else '0';
	RS_DAT   <='1' when EP=E4 or EP=E11 else '0';
	LD_2C    <='1' when EP=E12 else '0';
	DEC_PIX  <='1' when EP=E6 else '0';

	-- Activación de señales de salida
	LCD_CS_N <='0' when EP=E2 or EP=E5 else '1';
	LCD_WR_N <='0' when EP=E2 or EP=E5 else '1';
	DONE_CURSOR<='1' when EP=E9 else '0';
	DONE_COLOUR <='1' when EP=E8 else '0';



	-- #######################
	-- ## UNIDAD DE PROCESO ##
	-- #######################

	--REG XCOL
	RX: process(CLK,RESET_L)
	begin
		if RESET_L = '0' then RXCOL <= (others => '0');  -- clear con señal reset
		elsif CLK'event and CLK='1' then				 -- flanco reloj
			if LD_INF = '1' then RXCOL <= XCOL;
			end if;
		end if;
	end process RX;

	--REG YROW
	RY: process(CLK,RESET_L)
	begin
		if RESET_L = '0' then RYROW <= (others => '0'); -- clear con señal reset
		elsif CLK'event and CLK='1' then				-- flanco reloj
			if LD_INF = '1' then RYROW <= YROW;
			end if;
		end if;
	end process RY;

	--REG RGB
	RC: process(CLK,RESET_L)
	begin
		if RESET_L = '0' then RRGB <= (others => '0'); -- clear con señal reset
		elsif CLK'event and CLK='1' then				-- flanco reloj
			if LD_INF = '1' then RRGB <= RGB;
			end if;
		end if;
	end process RC;

	-- REG RDAT
	RDAT : process(clk, reset_L)
	begin
		if reset_L = '0' then LCD_RS <= '0'; 	-- clear con señal reset
		elsif clk'event and clk='1' then 		-- flanco de reloj
			if RS_DAT = '1' then LCD_RS <= '1';
			elsif RS_COM = '1' then LCD_RS <=  '0';
			end if;
		end if;
	end process RDAT;


	--CONTADOR DECREMENTAL: pixels
	CNPIX: process(CLK,RESET_L)
	begin
		if RESET_L = '0' then Q_PIX <= (others => '0'); -- clear  con señal reset
		elsif clk'event and clk='1' then				-- flanco reloj
			if LD_INF='1' then Q_PIX<=NUM_PIX;
				elsif DEC_PIX='1' then Q_PIX<= Q_PIX-1;
			end if;
		end if;
	end process CNPIX;
	END_PIX <= '1' when Q_PIX = ('0' & x"0000") else '0';

	--CONTADOR INCREMENTAL: ddat
	CDDAT: process(CLK,RESET_L)
	begin
		if RESET_L = '0' then Q_PIX <= (others => '0'); -- clear  con señal reset
		elsif CLK'event and CLK='1' then				-- flanco reloj
			if LD_2C='1' then DDAT<="110";
				elsif INC_DAT='1' then DDAT<= DDAT+1;
				elsif CL_DAT='0' then DDAT <= "000";
			end if;
		end if;
	end process CDDAT;

	--DECODIFICADOR
	D0 <= '1' when DDAT="000" else '0';
	D1 <= '1' when DDAT="001" else '0';
	D2 <= '1' when DDAT="010" else '0';
	D3 <= '1' when DDAT="011" else '0';
	D4 <= '1' when DDAT="100" else '0';
	D5 <= '1' when DDAT="101" else '0';
	D6 <= '1' when DDAT="110" else '0';
	D7 <= '1' when DDAT="111" else '0';

	--MULTIPLEXOR
	LCD_DATA <= x"0000" when CL_MUX ='1' else
		    x"002A" when DDAT="000" else
			x"0000" when DDAT="001" else
			x"00"&RXCOL when DDAT="010" else
			x"002B" when DDAT="011" else
			x"000"&"000"&RYROW(8) when DDAT="100" else
			x"00"&RYROW(7 downto 0) when DDAT="101" else
			x"002C" when DDAT="110" else
			RRGB when DDAT="111" else
			x"0000";

end arq_lcd_control;
