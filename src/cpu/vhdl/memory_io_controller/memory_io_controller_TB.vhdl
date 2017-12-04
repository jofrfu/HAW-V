--!@brief 	This file contains the memory/IO controller Testbench
--!@author 	Matthis Keppner
--!@date 	2017
use WORK.riscv_pack.all;
library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;
    
entity memory_io_controller_TB is
end entity memory_io_controller_TB;

architecture TB of memory_io_controller_TB is

component dut is
    port(
        CLK            : IN STD_LOGIC;
        reset          : IN STD_LOGIC;
        pc_asynch      : IN ADDRESS_TYPE;
        instruction    : OUT INSTRUCTION_BIT_TYPE;
        
        EN             : IN STD_LOGIC;
        WEN            : IN STD_LOGIC;
        WORD_LENGTH    : in WORD_CNTRL_TYPE;
        ADDR           : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        DIN            : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        DOUT           : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        
        -- IO
        PERIPH_IN_EN   : IN  IO_ENABLE_TYPE;-- disables write access - register is written from peripheral
        PERIPH_IN      : IN  IO_BYTE_TYPE;  -- input for peripheral connections
        PERIPH_OUT     : OUT IO_BYTE_TYPE   -- output for peripheral connections 
    );
end component dut;
for all : dut use entity work.memory_io_controller(beh);

    signal CLK: STD_LOGIC;
    signal reset: STD_LOGIC;
    signal pc_asynch: ADDRESS_TYPE;
    signal instruction: INSTRUCTION_BIT_TYPE;
    signal EN: STD_LOGIC;
    signal WEN: STD_LOGIC;
    signal WORD_LENGTH: WORD_CNTRL_TYPE;
    signal ADDR: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal DIN: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal DOUT: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal PERIPH_IN_EN: IO_ENABLE_TYPE;
    signal PERIPH_IN: IO_BYTE_TYPE;
    signal PERIPH_OUT: IO_BYTE_TYPE;
    signal simulation_running: boolean := false;
