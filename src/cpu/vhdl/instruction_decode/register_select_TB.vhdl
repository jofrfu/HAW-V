--!@file 	PC_log.vhdl
--!@author 	Sebastian Brückner
--!@date 	2017

library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;

--!@biref 	Testbench for register_select
--!@details 
--!@author 	Sebastian Brückner
--!@date 	2017
entity register_select_TB is
end entity register_select_TB;

architecture TB of register_select_TB is
	component register_select is   
	port(   
		clk, reset   :   in  std_logic;
		DI           :   in  DATA_TYPE;
		rs1, rs2, rd :   in  REGISTER_ADDRESS_TYPE;
		OPA, OPB, DO :   out DATA_TYPE
    );--]port
	end component register_select;
	for all: register_select use entity WORK.REGISTER_SELECT(BEH);
	
	signal clk : std_logic := '0';
	signal reset : std_logic := '0';
	signal simulation_running : boolean := false;
	
begin

clk_gen : process is
begin
	wait until simulation_running = true;
	clk <= '0';
	wait for 10 ns;
	clk <= '1';
	wait for 10 ns;
end process clk_gen;

test : process is
begin
	simulation_running <= true;
end process test;


  
end architecture TB;

