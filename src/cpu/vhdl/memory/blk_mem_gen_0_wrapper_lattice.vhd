library IEEE;
    use IEEE.std_logic_1164.all;

library ICE40UP;
    use ICE40UP.COMPONENTS.all;
    
architecture lattice of blk_mem_gen_0_wrapper is
    -- EBRAM
    signal EB32K_CS0_cs : std_logic := '0';
    signal EB32K_CS0_ns : std_logic;
    signal EB32K_CS1_cs : std_logic := '0';
    signal EB32K_CS1_ns : std_logic;
    
    signal EBRAM32K_OUT0 : std_logic_vector(31 downto 0);
    signal EBRAM32K_OUT1 : std_logic_vector(31 downto 0);
    
    signal EB16K_CS0_cs : std_logic := '0';
    signal EB16K_CS0_ns : std_logic;
    signal EB16K_CS1_cs : std_logic := '0';
    signal EB16K_CS1_ns : std_logic;
    
    signal EBRAM16K_OUT0 : std_logic_vector(31 downto 0);
    signal EBRAM16K_OUT1 : std_logic_vector(31 downto 0);
    
    signal EB8K_CS0_cs : std_logic := '0';
    signal EB8K_CS0_ns : std_logic;
    signal EB8K_CS1_cs : std_logic := '0';
    signal EB8K_CS1_ns : std_logic;
    
    signal EBRAM8K_OUT0 : std_logic_vector(31 downto 0);
    signal EBRAM8K_OUT1 : std_logic_vector(31 downto 0);
    
    -- SPRAM
    signal SP_CS0_cs : std_logic := '0';
    signal SP_CS0_ns : std_logic;
    signal SP_CS1_cs : std_logic := '0';
    signal SP_CS1_ns : std_logic;
    
    signal SPRAM0_OUT : std_logic_vector(31 downto 0);
    signal SPRAM1_OUT : std_logic_vector(31 downto 0);
