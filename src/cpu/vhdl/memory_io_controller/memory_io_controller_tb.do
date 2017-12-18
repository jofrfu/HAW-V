onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label simulation_running /memory_io_controller_tb/simulation_running
add wave -noupdate -label reset /memory_io_controller_tb/reset
add wave -noupdate -label CLK /memory_io_controller_tb/CLK
add wave -noupdate -divider input
add wave -noupdate -label WORD_LENGTH /memory_io_controller_tb/WORD_LENGTH
add wave -noupdate -label EN /memory_io_controller_tb/EN
add wave -noupdate -label WEN /memory_io_controller_tb/WEN
add wave -noupdate -label DIN /memory_io_controller_tb/DIN
add wave -noupdate -label ADDR /memory_io_controller_tb/ADDR
add wave -noupdate -divider input_periph
add wave -noupdate -label PERIPH_IN_EN /memory_io_controller_tb/PERIPH_IN_EN
add wave -noupdate -divider input_mem
add wave -noupdate -label PERIPH_IN /memory_io_controller_tb/PERIPH_IN
add wave -noupdate -label pc_asynch /memory_io_controller_tb/pc_asynch
add wave -noupdate -divider output
add wave -noupdate -label PERIPH_OUT /memory_io_controller_tb/PERIPH_OUT
add wave -noupdate -label DOUT /memory_io_controller_tb/DOUT
add wave -noupdate -label instruction /memory_io_controller_tb/instruction
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 165
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
WaveRestoreZoom {0 ns} {1399 ns}
