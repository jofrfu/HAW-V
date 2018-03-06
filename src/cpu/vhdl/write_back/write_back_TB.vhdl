use WORK.riscv_pack.all;
library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;
    
entity WRITE_BACK_TB is
end entity WRITE_BACK_TB;

architecture TB of WRITE_BACK_TB is
    component dut is
    port(
		WB_CNTRL_IN : in WB_CNTRL_TYPE;
		DATA_IN     : in DATA_TYPE;
		PC_IN       : in ADDRESS_TYPE;
		
		REG_ADDR    : out REGISTER_ADDRESS_TYPE;
		WRITE_BACK  : out DATA_TYPE
	);
    end component dut;
    for all : dut use entity work.write_back(beh);

    signal WB_CNTRL_IN_s    : WB_CNTRL_TYPE := (others => '0');
    signal DATA_IN_s        : DATA_TYPE     := (others => '0');
    signal PC_IN_s          : ADDRESS_TYPE  := (others => '0');
    
    signal REG_ADDR_s       : REGISTER_ADDRESS_TYPE;
    signal WRITE_BACK_s     : DATA_TYPE;
begin

dut_i : dut
port map(
    WB_CNTRL_IN_s,
    DATA_IN_s,
    PC_IN_s,
    REG_ADDR_s,
    WRITE_BACK_s
);

test:
process is
    begin
    
    -- test1
    -- WB_CNTRL_IN = '000000'
    -- DI = 67
    -- Action: Sets PC mux to DI
    -- Result: WRITE_BACK should be 67 instantly
    
    WB_CNTRL_IN_s <= (others => '0');
    DATA_IN_s <= std_logic_vector(to_unsigned(67, DATA_WIDTH));
    wait for 1 ns;
    if WRITE_BACK_s /= std_logic_vector(to_unsigned(67, DATA_WIDTH)) then
        report "Error! WRITE_BACK should be DATA_IN!";
        wait;
    end if;
    
    -- test2
    -- WB_CNTRL_IN = '100000'
    -- PC = 42
    -- Action: Sets PC mux to PC
    -- Result: WRITE_BACK should be 42 instantly
    
    WB_CNTRL_IN_s <= (others => '0');
    WB_CNTRL_IN_s(WB_CNTRL_IN_s'left) <= '1';
    PC_IN_s <= std_logic_vector(to_unsigned(42, ADDRESS_WIDTH));
    wait for 1 ns;
    if WRITE_BACK_s /= std_logic_vector(to_unsigned(42, DATA_WIDTH)) then
        report "Error! WRITE_BACK should be PC_IN!";
        wait;
    end if;
    
    -- test3
    -- WB_CNTRL_IN = '1' & 25
    -- Action: Sets REG_ADDR to WB_CNTRL_IN(4 downto 0)
    -- Result: REG_ADDR should be 25
    
    WB_CNTRL_IN_s(4 downto 0) <= std_logic_vector(to_unsigned(25, REGISTER_ADDRESS_WIDTH));
    wait for 1 ns;
    if REG_ADDR_s /= std_logic_vector(to_unsigned(25, REGISTER_ADDRESS_WIDTH)) then
        report "Error! REG_ADDR should be 25!";
        wait;
    end if;
    
    report "Test was successful!";
    wait;
    
end process test;

end architecture TB;