library IEEE;
    use IEEE.std_logic_1164.all;
    
use WORK.COMPONENTS.all;
    
architecture lattice of blk_mem_gen_0_wrapper is
    -- EBRAM for Instructions
    signal EB_CS00 : std_logic;
    signal EB_CS01 : std_logic;
    signal EB_CS10 : std_logic;
    signal EB_CS11 : std_logic;
    
    signal EBRAM00_OUT : std_logic_vector(31 downto 0);
    signal EBRAM01_OUT : std_logic_vector(31 downto 0);
    signal EBRAM10_OUT : std_logic_vector(31 downto 0);
    signal EBRAM11_OUT : std_logic_vector(31 downto 0);
    
    -- EBRAM for Data
    signal EB_DATA_CS : std_logic;
    
    signal EBRAM_DATA_OUT : std_logic_vector(31 downto 0);
    
    -- SPRAM
    signal SP_CS0 : std_logic;
    signal SP_CS1 : std_logic;
    
    signal SPRAM0_OUT : std_logic_vector(31 downto 0);
    signal SPRAM1_OUT : std_logic_vector(31 downto 0);
begin
    
    process(ADDRB, ENB, EBRAM00_OUT, EBRAM10_OUT, EBRAM_DATA_OUT, SPRAM0_OUT, SPRAM1_OUT) is
    begin
        if ADDRB(15 downto 14) = "10" then
            -- SPRAM1 - 32 KiB
            SP_CS1 <= '1' and ENB;
            SP_CS0 <= '0';
            EB_CS00 <= '0';
            EB_CS10 <= '0';
            EB_DATA_CS <= '0';
            DOUTB <= SPRAM1_OUT;
        elsif ADDRB(14) = '1' then
            -- SPRAM0 - 32 KiB
            SP_CS1 <= '0';
            SP_CS0 <= '1' and ENB;
            EB_CS00 <= '0';
            EB_CS10 <= '0';
            EB_DATA_CS <= '0';
            DOUTB <= SPRAM0_OUT;
        elsif ADDRB(11) = '1' then
            -- Unmapped
            SP_CS1 <= '0';
            SP_CS0 <= '0';
            EB_CS00 <= '0';
            EB_CS10 <= '0';
            EB_DATA_CS <= '0';
            DOUTB <= (others => '0');
        elsif ADDRB(10 downto 9) = "11" then
            -- Data EBR - 2 KiB
            SP_CS1 <= '0';
            SP_CS0 <= '0';
            EB_CS00 <= '0';
            EB_CS10 <= '0';
            EB_DATA_CS <= '1' and ENB;
            DOUTB <= EBRAM_DATA_OUT;
        elsif ADDRB(10) = '1' then
            -- redundant EDR1 - 2 KiB
            SP_CS1 <= '0';
            SP_CS0 <= '0';
            EB_CS00 <= '0';
            EB_CS10 <= '1' and ENB;
            EB_DATA_CS <= '0';
            DOUTB <= EBRAM10_OUT;
        else
            -- redundant EDR0 - 4 KiB
            SP_CS1 <= '0';
            SP_CS0 <= '0';
            EB_CS00 <= '1' and ENB;
            EB_CS10 <= '0';
            EB_DATA_CS <= '0';
            DOUTB <= EBRAM00_OUT;
        end if;
    end process;
    
    process(ADDRA, ENA, EBRAM01_OUT, EBRAM11_OUT) is
    begin
        if ADDRA(10) = '1' then
            DOUTA <= EBRAM11_OUT;
            EB_CS01 <= '0';
            EB_CS11 <= '1' and ENA;
        else
            DOUTA <= EBRAM01_OUT;
            EB_CS01 <= '1' and ENA;
            EB_CS11 <= '0';
        end if;
    end process;
    
    EBRAM00 : entity EBR
    generic map(
        ADDRESS_WIDTH => 10
    )
    port map(
        READ_CLK => CLKB,     
        READ_ADDRESS => ADDRB(9 downto 0),
        READ_PORT => EBRAM00_OUT,
        READ_EN => EB_CS00,
        --
        WRITE_CLK => CLKB,
        WRITE_ADDRESS => ADDRB(9 downto 0),
        WRITE_PORT => DINB,
        WRITE_EN => EB_CS00,
        WRITE_MASK => WEB
    );
    
    EBRAM01 : entity EBR
    generic map(
        ADDRESS_WIDTH => 10
    )
    port map(
        READ_CLK => CLKA,     
        READ_ADDRESS => ADDRA(9 downto 0),
        READ_PORT => EBRAM01_OUT,
        READ_EN => EB_CS01,
        --
        WRITE_CLK => CLKB,
        WRITE_ADDRESS => ADDRB(9 downto 0),
        WRITE_PORT => DINB,
        WRITE_EN => EB_CS00,
        WRITE_MASK => WEB
    );
    
    EBRAM10 : entity EBR
    generic map(
        ADDRESS_WIDTH => 9
    )
    port map(
        READ_CLK => CLKB,     
        READ_ADDRESS => ADDRB(8 downto 0),
        READ_PORT => EBRAM10_OUT,
        READ_EN => EB_CS10,
        --
        WRITE_CLK => CLKB,
        WRITE_ADDRESS => ADDRB(8 downto 0),
        WRITE_PORT => DINB,
        WRITE_EN => EB_CS10,
        WRITE_MASK => WEB
    );
    
    EBRAM11 : entity EBR
    generic map(
        ADDRESS_WIDTH => 9
    )
    port map(
        READ_CLK => CLKA,     
        READ_ADDRESS => ADDRA(8 downto 0),
        READ_PORT => EBRAM11_OUT,
        READ_EN => EB_CS11,
        --
        WRITE_CLK => CLKB,
        WRITE_ADDRESS => ADDRB(8 downto 0),
        WRITE_PORT => DINB,
        WRITE_EN => EB_CS10,
        WRITE_MASK => WEB
    );
    
    EBRAM_DATA : entity EBR
    generic map(
        ADDRESS_WIDTH => 9
    )
    port map(
        READ_CLK => CLKB,     
        READ_ADDRESS => ADDRB(8 downto 0),
        READ_PORT => EBRAM_DATA_OUT,
        READ_EN => EB_DATA_CS,
        --
        WRITE_CLK => CLKB,
        WRITE_ADDRESS => ADDRB(8 downto 0),
        WRITE_PORT => DINB,
        WRITE_EN => EB_DATA_CS,
        WRITE_MASK => WEB
    );
        
    SPRAM00 : SP256K
    port map(
        AD => ADDRB(13 downto 0),
        DI => DINB(15 downto 0),
        MASKWE => WEB(1) & WEB(1) & WEB(0) & WEB(0),
        WE => WEB(1) or WEB(0),
        CS => SP_CS0,
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
        CS => SP_CS0,
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
        CS => SP_CS1,
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
        CS => SP_CS1,
        CK => CLKB,
        STDBY => '0',
        SLEEP => '0',
        PWROFF_N => '1',
        DO => SPRAM1_OUT(31 downto 16)
    );
end architecture lattice;