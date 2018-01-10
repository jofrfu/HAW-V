# ----------------------------------------------------------------------------
# Clock Source - Bank 13
# ---------------------------------------------------------------------------- 
set_property PACKAGE_PIN Y9 [get_ports {clk}];  # "GCLK"
set_property IOSTANDARD LVCMOS33 [get_ports {clk}];
#create_clock -period 20.000 -name clk -waveform {0.000 10.000} [get_ports clk]

set_property PACKAGE_PIN R18 [get_ports {reset}];   # "BTNR" right button
set_property IOSTANDARD LVCMOS18 [get_ports {reset}];
set_input_delay -clock clk -max 2.000 [get_ports {reset}];
set_input_delay -clock clk -min 1.000 [get_ports {reset}];


# ----------------------------------------------------------------------------
# GPIOs - Bank 33
# ---------------------------------------------------------------------------- 

# LEDs 

set_property PACKAGE_PIN T22 [get_ports {periph_bit_io[0]}];  # "LD0"
set_property PACKAGE_PIN T21 [get_ports {periph_bit_io[1]}];  # "LD1"
set_property PACKAGE_PIN U22 [get_ports {periph_bit_io[2]}];  # "LD2"
set_property PACKAGE_PIN U21 [get_ports {periph_bit_io[3]}];  # "LD3"
set_property PACKAGE_PIN V22 [get_ports {periph_bit_io[4]}];  # "LD4"
set_property PACKAGE_PIN W22 [get_ports {periph_bit_io[5]}];  # "LD5"
set_property PACKAGE_PIN U19 [get_ports {periph_bit_io[6]}];  # "LD6"
set_property PACKAGE_PIN U14 [get_ports {periph_bit_io[7]}];  # "LD7"

# SWITCHs 

set_property PACKAGE_PIN F22 [get_ports {periph_bit_io[8]}];  # "SW0"
set_property PACKAGE_PIN G22 [get_ports {periph_bit_io[9]}];  # "SW1"
set_property PACKAGE_PIN H22 [get_ports {periph_bit_io[10]}]; # "SW2"
set_property PACKAGE_PIN F21 [get_ports {periph_bit_io[11]}]; # "SW3"
set_property PACKAGE_PIN H19 [get_ports {periph_bit_io[12]}]; # "SW4"
set_property PACKAGE_PIN H18 [get_ports {periph_bit_io[13]}]; # "SW5"
set_property PACKAGE_PIN H17 [get_ports {periph_bit_io[14]}]; # "SW6"
set_property PACKAGE_PIN M15 [get_ports {periph_bit_io[15]}]; # "SW7"

# BUTTONs 

set_property PACKAGE_PIN N15 [get_ports {periph_bit_io[16]}]; # "BTNL" left     button
set_property PACKAGE_PIN T18 [get_ports {periph_bit_io[17]}]; # "BTNU" up       button
set_property PACKAGE_PIN P16 [get_ports {periph_bit_io[18]}]; # "BTNC" center   button
set_property PACKAGE_PIN R16 [get_ports {periph_bit_io[19]}]; # "BTND" down     button


# PMOD JA1  is not used at the moment

set_property PACKAGE_PIN Y11  [get_ports {periph_bit_io[20]}]; # "JA1" 
set_property PACKAGE_PIN AA11 [get_ports {periph_bit_io[21]}]; # "JA2" 
set_property PACKAGE_PIN Y10  [get_ports {periph_bit_io[22]}]; # "JA3" 
set_property PACKAGE_PIN AB11 [get_ports {periph_bit_io[23]}]; # "JA4"

# UART # BANK 13 PMOD JB1

set_property PACKAGE_PIN W12 [get_ports {periph_bit_io[24]}]; # "JB1"        tx transmission
set_property PACKAGE_PIN W11 [get_ports {periph_bit_io[25]}]; # "JB2"        rx receive

set_property PULLDOWN TRUE [get_ports {periph_bit_io[*]}];

set_property IOSTANDARD LVCMOS33 [get_ports {periph_bit_io[*]}];

set_input_delay -clock clk -max 2.000 [get_ports {periph_bit_io[*]}];
set_input_delay -clock clk -min 1.000 [get_ports {periph_bit_io[*]}];

set_output_delay -clock clk -max 2.000 [get_ports {periph_bit_io[*]}];
set_output_delay -clock clk -min 1.000 [get_ports {periph_bit_io[*]}];