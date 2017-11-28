--!@brief 	This file contains the top level entity of the System
--!@author 	Jonas Fuhrmann
--!@date 	2017

library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;

use WORK.riscv_pack.all;

entity top_level is
    port(
        clk, reset     : in    std_logic;
        
        -- peripheral I/O
        periph_bit_io  : inout PERIPH_IN_TYPE;
    );
end entity top_level;

architecture beh of top_level is
    component risc_v_core is
        port(
            clk, reset    : in std_logic;
            
            -- memory
            pc_asynch     : out ADDRESS_TYPE;
            instruction   : in  INSTRUCTION_BIT_TYPE;
            
            EN            : out std_logic;
            WEN           : out std_logic;
            WORD_LENGTH   : out WORD_CNTRL_TYPE;
            ADDR          : out ADDRESS_TYPE;
            D_CORE_to_MEM : out DATA_TYPE;
            D_MEM_to_CORE : in  DATA_TYPE
        );
    end component risc_v_core;
    for all : risc_v_core use entity work.risc_v_core(beh);
    
    signal pc_asynch_s     : ADDRESS_TYPE;
    signal instruction_s   : INSTRUCTION_BIT_TYPE;
    signal EN_s            : std_logic;
    signal WEN_s           : std_logic;
    signal WORD_LENGTH_s   : WORD_CNTRL_TYPE;
    signal ADDR_s          : ADDRESS_TYPE;
    signal D_CORE_to_MEM_s : DATA_TYPE;
    signal D_MEM_to_CORE_s : DATA_TYPE;
    
    component memory is
        port(
            CLK            : IN STD_LOGIC;
            reset          : IN STD_LOGIC;
            
            pc_asynch      : IN ADDRESS_TYPE;
            instruction    : OUT INSTRUCTION_BIT_TYPE;
            
            EN             : IN STD_LOGIC;
            WEN            : IN STD_LOGIC;
            WORD_LENGTH    : in WORD_CNTRL_TYPE;
            ADDR           : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            DIN            : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            DOUT           : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            
            -- IO
            PERIPH_IN_EN   : IN  IO_ENABLE_TYPE;-- disables write access - register is written from peripheral
            PERIPH_IN      : IN  IO_BYTE_TYPE;  -- input for peripheral connections
            PERIPH_OUT     : OUT IO_BYTE_TYPE   -- output for peripheral connections 
        );
    end component memory;
    for all : memory use entity work.memory_io_controller(beh);
    
    signal PERIPH_WRITE_EN_s : IO_ENABLE_TYPE;
    signal PERIPH_to_MEM_s   : IO_BYTE_TYPE;
    signal MEM_to_PERIPH_s   : IO_BYTE_TYPE;
    
    component peripherals is
        port(
            clk, reset      : in std_logic;
            
            -- memory connections
            PERIPH_WRITE_EN : out   IO_ENABLE_TYPE;
            PERIPH_to_MEM   : out   IO_BYTE_TYPE;
            MEM_to_PERIPH   : in    IO_BYTE_TYPE;
            
            -- top level connections
            PERIPH_BIT_IO   : inout PERIPH_IN_TYPE;
        );
    end component peripherals;
    for all : peripherals use open; -- todo: change
begin
    
    core_i : risc_v_core
    port map(
        clk,
        reset,
        
        pc_asynch_s,
        instruction_s,
        EN_s,
        WEN_s,
        WORD_LENGTH_s,
        ADDR_s,
        D_CORE_to_MEM_s,
        D_MEM_to_CORE_s
    );
    
    mem_i : memory
    port map(
        clk,
        reset,
        
        pc_asynch_s,
        instruction_s,
        EN_s,
        WEN_s,
        WORD_LENGTH_s,
        ADDR_s,
        D_CORE_to_MEM_s,
        D_MEM_to_CORE_s,
        
        PERIPH_WRITE_EN_s,
        PERIPH_to_MEM_s,
        MEM_to_PERIPH_s
    );
    
    periph_i : peripherals
    port map(
        clk,
        reset,
        
        PERIPH_WRITE_EN_s,
        PERIPH_to_MEM_s,
        MEM_to_PERIPH_s,
        
        periph_bit_io
    );
    
end architecture top_level;
