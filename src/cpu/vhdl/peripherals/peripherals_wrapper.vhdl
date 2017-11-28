--!@brief 	This file contains the peripherals
--!@author 	Jonas Fuhrmann
--!@date 	2017

library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;

use WORK.riscv_pack.all;

entity peripherals_wrapper is
    port(
        clk, reset      : in std_logic;
        
        -- memory connections
        PERIPH_WRITE_EN : out   IO_ENABLE_TYPE;
        PERIPH_to_MEM   : out   IO_BYTE_TYPE;
        MEM_to_PERIPH   : in    IO_BYTE_TYPE;
        
        -- top level connections
        PERIPH_BIT_IO   : inout PERIPH_IO_TYPE
    );
end entity peripherals_wrapper;

architecture beh of peripherals_wrapper is
    signal PERIPH_BIT_IN  : PERIPH_IO_TYPE;
    signal PERIPH_BIT_OUT : PERIPh_IO_TYPE;
begin
    GPIO:
    process(MEM_to_PERIPH(1 downto 0), PERIPH_BIT_IO(BYTE_WIDTH-1 downto 0)) is
        variable MEM_to_PERIPH_v : GPIO_TYPE;
        variable PERIPH_BIT_IO_v : BYTE_TYPE;
        
        variable PERIPH_WRITE_EN_v : std_logic;
        variable PERIPH_to_MEM_v   : BYTE_TYPE;
    begin
        MEM_to_PERIPH_v(0) := MEM_to_PERIPH(0);
        MEM_to_PERIPH_v(1) := MEM_to_PERIPH(1);
        PERIPH_BIT_IO_v := PERIPH_BIT_IO(BYTE_WIDTH-1 downto 0);
        
        -- map periph write enable
        PERIPH_WRITE_EN_v := MEM_to_PERIPH_v(0)(0);

        if PERIPH_WRITE_EN_v = '1' then
            -- map memory to output
            PERIPH_BIT_IO_v := MEM_to_PERIPH_v(1);
            -- unmapped - not used in memory
            PERIPH_to_MEM_v := (others => '0'); 
        else
            -- driven by input
            PERIPH_BIT_IO_v := (others => 'Z');
            -- map input to memory
            PERIPH_to_MEM_v := PERIPH_BIT_IO_v;
        end if;
        
        PERIPH_BIT_IO(BYTE_WIDTH-1 downto 0) <= PERIPH_BIT_IO_v;
        PERIPH_WRITE_EN(0) <= '0';
        PERIPH_WRITE_EN(1) <= PERIPH_WRITE_EN_v;
        PERIPH_to_MEM(0)   <= (others => '0');
        PERIPH_to_MEM(1)   <= PERIPH_to_MEM_v;
    end process GPIO;
end architecture beh;
