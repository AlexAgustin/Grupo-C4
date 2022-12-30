onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Entradas
add wave -noupdate -label CLK /tb_uart/DUT/CLK
add wave -noupdate -label RESET_L /tb_uart/DUT/RESET_L
add wave -noupdate -color magenta -label Rx /tb_uart/DUT/Rx
add wave -noupdate -color MAGENTA -label VEL /tb_uart/DUT/VEL
add wave -noupdate -color ORANGE -label DONE_OP /tb_uart/DUT/DONE_OP
add wave -noupdate -divider Salidas
add wave -noupdate -color MAGENTA -label DAT /tb_uart/DUT/DAT
add wave -noupdate -color YELLOW -label LED /tb_uart/DUT/LED
add wave -noupdate -color ORANGE -label NEWOP /tb_uart/DUT/NEWOP
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
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
WaveRestoreZoom {7999050 ps} {8000050 ps}
