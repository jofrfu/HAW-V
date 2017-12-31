--!@brief 	This file contains peripheral IO
--!@author 	Jonas Fuhrmann
--!@date 	2017

use WORK.riscv_pack.all;
LIBRARY IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;
    
entity peripheral_io is
    port(
        CLK            : IN  STD_LOGIC;
        RESET          : IN  STD_LOGIC;
        EN             : IN  STD_LOGIC;     -- enables access
        WEA            : IN  STD_LOGIC_vector(3 DOWNTO 0); -- enables write access
        ADDR           : IN  ADDRESS_TYPE;  -- selects peripheral
        DIN            : IN  DATA_TYPE;     -- input for selected peripheral
        DOUT           : OUT DATA_TYPE;     -- output of selected peripheral
        
        -- IO
        PERIPH_IN_EN   : IN  IO_ENABLE_TYPE;-- disables write access - register is written from peripheral
        PERIPH_IN      : IN  IO_BYTE_TYPE;  -- input for peripheral connections
        PERIPH_OUT     : OUT IO_BYTE_TYPE   -- output for peripheral connections 
    );
end entity peripheral_io;

architecture beh of peripheral_io is
    signal PERIPH_cs : IO_BYTE_TYPE := (others => (others => '0'));
    signal PERIPH_ns : IO_BYTE_TYPE;
    signal DOUT_cs   : DATA_TYPE := (others => '0');
    signal DOUT_ns   : DATA_TYPE;
    
    signal DECODE_RESU : IO_BYTE_TYPE;
begin

    PERIPH_OUT <= PERIPH_cs;
    DOUT <= DOUT_cs;
    --!@brief writes eventually to registers, reads from registers
    decode:
    process(EN, WEA, ADDR, DIN, PERIPH_cs) is
        variable EN_v   : std_logic;
        variable WEA_v  : std_logic_vector(3 downto 0);
        variable ADDR_v : ADDRESS_TYPE;
        variable DIN_v  : DATA_TYPE;
        
        variable PERIPH_cs_v    : IO_BYTE_TYPE;
        
        variable DECODE_RESU_v  : IO_BYTE_TYPE;
        variable DOUT_v : DATA_TYPE;
    begin
        EN_v   := EN;
        WEA_v  := WEA;
        -- manipulate for getting memory behavior
        ADDR_v := '0' & ADDR(ADDRESS_WIDTH-2 downto 2) & "00";
        DIN_v  := DIN;
        
        PERIPH_cs_v := PERIPH_cs;
        
        DOUT_v := (others => '0');
        DECODE_RESU_v := (others => (others => '0'));
        
        if EN_v = '1' then
            -- read and write
            if to_integer(unsigned(ADDR_v)) + 0 < IO_BYTE_COUNT then
                DOUT_v(4*BYTE_WIDTH-1 downto 3*BYTE_WIDTH) := PERIPH_cs_v(to_integer(unsigned(ADDR_v)) + 0);
                
                if WEA_v(3) = '1' then
                    DECODE_RESU_v(to_integer(unsigned(ADDR_v)) + 0) := DIN_v(4*BYTE_WIDTH-1 downto 3*BYTE_WIDTH);
                end if;
            end if;
            
            if to_integer(unsigned(ADDR_v)) + 1 < IO_BYTE_COUNT then
                DOUT_v(3*BYTE_WIDTH-1 downto 2*BYTE_WIDTH) := PERIPH_cs_v(to_integer(unsigned(ADDR_v)) + 1);
                
                if WEA_v(2) = '1' then
                    DECODE_RESU_v(to_integer(unsigned(ADDR_v)) + 1) := DIN_v(3*BYTE_WIDTH-1 downto 2*BYTE_WIDTH);
                end if;
            end if;
            
            if to_integer(unsigned(ADDR_v)) + 2 < IO_BYTE_COUNT then
                DOUT_v(2*BYTE_WIDTH-1 downto 1*BYTE_WIDTH) := PERIPH_cs_v(to_integer(unsigned(ADDR_v)) + 2);
                
                if WEA_v(1) = '1' then
                    DECODE_RESU_v(to_integer(unsigned(ADDR_v)) + 2) := DIN_v(2*BYTE_WIDTH-1 downto 1*BYTE_WIDTH);
                end if;
            end if;
            
            if to_integer(unsigned(ADDR_v)) + 3 < IO_BYTE_COUNT then
                DOUT_v(1*BYTE_WIDTH-1 downto 0*BYTE_WIDTH) := PERIPH_cs_v(to_integer(unsigned(ADDR_v)) + 3);
            
                if WEA_v(0) = '1' then
                    DECODE_RESU_v(to_integer(unsigned(ADDR_v)) + 3) := DIN_v(1*BYTE_WIDTH-1 downto 0*BYTE_WIDTH);
                end if;
            end if;
            
        end if;
        
        DECODE_RESU <= DECODE_RESU_v;
        DOUT_ns <= DOUT_v;
    end process decode;
    
    --!@brief chooses between input or peripheral for writing to registers
    choose:
    process(PERIPH_IN_EN, PERIPH_IN, DECODE_RESU, EN, PERIPH_cs, ADDR, WEA) is
        variable PERIPH_IN_EN_v : IO_ENABLE_TYPE;
        variable PERIPH_IN_v    : IO_BYTE_TYPE;
        variable DECODE_RESU_v  : IO_BYTE_TYPE;
        
        variable PERIPH_ns_v    : IO_BYTE_TYPE;
        variable PERIPH_cs_v    : IO_BYTE_TYPE;
        
        variable EN_v : std_logic;
        
        variable ADDR_v : ADDRESS_TYPE;
        variable WEA_v : STD_LOGIC_vector(3 DOWNTO 0);
    begin
        
        -- manipulate for getting memory behavior
        ADDR_v := '0' & ADDR(ADDRESS_WIDTH-2 downto 2) & "00";
        
        PERIPH_IN_EN_v := PERIPH_IN_EN;
        PERIPH_IN_v    := PERIPH_IN;
        DECODE_RESU_v  := DECODE_RESU;
        
        PERIPH_cs_v := PERIPH_cs;
        EN_v := EN;
        WEA_v := WEA;
    
        for i in 0 to IO_BYTE_COUNT-1 loop
            if PERIPH_IN_EN_v(i) = '1' then
                PERIPH_ns_v(i) := PERIPH_IN_v(i);
            else
                if EN_v = '1' and
                    ((to_integer(unsigned(ADDR_v) + 0) = i and WEA_v(3) = '1') or 
                     (to_integer(unsigned(ADDR_v) + 1) = i and WEA_v(2) = '1') or 
                     (to_integer(unsigned(ADDR_v) + 2) = i and WEA_v(1) = '1') or 
                     (to_integer(unsigned(ADDR_v) + 3) = i and WEA_v(0) = '1')) then -- chip enable - only on write from core
                    PERIPH_ns_v(i) := DECODE_RESU_v(i);
                else
                    PERIPH_ns_v(i) := PERIPH_cs_v(i);
                end if;
            end if;
        end loop;
        
        PERIPH_ns <= PERIPH_ns_v;
    end process choose;
    
    sequ_log:
    process(clk) is
    begin
        if clk'event and clk = '1' then
            if reset = '1' then
                PERIPH_cs <= (others => (others => '0'));
                DOUT_cs <= (others => '0'); 
            else
                PERIPH_cs <= PERIPH_ns;
                DOUT_cs <= DOUT_ns;
            end if;
        end if;
    end process sequ_log;
    
end architecture beh;
