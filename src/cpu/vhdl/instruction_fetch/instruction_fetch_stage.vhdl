--!@file 	instruction_fetch_stage.vhdl
--!@biref 	This file contains the instruction fetch stage entity of the CPU
--!@author 	Sebastian Brückner
--!@date 	2017

use WORK.riscv_pack.all;
library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;

--!@biref 	This is the instruction fetch stage of the CPU
--!@details This Stage sets the programm counter and loads the new Instructions.
--!@author 	Sebastian Brückner
--!@date 	2017
entity instruction_fetch is
	port(
		 clk, reset : in std_logic;
		 
		 branch    : in std_logic;      --! when branch the IFR has to be resetted
         cntrl     : in IF_CNTRL_TYPE;  --! Control the operation mode of the PC logic
		 rel	   : in DATA_TYPE;		--! relative branch address
		 abso	   : in DATA_TYPE;		--! absolute branch address, or base for relative jump
		 ins 	   : in DATA_TYPE;		--! the new instruction is loaded from here
		 
         IFR	   : out DATA_TYPE;	    --! Instruction fetch register contents
         pc_asynch : out ADDRESS_TYPE;  --! clocked pc register for ID stage
         pc_synch  : out ADDRESS_TYPE   --! asynchronous PC for instruction memory
    );
end entity instruction_fetch;

architecture std_impl of instruction_fetch is 

    signal IFR_cs : INSTRUCTION_BIT_TYPE := NOP_INSTRUCT;
    
    component PC_log is
    port(
         clk, reset : in std_logic;
         
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
            if branch = '1' or reset = '1' or cntrl = "01" or cntrl = "11" then
                IFR_cs <= NOP_INSTRUCT; --discard next instruction
            else
                IFR_cs <= ins;  --store data from instruction memory to IFR at rising edge   
            end if;
        end if; 
    end process reg;
        
    IFR <= IFR_cs;    
    
end architecture std_impl;
