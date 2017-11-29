use WORK.riscv_pack.all;
library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;
    
entity memory_access_TB is
end entity memory_access_TB;

architecture TB of memory_access_TB is

component dut is
    port(
        clk, reset : in std_logic;
        
        --! @brief stage inputs
        WB_CNTRL_IN : in WB_CNTRL_TYPE;
        MA_CNTRL    : in MA_CNTRL_TYPE;
        WORD_CNTRL  : in WORD_CNTRL_TYPE;
        SIGN_EN     : in std_logic;
        RESU        : in DATA_TYPE;
        DO          : in DATA_TYPE;
        PC_IN       : in ADDRESS_TYPE;
        
        --! @brief memory inputs
        DATA_IN     : in DATA_TYPE;
        
        --! @brief stage outputs
        WB_CNTRL_OUT: out WB_CNTRL_TYPE;
        DI          : out DATA_TYPE;
        PC_OUT      : out ADDRESS_TYPE;
        
        --! @brief memory outputs
        ENABLE      : out std_logic;
        WRITE_EN    : out std_logic;
        DATA_OUT    : out DATA_TYPE;
        ADDRESS     : out ADDRESS_TYPE;
        WORD_LENGTH : out WORD_CNTRL_TYPE
    );
end component dut;
for all : dut use entity work.memory_access(beh);

    signal clk_s         : std_logic    := '0';
    signal reset_s       : std_logic    := '0';
    signal simulation_running : boolean := false;
    
    -- inputs
    signal WB_CNTRL_IN_s : WB_CNTRL_TYPE       := (others => '0');
    signal MA_CNTRL_s    : MA_CNTRL_TYPE       := (others => '0');
    signal WORD_CNTRL_s  : WORD_CNTRL_TYPE     := (others => '0');
    signal SIGN_EN_s     : std_logic           := '0';
    signal RESU_s        : DATA_TYPE           := (others => '0');
    signal DO_s          : DATA_TYPE           := (others => '0');
    signal PC_IN_s       : ADDRESS_TYPE        := (others => '0');
    -- memory input
    signal DATA_IN_s     : DATA_TYPE           := (others => '0');
    -- outputs
    signal WB_CNTRL_OUT_s: WB_CNTRL_TYPE;
    signal DI_s          : DATA_TYPE;
    signal PC_OUT_s      : ADDRESS_TYPE;
    -- memory outputs
    signal ENABLE_s      : std_logic;
    signal WRITE_EN_s    : std_logic;
    signal DATA_OUT_s    : DATA_TYPE;
    signal ADDRESS_s     : ADDRESS_TYPE;
    signal WORD_LENGTH_s : WORD_CNTRL_TYPE;