begin
    
    process(EB8K_CS0_cs, EB8K_CS1_cs, EB16K_CS0_cs, EB16K_CS1_cs, EB32K_CS0_cs, EB32K_CS1_cs, SP_CS0_cs, SP_CS1_cs) is
    begin
        case (EB32K_CS0_cs & EB16K_CS0_cs & EB8K_CS0_cs) is
            when "100" => DOUTA <= EBRAM32K_OUT0;
            when "010" => DOUTA <= EBRAM16K_OUT0;
            when "001" => DOUTA <= EBRAM8K_OUT0;
            when others => DOUTA <= (others => '0');
        end case;
        
        case (SP_CS1_cs & SP_CS0_cs & EB32K_CS1_cs & EB16K_CS1_cs & EB8K_CS1_cs) is
            when "10000" => DOUTB <= SPRAM1_OUT;
            when "01000" => DOUTB <= SPRAM0_OUT;
            when "00100" => DOUTB <= EBRAM32K_OUT1;
            when "00010" => DOUTB <= EBRAM16K_OUT1;
            when "00001" => DOUTB <= EBRAM8K_OUT1;
            when others => DOUTB <= (others => '0');
        end case;
    end process;
    
    process(ADDRA, ADDRB, ENA, ENB) is
    begin
        if ADDRA(10) = '1' then
            if ADDRA(9) = '1' then
                EB8K_CS0_ns <= '1' and ENA;
                EB16K_CS0_ns <= '0';
            else
                EB8K_CS0_ns <= '0';
                EB16K_CS0_ns <= '1' and ENA;
            end if;
            
            EB32K_CS0_ns <= '0';
        else            
            EB8K_CS0_ns <= '0';
            EB16K_CS0_ns <= '0';
            EB32K_CS0_ns <= '1' and ENA;
        end if;
    
        if ADDRB(15) = '1' then
            SP_CS1_ns <= '1' and ENB;
            SP_CS0_ns <= '0';
            
            EB8K_CS1_ns <= '0';
            EB16K_CS1_ns <= '0';
            EB32K_CS1_ns <= '0';  
        elsif ADDRB(14) = '1' then
            SP_CS1_ns <= '0';
            SP_CS0_ns <= '1' and ENB;
            
            EB8K_CS1_ns <= '0';
            EB16K_CS1_ns <= '0';
            EB32K_CS1_ns <= '0';          
        elsif ADDRB(10) = '1' then
            SP_CS1_ns <= '0';
            SP_CS0_ns <= '0';
            
            if ADDRB(9) = '1' then
                EB8K_CS1_ns <= '1' and ENB;
                EB16K_CS1_ns <= '0';
            else
                EB8K_CS1_ns <= '0';
                EB16K_CS1_ns <= '1' and ENB;
            end if;
            
            EB32K_CS1_ns <= '0';
        else
            SP_CS1_ns <= '0';
            SP_CS0_ns <= '0';
            
            EB8K_CS1_ns <= '0';
            EB16K_CS1_ns <= '0';
            EB32K_CS1_ns <= '1' and ENB;
        end if;
    end process;
    
    SEQ_LOG_A:
    process(CLKA) is
    begin
        if CLKA='1' and CLKA'event then
            EB32K_CS0_cs <= EB32K_CS0_ns;
            EB32K_CS1_cs <= EB32K_CS1_ns;
            EB16K_CS0_cs <= EB16K_CS0_ns;
            EB16K_CS1_cs <= EB16K_CS1_ns;
            EB8K_CS0_cs  <= EB8K_CS0_ns;
            EB8K_CS1_cs  <= EB8K_CS1_ns;
            ----
            SP_CS0_cs    <= SP_CS0_ns;
            SP_CS1_cs    <= SP_CS1_ns;
        end if;
    end process SEQ_LOG_A;
    
    EBR32K : entity DUAL_PORT_32K
    port map(
        -- READ PORT0
        READ0_CLK => CLKA,   
        READ0_ADDRESS => ADDRA(9 downto 0),
        READ0_PORT => EBRAM32K_OUT0,   
        READ0_EN => EB32K_CS0_ns,
        -- READ PORT1
        READ1_CLK => CLKB,    
        READ1_ADDRESS => ADDRB(9 downto 0),
        READ1_PORT => EBRAM32K_OUT1,   
        READ1_EN => EB32K_CS1_ns,    
        -- WRITE PORT
        WRITE_CLK => CLKB,    
        WRITE_ADDRESS => ADDRB(9 downto 0),
        WRITE_PORT => DINB,   
        WRITE_EN => EB32K_CS1_ns,
        WRITE_MASK => WEB
    );
    
    EBR16K : entity DUAL_PORT_16K
    port map(
        -- READ PORT0
        READ0_CLK => CLKA,   
        READ0_ADDRESS => ADDRA(8 downto 0),
        READ0_PORT => EBRAM16K_OUT0,   
        READ0_EN => EB16K_CS0_ns,
        -- READ PORT1
        READ1_CLK => CLKB,    
        READ1_ADDRESS => ADDRB(8 downto 0),
        READ1_PORT => EBRAM16K_OUT1,   
        READ1_EN => EB16K_CS1_ns,    
        -- WRITE PORT
        WRITE_CLK => CLKB,    
        WRITE_ADDRESS => ADDRB(8 downto 0),
        WRITE_PORT => DINB,   
        WRITE_EN => EB16K_CS1_ns,
        WRITE_MASK => WEB
    );
    
    EBR8K : entity DUAL_PORT_8K
    port map(
        -- READ PORT0
        READ0_CLK => CLKA,   
        READ0_ADDRESS => ADDRA(7 downto 0),
        READ0_PORT => EBRAM8K_OUT0,   
        READ0_EN => EB8K_CS0_ns,
        -- READ PORT1
        READ1_CLK => CLKB,    
        READ1_ADDRESS => ADDRB(7 downto 0),
        READ1_PORT => EBRAM8K_OUT1,   
        READ1_EN => EB8K_CS1_ns,    
        -- WRITE PORT
        WRITE_CLK => CLKB,    
        WRITE_ADDRESS => ADDRB(7 downto 0),
        WRITE_PORT => DINB,   
        WRITE_EN => EB8K_CS1_ns,
        WRITE_MASK => WEB
    );
        
    SPRAM00 : SP256K
    port map(
        AD => ADDRB(13 downto 0),
        DI => DINB(15 downto 0),
        MASKWE => WEB(1) & WEB(1) & WEB(0) & WEB(0),
        WE => WEB(1) or WEB(0),
        CS => SP_CS0_ns,
        CK => CLKB,
        STDBY => '0',
        SLEEP => '0',
        PWROFF_N => '1',
        DO => SPRAM0_OUT(15 downto 0)
    );
    
    SPRAM01 : SP256K
    port map(
        AD => ADDRB(13 downto 0),
        DI => DINB(31 downto 16),
        MASKWE => WEB(3) & WEB(3) & WEB(2) & WEB(2),
        WE => WEB(3) or WEB(2),
        CS => SP_CS0_ns,
        CK => CLKB,
        STDBY => '0',
        SLEEP => '0',
        PWROFF_N => '1',
        DO => SPRAM0_OUT(31 downto 16)
    );
    
    SPRAM10 : SP256K
    port map(
        AD => ADDRB(13 downto 0),
        DI => DINB(15 downto 0),
        MASKWE => WEB(1) & WEB(1) & WEB(0) & WEB(0),
        WE => WEB(1) or WEB(0),
        CS => SP_CS1_ns,
        CK => CLKB,
        STDBY => '0',
        SLEEP => '0',
        PWROFF_N => '1',
        DO => SPRAM1_OUT(15 downto 0)
    );
    
    SPRAM11 : SP256K
    port map(
        AD => ADDRB(13 downto 0),
        DI => DINB(31 downto 16),
        MASKWE => WEB(3) & WEB(3) & WEB(2) & WEB(2),
        WE => WEB(3) or WEB(2),
        CS => SP_CS1_ns,
        CK => CLKB,
        STDBY => '0',
        SLEEP => '0',
        PWROFF_N => '1',
        DO => SPRAM1_OUT(31 downto 16)
    );
end architecture lattice;