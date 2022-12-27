-------------------------
-- fichero top: fase 2 --
-------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DE1SOC_LCDLT24_2fas is
	port(
		--  CLOCK ----------------
		CLOCK_50	: in	std_logic;
	--	CLOCK2_50	: in	std_logic;
	--	CLOCK3_50	: in	std_logic;
	--	CLOCK4_50	: in	std_logic;

		-- UART----------------
		Rx : in std_logic;
		-- UART_TX : out std_logic;
		--CTS : out std_logic;
		--RTS : in std_logic;
		
		-- KEY ----------------
		KEY 		: in	std_logic_vector(1 downto 0);

		-- SW ----------------
		SW 			: in	std_logic_vector(8 downto 7);
	--	SW 			: in	std_logic_vector(9 downto 0);

		-- LEDR ----------------
		LEDR 		: out	std_logic_vector(9 downto 4);

		-- LT24_LCD ----------------
		LT24_LCD_ON     : out std_logic;
		LT24_RESET_N    : out std_logic;
		LT24_CS_N       : out std_logic;
		LT24_RD_N       : out std_logic;
		LT24_RS         : out std_logic;
		LT24_WR_N       : out std_logic;
		LT24_D          : out std_logic_vector(15 downto 0);

		-- GPIO ----------------
	--	GPIO_0 		: inout	std_logic_vector(35 downto 0);

		-- SEG7 ----------------
		HEX5	: out	std_logic_vector(6 downto 1);
		HEX4	: out	std_logic_vector(5 downto 0);
		HEX3	: out	std_logic_vector(6 downto 0);
		HEX2	: out	std_logic_vector(6 downto 1);
		HEX1	: out	std_logic_vector(5 downto 0);
		HEX0	: out	std_logic_vector(6 downto 1)

	);
end;

