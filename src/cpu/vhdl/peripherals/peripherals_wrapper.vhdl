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
        PERIPH_BIT_IO   : inout PERIPH_IN_TYPE;
    );
end entity peripherals_wrapper;

architecture beh of peripherals_wrapper is

begin
    PERIPH_WRITE_EN <= (others => '0');
    PERIPH_to_MEM   <= (others => (others => '0'));
    PERIPH_BIT_IO   <= (others => '0');
end architecture beh;
