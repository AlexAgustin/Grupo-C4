onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Entradas
add wave -noupdate -label CLK /tb_lcd_ctrl/DUT/CLK
add wave -noupdate -label RESET_L /tb_lcd_ctrl/DUT/RESET_L
add wave -noupdate -label LCD_Init_Done /tb_lcd_ctrl/DUT/LCD_Init_Done
add wave -noupdate -color White -label OP_SETCURSOR /tb_lcd_ctrl/DUT/OP_SETCURSOR
add wave -noupdate -color Magenta -label XCOL -radix hexadecimal /tb_lcd_ctrl/DUT/XCOL
add wave -noupdate -color Magenta -label YROW -radix hexadecimal /tb_lcd_ctrl/DUT/YROW
add wave -noupdate -color Cyan -label OP_DRAWCOLOUR /tb_lcd_ctrl/DUT/OP_DRAWCOLOUR
add wave -noupdate -color Magenta -label RGB /tb_lcd_ctrl/DUT/RGB
add wave -noupdate -color Magenta -label NUM_PIX -radix unsigned /tb_lcd_ctrl/DUT/NUM_PIX
add wave -noupdate -divider Salidas
add wave -noupdate -color White -label DONE_CURSOR /tb_lcd_ctrl/DUT/DONE_CURSOR
add wave -noupdate -color Cyan -label DONE_COLOUR /tb_lcd_ctrl/DUT/DONE_COLOUR
add wave -noupdate -color Orange -label LCD_CS_N /tb_lcd_ctrl/DUT/LCD_CS_N
add wave -noupdate -color Orange -label LCD_WR_N /tb_lcd_ctrl/DUT/LCD_WR_N
add wave -noupdate -color Orange -label LCD_RS /tb_lcd_ctrl/DUT/LCD_RS
add wave -noupdate -color Yellow -label LCD_DATA -radix hexadecimal /tb_lcd_ctrl/DUT/LCD_DATA
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 230
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {2982 ns}
