onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /instruction_fetch_tb/clk_s
add wave -noupdate /instruction_fetch_tb/reset_s
add wave -noupdate /instruction_fetch_tb/simulation_running
add wave -noupdate -divider input
add wave -noupdate /instruction_fetch_tb/cntrl_s
add wave -noupdate /instruction_fetch_tb/rel_s
add wave -noupdate /instruction_fetch_tb/abso_s
add wave -noupdate /instruction_fetch_tb/ins_s
add wave -noupdate -divider output
add wave -noupdate /instruction_fetch_tb/pc_asynch_s
add wave -noupdate /instruction_fetch_tb/pc_synch_s
add wave -noupdate /instruction_fetch_tb/IFR_s
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {350 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 219
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
WaveRestoreZoom {8934 ns} {9846 ns}
