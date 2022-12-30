onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Entradas
add wave -noupdate -label CLK /tb_lcd_drawing/DUT/CLK
add wave -noupdate -label RESET_L /tb_lcd_drawing/DUT/RESET_L
add wave -noupdate -color Yellow -label DEFAULT /tb_lcd_drawing/DUT/DEFAULT
add wave -noupdate -color white -label DONE_CURSOR /tb_lcd_drawing/DUT/DONE_CURSOR
add wave -noupdate -color cyan -label DONE_COLOUR /tb_lcd_drawing/DUT/DONE_COLOUR
add wave -noupdate -color orange -label DEL_SCREEN /tb_lcd_drawing/DUT/DEL_SCREEN
add wave -noupdate -color orange -label DRAW_FIG /tb_lcd_drawing/DUT/DRAW_FIG
add wave -noupdate -color orange -label HORIZ /tb_lcd_drawing/DUT/HORIZ
add wave -noupdate -color orange -label VERT /tb_lcd_drawing/DUT/VERT
add wave -noupdate -color orange -label DIAG /tb_lcd_drawing/DUT/DIAG
add wave -noupdate -color orange -label MIRROR /tb_lcd_drawing/DUT/MIRROR
add wave -noupdate -color orange -label TRIAN /tb_lcd_drawing/DUT/TRIAN
add wave -noupdate -color orange -label EQUIL /tb_lcd_drawing/DUT/EQUIL
add wave -noupdate -color orange -label ROMBO /tb_lcd_drawing/DUT/ROMBO
add wave -noupdate -color orange -label ROMBOIDE /tb_lcd_drawing/DUT/ROMBOIDE
add wave -noupdate -color orange -label TRAP /tb_lcd_drawing/DUT/TRAP
add wave -noupdate -color orange -label PATRON /tb_lcd_drawing/DUT/PATRON
add wave -noupdate -color orange -label HEXAG /tb_lcd_drawing/DUT/HEXAG
add wave -noupdate -color Yellow -label COLOUR_CODE -radix unsigned /tb_lcd_drawing/DUT/COLOUR_CODE
add wave -noupdate -color Yellow -label UART_XCOL -radix unsigned /tb_lcd_drawing/DUT/UART_XCOL
add wave -noupdate -color Yellow -label UART_YROW -radix unsigned /tb_lcd_drawing/DUT/UART_YROW
add wave -noupdate -divider Salidas
add wave -noupdate -color WHITe -label OP_SETCURSOR /tb_lcd_drawing/DUT/OP_SETCURSOR
add wave -noupdate -color Magenta -label XCOL -radix unsigned /tb_lcd_drawing/DUT/XCOL
add wave -noupdate -color Magenta -label YROW -radix unsigned /tb_lcd_drawing/DUT/YROW
add wave -noupdate -color cyan -label OP_DRAWCOLOUR /tb_lcd_drawing/DUT/OP_DRAWCOLOUR
add wave -noupdate -color Magenta -label RGB /tb_lcd_drawing/DUT/RGB
add wave -noupdate -color Magenta -label NUM_PIX -radix unsigned /tb_lcd_drawing/DUT/NUM_PIX
add wave -noupdate -color orange -label DONE_ORDER /tb_lcd_drawing/DUT/DONE_ORDER
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {7999465 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 244
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
WaveRestoreZoom {0 ps} {8400 ns}