architecture str of DE1SOC_LCDLT24_2fas is 
		
	component LT24Setup 
		port(
			-- CLOCK and Reset_l ----------------
			clk            : in      std_logic;
			reset_l        : in      std_logic;

			LT24_LCD_ON      : out std_logic;
			LT24_RESET_N     : out std_logic;
			LT24_CS_N        : out std_logic;
			LT24_RS          : out std_logic;
			LT24_WR_N        : out std_logic;
			LT24_RD_N        : out std_logic;
			LT24_D           : out std_logic_vector(15 downto 0);
		
			LT24_CS_N_Int        : in std_logic;
			LT24_RS_Int          : in std_logic;
			LT24_WR_N_Int        : in std_logic;
			LT24_RD_N_Int        : in std_logic;
			LT24_D_Int           : in std_logic_vector(15 downto 0);
		  
			LT24_Init_Done       : out std_logic
		);
	  end component;
	  

	component LCD_DRAWING IS
		port
		(
		CLK, RESET_L, DEFAULT: in std_logic;

		DEL_SCREEN, DRAW_FIG, DONE_CURSOR, DONE_COLOUR, HORIZ, VERT, DIAG, MIRROR, TRIAN, EQUIL, ROMBO, ROMBOIDE, TRAP, PATRON, HEXAG: in std_logic;
		COLOUR_CODE: in std_logic_vector(2 downto 0);
		UART_XCOL: in std_logic_vector(7 downto 0);
		UART_YROW: in std_logic_vector(8 downto 0);
		
		XCOL: out std_logic_vector(7 downto 0);
		YROW: out std_logic_vector(8 downto 0);
		OP_SETCURSOR, OP_DRAWCOLOUR: out std_logic;
		RGB: out std_logic_vector(15 downto 0);
		NUM_PIX: out unsigned(16 downto 0);
		DONE_ORDER: out std_logic
		);
	end component;

	component LCD_CTRL
		port
		(
			CLK,RESET_L,LCD_Init_Done,OP_SETCURSOR,OP_DRAWCOLOUR: in std_logic;
			XCOL: in std_logic_vector(7 downto 0);
			YROW: in std_logic_vector(8 downto 0);
			RGB: in std_logic_vector(15 downto 0);
			NUM_PIX: in unsigned(16 downto 0);
			DONE_CURSOR,DONE_COLOUR,LCD_CS_N,LCD_WR_N,LCD_RS: out std_logic;
			LCD_DATA: out std_logic_vector(15 downto 0)
		);
	end component;
	
	
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
	
	component uart_ctrl
		port(
			CLK, RESET_L: in std_logic;
			NEWOP, DONE_ORDER: in std_logic;
			DAT: in std_logic_vector(7 downto 0);
			DONE_OP,DRAW_FIG,DEL_SCREEN, DIAG, VERT, HORIZ, EQUIL, ROMBO, ROMBOIDE, TRAP, TRIAN, PATRON, HEXAG, LED_POS, LED_SIG, DEFAULT: out std_logic;
			COLOUR_CODE: out std_logic_vector(2 downto 0);
			UART_XCOL: out std_logic_vector(7 downto 0);
			UART_YROW: out std_logic_vector(8 downto 0)
		);
	end component;
	  
	signal clk,reset,reset_l 		:	std_logic;

	-- setup
	signal 		LT24_Init_Done		: 	std_logic;
	signal  	LT24_CS_N_Int		:	std_logic;
	signal  	LT24_RS_Int			:	std_logic;
	signal  	LT24_WR_N_Int		:	std_logic;
	signal  	LT24_RD_N_Int		:	std_logic;
	signal  	LT24_D_Int			:	std_logic_vector(15 downto 0);
  
  
	-- ctrl
	signal	OP_SETCURSOR 			:  std_logic;
	signal	OP_DRAWCOLOUR 			:  std_logic;
	signal	DONE_CURSOR 			:  std_logic;
	signal	DONE_COLOUR 			:  std_logic;
	signal	XCOL 					:  std_logic_vector(7 downto 0);
	signal	YROW 					:  std_logic_vector(8 downto 0);
	signal	RGB 					:  std_logic_vector(15 downto 0);
	signal	NUM_PIX 				: 	unsigned(16 downto 0);
	signal 	LCD_CS_N 				:  std_logic;
	signal	LCD_RS 					:  std_logic;
	signal	LCD_WR_N 				:  std_logic;
	signal	LCD_DATA				: 	std_logic_vector(15 downto 0);
	signal	LCD_Init_Done 			:  std_logic;
  
	-- drawing
	signal 	HORIZ 					: 	std_logic;
	signal 	TRIAN 					: 	std_logic;
	signal 	MIRROR 					: 	std_logic;
	signal 	EQUIL 					: 	std_logic;
	signal 	ROMBO 					: 	std_logic;
	signal 	ROMBOIDE 				: 	std_logic;
	signal 	TRAP 					: 	std_logic;
	signal 	PATRON 					: 	std_logic;
	signal 	VERT 					: 	std_logic;
	signal 	DIAG 					: 	std_logic;
	signal 	HEXAG 					: 	std_logic;
	signal	COLOUR_CODE 			:  std_logic_vector(2 downto 0);
	signal 	DEL_SCREEN 				: 	std_logic;
	signal 	DRAW_FIG 				: 	std_logic;
	
	-- uart
	signal 	VEL						:  std_logic_vector(1 downto 0);
	signal 	DONE_OP				:	std_logic;
	signal 	DAT					:  std_logic_vector (7 downto 0);
	signal 	LED						:  std_logic;
	signal 	NEWOP				:	std_logic;
	
	--uart ctrl
	signal 	DONE_ORDER				:	std_logic;
	signal 	DEFAULT					:	std_logic;
	signal 	LED_POS					:	std_logic;
	signal 	LED_SIG					:	std_logic;
	signal	UART_XCOL				:  std_logic_vector(7 downto 0);
	signal	UART_YROW				:  std_logic_vector(8 downto 0);
	
	begin 
		clk <= CLOCK_50;
		
		LT24_RD_N_Int<='1'; -- no usaremos la funcionalidad táctil.

		reset_l	<=		KEY(0);

		MIRROR <= 		not(KEY(1));	
		
		
		VEL <= SW(8 downto 7);
		LEDR(4)  <= LED_POS;
		LEDR(5)  <= LED_SIG;
		LEDR(6)  <= LED;
		LEDR(7)  <= SW(7); --para comprobar visualmente que el switch está activado 
		LEDR(8)  <= SW(8); --para comprobar visualmente que el switch está activado 
		LEDR(9)  <= LT24_Init_Done; --para comprobar visualmente que funciona
		
		--D
		HEX5(1) <= '0';
		HEX5(2) <= '0';
		HEX5(3) <= '0';
		HEX5(4) <= '0';
		HEX5(5) <= '1';
		HEX5(6) <= '0';
		
		--C
		HEX4(0) <= '0';
		HEX4(1) <= '1';
		HEX4(2) <= '1';
		HEX4(3) <= '0';
		HEX4(4) <= '0';
		HEX4(5) <= '0';
		
		--S
		HEX3(0) <= '0';
		HEX3(1) <= '1';
		HEX3(2) <= '0';
		HEX3(3) <= '0';
		HEX3(4) <= '1';
		HEX3(5) <= '0';
		HEX3(6) <= '0';
		
		--D
		HEX2(1) <= '0';
		HEX2(2) <= '0';
		HEX2(3) <= '0';
		HEX2(4) <= '0';
		HEX2(5) <= '1';
		HEX2(6) <= '0';
		
		--G
		HEX1(0) <= '0';
		HEX1(1) <= '1';
		HEX1(2) <= '0';
		HEX1(3) <= '0';
		HEX1(4) <= '0';
		HEX1(5) <= '0';
		
		--4
		HEX0(1) <= '0';
		HEX0(2) <= '0';
		HEX0(3) <= '1';
		HEX0(4) <= '1';
		HEX0(5) <= '0';
		HEX0(6) <= '0';
		
		
		
		-- Union de componentes        --------------    
		--    señal de entrada del componente     => señal a la que se va ha enlazar
		O1_SETUP:LT24Setup 
		port map(
			clk          => clk,
			reset_l      => reset_l,

			-- entradas
			LT24_CS_N_Int       => LT24_CS_N_Int,
			LT24_RS_Int         => LT24_RS_Int,
			LT24_WR_N_Int       => LT24_WR_N_Int,
			LT24_RD_N_Int       => LT24_RD_N_Int,
			LT24_D_Int          => LT24_D_Int,
			
			-- salidas
			LT24_LCD_ON      => LT24_LCD_ON,
			LT24_RESET_N     => LT24_RESET_N,
			LT24_CS_N        => LT24_CS_N,
			LT24_RS          => LT24_RS,
			LT24_WR_N        => LT24_WR_N,
			LT24_RD_N        => LT24_RD_N,
			LT24_D           => LT24_D,  
			LT24_Init_Done   => LT24_Init_Done
		 );
		   



		O2_LCDDRAW: LCD_DRAWING
		port map (
			CLK =>  clk,
			RESET_L => reset_l,

			-- entradas
			DEL_SCREEN => DEL_SCREEN,
			DRAW_FIG => DRAW_FIG, 
			HORIZ => HORIZ,
			VERT => VERT,
			DIAG => DIAG,
			TRIAN => TRIAN,
			MIRROR => MIRROR,
			EQUIL => EQUIL,
			ROMBO => ROMBO,
			ROMBOIDE  => ROMBOIDE,
			TRAP => TRAP,
			PATRON => PATRON,
			HEXAG => HEXAG,
			
			DONE_CURSOR => DONE_CURSOR,
			DONE_COLOUR =>  DONE_COLOUR,
			COLOUR_CODE => COLOUR_CODE,
			DEFAULT => DEFAULT,
			UART_XCOL => UART_XCOL,
			UART_YROW => UART_YROW,

			-- salidas
			OP_SETCURSOR => OP_SETCURSOR,
			OP_DRAWCOLOUR => OP_DRAWCOLOUR,
			XCOL => XCOL,
			YROW => YROW,
			RGB => RGB,
			NUM_PIX => NUM_PIX,
			DONE_ORDER=>DONE_ORDER
		);
			
		O3_LCDCONT: LCD_CTRL
		port map (
			-- entradas
			RESET_L => reset_l,
			CLK	=> clk,
			LCD_INIT_DONE	=> LT24_Init_Done,
			OP_SETCURSOR	=> OP_SETCURSOR,
			XCOL	=>	XCOL,
			YROW => YROW,
			OP_DRAWCOLOUR => OP_DRAWCOLOUR,
			RGB => RGB,
			NUM_PIX => NUM_PIX,
				
			-- salidas
			DONE_CURSOR => DONE_CURSOR,
			DONE_COLOUR => DONE_COLOUR,
			LCD_CS_N => LT24_CS_N_Int,
			LCD_RS => LT24_RS_Int,
			LCD_WR_N => LT24_WR_N_Int,
			LCD_DATA => LT24_D_Int 
		);
		
		
		O4_LCDUART: UART
		port map (
			-- entradas
			RESET_L => reset_l,
			CLK	=> clk,
			Rx => Rx,
			VEL => VEL,
			DONE_OP=>DONE_OP,
			---RTS => RTS,
			
			-- salidas
			--CTS => CTS,
			DAT => DAT,
			LED => LED,
			NEWOP => NEWOP
			
		);
		
		O5_LCDUARTCTRL: UART_CTRL
		port map (
			-- entradas
			RESET_L => reset_l,
			CLK	=> clk,
			NEWOP => NEWOP,
			DONE_ORDER => DONE_ORDER,
			DAT => DAT,
			
			-- salidas
			DONE_OP => DONE_OP,
			DRAW_FIG => DRAW_FIG,
			DEL_SCREEN => DEL_SCREEN,
			VERT=> VERT,
			DIAG => DIAG,
			HORIZ => HORIZ,
			EQUIL => EQUIL,
			ROMBO => ROMBO,
			ROMBOIDE => ROMBOIDE,
			TRAP => TRAP,
			TRIAN => TRIAN,
			PATRON => PATRON,
			HEXAG => HEXAG,
			COLOUR_CODE => COLOUR_CODE,
			DEFAULT => DEFAULT,
			LED_POS => LED_POS,
			LED_SIG => LED_SIG,
			UART_XCOL => UART_XCOL,
			UART_YROW => UART_YROW
		);
END str;
