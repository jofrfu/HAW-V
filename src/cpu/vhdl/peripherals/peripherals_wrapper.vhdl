--!@file    peripherals_wrapper.vhdl
--!@brief   This file is part of the ach-ne project at the HAW Hamburg
--!@details Check: https://gitlab.informatik.haw-hamburg.de/lehr-cpu-bs/ach-ne-2017-2018 for more information
--!@author  Jonas Fuhrmann
--!@date    2017 - 2018

library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;

use WORK.riscv_pack.all;

--!brief This wraps all peripherals mapped to the memory of the CPU.
--! Only GPIOs are present at the moment.

entity peripherals_wrapper is
    port(
        clk, reset      : in    std_logic;
        
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

--!brief The process which maps GPIOs
--!details  This device does the following:
--!         1. Get data from memory at GPIO-address (MEM_to_PERIPH)
--!             1.1 Get GPIO configuration bytes
--!             1.2 Get GPIO data bytes
--!         2. Get the in-/output from the pins on the board
--!         3. Map either
--!             3.1 the data from the memory to the output of the pins (MEM_to_PERIPH => PERIPH_BIT_IO) or
--!             3.2 the input of the pins to the memory data (PERIPH_BIT_IO => PERIPH_to_MEM),
--!         depending on the configuration bytes of each GPIO
--!
--! This device is highly scalable by modifying IO_BYTE_COUNT, PERIPH_IO_WIDTH and GPIO_WIDTH in riscv_pack.vhd

    GPIO:
    process(MEM_to_PERIPH(0 to 2*GPIO_WIDTH-1), PERIPH_BIT_IO(GPIO_WIDTH*BYTE_WIDTH-1 downto 0)) is
        variable MEM_to_PERIPH_CONF_v : GPIO_TYPE;
        variable MEM_to_PERIPH_GPIO_v : GPIO_TYPE;
        variable PERIPH_BIT_IO_v : std_logic_vector(GPIO_WIDTH*BYTE_WIDTH-1 downto 0);
        variable PERIPH_BIT_IN_v : std_logic_vector(GPIO_WIDTH*BYTE_WIDTH-1 downto 0);
        
        variable PERIPH_to_MEM_v   : GPIO_TYPE;
    begin
        -- 1.1 Get GPIO config bytes
        for i in 0 to GPIO_WIDTH-1 loop
            MEM_to_PERIPH_CONF_v(i) := MEM_to_PERIPH(i);
        end loop;
        -- 1.2 Get GPIO data bytes
        for i in 0 to GPIO_WIDTH-1 loop
            MEM_to_PERIPH_GPIO_v(i) := MEM_to_PERIPH(GPIO_WIDTH + i);
        end loop;
        
        -- 2. Get the in-/output from pins
        PERIPH_BIT_IO_v := PERIPH_BIT_IO(GPIO_WIDTH*BYTE_WIDTH-1 downto 0);
        PERIPH_BIT_IN_v := PERIPH_BIT_IO(GPIO_WIDTH*BYTE_WIDTH-1 downto 0);
        
        -- 3. Map memory and in-/output pins
        for i in 0 to GPIO_WIDTH-1 loop
            for j in BYTE_WIDTH-1 downto 0 loop
                if MEM_to_PERIPH_CONF_v(i)(j) = '0' then
                    -- 3.1 Map memory data to the pins (output configuration)
                    PERIPH_BIT_IO_v(i*BYTE_WIDTH + j) := MEM_to_PERIPH_GPIO_v(i)(j);
                    PERIPH_to_MEM_v(i)(j) := '0';
                else
                    -- 3.2 Map input from the pins to the memory input
                    PERIPH_BIT_IO_v(i*BYTE_WIDTH + j) := 'Z';
                    PERIPH_to_MEM_v(i)(j) := PERIPH_BIT_IN_v(i*BYTE_WIDTH + j);
                end if;
            end loop;
        end loop;
        
        -- Assign signals
        PERIPH_BIT_IO(GPIO_WIDTH*BYTE_WIDTH-1 downto 0) <= PERIPH_BIT_IO_v;
        PERIPH_WRITE_EN(0 to GPIO_WIDTH-1) <= (others => (others => '0'));
        PERIPH_to_MEM(0 to GPIO_WIDTH-1) <= (others => (others => '0'));
        
        -- Override signals
        for i in GPIO_WIDTH to 2* GPIO_WIDTH-1 loop
            PERIPH_WRITE_EN(i) <= MEM_to_PERIPH_CONF_v(i - GPIO_WIDTH);
            PERIPH_to_MEM(i) <= PERIPH_to_MEM_v(i - GPIO_WIDTH);
        end loop;

    end process GPIO;
    
end architecture beh;
