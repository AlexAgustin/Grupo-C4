library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity lcd_ctrl is
	port(
		CLK,RESET_L,LCD_Init_Done,OP_SETCURSOR,OP_DRAWCOLOUR: in std_logic;
		XCOL: in std_logic_vector(7 downto 0);
		YROW: in std_logic_vector(8 downto 0);
		RGB: in std_logic_vector(15 downto 0);
		NUM_PIX: in unsigned(16 downto 0);
		DONE_CURSOR,DONE_COLOUR,LCD_CS_N,LCD_WR_N,LCD_RS: out std_logic;
		LCD_DATA: out std_logic_vector(15 downto 0)
	);
end lcd_ctrl;

architecture arq_lcd_ctrl of lcd_ctrl is

	-- Declaraci�n de estados
	type ESTADOS is (INICIO,INITCUR,WR,CHOICE,DRDAT,DRWR,DECPIX,REPEAT,FINDR,FINCUR,COM,DAT,INITDR);

	-- Declaraci�n de se�ales
	signal EP, ES: ESTADOS;
	signal LD_INF,DEC_PIX,END_PIX,RS_DAT,RS_COM,CL_DAT,INC_DAT,LD_2C,CL_MUX: std_logic;
	signal D0,D1,D2,D3,D4,D5,D6,D7: std_logic; 
	signal DDAT: unsigned(2 downto 0);
	signal Q_PIX: unsigned(16 downto 0);
	signal RXCOL: std_logic_vector(7 downto 0);
	signal RYROW: std_logic_vector(8 downto 0);
	signal RRGB: std_logic_vector(15 downto 0);

	begin

	-- #######################
	-- ## UNIDAD DE CONTROL ##
	-- #######################
	
	--Control de estado presente y siguiente
	SWSTATE: process (EP, LCD_Init_done, OP_SETCURSOR, OP_DRAWCOLOUR, D0,D1,D2,D3,D4,D5,D6,D7, END_PIX) begin 
		case EP is
			when INICIO => 		if LCD_Init_Done = '1' then 
								if OP_SETCURSOR = '1' then ES<=INITCUR;
								elsif OP_DRAWCOLOUR = '1' then ES<=INITDR;
								else ES<=INICIO;
								end if;
						
							else ES <= INICIO;
							end if;

			when INITCUR =>		ES<=WR;
			when WR =>		ES<=CHOICE;
			when CHOICE =>		if D0='1' OR D1='1' OR D3='1' OR D4='1' then ES<=DAT;
								elsif D2='1' then ES<=COM;
								elsif D5='1' then ES<=FINCUR;
								elsif D6='1' or D7='1' then ES<=DRDAT;
								else ES<=DRDAT; --else inalcanzable, siempre habra un D activo.
								end if;

			when DRDAT =>		ES<=DRWR;
			when DRWR =>		ES<=DECPIX;
			when DECPIX =>		ES<=REPEAT;
		
			when REPEAT =>		if END_PIX ='0' then ES<=DRWR;
							else ES<=FINDR;
							end if;
						
			when FINDR =>		ES<=INICIO;
			when FINCUR =>		ES<=INICIO;
			when COM =>		ES<=WR;
			when DAT =>		ES<=WR;
			when INITDR =>		ES<=WR;
			when others=>   ES<=INICIO;
			end case;
	end process SWSTATE;

	--Cambio de estado con flanco de reloj
	SEC: process (CLK, RESET_L) begin
		if RESET_L = '0' then EP <= INICIO; -- reset as�ncrono
		elsif CLK'event and CLK='1'     -- flanco de reloj
			then EP <= ES;              -- Estado Presente = Estado Siguiente
		end if;	
	end process SEC;

	--Activacion de se�ales de control
	CL_MUX   <='1' when EP=INICIO or EP=INITCUR or EP=INITDR else '0';
	CL_DAT   <='1' when EP=INITCUR else '0';
	LD_INF   <='1' when EP=INITCUR or EP=INITDR else '0';
	RS_COM   <='1' when EP=INITCUR or EP=COM or EP=INITDR else '0';
	INC_DAT  <='1' when EP=DRDAT or EP=COM or EP=DAT else '0';
	RS_DAT   <='1' when EP=DRDAT or EP=DAT else '0';
	LD_2C    <='1' when EP=INITDR else '0';
	DEC_PIX  <='1' when EP=DECPIX else '0';

	-- Activaci�n de se�ales de salida
	LCD_CS_N <='0' when EP=WR or EP=DRWR else '1';
	LCD_WR_N <='0' when EP=WR or EP=DRWR else '1';
	DONE_CURSOR<='1' when EP=FINCUR else '0';
	DONE_COLOUR <='1' when EP=FINDR else '0';



	-- #######################
	-- ## UNIDAD DE PROCESO ##
	-- #######################

	--REG XCOL: RX
	RX: process(CLK,RESET_L)
	begin
		if RESET_L = '0' then RXCOL <= (others => '0');  -- clear con se�al reset
		elsif CLK'event and CLK='1' then				 -- flanco reloj
			if LD_INF = '1' then RXCOL <= XCOL;
			end if;
		end if;
	end process RX;

	--REG YROW: RY
	RY: process(CLK,RESET_L)
	begin
		if RESET_L = '0' then RYROW <= (others => '0'); -- clear con se�al reset
		elsif CLK'event and CLK='1' then				-- flanco reloj
			if LD_INF = '1' then RYROW <= YROW;
			end if;
		end if;
	end process RY;

	--REG RGB: RC
	RC: process(CLK,RESET_L)
	begin
		if RESET_L = '0' then RRGB <= (others => '0'); -- clear con se�al reset
		elsif CLK'event and CLK='1' then				-- flanco reloj
			if LD_INF = '1' then RRGB <= RGB;
			end if;
		end if;
	end process RC;

	-- REG RRS
	RRS : process(CLK, RESET_L)
	begin
		if RESET_L = '0' then LCD_RS <= '0'; 	-- clear con se�al reset
		elsif CLK'event and CLK='1' then 		-- flanco de reloj
			if RS_DAT = '1' then LCD_RS <= '1';
			elsif RS_COM = '1' then LCD_RS <=  '0';
			end if;
		end if;
	end process RRS;


	--CONTADOR DECREMENTAL PÍXELES: CNPIX
	CNPIX: process(CLK,RESET_L)
	begin
		if RESET_L = '0' then Q_PIX <= (others => '0'); END_PIX<='0'; -- clear  con se�al reset
		elsif CLK'event and CLK='1' then				-- flanco reloj
			if LD_INF='1' then Q_PIX<=NUM_PIX; END_PIX<='0';
			elsif DEC_PIX='1' and Q_PIX="00000000000000001" then Q_PIX<= Q_PIX-1; END_PIX<='1';
			elsif DEC_PIX='1' and Q_PIX="00000000000000000" then Q_PIX<= "11111111111111111"; END_PIX<='0';
			elsif DEC_PIX='1' then Q_PIX<= Q_PIX-1; END_PIX<='0';
			end if;
		end if;
	end process CNPIX;

	--CONTADOR INCREMENTAL DDAT: CDDAT
	CDDAT: process(CLK,RESET_L)
	begin
		if RESET_L = '0' then DDAT <= (others => '0'); -- clear  con se�al reset
		elsif CLK'event and CLK='1' then				-- flanco reloj
			if LD_2C='1' then DDAT<="110";
			elsif INC_DAT='1' then DDAT<= DDAT+1;
			elsif CL_DAT='1' then DDAT <= "000";
			end if;
		end if;
	end process CDDAT;

	--DECODIFICADOR: DEC
	D0 <= '1' when DDAT="000" else '0';
	D1 <= '1' when DDAT="001" else '0';
	D2 <= '1' when DDAT="010" else '0';
	D3 <= '1' when DDAT="011" else '0';
	D4 <= '1' when DDAT="100" else '0';
	D5 <= '1' when DDAT="101" else '0';
	D6 <= '1' when DDAT="110" else '0';
	D7 <= '1' when DDAT="111" else '0';

	--MULTIPLEXOR: MUX
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

end arq_lcd_ctrl;
