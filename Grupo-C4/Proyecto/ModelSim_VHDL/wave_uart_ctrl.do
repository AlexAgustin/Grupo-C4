onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Entradas
add wave -noupdate -label CLK /tb_uart_ctrl/DUT/CLK
add wave -noupdate -label RESET_L /tb_uart_ctrl/DUT/RESET_L
add wave -noupdate -color White -label NEWOP /tb_uart_ctrl/DUT/NEWOP
add wave -noupdate -color White -label DONE_ORDER /tb_uart_ctrl/DUT/DONE_ORDER
add wave -noupdate -color Magenta -label DAT -radix ascii -radixshowbase 0 /tb_uart_ctrl/DUT/DAT
add wave -noupdate -divider Salidas
add wave -noupdate -color White -label DONE_OP /tb_uart_ctrl/DUT/DONE_OP
add wave -noupdate -color Orange -label DRAW_FIG /tb_uart_ctrl/DUT/DRAW_FIG
add wave -noupdate -color Orange -label DEL_SCREEN /tb_uart_ctrl/DUT/DEL_SCREEN
add wave -noupdate -color Orange -label DIAG /tb_uart_ctrl/DUT/DIAG
add wave -noupdate -color Orange -label VERT /tb_uart_ctrl/DUT/VERT
add wave -noupdate -color Orange -label HORIZ /tb_uart_ctrl/DUT/HORIZ
add wave -noupdate -color Orange -label EQUIL /tb_uart_ctrl/DUT/EQUIL
add wave -noupdate -color Orange -label ROMBO /tb_uart_ctrl/DUT/ROMBO
add wave -noupdate -color Orange -label ROMBOIDE /tb_uart_ctrl/DUT/ROMBOIDE
add wave -noupdate -color Orange -label TRAP /tb_uart_ctrl/DUT/TRAP
add wave -noupdate -color Orange -label TRIAN /tb_uart_ctrl/DUT/TRIAN
add wave -noupdate -color Cyan -label LED_POS /tb_uart_ctrl/DUT/LED_POS
add wave -noupdate -color Cyan -label LED_SIG /tb_uart_ctrl/DUT/LED_SIG
add wave -noupdate -color Yellow -label DEFAULT /tb_uart_ctrl/DUT/DEFAULT
add wave -noupdate -color Magenta -label COLOUR_CODE -radix unsigned /tb_uart_ctrl/DUT/COLOUR_CODE
add wave -noupdate -color Magenta -label UART_XCOL -radix unsigned /tb_uart_ctrl/DUT/UART_XCOL
add wave -noupdate -color Magenta -label UART_YROW -radix unsigned /tb_uart_ctrl/DUT/UART_YROW
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 140
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
WaveRestoreZoom {0 ps} {5378934 ps}
