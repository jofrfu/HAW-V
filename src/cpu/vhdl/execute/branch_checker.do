onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label simulation_running /branch_checker_tb/simulation_running
add wave -noupdate -divider input
add wave -noupdate -label OPCODE /branch_checker_tb/OP_CODE_s
add wave -noupdate -label OPCODE_BITS -expand /branch_checker_tb/OP_BITS_s
add wave -noupdate -label FUNCT3 /branch_checker_tb/FUNCT3_s
add wave -noupdate -label FLAGS /branch_checker_tb/FLAGS_s
add wave -noupdate -divider output
add wave -noupdate -label BRANCH /branch_checker_tb/BRANCH_s
add wave -noupdate -label SIGN_EN /branch_checker_tb/sign_en_s
add wave -noupdate -label WORD_CNTRL -expand /branch_checker_tb/WORD_CNTRL_s
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 209
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
WaveRestoreZoom {21 ns} {31 ns}
