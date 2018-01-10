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

begin
    GPIO:
    process(MEM_to_PERIPH(0 to 2*GPIO_WIDTH-1), PERIPH_BIT_IO(GPIO_WIDTH*BYTE_WIDTH-1 downto 0)) is
        variable MEM_to_PERIPH_CONF_v : GPIO_TYPE;
        variable MEM_to_PERIPH_GPIO_v : GPIO_TYPE;
        variable PERIPH_BIT_IO_v : std_logic_vector(GPIO_WIDTH*BYTE_WIDTH-1 downto 0);
        
        variable PERIPH_to_MEM_v   : GPIO_TYPE;
    begin
        for i in 0 to GPIO_WIDTH-1 loop
            MEM_to_PERIPH_CONF_v(i) := MEM_to_PERIPH(i);
        end loop;
        
        for i in GPIO_WIDTH to 2*GPIO_WIDTH-1 loop
            MEM_to_PERIPH_GPIO_v(GPIO_WIDTH + i) := MEM_to_PERIPH(i);
        end loop;
        
        PERIPH_BIT_IO_v := PERIPH_BIT_IO(GPIO_WIDTH*BYTE_WIDTH-1 downto 0);
        
        
        for i in 0 to GPIO_WIDTH-1 loop
            for j in BYTE_WIDTH-1 downto 0 loop
                if MEM_to_PERIPH_CONF_v(i)(j) = '0' then
                    PERIPH_BIT_IO_v(i*j) := MEM_to_PERIPH_GPIO_v(i)(j);
                    PERIPH_to_MEM_v(i)(j) := '0';
                else
                    PERIPH_BIT_IO_v(i*j) := 'Z';
                    PERIPH_to_MEM_v(i)(j) := PERIPH_BIT_IO_v(i*j);
                end if;
            end loop;
        end loop;
        
        PERIPH_BIT_IO(GPIO_WIDTH*BYTE_WIDTH-1 downto 0) <= PERIPH_BIT_IO_v;
        PERIPH_WRITE_EN(0 to GPIO_WIDTH-1) <= (others => (others => '0'));
        
        for i in GPIO_WIDTH to 2* GPIO_WIDTH-1 loop
            PERIPH_WRITE_EN(i) <= MEM_to_PERIPH_CONF_v(i - GPIO_WIDTH);
            PERIPH_to_MEM(i) <= PERIPH_to_MEM_v(i - GPIO_WIDTH);
        end loop;
        
        PERIPH_to_MEM(0 to GPIO_WIDTH-1)    <= (others => (others => '0'));
    end process GPIO;
end architecture beh;
