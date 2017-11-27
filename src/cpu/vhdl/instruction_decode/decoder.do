onerror {resume}
vsim -gui -novopt work.decode_TB
quietly virtual signal -install /decode_tb { /decode_tb/ID_CNTRL_s(4 downto 0)} OPA
quietly virtual signal -install /decode_tb { /decode_tb/ID_CNTRL_s(9 downto 5)} OPB
quietly virtual signal -install /decode_tb { /decode_tb/EX_CNTRL_s(16 downto 10)} funct7
quietly virtual signal -install /decode_tb { /decode_tb/EX_CNTRL_s(9 downto 7)} funct3
quietly virtual signal -install /decode_tb { /decode_tb/EX_CNTRL_s(6 downto 0)} op_code
quietly virtual signal -install /decode_tb {/decode_tb/ID_CNTRL_s(10)  } imm_mux
quietly virtual signal -install /decode_tb {/decode_tb/ID_CNTRL_s(11)  } pc_en
quietly virtual signal -install /decode_tb { /decode_tb/IFR_s(6 downto 0)} op_code001
quietly virtual signal -install /decode_tb { /decode_tb/IFR_s(6 downto 0)} ifr_op_code
quietly virtual signal -install /decode_tb { /decode_tb/IFR_s(11 downto 7)} rd
quietly virtual signal -install /decode_tb { /decode_tb/IFR_s(19 downto 15)} rs1
quietly virtual signal -install /decode_tb { /decode_tb/IFR_s(24 downto 20)} rs2
quietly virtual signal -install /decode_tb { /decode_tb/IFR_s(14 downto 12)} ifr_funct3
quietly virtual signal -install /decode_tb { /decode_tb/IFR_s(31 downto 25)} ifr_funct7
quietly virtual signal -install /decode_tb { /decode_tb/WB_CNTRL_s(4 downto 0)} wb_rd
quietly virtual signal -install /decode_tb { /decode_tb/EX_CNTRL_s(16 downto 10)} ex_funct7
quietly virtual signal -install /decode_tb { /decode_tb/EX_CNTRL_s(9 downto 7)} ex_funct3
quietly virtual signal -install /decode_tb { /decode_tb/EX_CNTRL_s(6 downto 0)} ex_op_code
quietly virtual signal -install /decode_tb {/decode_tb/WB_CNTRL_s(5)  } pc_Mux
quietly WaveActivateNextPane {} 0
add wave -noupdate /decode_tb/branch_s
add wave -noupdate -radix binary -radixshowbase 0 /decode_tb/IFR_s
add wave -noupdate -radix binary /decode_tb/ifr_funct3
add wave -noupdate -radix binary /decode_tb/ifr_funct7
add wave -noupdate -radix decimal /decode_tb/rs2
add wave -noupdate -radix decimal /decode_tb/rs1
add wave -noupdate -radix decimal /decode_tb/rd
add wave -noupdate -radix binary -radixshowbase 0 /decode_tb/ifr_op_code
add wave -noupdate -divider -height 40 IF_CNTRL
add wave -noupdate -radix binary -radixshowbase 0 /decode_tb/IF_CNTRL_s
add wave -noupdate -divider -height 40 ID_CNTRL
add wave -noupdate /decode_tb/pc_en
add wave -noupdate /decode_tb/imm_mux
add wave -noupdate -radix decimal /decode_tb/OPB
add wave -noupdate -radix decimal /decode_tb/OPA
add wave -noupdate -radix decimal -radixshowbase 0 /decode_tb/Imm_s
add wave -noupdate -divider -height 40 EX_CNTRL
add wave -noupdate -radix binary /decode_tb/ex_funct7
add wave -noupdate -radix binary /decode_tb/ex_funct3
add wave -noupdate -radix binary /decode_tb/ex_op_code
add wave -noupdate -divider -height 40 MA_CNTRL
add wave -noupdate -radix binary -childformat {{/decode_tb/MA_CNTRL_s(1) -radix binary} {/decode_tb/MA_CNTRL_s(0) -radix binary}} -radixshowbase 0 -subitemconfig {/decode_tb/MA_CNTRL_s(1) {-radix binary -radixshowbase 0} /decode_tb/MA_CNTRL_s(0) {-radix binary -radixshowbase 0}} /decode_tb/MA_CNTRL_s
add wave -noupdate -divider -height 40 WB_CNTRL
add wave -noupdate /decode_tb/pc_Mux
add wave -noupdate -radix decimal /decode_tb/wb_rd
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {399 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 224
configure wave -valuecolwidth 241
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
WaveRestoreZoom {226 ps} {1818 ps}
run -all
