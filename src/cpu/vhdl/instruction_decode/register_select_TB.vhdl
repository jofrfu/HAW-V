use WORK.riscv_pack.all;
library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;
    
entity register_select_TB is
end entity register_select_TB;

architecture TB of register_select_TB is
    component dut is
        port(   clk, reset   :   in  std_logic;
                DI           :   in  DATA_TYPE;
                rs1, rs2, rd :   in  REGISTER_ADDRESS_TYPE;
                OPA, OPB, DO :   out DATA_TYPE;
                -------- PC ports
                PC           :   in  ADDRESS_TYPE;
                PC_en        :   in  std_logic
        );--]port
    end component dut;
    for all : dut use entity work.register_select(beh);
     
    signal clk_s        : std_logic := '0';
    signal reset_s      : std_logic := '0';
    signal simulation_running : boolean := false;
    
    signal DI_s         : DATA_TYPE := (others => '0');
    signal rs1_s        : REGISTER_ADDRESS_TYPE := (others => '0');
    signal rs2_s        : REGISTER_ADDRESS_TYPE := (others => '0');
    signal rd_s         : REGISTER_ADDRESS_TYPE := (others => '0');
    signal OPA_s        : DATA_TYPE;
    signal OPB_s        : DATA_TYPE;
    signal DO_s         : DATA_TYPE;
    signal PC_s         : ADDRESS_TYPE := (others => '0');
    signal Pc_en_s      : std_logic := '0'; --not pc
    
    begin

    dut_i : dut
    port map(
        clk_s,
        reset_s,
        DI_s,
        rs1_s,
        rs2_s,
        rd_s,
        OPA_s,
        OPB_s,
        DO_s,
        PC_s,
        PC_en_s
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
        
        --actions: put the value of the register into the register
        for i in 0 to REGISTER_COUNT-1 loop
            rd_s <= std_logic_vector(to_unsigned(i,REGISTER_ADDRESS_WIDTH));
            DI_s <= std_logic_vector(to_unsigned(i,DATA_WIDTH));
            wait until '1'=clk_s and clk_s'event;   
        end loop;
        
        --test1
        --rs1_s: 0-31
        --rs2_s: 31-0
        --actions: select each register
        --result: OPA: 0-31 OPB: 31-0
        for i in 0 to REGISTER_COUNT-1 loop
            rs1_s <= std_logic_vector(to_unsigned(i,REGISTER_ADDRESS_WIDTH));
            rs2_s <= std_logic_vector(to_unsigned((REGISTER_COUNT-1-i),REGISTER_ADDRESS_WIDTH));
            wait for 1 ns;
            if OPA_s /= std_logic_vector(to_unsigned(i, DATA_WIDTH)) then
                report "Test failed! Error in rs1 to OPA!";
                wait;
            end if;
            if OPB_s /= std_logic_vector(to_unsigned((REGISTER_COUNT-1-i), DATA_WIDTH)) then
                report "Test failed! Error in rs2 to OPB!";
                wait;
            end if;
            if DO_s /= OPB_S then
                report "Test failed! DO should be OPB!";
                wait;
            end if;    
        end loop;
        
        --test2
        --pc_en: 1
        --pc: 42
        --actions: select PC as OPA
        --result: OPA = PC = 42
        pc_en_s <= '1';
        pc_s <= std_logic_vector(to_unsigned(42,ADDRESS_WIDTH));
        wait for 1 ns;
        if OPA_s /= std_logic_vector(to_unsigned(42, ADDRESS_WIDTH)) then
            report "Test failed! Error in pc to OPA!";
            wait;
        end if;        
        
        --test3
        --rs1: 0
        --di: 42
        --rd:  0
        --actions: select R0
        --result: OPA should be 0
        rd_s <= std_logic_vector(to_unsigned(0,REGISTER_ADDRESS_WIDTH));
        di_s <= std_logic_vector(to_unsigned(42,DATA_WIDTH));
        pc_en_s <= '0';
        wait until '1'=clk_s and clk_s'event;
        rs1_s <= std_logic_vector(to_unsigned(0,REGISTER_ADDRESS_WIDTH));
        wait for 1 ns;
        if OPA_s /= std_logic_vector(to_unsigned(0, ADDRESS_WIDTH)) then
            report "Test failed! R0 does not return 0!!!";
            wait;
        end if;        
        
        simulation_running <= false;
        report "Test successful!";
        wait;
        
    end process test;  
end architecture TB;