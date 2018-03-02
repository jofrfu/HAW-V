--!@file    instruction_fetch_stage.vhdl
--!@brief   This file is part of the ach-ne project at the HAW Hamburg
--!@details Check: https://gitlab.informatik.haw-hamburg.de/lehr-cpu-bs/ach-ne-2017-2018 for more information
--!@author  Sebastian Brückner
--!@author  TODO authors missing
--!@date    2017

use WORK.riscv_pack.all;
library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;

--!@biref   This is the instruction fetch stage of the CPU
--!@details This Stage sets the programm counter and loads the new Instructions
entity instruction_fetch is
    port(
        clk, reset : in std_logic;
        
        branch    : in std_logic;
        cntrl     : in IF_CNTRL_TYPE;  --! Control the operation mode of the PC logic
        rel    : in DATA_TYPE;         --! relative branch address
        abso       : in DATA_TYPE;     --! absolute branch address, or base for relative jump
        ins        : in DATA_TYPE;     --! the new instruction is loaded from here
        
        IFR    : out DATA_TYPE;        --! Instruction fetch register contents
        pc_asynch : out ADDRESS_TYPE;  --! clocked pc register for ID stage
        pc_synch  : out ADDRESS_TYPE   --! asynchronous PC for instruction memory
    );
end entity instruction_fetch;

--!@brief instruction_fetch.std_impl simply connects PC_log to memory and IFR
architecture std_impl of instruction_fetch is 

    signal IFR_cs : INSTRUCTION_BIT_TYPE := NOP_INSTRUCT;
    signal IFR_ns : INSTRUCTION_BIT_TYPE;
    signal reset_cs : std_logic := '0';
    signal reset_ns : std_logic;
    signal reset_s : std_logic;
    
    component PC_log is
    port(
        clk, reset : in std_logic;
        
        branch    : in std_logic;
        cntrl     : in IF_CNTRL_TYPE; --! Control the operation mode of the PC logic
        rel       : in DATA_TYPE;     --! relative branch adress
        abso      : in DATA_TYPE;     --! absolute branch adress, or base for relative jump
        
        pc_asynch : out ADDRESS_TYPE; --! programm counter output
        pc_synch  : out ADDRESS_TYPE  --! programm counter output

    );
    end component PC_log;    
    for all: PC_log use entity work.PC_log(std_impl);
    
    -- instruction memory to be added with PC in and IFR out
    
begin

    PC_log_i : PC_log
    port map(
        clk => clk,
        reset => reset,
        branch => branch,
        cntrl => cntrl,
        rel => rel,
        abso => abso,
        pc_asynch => pc_asynch, --reserved for instruction memory
        pc_synch => pc_synch
    );
    
    reg : 
    process(clk) is
    begin
        if clk'event and clk = '1' then     --when cntrl is 01 or 11 it means jump
            reset_cs <= reset_ns;
            if reset_s = '1' or cntrl = "01" or cntrl = "11" then
                IFR_cs <= NOP_INSTRUCT; --discard next instruction                
            else
                IFR_cs <= IFR_ns;  --store data from instruction memory to IFR at rising edge   
            end if;
        end if; 
    end process reg;
        
    IFR_ns <= IFR_cs when cntrl = "10" else ins;
    reset_ns <= reset;
    reset_s <= reset or reset_cs;
    IFR <= IFR_cs;    
    
end architecture std_impl;
