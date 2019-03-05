library IEEE;
    use IEEE.std_logic_1164.all;

library ICE40UP;
    use ICE40UP.COMPONENTS.all;
    
use WORK.RAM_CONTENT.all;
    
architecture lattice of blk_mem_gen_0_wrapper is
    -- EBRAM for Instructions   
    signal EB64K_WE : std_logic;
    
    -- EBRAM for Data
    signal EB32K_CS_cs : std_logic := '0';
    signal EB32K_CS_ns : std_logic;
    
    signal EBRAM32K_OUT : std_logic_vector(31 downto 0);
    
    signal EB16K_CS_cs : std_logic := '0';
    signal EB16K_CS_ns : std_logic;
    
    signal EBRAM16K_OUT : std_logic_vector(31 downto 0);
    
    signal EB8K_CS_cs : std_logic := '0';
    signal EB8K_CS_ns : std_logic;
    
    signal EBRAM8K_OUT : std_logic_vector(31 downto 0);
    
    -- SPRAM for Data
    signal SP_CS0_cs : std_logic := '0';
    signal SP_CS0_ns : std_logic;
    signal SP_CS1_cs : std_logic := '0';
    signal SP_CS1_ns : std_logic;
    
    signal SPRAM0_OUT : std_logic_vector(31 downto 0);
    signal SPRAM1_OUT : std_logic_vector(31 downto 0);
    
    -- Address
    signal ADDRA_WORD : std_logic_vector(29 downto 0);
    signal ADDRB_WORD : std_logic_vector(29 downto 0);
    
