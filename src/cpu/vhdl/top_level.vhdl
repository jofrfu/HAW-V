--!@file    top_level.vhdl
--!@brief   This file is part of the ach-ne project at the HAW Hamburg
--!@details Check: https://gitlab.informatik.haw-hamburg.de/lehr-cpu-bs/ach-ne-2017-2018 for more information
--!@author  Jonas Fuhrmann
--!@date    2017 - 2018

--!@mainpage    HAW risc-v Processor
--!@section     Introduction
--!             The HAW risc-v processor is a simple risc-v RV32I Instruction set processor aimed educational purposes.
--!             Therefore the architecture is kept simple and performance is of secondary importance.
--!             At the moments the Core isn't finished, so use with care
--!@section     missing_features Missing features
--!@subsection  rv32i RV32I
--!             At the moment the System Instructions specified by the risc-v instruction RV32I instruction set are missing
--!@subsection  isr Interrupts
--!             For an potential OS support and if the processor should be capable of replacing an ARM core interrupts are needed.
--!@subsection  timers Timers
--!             Because Interrupts are missing, timers are also missing
--!@section     Testbenches
--!             Many testbenches are outdated and do no longer work. Mostly because it ware easier to update the testbench of an higher level entity,
--!             which will test the lower level component as well. If a testbench on master branch fails, it needs to be updated. 
--!@section     RAM
--!             At the moment, the RAM is specific to the Xilinx FGPA used. The RAM is generated via Xilinx IP blockram (see RAM generation guide)
library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;

library ICE40UP;
    use ICE40UP.COMPONENTS.all;
    
use WORK.riscv_pack.all;

--!@brief This device contains the complete processor (Core, Memory and Peripherals).

entity top_level is
    port(
        reset_n     : in    std_logic;
        
        -- peripheral I/O
        periph_bit_io  : inout PERIPH_IO_TYPE
    );
end entity top_level;

architecture beh of top_level is

    signal CLK : std_logic;
    signal RESET : std_logic;

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
            clk, reset      : in    std_logic;
            
            -- memory connections
            PERIPH_WRITE_EN : out   IO_ENABLE_TYPE;
            PERIPH_to_MEM   : out   IO_BYTE_TYPE;
            MEM_to_PERIPH   : in    IO_BYTE_TYPE;
            
            -- top level connections
            PERIPH_BIT_IO   : inout PERIPH_IO_TYPE
        );
    end component peripherals;
    for all : peripherals use entity work.peripherals_wrapper(beh);
begin
 
    RESET <= not reset_n;
 
    OSCILLATOR : HSOSC
    generic map(
        CLKHF_DIV => "0b11"
    )
    port map ( 
       CLKHFPU => '1',
       CLKHFEN => '1',
       CLKHF => CLK
    );
 
    core_i : risc_v_core
    port map(
        CLK,
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
        CLK,
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
        CLK,
        reset,
        
        PERIPH_WRITE_EN_s,
        PERIPH_to_MEM_s,
        MEM_to_PERIPH_s,
        
        periph_bit_io
    );
    
end architecture beh;