begin

    dut_i: dut port map(
    CLK          => CLK,
    reset        => reset,
    pc_asynch    => pc_asynch,
    instruction  => instruction,
    EN           => EN,
    WEN          => WEN,
    WORD_LENGTH  => WORD_LENGTH,
    ADDR         => ADDR,
    DIN          => DIN,
    DOUT         => DOUT,
    PERIPH_IN_EN => PERIPH_IN_EN,
    PERIPH_IN    => PERIPH_IN,
    PERIPH_OUT   => PERIPH_OUT 
    );
    
    clk_gen:
    process is
        begin
        wait until simulation_running = true;
        CLK <= '0';
        wait for 40 ns;
        while simulation_running loop
            CLK <= '1';
            wait for 20 ns;
            CLK <= '0';
            wait for 20 ns;
        end loop;
    end process clk_gen;
    
    test:
    process is
        begin
        simulation_running <= true;
        reset <= '1';
        wait until '1'=CLK and CLK'event;
        reset <= '0';
        
        --test1
        --test periph_out
        --set:
        --      en   = 1
        --      DIN   = 0x"FFFF0000"
        --      ADDR = 0x"80000000"
        --      WEN  = 1
        --      word_length = half 01
        --      periph_in_en = 00
        --action: load DIN in periph and get it as output
        --resu: periph_out should be 0x"FFFF"
        EN <= '1';
        DIN <= x"FFFF0000";
        ADDR <= x"80000000";
        WEN <= '1';
        word_length <= "01";
        periph_in_en <= "00";
        wait until '1'=CLK and CLK'event;
        wait for 1 ns;
        if PERIPH_OUT(0) /= x"FF" or PERIPH_OUT(1) /= x"FF"  then 
            report ">>>>TEST ONE<<<< Error! storing a value form DIN ([00]FF) into Periph and reloading it does not work!!!";
            wait;
        end if;
        
        --test2
        --test periph_out
        --set:
        --      en   = 1
        --      DIN   = 0x"FFFF0000"
        --      ADDR = 0x"80000000"
        --      WEN  = 1
        --      word_length = byte 00
        --      periph_in_en = 01
        --      periph_in = 0x0001
        --action: load byte from periph_in into periph and get it as output
        --resu: periph_out should be 0x"0000FF01"
        EN <= '1';
        DIN <= x"FFFF0000";
        ADDR <= x"80000000";
        WEN <= '0';
        word_length <= "00";
        periph_in_en <= "01";
        periph_in(0) <= x"01";
        periph_in(1) <= x"00";
        wait until '1'=CLK and CLK'event;
        wait for 1 ns;
        if PERIPH_OUT(0) /= x"01" or PERIPH_OUT(1) /= x"FF" then 
            report ">>>>TEST TWO<<<< Error! storing a value(BYTE) from periph_in([00]01) into Periph(01) and reloading it does not work!!!";
            wait;
        end if;
        
        --test3
        --test periph_out
        --set:
        --      en   = 1
        --      DIN   = 0x"FFFF0000"
        --      ADDR = 0x"80000000"
        --      WEN  = 1
        --      word_length = HALF 01
        --      periph_in_en = 11
        --      periph_in = 0x01
        --action: load byte from periph_in into periph and get it as output
        --resu: periph_out should be 0x"0001"
        EN <= '1';
        DIN <= x"FFFF0000";
        ADDR <= x"80000000";
        WEN <= '1';
        word_length <= "01";
        periph_in_en <= "11";
        periph_in(0) <= x"01";
        periph_in(1) <= x"00";
        wait until '1' = CLK and CLK'event;
        wait for 1 ns;
        if PERIPH_OUT(0) /= x"01" or PERIPH_OUT(1) /= x"00" then 
            report ">>>>TEST THREE<<<< Error! storing a value(HALF) from periph_in([00]01) into Periph(11) and reloading it does not work!!!";
            wait;
        end if;
        
        --test4
        --test Data out from periph_io
        --set:
        --      en   = 1
        --      DIN   = 0x"FFFF0000"
        --      ADDR = 0x"80000000"
        --      WEN  = 0
        --      word_length = HALF 01
        --      periph_in_en = 11
        --      periph_in = 0xFFFF
        --action: load byte from periph_in into periph and get it as output
        --resu: data_out should be 0x"01"
        EN <= '1';
        DIN <= x"FFFF0000";
        ADDR <= x"80000000";
        WEN <= '0';
        word_length <= "01";
        periph_in_en <= "11";
        periph_in(0) <= x"AF";
        periph_in(1) <= x"FE";
        wait until '1' = CLK and CLK'event;
        
        wait for 1 ns;
        if DOUT /= x"AFFE0000" then
            report ">>>>TEST FOUR<<<< You stupid monkey!!! ERROR with dataout";
            wait;
        end if;
        
        
            -- test5
            -- test Data out from periph_io
            -- set:
                 -- en   = 1
                 -- DIN   = 0x"FFFF0000"
                 -- ADDR = 0x"80000000"
                 -- WEN  = 0
                 -- word_length = HALF 01
                 -- periph_in_en = 11
                 -- periph_in = 0xFFFF
            -- action: load byte from periph_in into periph and get it as output
            -- resu: data_out should be 0x"01"
            
            -- EN <= '1';
            -- DIN <= x"FFFF0000";
            -- ADDR <= x"80000000";
            -- WEN <= '0';
            -- word_length <= "01";
            -- periph_in_en <= "11";
            -- periph_in(0) <= x"FE";
            -- periph_in(1) <= x"AF";
            -- wait until '1' CLK and CLK'event;
            -- wait for 1 ns;
            -- if DOUT /= x"0000AFFE" then
                -- report ">>>>TEST FIVE<<<< You stupid monkey!!! ERROR with dataout";
                -- wait;
        
        report ">>>>>>>TEST SUCCESSFUL<<<<<<<<<<<<!!!!!!!";
        simulation_running <= false;
        wait;
        
    end process test;
    
end architecture TB;
