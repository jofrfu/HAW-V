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
    
    signal DECODE_RESU : IO_BYTE_TYPE;
begin

    PERIPH_OUT <= PERIPH_cs;
    
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
        ADDR_v := ADDR;
        DIN_v  := DIN;
        
        PERIPH_cs_v := PERIPH_cs;
        
        DECODE_RESU_v := (others => (others => '0'));
        
        if EN_v = '1' then
            case WEA_v is
                when "0000" =>
                    DOUT_v := PERIPH_cs_v(to_integer(unsigned(ADDR_v)) + 3)
                            & PERIPH_cs_v(to_integer(unsigned(ADDR_v)) + 2)
                            & PERIPH_cs_v(to_integer(unsigned(ADDR_v)) + 1)
                            & PERIPH_cs_v(to_integer(unsigned(ADDR_v)) + 0);
                when "0001" =>
                    DOUT_v := (others => '0');
                    
                    DECODE_RESU_v(to_integer(unsigned(ADDR_v)) + 0) := DIN_v(1*BYTE_WIDTH-1 downto 0*BYTE_WIDTH);
                when "0011" =>
                    DOUT_v := (others => '0');

                    DECODE_RESU_v(to_integer(unsigned(ADDR_v)) + 0) := DIN_v(1*BYTE_WIDTH-1 downto 0*BYTE_WIDTH);
                    DECODE_RESU_v(to_integer(unsigned(ADDR_v)) + 1) := DIN_v(2*BYTE_WIDTH-1 downto 1*BYTE_WIDTH);
                when "1111" =>
                    DOUT_v := (others => '0');
                    
                    DECODE_RESU_v(to_integer(unsigned(ADDR_v)) + 0) := DIN_v(1*BYTE_WIDTH-1 downto 0*BYTE_WIDTH);
                    DECODE_RESU_v(to_integer(unsigned(ADDR_v)) + 1) := DIN_v(2*BYTE_WIDTH-1 downto 1*BYTE_WIDTH);
                    DECODE_RESU_v(to_integer(unsigned(ADDR_v)) + 2) := DIN_v(3*BYTE_WIDTH-1 downto 2*BYTE_WIDTH);
                    DECODE_RESU_v(to_integer(unsigned(ADDR_v)) + 3) := DIN_v(4*BYTE_WIDTH-1 downto 3*BYTE_WIDTH);
                when others =>
                    report "Unkwown write enable in IO!" severity error;
                    DOUT_v := (others => '0');
            end case;
        else
            DOUT_v := (others => '0');
        end if;
        
        DECODE_RESU <= DECODE_RESU_v;
        DOUT <= DOUT_v;
    end process decode;
    
    --!@brief chooses between input or peripheral for writing to registers
    choose:
    process(PERIPH_IN_EN, PERIPH_IN, DECODE_RESU) is
        variable PERIPH_IN_EN_v : IO_ENABLE_TYPE;
        variable PERIPH_IN_v    : IO_BYTE_TYPE;
        variable DECODE_RESU_v  : IO_BYTE_TYPE;
        
        variable PERIPH_ns_v    : IO_BYTE_TYPE;
    begin
        
        PERIPH_IN_EN_v := PERIPH_IN_EN;
        PERIPH_IN_v    := PERIPH_IN;
        DECODE_RESU_v  := DECODE_RESU;
    
        for i in IO_BYTE_COUNT-1 downto 0 loop
            if PERIPH_IN_EN_v(i) = '1' then
                PERIPH_ns_v(i) := PERIPH_IN_v(i);
            else
                PERIPH_ns_v(i) := DECODE_RESU_v(i);
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
            else
                PERIPH_cs <= PERIPH_ns;
            end if;
        end if;
    end process sequ_log;
    
end architecture beh;
