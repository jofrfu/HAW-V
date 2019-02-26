library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;
    
entity TB_MEMORY_LATTICE is
end entity TB_MEMORY_LATTICE;

architecture BEH of TB_MEMORY_LATTICE is
    signal CLK   : STD_LOGIC;

    --Inputs - Port A
    signal ENA   : STD_LOGIC;  --opt port
    signal WEA   : STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal ADDRA : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal DINA  : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal DOUTA : STD_LOGIC_VECTOR(31 DOWNTO 0);
    --Inputs - Port B
    signal ENB   : STD_LOGIC;  --opt port
    signal WEB   : STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal ADDRB : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal DINB  : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal DOUTB : STD_LOGIC_VECTOR(31 DOWNTO 0);
    
    
    -- for clock gen
    constant clock_period   : time := 10 ns;
    signal stop_the_clock   : boolean;

begin
    DUT : entity WORK.blk_mem_gen_0_wrapper(lattice)
    port map(
        --Inputs - Port A
        ENA   => ENA,      
        WEA   => WEA,
        ADDRA => ADDRA,
        DINA  => DINA,
        DOUTA => DOUTA,
        CLKA  => CLK,
        --Inputs - Port B
        ENB   => ENB,
        WEB   => WEB,
        ADDRB => ADDRB,
        DINB  => DINB,
        DOUTB => DOUTB,
        CLKB  => CLK
    );
    
    STIMULUS:
    process is
    begin
        stop_the_clock <= false;
    
        ENA <= '0';
        WEA <= "0000";
        ADDRA <= (others => '0');
        DINA <= (others => '0');
        --
        ENB <= '0';
        WEB <= "0000";
        ADDRB <= (others => '0');
        DINB <= (others => '0');
        wait until CLK='1' and CLK'event;
        
        ------------ 32K EBR
        
        ENB <= '1';
        WEB <= "1111";
            
        for i in 0 to 2**10-1 loop -- test 32K block
            ADDRB <= std_logic_vector(to_unsigned(i, 30)) & "00";
            DINB <= std_logic_vector(to_unsigned(i, 8)) & std_logic_vector(to_unsigned(i, 8)) & std_logic_vector(to_unsigned(i, 8)) & std_logic_vector(to_unsigned(i, 8));
            wait until CLK='1' and CLK'event;
        end loop;
        
        WEB <= "0000";
        for i in 0 to 2**10-1 loop -- read 32K block from B
            ADDRB <= std_logic_vector(to_unsigned(i, 30)) & "00";
            wait until CLK='1' and CLK'event;
        end loop;
        ENB <= '0';
        
        ENA <= '1';
        for i in 0 to 2**10-1 loop -- read 32K block from A
            ADDRA <= std_logic_vector(to_unsigned(i, 30)) & "00";
            wait until CLK='1' and CLK'event;
        end loop;
        ENA <= '0';
        
        ------------ 16K EBR
        
        ENB <= '1';
        WEB <= "1111";
            
        for i in 2**10 to 2**10+2**9-1 loop -- test 16K block
            ADDRB <= std_logic_vector(to_unsigned(i, 30)) & "00";
            DINB <= std_logic_vector(to_unsigned(i, 8)) & std_logic_vector(to_unsigned(i, 8)) & std_logic_vector(to_unsigned(i, 8)) & std_logic_vector(to_unsigned(i, 8));
            wait until CLK='1' and CLK'event;
        end loop;
        
        WEB <= "0000";
        for i in 2**10 to 2**10+2**9-1 loop -- read 16K block from B
            ADDRB <= std_logic_vector(to_unsigned(i, 30)) & "00";
            wait until CLK='1' and CLK'event;
        end loop;
        ENB <= '0';
        
        ENA <= '1';
        for i in 2**10 to 2**10+2**9-1 loop -- read 16K block from A
            ADDRA <= std_logic_vector(to_unsigned(i, 30)) & "00";
            wait until CLK='1' and CLK'event;
        end loop;
        ENA <= '0';
        
        ------------ 8K EBR
        
        ENB <= '1';
        WEB <= "1111";
            
        for i in 2**10+2**9 to 2**10+2**9+2**8-1 loop -- test 8K block
            ADDRB <= std_logic_vector(to_unsigned(i, 30)) & "00";
            DINB <= std_logic_vector(to_unsigned(i, 8)) & std_logic_vector(to_unsigned(i, 8)) & std_logic_vector(to_unsigned(i, 8)) & std_logic_vector(to_unsigned(i, 8));
            wait until CLK='1' and CLK'event;
        end loop;
        
        WEB <= "0000";
        for i in 2**10+2**9 to 2**10+2**9+2**8-1 loop -- read 8K block from B
            ADDRB <= std_logic_vector(to_unsigned(i, 30)) & "00";
            wait until CLK='1' and CLK'event;
        end loop;
        ENB <= '0';
        
        ENA <= '1';
        for i in 2**10+2**9 to 2**10+2**9+2**8-1 loop -- read 8K block from A
            ADDRA <= std_logic_vector(to_unsigned(i, 30)) & "00";
            wait until CLK='1' and CLK'event;
        end loop;
        ENA <= '0';
        
        ------------ 256K SPRAM0
        
        ENB <= '1';
        WEB <= "1111";
        
        for i in 2**14 to 2**14+2**14-1 loop -- test 256K block
            ADDRB <= std_logic_vector(to_unsigned(i, 30)) & "00";
            DINB <= std_logic_vector(to_unsigned(i, 8)) & std_logic_vector(to_unsigned(i, 8)) & std_logic_vector(to_unsigned(i, 8)) & std_logic_vector(to_unsigned(i, 8));
            wait until CLK='1' and CLK'event;
        end loop;
        
        WEB <= "0000";
        for i in 2**14 to 2**14+2**14-1 loop -- read 256K block only accessible from B
            ADDRB <= std_logic_vector(to_unsigned(i, 30)) & "00";
            wait until CLK='1' and CLK'event;
        end loop;
        ENB <= '0';
        
        ------------ 256K SPRAM1
        
        ENB <= '1';
        WEB <= "1111";
        
        for i in 2**15 to 2**15+2**14-1 loop -- test 256K block
            ADDRB <= std_logic_vector(to_unsigned(i, 30)) & "00";
            DINB <= std_logic_vector(to_unsigned(i, 8)) & std_logic_vector(to_unsigned(i, 8)) & std_logic_vector(to_unsigned(i, 8)) & std_logic_vector(to_unsigned(i, 8));
            wait until CLK='1' and CLK'event;
        end loop;
        
        WEB <= "0000";
        for i in 2**15 to 2**15+2**14-1 loop -- read 256K block only accessible from B
            ADDRB <= std_logic_vector(to_unsigned(i, 30)) & "00";
            wait until CLK='1' and CLK'event;
        end loop;
        ENB <= '0';
        
        stop_the_clock <= true;
        wait;
    end process STIMULUS;
    
    CLOCK_GEN: 
    process
    begin
        while not stop_the_clock loop
          CLK <= '0', '1' after clock_period / 2;
          wait for clock_period;
        end loop;
        wait;
    end process CLOCK_GEN;
end architecture BEH;