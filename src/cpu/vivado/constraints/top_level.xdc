# ----------------------------------------------------------------------------
# Clock Source - Bank 13
# ---------------------------------------------------------------------------- 
set_property PACKAGE_PIN Y9 [get_ports {clk}];  # "GCLK"
set_property IOSTANDARD LVCMOS33 [get_ports {clk}];
create_clock -period 20.000 -name clk -waveform {0.000 10.000} [get_ports clk]

set_property PACKAGE_PIN R18 [get_ports {nres}];
set_property IOSTANDARD LVCMOS18 [get_ports {nres}];


# ----------------------------------------------------------------------------
# LEDs - Bank 33
# ---------------------------------------------------------------------------- 
set_property PACKAGE_PIN T22 [get_ports {periph_bit_io[0]}];  # "LD0"
set_property PACKAGE_PIN T21 [get_ports {periph_bit_io[1]}];  # "LD1"
set_property PACKAGE_PIN U22 [get_ports {periph_bit_io[2]}];  # "LD2"
set_property PACKAGE_PIN U21 [get_ports {periph_bit_io[3]}];  # "LD3"
set_property PACKAGE_PIN V22 [get_ports {periph_bit_io[4]}];  # "LD4"
set_property PACKAGE_PIN W22 [get_ports {periph_bit_io[5]}];  # "LD5"
set_property PACKAGE_PIN U19 [get_ports {periph_bit_io[6]}];  # "LD6"
set_property PACKAGE_PIN U14 [get_ports {periph_bit_io[7]}];  # "LD7"

set_property PULLDOWN TRUE [get_ports {periph_bit_io[*]}];

set_property IOSTANDARD LVCMOS33 [get_ports {periph_bit_io[0]}];  # "LD0"
set_property IOSTANDARD LVCMOS33 [get_ports {periph_bit_io[1]}];  # "LD1"
set_property IOSTANDARD LVCMOS33 [get_ports {periph_bit_io[2]}];  # "LD2"
set_property IOSTANDARD LVCMOS33 [get_ports {periph_bit_io[3]}];  # "LD3"
set_property IOSTANDARD LVCMOS33 [get_ports {periph_bit_io[4]}];  # "LD4"
set_property IOSTANDARD LVCMOS33 [get_ports {periph_bit_io[5]}];  # "LD5"
set_property IOSTANDARD LVCMOS33 [get_ports {periph_bit_io[6]}];  # "LD6"
set_property IOSTANDARD LVCMOS33 [get_ports {periph_bit_io[7]}];  # "LD7"