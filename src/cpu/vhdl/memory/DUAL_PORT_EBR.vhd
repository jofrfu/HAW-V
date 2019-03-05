library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;

use WORK.RAM_CONTENT.all;

entity DUAL_PORT_EBR is
    generic(
        ADDRESS_WIDTH  : integer := 11;
        MEMORY_CONTENT : MEMORY_TYPE(0 to 4*2**ADDRESS_WIDTH-1) := (others => (others => '0'))
    );
    port(
        -- READ PORT
        READ_CLK        : in  std_logic;
        READ_ADDRESS    : in  std_logic_vector(ADDRESS_WIDTH-1 downto 0);
        READ_PORT       : out std_logic_vector(31 downto 0);
        READ_EN         : in  std_logic;
        -- WRITE PORT
        WRITE_CLK       : in  std_logic;
        WRITE_ADDRESS   : in  std_logic_vector(ADDRESS_WIDTH-1 downto 0);
        WRITE_PORT      : in  std_logic_vector(31 downto 0);
        WRITE_EN        : in  std_logic;
        WRITE_MASK      : in  std_logic_vector(3 downto 0)
    );
end entity DUAL_PORT_EBR;

library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;
    
library ICE40UP;
    use ICE40UP.COMPONENTS.all;

use WORK.riscv_pack.all;

entity DUAL_PORT_EBR_8K is
    port(
        -- READ PORT
        READ_CLK        : in  std_logic;
        READ_ADDRESS    : in  std_logic_vector(7 downto 0);
        READ_PORT       : out std_logic_vector(31 downto 0);
        READ_EN         : in  std_logic;
        -- WRITE PORT
        WRITE_CLK       : in  std_logic;
        WRITE_ADDRESS   : in  std_logic_vector(7 downto 0);
        WRITE_PORT      : in  std_logic_vector(31 downto 0);
        WRITE_EN        : in  std_logic;
        WRITE_MASK      : in  std_logic_vector(3 downto 0)
    );
end entity DUAL_PORT_EBR_8K;

architecture BEH of DUAL_PORT_EBR is       
    type RAM_TYPE is array(0 to 2**ADDRESS_WIDTH-1) of std_logic_vector(7 downto 0);
    
    function INIT_RAM(DUMP : MEMORY_TYPE; INDEX : integer) return RAM_TYPE;
    function INIT_RAM(DUMP : MEMORY_TYPE; INDEX : integer) return RAM_TYPE is
        variable RAM_VALUES : RAM_TYPE;
    begin
        for i in 0 to 2**ADDRESS_WIDTH-1 loop
            RAM_VALUES(i) := DUMP(i*4+INDEX);
        end loop;
        return RAM_VALUES;
    end function INIT_RAM; 
    
    signal RAM0 : RAM_TYPE := INIT_RAM(MEMORY_CONTENT, 3);
    signal RAM1 : RAM_TYPE := INIT_RAM(MEMORY_CONTENT, 2);
    signal RAM2 : RAM_TYPE := INIT_RAM(MEMORY_CONTENT, 1);
    signal RAM3 : RAM_TYPE := INIT_RAM(MEMORY_CONTENT, 0);   
begin
    
    process(WRITE_CLK) is
    begin
        if WRITE_CLK = '1' and WRITE_CLK'event then
            if WRITE_EN = '1' then
                if WRITE_MASK(0) = '1' then
                    RAM0(to_integer(unsigned(WRITE_ADDRESS)))(7 downto 0) <= WRITE_PORT(7 downto 0);
                end if;
                
                if WRITE_MASK(1) = '1' then
                    RAM1(to_integer(unsigned(WRITE_ADDRESS)))(7 downto 0) <= WRITE_PORT(15 downto 8);
                end if;
                
                if WRITE_MASK(2) = '1' then
                    RAM2(to_integer(unsigned(WRITE_ADDRESS)))(7 downto 0) <= WRITE_PORT(23 downto 16);
                end if;
                
                if WRITE_MASK(3) = '1' then
                    RAM3(to_integer(unsigned(WRITE_ADDRESS)))(7 downto 0) <= WRITE_PORT(31 downto 24);
                end if;
            end if;
        end if;
    end process;
    
    process(READ_CLK) is
    begin
        if READ_CLK = '1' and READ_CLK'event then
            if READ_EN = '1' then
                READ_PORT <= RAM3(to_integer(unsigned(READ_ADDRESS)))
                           & RAM2(to_integer(unsigned(READ_ADDRESS)))
                           & RAM1(to_integer(unsigned(READ_ADDRESS)))
                           & RAM0(to_integer(unsigned(READ_ADDRESS)));
            end if;
        end if;
    end process;
end architecture BEH;

architecture BEH of DUAL_PORT_EBR_8K is
    -- function INIT_RAM(DUMP : MEMORY_TYPE; INDEX : integer; POSITION : integer) return string;
    -- TODO: Implement RAM initialization
begin

    EBR0 : PDP4K
    generic map(
        DATA_WIDTH_W => "16",
        DATA_WIDTH_R => "16"
    )
    port map(
        DI => WRITE_PORT(15 downto 0),
        ADW => "000" & WRITE_ADDRESS,
        ADR => "000" & READ_ADDRESS,
        CKW => WRITE_CLK,
        CKR => READ_CLK,
        CEW => '1',
        CER => '1',
        RE => READ_EN,
        WE => WRITE_EN and (WRITE_MASK(1) or WRITE_MASK(0)),
        MASK_N => (15 downto 8 => not WRITE_MASK(1), 7 downto 0 => not WRITE_MASK(0)),
        DO => READ_PORT(15 downto 0)
    );
    
    EBR1 : PDP4K
    generic map(
        DATA_WIDTH_W => "16",
        DATA_WIDTH_R => "16"
    )
    port map(
        DI => WRITE_PORT(31 downto 16),
        ADW => "000" & WRITE_ADDRESS,
        ADR => "000" & READ_ADDRESS,
        CKW => WRITE_CLK,
        CKR => READ_CLK,
        CEW => '1',
        CER => '1',
        RE => READ_EN,
        WE => WRITE_EN and (WRITE_MASK(3) or WRITE_MASK(2)),
        MASK_N => (15 downto 8 => not WRITE_MASK(3), 7 downto 0 => not WRITE_MASK(2)),
        DO => READ_PORT(31 downto 16)
    );
end architecture BEH;