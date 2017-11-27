onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /memory_access_tb/clk_s
add wave -noupdate /memory_access_tb/reset_s
add wave -noupdate /memory_access_tb/simulation_running
add wave -noupdate -divider inputs
add wave -noupdate /memory_access_tb/WB_CNTRL_IN_s
add wave -noupdate /memory_access_tb/MA_CNTRL_s
add wave -noupdate /memory_access_tb/WORD_CNTRL_s
add wave -noupdate /memory_access_tb/RESU_s
add wave -noupdate /memory_access_tb/DO_s
add wave -noupdate /memory_access_tb/PC_IN_s
add wave -noupdate -divider {memory inputs}
add wave -noupdate /memory_access_tb/DATA_IN_s
add wave -noupdate -divider outputs
add wave -noupdate /memory_access_tb/WB_CNTRL_OUT_s
add wave -noupdate /memory_access_tb/DI_s
add wave -noupdate /memory_access_tb/PC_OUT_s
add wave -noupdate -divider {memory outputs}
add wave -noupdate /memory_access_tb/ENABLE_s
add wave -noupdate /memory_access_tb/WRITE_EN_s
add wave -noupdate /memory_access_tb/DATA_OUT_s
add wave -noupdate /memory_access_tb/ADDRESS_s
add wave -noupdate /memory_access_tb/WORD_LENGTH_s
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {80 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 229
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
WaveRestoreZoom {869 ns} {1007 ns}
