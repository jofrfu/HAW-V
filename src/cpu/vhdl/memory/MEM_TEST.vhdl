library IEEE;
    use IEEE.std_logic_1164.all;
use WORK.COMPONENTS.all;
    
architecture mem_test of blk_mem_gen_0_wrapper is
    signal SPRAM0_OUT : std_logic_vector(31 downto 0);
    signal SPRAM1_OUT : std_logic_vector(31 downto 0);
    
    signal SP_CS0 : std_logic;
    signal SP_CS1 : std_logic;
begin 
    
    process(ADDRB, SPRAM0_OUT, SPRAM1_OUT, ENB) is
    begin
        if ADDRB(14) = '1' then
            SP_CS1 <= '1' and ENB;
            SP_CS0 <= '0';
            DOUTB <= SPRAM1_OUT;
        else
            SP_CS1 <= '0';
            SP_CS0 <= '1' and ENB;
            DOUTB <= SPRAM0_OUT;
        end if;
    end process;
    
    SPRAM00 : SP256k
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
end architecture mem_test;