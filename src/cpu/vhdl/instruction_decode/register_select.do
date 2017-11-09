onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /register_select_tb/clk_s
add wave -noupdate /register_select_tb/reset_s
add wave -noupdate /register_select_tb/simulation_running
add wave -noupdate -divider input
add wave -noupdate -radix unsigned /register_select_tb/DI_s
add wave -noupdate -radix unsigned /register_select_tb/rs1_s
add wave -noupdate -radix unsigned /register_select_tb/rs2_s
add wave -noupdate -radix unsigned /register_select_tb/rd_s
add wave -noupdate -radix unsigned /register_select_tb/PC_s
add wave -noupdate /register_select_tb/Pc_en_s
add wave -noupdate -divider output
add wave -noupdate -radix unsigned /register_select_tb/OPA_s
add wave -noupdate -radix unsigned /register_select_tb/OPB_s
add wave -noupdate -radix unsigned /register_select_tb/DO_s
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1496 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 213
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
WaveRestoreZoom {0 ns} {1575 ns}
