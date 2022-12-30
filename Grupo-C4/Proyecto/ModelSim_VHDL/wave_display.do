onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label CLK /tb_display/DUT/CLK
add wave -noupdate -label RESET_L /tb_display/DUT/RESET_L
add wave -noupdate -color Orange -label LED /tb_display/DUT/LED
add wave -noupdate -color Orange -label LED_POS /tb_display/DUT/LED_POS
add wave -noupdate -color Orange -label LED_SIG /tb_display/DUT/LED_SIG
add wave -noupdate -color Magenta -label DISPL -radix hexadecimal /tb_display/DUT/DISPL
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {270000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 207
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
WaveRestoreZoom {0 ps} {384169 ps}
