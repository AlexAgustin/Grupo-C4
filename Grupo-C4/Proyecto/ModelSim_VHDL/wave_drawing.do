onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Entradas
add wave -noupdate /tb_lcd_drawing/DUT/CLK
add wave -noupdate /tb_lcd_drawing/DUT/RESET_L
add wave -noupdate /tb_lcd_drawing/DUT/DEL_SCREEN
add wave -noupdate /tb_lcd_drawing/DUT/DRAW_FIG
add wave -noupdate /tb_lcd_drawing/DUT/DONE_CURSOR
add wave -noupdate /tb_lcd_drawing/DUT/DONE_COLOUR
add wave -noupdate -radix unsigned /tb_lcd_drawing/DUT/COLOUR_CODE
add wave -noupdate -divider Salidas
add wave -noupdate /tb_lcd_drawing/DUT/OP_SETCURSOR
add wave -noupdate -radix hexadecimal /tb_lcd_drawing/DUT/XCOL
add wave -noupdate -radix hexadecimal /tb_lcd_drawing/DUT/YROW
add wave -noupdate /tb_lcd_drawing/DUT/OP_DRAWCOLOUR
add wave -noupdate /tb_lcd_drawing/DUT/RGB
add wave -noupdate -radix unsigned /tb_lcd_drawing/DUT/NUM_PIX
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1326192 ps} 0}
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
WaveRestoreZoom {0 ps} {1554 ns}
