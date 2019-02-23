library IEEE;
    use IEEE.std_logic_1164.all;
    
use WORK.COMPONENTS.all;
    
architecture lattice of blk_mem_gen_0_wrapper is
    -- EBRAM
    signal EB_CS0 : std_logic;
    
    signal EBRAM0_OUT_MAP : std_logic_vector(15 downto 0);
    signal EBRAM0_OUT : std_logic_vector(3 downto 0);
    
    -- SPRAM
    signal SP_CS0 : std_logic;
    signal SP_CS1 : std_logic;
    
    signal SPRAM0_OUT : std_logic_vector(31 downto 0);
    signal SPRAM1_OUT : std_logic_vector(31 downto 0);
begin
    
    EBRAM0_OUT <= EBRAM0_OUT_MAP(13) & EBRAM0_OUT_MAP(9) & EBRAM0_OUT_MAP(5) & EBRAM0_OUT_MAP(1);
    
    process is
    begin
        if ADDRB(15) = '1' then
            SP_CS1 <= '1';
            SP_CS0 <= '0';
            EB_CS0 <= '0';
            DOUTB <= SPRAM1_OUT;
        elsif ADDRB(14) = '1' then
            SP_CS1 <= '0';
            SP_CS0 <= '1';
            EB_CS0 <= '0';
            DOUTB <= SPRAM0_OUT;
        else
            SP_CS1 <= '0';
            SP_CS0 <= '0';
            EB_CS0 <= '1';
            DOUTB <= x"0000000" & EBRAM0_OUT;
        end if;
    end process;
    
    EBR0 : PDP4K
    generic map(
        DATA_WIDTH_W => "4",
        DATA_WIDTH_R => "4"
    )
    port map(
        DI => (13 => DINB(3), 9 => DINB(2), 5 => DINB(1), 1 => DINB(0), others => '0'),
        ADW => '0' & ADDRB(9 downto 0),
        ADR => '0' & ADDRB(9 downto 0),
        CKW => CLKB,
        CKR => CLKB,
        CEW => '1',
        CER => '1',
        RE  => '1',
        WE  => EB_CS0,
        MASK_N => x"0000",
        DO => EBRAM0_OUT_MAP
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