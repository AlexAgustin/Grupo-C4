library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DE1SOC_LCDLT24_1fas is
 port(
	-- CLOCK ----------------
	CLOCK_50	: in	std_logic;
--	CLOCK2_50	: in	std_logic;
--	CLOCK3_50	: in	std_logic;
--	CLOCK4_50	: in	std_logic;
	-- KEY ----------------
	KEY 		: in	std_logic_vector(3 downto 0);
--	KEY 		: in	std_logic_vector(3 downto 0);
	-- SW ----------------
	SW 			: in	std_logic_vector(2 downto 0);
--	SW 			: in	std_logic_vector(9 downto 0);
	-- LEDR ----------------
	LEDR 		: out	std_logic_vector(9 downto 0);
--      -- LT24_LCD ----------------
        LT24_LCD_ON     : out std_logic;
        LT24_RESET_N    : out std_logic;
        LT24_CS_N       : out std_logic;
        LT24_RD_N       : out std_logic;
        LT24_RS         : out std_logic;
        LT24_WR_N       : out std_logic;
        LT24_D          : out std_logic_vector(15 downto 0)

	-- GPIO ----------------
--	GPIO_0 		: inout	std_logic_vector(35 downto 0);

	-- SEG7 ----------------
--	HEX0	: out	std_logic_vector(6 downto 0);
--	HEX1	: out	std_logic_vector(6 downto 0);
--	HEX2	: out	std_logic_vector(6 downto 0);
--	HEX3	: out	std_logic_vector(6 downto 0);
--	HEX4	: out	std_logic_vector(6 downto 0);
--	HEX5	: out	std_logic_vector(6 downto 0);

 );
end;

architecture str of DE1SOC_LCDLT24_1fas is 
	
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
      CLK, RESET_L: in std_logic;

      DEL_SCREEN, DRAW_FIG, DONE_CURSOR, DONE_COLOUR: in std_logic;
      COLOUR_CODE: in std_logic_vector(2 downto 0);

      OP_SETCURSOR, OP_DRAWCOLOUR: out std_logic;
      XCOL: out std_logic_vector(7 downto 0);
      YROW: out std_logic_vector(8 downto 0);
      RGB: out std_logic_vector(15 downto 0);
      NUM_PIX: out unsigned(16 downto 0)
		--reset,CLK		: in std_logic;
		--DEL_SCREEN		: in std_logic;
		--DRAW_FIG		: in std_logic;
		--COLOUR			: in std_logic_vector(2 downto 0);
		--DONE_CURSOR,DONE_COLOUR	: in std_logic;
		--SET_CURSOR,DRAW_COLOUR	: out std_logic;
		--COL			: out std_logic_vector(7 downto 0);
               -- ROW			: out std_logic_vector(8 downto 0);
               -- NUMPIX			: out std_logic_vector(16 downto 0);
		--RGB			: out std_logic_vector(15 downto 0)
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
		--reset,CLK		: in 	std_logic;
		--LCD_INIT_DONE		: in std_logic;
		--OP_SETCURSOR		: in	std_logic;
		--XCOL			: in std_logic_vector(7 downto 0);
		--YROW			: in std_logic_vector(8 downto 0);
		--OP_DRAWCOLOUR		: in	std_logic;
		--RGB			: in std_logic_vector(15 downto 0);
		--NUMPIX			: in std_logic_vector(16 downto 0);
		--DONE_CURSOR,DONE_COLOUR	: out std_logic;
		--LCD_CSN,LCD_RS,LCD_WRN	: out std_logic;
		--LCD_DATA		: out std_logic_vector(15 downto 0)
	);
end component;
  
  signal clk,reset,reset_l :  std_logic;


  signal LT24_Init_Done: std_logic;
  signal  LT24_CS_N_Int        :  std_logic;
  signal  LT24_RS_Int          :  std_logic;
  signal  LT24_WR_N_Int        :  std_logic;
  signal  LT24_RD_N_Int        :  std_logic;
  signal  LT24_D_Int           :  std_logic_vector(15 downto 0);
  
  signal	DONE_CURSOR :  std_logic;
  signal	DONE_COLOUR :  std_logic;
  signal	COLOUR_CODE :  std_logic_vector(2 downto 0);

  signal	OP_SETCURSOR :  std_logic;
  signal	OP_DRAWCOLOUR :  std_logic;
  signal	XCOL :  std_logic_vector(7 downto 0);
  signal	YROW :  std_logic_vector(8 downto 0);
  signal	RGB :  std_logic_vector(15 downto 0);
  signal	NUM_PIX : unsigned(16 downto 0);

  signal LCD_CS_N :  std_logic;
  signal	LCD_RS :  std_logic;
  signal	LCD_WR_N :  std_logic;
  signal	LCD_DATA: std_logic_vector(15 downto 0);
  signal	LCD_Init_Done :  std_logic;
  
  signal DEL_SCREEN : std_logic;
  signal DRAW_FIG : std_logic;
  
begin 
   clk <= CLOCK_50;
   reset <= not(KEY(0));
   reset_l<=KEY(0);
	
   LT24_RD_N_Int<='1';

	DEL_SCREEN <= KEY(1);
	DRAW_FIG <= KEY(2);
	COLOUR_CODE <= SW(2 downto 0);
	
    
-- Osagaien elkarketa        --------------    

  O1_SETUP:LT24Setup 
  port map(
      clk          => clk,
      reset_l      => reset_l,
--    señal de entrada del componente     => señal a la que se va ha enlazar
      LT24_LCD_ON      => LT24_LCD_ON,
      LT24_RESET_N     => LT24_RESET_N,
      LT24_CS_N        => LT24_CS_N,
      LT24_RS          => LT24_RS,
      LT24_WR_N        => LT24_WR_N,
      LT24_RD_N        => LT24_RD_N,
      LT24_D           => LT24_D,

      LT24_CS_N_Int       => LT24_CS_N_Int,
      LT24_RS_Int         => LT24_RS_Int,
      LT24_WR_N_Int       => LT24_WR_N_Int,
      LT24_RD_N_Int       => LT24_RD_N_Int,
      LT24_D_Int          => LT24_D_Int,
		
      
      LT24_Init_Done      => LT24_Init_Done
 );
   LEDR(8)  <= LT24_Init_Done; --para comprobar visualmente q funciona



  O2_LCDDRAW: LCD_DRAWING
  port map (
		CLK =>  clk,
		RESET_L => reset_l,

      DEL_SCREEN => DEL_SCREEN,
		DRAW_FIG => DRAW_FIG, 
		DONE_CURSOR => DONE_CURSOR,
		DONE_COLOUR =>  DONE_COLOUR,
      COLOUR_CODE => COLOUR_CODE,

      OP_SETCURSOR => OP_SETCURSOR,
		OP_DRAWCOLOUR => OP_DRAWCOLOUR,
      XCOL => XCOL,
      YROW => YROW,
      RGB => RGB,
      NUM_PIX => NUM_PIX
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
		LCD_CS_N => LCD_CS_N,
		LCD_RS => LCD_RS,
		LCD_WR_N => LCD_WR_N,
		LCD_DATA => LCD_DATA 
		);
  
END str;
