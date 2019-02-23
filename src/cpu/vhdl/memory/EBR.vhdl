library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;
    
entity EBR is
    generic(
        ADDRESS_WIDTH   : integer := 10
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
end entity EBR;

architecture BEH of EBR is
    type EBR_TYPE is array(0 to (2**ADDRESS_WIDTH)-1) of std_logic_vector(7 downto 0);
    
    signal EBR_MEM0 : EBR_TYPE;
    signal EBR_MEM1 : EBR_TYPE;
    signal EBR_MEM2 : EBR_TYPE;
    signal EBR_MEM3 : EBR_TYPE;
begin
    process(READ_CLK) is
    begin
        if READ_CLK = '1' and READ_CLK'event then
            if READ_EN = '1' then
                READ_PORT <= EBR_MEM0(to_integer(unsigned(READ_ADDRESS))) &
                             EBR_MEM1(to_integer(unsigned(READ_ADDRESS))) &
                             EBR_MEM2(to_integer(unsigned(READ_ADDRESS))) &
                             EBR_MEM3(to_integer(unsigned(READ_ADDRESS)));
            end if;
        end if;
    end process;
    
    process(WRITE_CLK) is
    begin
        if WRITE_EN = '1' then
            if WRITE_CLK = '1' and WRITE_CLK'event then
                if WRITE_MASK(3) = '1' then
                    EBR_MEM0(to_integer(unsigned(READ_ADDRESS))) <= WRITE_PORT(31 downto 24);
                end if;
                
                if WRITE_MASK(2) = '1' then
                    EBR_MEM1(to_integer(unsigned(READ_ADDRESS))) <= WRITE_PORT(23 downto 16);
                end if;

                if WRITE_MASK(1) = '1' then
                    EBR_MEM2(to_integer(unsigned(READ_ADDRESS))) <= WRITE_PORT(15 downto  8);
                end if;
                
                if WRITE_MASK(0) = '1' then
                    EBR_MEM3(to_integer(unsigned(READ_ADDRESS))) <= WRITE_PORT( 7 downto  0);
                end if;
            end if;
        end if;
    end process;
end architecture BEH;