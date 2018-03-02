onerror {resume}
vsim -gui -novopt work.pc_log_tb
quietly WaveActivateNextPane {} 0
add wave -noupdate /pc_log_tb/abso_s
add wave -noupdate /pc_log_tb/pc_asynch_s
add wave -noupdate /pc_log_tb/pc_synch_s
add wave -noupdate /pc_log_tb/rel_s
add wave -noupdate /pc_log_tb/cntrl_s
add wave -noupdate -divider {Basic Signals}
add wave -noupdate /pc_log_tb/reset_s
add wave -noupdate /pc_log_tb/simulation_running
add wave -noupdate /pc_log_tb/clk_s
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {165 ns} 0}
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
run -all