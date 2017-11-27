onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider inputs
add wave -noupdate /write_back_tb/WB_CNTRL_IN_s
add wave -noupdate /write_back_tb/DATA_IN_s
add wave -noupdate /write_back_tb/PC_IN_s
add wave -noupdate -divider outputs
add wave -noupdate /write_back_tb/REG_ADDR_s
add wave -noupdate /write_back_tb/WRITE_BACK_s
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {588 ns} 0}
quietly wave cursor active 1
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
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {1 us}