begin

    dut_i : dut
    port map(
        clk_s,
        reset_s,
        WB_CNTRL_IN_s,
        MA_CNTRL_s,
        WORD_CNTRL_s,
        SIGN_EN_s,
        RESU_s,
        DO_s,
        PC_IN_s,
        DATA_IN_s,
        WB_CNTRL_OUT_s,
        DI_s,
        PC_OUT_s,
        ENABLE_s,
        WRITE_EN_s,
        DATA_OUT_s,
        ADDRESS_s,
        WORD_LENGTH_s
    );
    
    
    clk_gen:
    process is
        begin
        wait until simulation_running = true;
        clk_s <= '0';
        wait for 40 ns;
        while simulation_running loop
            clk_s <= '1';
            wait for 20 ns;
            clk_s <= '0';
            wait for 20 ns;
        end loop;
    end process clk_gen;

    test:
    process is
        begin
        simulation_running <= true;
        reset_s <= '1';
        wait until '1'=clk_s and clk_s'event;
        reset_s <= '0';
        
        -- test1
        -- WB_CNTRL_IN = 42
        -- Action: WB_CNTRL gets loaded
        -- Result: WB_CNTRL_OUT should be 42 after clk
        WB_CNTRL_IN_s <= std_logic_vector(to_unsigned(42, WB_CNTRL_WIDTH));
        wait until '1'=clk_s and clk_s'event;
        wait for 1 ns;
        if WB_CNTRL_OUT_s /= std_logic_vector(to_unsigned(42, WB_CNTRL_WIDTH)) then
            report "Error on loading WB_CNTRL!";
            wait;
        end if;
        
        -- test2
        -- PC_IN = 21
        -- Action: PC_OUT gets loaded
        -- Result: PC_OUT should be 21 after clk
        PC_IN_s <= std_logic_vector(to_unsigned(21, ADDRESS_WIDTH));
        wait until '1'=clk_s and clk_s'event;
        wait for 1 ns;
        if PC_OUT_s /= std_logic_vector(to_unsigned(21, ADDRESS_WIDTH)) then
            report "Error on loading PC!";
            wait;
        end if;
        
        -- test3
        -- MA_CNTRL = "00"
        -- RESU = 74
        -- Action: DI gets loaded with RESU
        -- Result: DI should be 74 after clk,
        -- ENABLE and WRITE_EN should be 0
        MA_CNTRL_s <= "00";
        RESU_s <= std_logic_vector(to_unsigned(74, DATA_WIDTH));
        wait until '1'=clk_s and clk_s'event;
        wait for 1 ns;
        if DI_s /= std_logic_vector(to_unsigned(74, DATA_WIDTH)) then
            report "Error on loading RESU into DI!";
            wait;
        end if;
        
        if ENABLE_s /= '0' or WRITE_EN_s /= '0' then
            report "Error! ENABLE and WRITE_EN should be 0!";
            wait;
        end if;
        
        -- test4
        -- MA_CNTRL = "10"
        -- DATA_IN = 86
        -- Action: DI gets loaded with DATA_IN
        -- Result: DI should be 86 after clk,
        -- ENABLE should be 1, WRITE_EN should be 0
        MA_CNTRL_s <= "10";
        DATA_IN_s <= std_logic_vector(to_unsigned(86, DATA_WIDTH));
        wait until '1'=clk_s and clk_s'event;
        wait for 1 ns;
        if DI_s /= std_logic_vector(to_unsigned(86, DATA_WIDTH)) then
            report "Error on loading DATA_IN into DI!";
            wait;
        end if;
        
        if ENABLE_s /= '1' or WRITE_EN_s /= '0' then
            report "Error! ENABLE should be 1 and WRITE_EN should be 0!";
            wait;
        end if;
        
        -- test5
        -- MA_CNTRL = "01"
        -- DO = 93
        -- Action: DATA_OUT gets value from DO
        -- Result: DATA_OUT should be 93 instantly,
        -- ENABLE and WRITE_EN should be 1
        MA_CNTRL_s <= "01";
        DO_s <= std_logic_vector(to_unsigned(93, DATA_WIDTH));
        wait for 1 ns;
        if DATA_OUT_s /= std_logic_vector(to_unsigned(93, DATA_WIDTH)) then
            report "Error on loading DO to DATA_OUT!";
            wait;
        end if;
        
        if ENABLE_s /= '1' or WRITE_EN_s /= '1' then
            report "Error! ENABLE and WRITE_EN should be 1!";
            wait;
        end if;
        
        -- test6
        -- WORD_CNTRL = "10"
        -- Action: WORD_LENGTH gets set
        -- Result: WORD_LENGTH should be "10" instantly
        WORD_CNTRL_s <= "10";
        wait for 1 ns;
        if WORD_LENGTH_s /= "10" then
            report "Error! WORD_LENGTH should be 10";
            wait;
        end if;
        
        -- test7
        -- RESU = 104
        -- Action: ADDRESS gets value
        -- Result: ADDRESS should be 104 instantly
        RESU_s <= std_logic_vector(to_unsigned(104, DATA_WIDTH));
        wait for 1 ns;
        if ADDRESS_s /= std_logic_vector(to_unsigned(104, ADDRESS_WIDTH)) then
            report "Error! ADDRESS should be 104!";
            wait;
        end if;
        
        -- test8
        -- SIGN_EN = 1
        -- WORD_CNTRL = 00
        -- MA_CNTRL = 10 : load
        -- Data_in = 0x80
        -- action: load signextended negative byte 
        -- result : DI should be 0xFFFFFF80
        SIGN_EN_s <= '1';
        WORD_CNTRL_s <= "00";
        MA_CNTRL_s <= "10";
        DATA_IN_s <= x"00000080";
        wait until '1'=clk_s and clk_s'event;
        wait for 1 ns;
        if DI_s /= x"FFFFFF80" then 
            report "Error! DI was not SIGN EXTENDED, but should be (BYTE)!!!";
            wait;
        end if;
        
        -- test9
        -- SIGN_EN = 1
        -- WORD_CNTRL = 00
        -- MA_CNTRL = 01 : load
        -- Data_in = 0x70
        -- action: load sign extended  positive byte
        -- result : DI should be 0x00000070
        SIGN_EN_s <= '1';
        WORD_CNTRL_s <= "00";
        MA_CNTRL_s <= "10";
        DATA_IN_s <= x"00000070";
        wait until '1'=clk_s and clk_s'event;
        wait for 1 ns;
        if DI_s /= x"00000070" then 
            report "Error! DI was SIGN EXTENDED, but should not be (BYTE)!!!";
            wait;
        end if;
        
        -- test10
        -- SIGN_EN = 1
        -- WORD_CNTRL = 01
        -- MA_CNTRL = 01 : load
        -- Data_in = 0x8000
        -- action: load signextended negative half-word 
        -- result : DI should be 0xFFFF8000
        SIGN_EN_s <= '1';
        WORD_CNTRL_s <= "01";
        MA_CNTRL_s <= "10";
        DATA_IN_s <= x"00008000";
        wait until '1'=clk_s and clk_s'event;
        wait for 1 ns;
        if DI_s /= x"FFFF8000" then 
            report "Error! DI was not SIGN EXTENDED, but should be (HALFWORD)!!!";
            wait;
        end if;
        
        -- test11
        -- SIGN_EN = 1
        -- WORD_CNTRL = 01
        -- MA_CNTRL = 01 : load
        -- Data_in = 0x7000
        -- action: load sign extended  positive half-word
        -- result : DI should be 0x00007000
        SIGN_EN_s <= '1';
        WORD_CNTRL_s <= "01";
        MA_CNTRL_s <= "10";
        DATA_IN_s <= x"00007000";
        wait until '1'=clk_s and clk_s'event;
        wait for 1 ns;
        if DI_s /= x"00007000" then 
            report "Error! DI was SIGN EXTENDED, but should not be (HALFWORD)!!!";
            wait;
        end if;     
        
        -- test12
        -- SIGN_EN = 1
        -- WORD_CNTRL = 10
        -- MA_CNTRL = 01 : load
        -- Data_in = 0x80000000
        -- action: load signextended negative word 
        -- result : DI should be 0x80000000
        SIGN_EN_s <= '1';
        WORD_CNTRL_s <= "10";
        MA_CNTRL_s <= "10";
        DATA_IN_s <= x"80000000";
        wait until '1'=clk_s and clk_s'event;
        wait for 1 ns;
        if DI_s /= x"80000000" then 
            report "Error! DI was not SIGN EXTENDED, but should be! (WORD)!!!";
            wait;
        end if;
        
        -- test13
        -- SIGN_EN = 1
        -- WORD_CNTRL = 01
        -- MA_CNTRL = 01 : load
        -- Data_in = 0x70000000
        -- action: load sign extended  positive half-word
        -- result : DI should be 0x70000000
        SIGN_EN_s <= '1';
        WORD_CNTRL_s <= "10";
        MA_CNTRL_s <= "10";
        DATA_IN_s <= x"70000000";
        wait until '1'=clk_s and clk_s'event;
        wait for 1 ns;
        if DI_s /= x"70000000" then 
            report "Error! DI was SIGN EXTENDED, but should not be! (WORD)!!!";
            wait;
        end if;     

        
        report "Test was successful!";
        simulation_running <= false;
        wait;
    end process test;

end architecture TB;