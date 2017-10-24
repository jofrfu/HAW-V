use WORK.riscv_pack.all;
library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;
    
entity PC_log_TB is
end entity PC_log_TB;

architecture TB of PC_log_TB is

	component dut is
		port (
			clk, reset 	: in std_logic;
			 
			cntrl  		: in IF_CNTRL_TYPE; --! Control the operation mode of the PC logic
		 	rel			: in DATA_TYPE;		--! relative branch adress
			abso		: in DATA_TYPE;		--! absolute branch adress, or base for relative jump
			 
			pc 			: out ADRESS_TYPE;	--! programm counter output
		);
	end component dut;
	for all : dut use entity work.PC_log(std_impl);

	signal clk_s 	: std_logic := '0';
	signal reset_s 	: std_logic := '0';
	signal cntrl_s 	: IF_CNTRL_TYPE := (others => '0');
	signal rel_s	: DATA_TYPE := (others => '0');
	signal abso_s	: DATA_TYPE := (others => '0');
	
	signal pc_s		: ADDRESS_TYPE;
	
	signal simulation_running : boolean := false;

begin

dut_i : dut
port map(
	clk_s,
	reset_s,
	cntrl_s,
	rel_s,
	abso_s,
	pc_s
);
	
clk_gen:
process is
	begin
	wait until simulation_running = true;
	clk_s <= '0';
	wait for 20 ns;
	clk_s <= '1';
	wait for 20 ns;
end process clk_gen;

test:
process is
	begin
	simulation_running <= true;
	reset_s <= '1';
    wait until '1'=clk_s and clk_s'event;
    reset_s <= '0';
    
    -- test1
    -- cntrl: 00
    -- action: adds 4 to PC
    -- result: PC should be 4
    cntrl_s <= "00";
    wait until '1'=clk_s and clk_s'event;
    if pc_s /= std_logic_vector(to_unsigned(4, ADDRESS_WIDTH)) then
    	report "Test failed! Error on PC standard addition!";
    	wait;
    end if;
    
    -- test2
    -- cntrl: 01
    -- action: adds immediate (16 in this case) to PC
    -- result: PC should be 20
	cntrl_s <= "01";
	rel_s <= std_logic_vector(to_unsigned(16, ADDRESS_WIDTH));
	wait until '1'=clk_s and clk_s'event;
	if pc_s /= std_logic_vector(to_unsigned(20, ADDRESS_WIDTH)) then
		report "Test failed! Error on PC immediate addition!";
		wait;
	end if;
	
	-- test3
	-- cntrl: 11
	-- action: adds immediate (8 in this case) to a register (512 in this case)
	-- result: PC should be 520
	cntrl_s <= "11";
	rel_s <= std_logic_vector(to_unisgned(8, ADDRESS_WIDTH));
	abso_s <= std_logic_vector(to_unsigned(512, ADDRESS_WIDTH));
	wait until '1'=clk_s and clk_s'event;
	if pc_s /= std_logic_vector(to_unsigned(520, ADDRESS_WIDTH)) then
		report "Test failed! Error on PC immediate and register addition!";
		wait; 
	end if;
	
	-- test4
	-- cntrl: 10
	-- action: adds 4 to a register (512 in this case)
	-- result: PC should be 516, an error message should be shown
	cntrl <= "10";
	abso_s <= std_logic_vector(to_unisgned(512, ADDRESS_WIDTH));
	if pc_s /= std_logic_vector(to_unsigned(516, ADDRESS_WIDTH)) then
		report "Test failed! Error on PC 4 and register addition!";
		wait;
	end if;
	
	-- test5
	-- cntrl: 00
	-- action: reset the PC
	-- result: PC should be 0
	cntrl <= "00";
	reset_s <= '1';
    wait until '1'=clk_s and clk_s'event;
    reset_s <= '0';
    
    if pc_s /= std_logic_vector(to_unsigned(0, ADDRESS_WIDTH)) then
    	report "Test failed! Error on resetting PC!";
		wait;
	end if;
	
	report "Test successful!";
	
	wait;
	
end process test;
	
end architecture TB;