begin
    
    ADDRA_WORD <= ADDRA(31 downto 2);
    ADDRB_WORD <= ADDRB(31 downto 2);
    
    process(EB8K_CS_cs, EB16K_CS_cs, EB32K_CS_cs, SP_CS0_cs, SP_CS1_cs,
            EBRAM32K_OUT, EBRAM16K_OUT, EBRAM8K_OUT, SPRAM0_OUT, SPRAM1_OUT) is
        variable check_v : std_logic_vector(4 downto 0);
    begin        
        check_v := SP_CS1_cs & SP_CS0_cs & EB32K_CS_cs & EB16K_CS_cs & EB8K_CS_cs;
        case check_v is
            when "10000" => DOUTB <= SPRAM1_OUT;
            when "01000" => DOUTB <= SPRAM0_OUT;
            when "00100" => DOUTB <= EBRAM32K_OUT;
            when "00010" => DOUTB <= EBRAM16K_OUT;
            when "00001" => DOUTB <= EBRAM8K_OUT;
            when others => DOUTB <= (others => '0');
        end case;
    end process;
    
    process(ADDRB_WORD, ENB) is
    begin
    
        if ADDRB_WORD(15) = '1' then
            SP_CS1_ns <= '1' and ENB;
            SP_CS0_ns <= '0';
            
            EB64K_WE <= '0';

            EB8K_CS_ns <= '0';
            EB16K_CS_ns <= '0';
            EB32K_CS_ns <= '0';            
        elsif ADDRB_WORD(14) = '1' then
            SP_CS1_ns <= '0';
            SP_CS0_ns <= '1' and ENB;
            
            EB64K_WE <= '0';

            EB8K_CS_ns <= '0';
            EB16K_CS_ns <= '0';
            EB32K_CS_ns <= '0';            
        elsif ADDRB_WORD(11) = '1' then
            SP_CS1_ns <= '0';
            SP_CS0_ns <= '0';
            
            EB64K_WE <= '0';
            
            if ADDRB_WORD(10) = '1' then
                if ADDRB_WORD(9) = '1' then
                    EB8K_CS_ns <= '1' and ENB;
                    EB16K_CS_ns <= '0';
                else
                    EB8K_CS_ns <= '0';
                    EB16K_CS_ns <= '1' and ENB;
                end if;
                
                EB32K_CS_ns <= '0';
            else
                EB8K_CS_ns <= '0';
                EB16K_CS_ns <= '0';
                EB32K_CS_ns <= '1' and ENB;
            end if;
        else
            SP_CS1_ns <= '0';
            SP_CS0_ns <= '0';
            
            EB64K_WE <= '1' and ENB;
            
            EB8K_CS_ns <= '0';
            EB16K_CS_ns <= '0';
            EB32K_CS_ns <= '0';
        end if;
    end process;
    
    SEQ_LOG:
    process(CLKB) is
    begin
        if CLKB='1' and CLKB'event then
            EB32K_CS_cs <= EB32K_CS_ns;
            EB16K_CS_cs <= EB16K_CS_ns;
            EB8K_CS_cs  <= EB8K_CS_ns;
            ----
            SP_CS0_cs    <= SP_CS0_ns;
            SP_CS1_cs    <= SP_CS1_ns;
        end if;
    end process SEQ_LOG;
    
    EBR64K : entity WORK.DUAL_PORT_EBR(BEH)
    generic map(
        ADDRESS_WIDTH => 11,
        MEMORY_CONTENT => INSTRUCTION_EBRAM
    )
    port map(
        -- READ PORT
        READ_CLK => CLKA,   
        READ_ADDRESS => ADDRA_WORD(10 downto 0),
        READ_PORT => DOUTA,   
        READ_EN => ENA,   
        -- WRITE PORT
        WRITE_CLK => CLKB,    
        WRITE_ADDRESS => ADDRB_WORD(10 downto 0),
        WRITE_PORT => DINB,   
        WRITE_EN => EB64K_WE,
        WRITE_MASK => WEB
    );
    
    -----------
    
    EBR32K : entity WORK.DUAL_PORT_EBR(BEH)
    generic map(
        ADDRESS_WIDTH => 10,
        MEMORY_CONTENT => DATA_EBRAM
    )
    port map(
        -- READ PORT
        READ_CLK => CLKB,   
        READ_ADDRESS => ADDRB_WORD(9 downto 0),
        READ_PORT => EBRAM32K_OUT,   
        READ_EN => EB32K_CS_ns,   
        -- WRITE PORT
        WRITE_CLK => CLKB,    
        WRITE_ADDRESS => ADDRB_WORD(9 downto 0),
        WRITE_PORT => DINB,   
        WRITE_EN => EB32K_CS_ns,
        WRITE_MASK => WEB
    );
    
    EBR16K : entity WORK.DUAL_PORT_EBR(BEH)
    generic map(
        ADDRESS_WIDTH => 9
    )
    port map(
        -- READ PORT
        READ_CLK => CLKB,   
        READ_ADDRESS => ADDRB_WORD(8 downto 0),
        READ_PORT => EBRAM16K_OUT,   
        READ_EN => EB16K_CS_ns,   
        -- WRITE PORT
        WRITE_CLK => CLKB,    
        WRITE_ADDRESS => ADDRB_WORD(8 downto 0),
        WRITE_PORT => DINB,   
        WRITE_EN => EB16K_CS_ns,
        WRITE_MASK => WEB
    );
    
    EBR8K : entity WORK.DUAL_PORT_EBR_8K(BEH)
    port map(
        -- READ PORT
        READ_CLK => CLKB,   
        READ_ADDRESS => ADDRB_WORD(7 downto 0),
        READ_PORT => EBRAM8K_OUT,   
        READ_EN => EB8K_CS_ns,   
        -- WRITE PORT
        WRITE_CLK => CLKB,    
        WRITE_ADDRESS => ADDRB_WORD(7 downto 0),
        WRITE_PORT => DINB,   
        WRITE_EN => EB8K_CS_ns,
        WRITE_MASK => WEB
    );
    
    ------------
    
    SPRAM00 : SP256K
    port map(
        AD => ADDRB_WORD(13 downto 0),
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
        AD => ADDRB_WORD(13 downto 0),
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
        AD => ADDRB_WORD(13 downto 0),
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
        AD => ADDRB_WORD(13 downto 0),
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