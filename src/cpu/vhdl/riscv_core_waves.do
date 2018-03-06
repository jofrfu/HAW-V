onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider -height 20 {clk, reset}
add wave -noupdate -label Clock /risc_v_core_tb/clk
add wave -noupdate -label Reset /risc_v_core_tb/reset
add wave -noupdate -divider -height 50 {Instruction Memory}
add wave -noupdate -label PC -radix hexadecimal /risc_v_core_tb/pc_asynch
add wave -noupdate -label Instruction -radix binary /risc_v_core_tb/instruction
add wave -noupdate -divider -height 50 {Data Memory}
add wave -noupdate -label {Data Memory Enable} /risc_v_core_tb/EN
add wave -noupdate -label {Write Enable} -radix binary /risc_v_core_tb/BYTE_WRITE_EN_s
add wave -noupdate -label {Data Address} -radix hexadecimal /risc_v_core_tb/ADDR
add wave -noupdate -label {Data TO Memory} -radix decimal /risc_v_core_tb/D_CORE_to_MEM
add wave -noupdate -label {Data FROM Memory} -radix decimal /risc_v_core_tb/D_MEM_to_CORE
add wave -noupdate -divider -height 50 {Register File}
add wave -noupdate -label x1 -radix decimal -radixshowbase 0 /risc_v_core_tb/dut_i/instruction_decode_i/reg_sel_i/register_generate(1)/reg_i/reg_out
add wave -noupdate -label x2 -radix decimal -radixshowbase 0 /risc_v_core_tb/dut_i/instruction_decode_i/reg_sel_i/register_generate(2)/reg_i/reg_out
add wave -noupdate -label x3 -radix decimal -radixshowbase 0 /risc_v_core_tb/dut_i/instruction_decode_i/reg_sel_i/register_generate(3)/reg_i/reg_out
add wave -noupdate -label x4 -radix decimal -radixshowbase 0 /risc_v_core_tb/dut_i/instruction_decode_i/reg_sel_i/register_generate(4)/reg_i/reg_out
add wave -noupdate -label x5 -radix decimal -radixshowbase 0 /risc_v_core_tb/dut_i/instruction_decode_i/reg_sel_i/register_generate(5)/reg_i/reg_out
add wave -noupdate -label x6 -radix decimal -radixshowbase 0 /risc_v_core_tb/dut_i/instruction_decode_i/reg_sel_i/register_generate(6)/reg_i/reg_out
add wave -noupdate -label x7 -radix decimal -radixshowbase 0 /risc_v_core_tb/dut_i/instruction_decode_i/reg_sel_i/register_generate(7)/reg_i/reg_out
add wave -noupdate -label x8 -radix decimal -radixshowbase 0 /risc_v_core_tb/dut_i/instruction_decode_i/reg_sel_i/register_generate(8)/reg_i/reg_out
add wave -noupdate -label x9 -radix decimal -radixshowbase 0 /risc_v_core_tb/dut_i/instruction_decode_i/reg_sel_i/register_generate(9)/reg_i/reg_out
add wave -noupdate -label x10 -radix decimal -radixshowbase 0 /risc_v_core_tb/dut_i/instruction_decode_i/reg_sel_i/register_generate(10)/reg_i/reg_out
add wave -noupdate -label x11 -radix decimal -radixshowbase 0 /risc_v_core_tb/dut_i/instruction_decode_i/reg_sel_i/register_generate(11)/reg_i/reg_out
add wave -noupdate -label x12 -radix decimal -radixshowbase 0 /risc_v_core_tb/dut_i/instruction_decode_i/reg_sel_i/register_generate(12)/reg_i/reg_out
add wave -noupdate -label x13 -radix decimal -radixshowbase 0 /risc_v_core_tb/dut_i/instruction_decode_i/reg_sel_i/register_generate(13)/reg_i/reg_out
add wave -noupdate -label x14 -radix decimal -radixshowbase 0 /risc_v_core_tb/dut_i/instruction_decode_i/reg_sel_i/register_generate(14)/reg_i/reg_out
add wave -noupdate -label x15 -radix decimal -radixshowbase 0 /risc_v_core_tb/dut_i/instruction_decode_i/reg_sel_i/register_generate(15)/reg_i/reg_out
add wave -noupdate -label x16 -radix decimal -radixshowbase 0 /risc_v_core_tb/dut_i/instruction_decode_i/reg_sel_i/register_generate(16)/reg_i/reg_out
add wave -noupdate -label x17 -radix decimal -radixshowbase 0 /risc_v_core_tb/dut_i/instruction_decode_i/reg_sel_i/register_generate(17)/reg_i/reg_out
add wave -noupdate -label x18 -radix decimal -radixshowbase 0 /risc_v_core_tb/dut_i/instruction_decode_i/reg_sel_i/register_generate(18)/reg_i/reg_out
add wave -noupdate -label x19 -radix decimal -radixshowbase 0 /risc_v_core_tb/dut_i/instruction_decode_i/reg_sel_i/register_generate(19)/reg_i/reg_out
add wave -noupdate -label x20 -radix decimal -radixshowbase 0 /risc_v_core_tb/dut_i/instruction_decode_i/reg_sel_i/register_generate(20)/reg_i/reg_out
add wave -noupdate -label x21 -radix decimal -radixshowbase 0 /risc_v_core_tb/dut_i/instruction_decode_i/reg_sel_i/register_generate(21)/reg_i/reg_out
add wave -noupdate -label x22 -radix decimal -radixshowbase 0 /risc_v_core_tb/dut_i/instruction_decode_i/reg_sel_i/register_generate(22)/reg_i/reg_out
add wave -noupdate -label x23 -radix decimal -radixshowbase 0 /risc_v_core_tb/dut_i/instruction_decode_i/reg_sel_i/register_generate(23)/reg_i/reg_out
add wave -noupdate -label x24 -radix decimal -radixshowbase 0 /risc_v_core_tb/dut_i/instruction_decode_i/reg_sel_i/register_generate(24)/reg_i/reg_out
add wave -noupdate -label x25 -radix decimal -radixshowbase 0 /risc_v_core_tb/dut_i/instruction_decode_i/reg_sel_i/register_generate(25)/reg_i/reg_out
add wave -noupdate -label x26 -radix decimal -radixshowbase 0 /risc_v_core_tb/dut_i/instruction_decode_i/reg_sel_i/register_generate(26)/reg_i/reg_out
add wave -noupdate -label x27 -radix decimal -radixshowbase 0 /risc_v_core_tb/dut_i/instruction_decode_i/reg_sel_i/register_generate(27)/reg_i/reg_out
add wave -noupdate -label x28 -radix decimal -radixshowbase 0 /risc_v_core_tb/dut_i/instruction_decode_i/reg_sel_i/register_generate(28)/reg_i/reg_out
add wave -noupdate -label x29 -radix decimal -radixshowbase 0 /risc_v_core_tb/dut_i/instruction_decode_i/reg_sel_i/register_generate(29)/reg_i/reg_out
add wave -noupdate -label x30 -radix decimal -radixshowbase 0 /risc_v_core_tb/dut_i/instruction_decode_i/reg_sel_i/register_generate(30)/reg_i/reg_out
add wave -noupdate -label x31 -radix decimal -radixshowbase 0 /risc_v_core_tb/dut_i/instruction_decode_i/reg_sel_i/register_generate(31)/reg_i/reg_out
add wave -noupdate -divider -height 50 IF
add wave -noupdate -divider in
add wave -noupdate /risc_v_core_tb/dut_i/instruction_fetch_i/branch
add wave -noupdate /risc_v_core_tb/dut_i/instruction_fetch_i/cntrl
add wave -noupdate /risc_v_core_tb/dut_i/instruction_fetch_i/rel
add wave -noupdate /risc_v_core_tb/dut_i/instruction_fetch_i/abso
add wave -noupdate /risc_v_core_tb/dut_i/instruction_fetch_i/ins
add wave -noupdate -divider out
add wave -noupdate /risc_v_core_tb/dut_i/instruction_fetch_i/IFR
add wave -noupdate /risc_v_core_tb/dut_i/instruction_fetch_i/pc_asynch
add wave -noupdate /risc_v_core_tb/dut_i/instruction_fetch_i/pc_synch
add wave -noupdate /risc_v_core_tb/dut_i/instruction_fetch_i/IFR_cs
add wave -noupdate -divider -height 50 ID
add wave -noupdate -divider in
add wave -noupdate /risc_v_core_tb/dut_i/instruction_decode_i/branch
add wave -noupdate /risc_v_core_tb/dut_i/instruction_decode_i/IFR
add wave -noupdate /risc_v_core_tb/dut_i/instruction_decode_i/PC
add wave -noupdate /risc_v_core_tb/dut_i/instruction_decode_i/DI
add wave -noupdate /risc_v_core_tb/dut_i/instruction_decode_i/rd
add wave -noupdate -divider out
add wave -noupdate /risc_v_core_tb/dut_i/instruction_decode_i/IF_CNTRL
add wave -noupdate /risc_v_core_tb/dut_i/instruction_decode_i/WB_CNTRL
add wave -noupdate /risc_v_core_tb/dut_i/instruction_decode_i/MA_CNTRL
add wave -noupdate /risc_v_core_tb/dut_i/instruction_decode_i/EX_CNTRL
add wave -noupdate /risc_v_core_tb/dut_i/instruction_decode_i/Imm
add wave -noupdate /risc_v_core_tb/dut_i/instruction_decode_i/OPB
add wave -noupdate /risc_v_core_tb/dut_i/instruction_decode_i/OPA
add wave -noupdate /risc_v_core_tb/dut_i/instruction_decode_i/DO
add wave -noupdate /risc_v_core_tb/dut_i/instruction_decode_i/PC_o
add wave -noupdate -divider -height 50 EX
add wave -noupdate -divider in
add wave -noupdate /risc_v_core_tb/dut_i/execute_stage_i/WB_CNTRL_IN
add wave -noupdate /risc_v_core_tb/dut_i/execute_stage_i/MA_CNTRL_IN
add wave -noupdate /risc_v_core_tb/dut_i/execute_stage_i/EX_CNTRL_IN
add wave -noupdate /risc_v_core_tb/dut_i/execute_stage_i/Imm
add wave -noupdate /risc_v_core_tb/dut_i/execute_stage_i/OPB
add wave -noupdate /risc_v_core_tb/dut_i/execute_stage_i/OPA
add wave -noupdate /risc_v_core_tb/dut_i/execute_stage_i/DO_IN
add wave -noupdate /risc_v_core_tb/dut_i/execute_stage_i/PC_IN
add wave -noupdate -divider out
add wave -noupdate /risc_v_core_tb/dut_i/execute_stage_i/WB_CNTRL_OUT
add wave -noupdate /risc_v_core_tb/dut_i/execute_stage_i/MA_CNTRL_OUT_SYNCH
add wave -noupdate /risc_v_core_tb/dut_i/execute_stage_i/MA_CNTRL_OUT_ASYNCH
add wave -noupdate /risc_v_core_tb/dut_i/execute_stage_i/WORD_CNTRL_OUT_SYNCH
add wave -noupdate /risc_v_core_tb/dut_i/execute_stage_i/WORD_CNTRL_OUT_ASYNCH
add wave -noupdate /risc_v_core_tb/dut_i/execute_stage_i/SIGN_EN
add wave -noupdate /risc_v_core_tb/dut_i/execute_stage_i/RESU_DAR_SYNCH
add wave -noupdate /risc_v_core_tb/dut_i/execute_stage_i/RESU_DAR_ASYNCH
add wave -noupdate /risc_v_core_tb/dut_i/execute_stage_i/Branch
add wave -noupdate /risc_v_core_tb/dut_i/execute_stage_i/ABS_OUT
add wave -noupdate /risc_v_core_tb/dut_i/execute_stage_i/REL_OUT
add wave -noupdate /risc_v_core_tb/dut_i/execute_stage_i/DO_OUT
add wave -noupdate /risc_v_core_tb/dut_i/execute_stage_i/PC_OUT
add wave -noupdate -divider -height 50 MA
add wave -noupdate -divider in
add wave -noupdate /risc_v_core_tb/dut_i/memory_access_i/WB_CNTRL_IN
add wave -noupdate /risc_v_core_tb/dut_i/memory_access_i/MA_CNTRL_SYNCH
add wave -noupdate /risc_v_core_tb/dut_i/memory_access_i/MA_CNTRL_ASYNCH
add wave -noupdate /risc_v_core_tb/dut_i/memory_access_i/WORD_CNTRL_SYNCH
add wave -noupdate /risc_v_core_tb/dut_i/memory_access_i/WORD_CNTRL_ASYNCH
add wave -noupdate /risc_v_core_tb/dut_i/memory_access_i/SIGN_EN
add wave -noupdate /risc_v_core_tb/dut_i/memory_access_i/RESU_SYNCH
add wave -noupdate /risc_v_core_tb/dut_i/memory_access_i/RESU_ASYNCH
add wave -noupdate /risc_v_core_tb/dut_i/memory_access_i/DO
add wave -noupdate /risc_v_core_tb/dut_i/memory_access_i/PC_IN
add wave -noupdate /risc_v_core_tb/dut_i/memory_access_i/DATA_IN
add wave -noupdate -divider out
add wave -noupdate /risc_v_core_tb/dut_i/memory_access_i/WB_CNTRL_OUT
add wave -noupdate /risc_v_core_tb/dut_i/memory_access_i/DI
add wave -noupdate /risc_v_core_tb/dut_i/memory_access_i/PC_OUT
add wave -noupdate /risc_v_core_tb/dut_i/memory_access_i/ENABLE
add wave -noupdate /risc_v_core_tb/dut_i/memory_access_i/WRITE_EN
add wave -noupdate /risc_v_core_tb/dut_i/memory_access_i/DATA_OUT
add wave -noupdate /risc_v_core_tb/dut_i/memory_access_i/ADDRESS
add wave -noupdate /risc_v_core_tb/dut_i/memory_access_i/WORD_LENGTH
add wave -noupdate -divider -height 50 WB
add wave -noupdate -divider in
add wave -noupdate /risc_v_core_tb/dut_i/write_back_i/WB_CNTRL_IN
add wave -noupdate /risc_v_core_tb/dut_i/write_back_i/DATA_IN
add wave -noupdate /risc_v_core_tb/dut_i/write_back_i/PC_IN
add wave -noupdate -divider out
add wave -noupdate /risc_v_core_tb/dut_i/write_back_i/REG_ADDR
add wave -noupdate /risc_v_core_tb/dut_i/write_back_i/WRITE_BACK
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {107692 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 499
configure wave -valuecolwidth 213
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
WaveRestoreZoom {161227 ps} {1849377 ps}
