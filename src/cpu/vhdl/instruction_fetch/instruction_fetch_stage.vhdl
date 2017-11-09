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
		 
		 cntrl     : in IF_CNTRL_TYPE;  --! Control the operation mode of the PC logic
		 rel	   : in DATA_TYPE;		--! relative branch address
		 abso	   : in DATA_TYPE;		--! absolute branch address, or base for relative jump
		 ins 	   : in DATA_TYPE;		--! the new instruction is loaded from here
		 
         IFR	   : out DATA_TYPE;	    --! Instruction fetch register contents
         pc_asynch : out ADDRESS_TYPE;  --! clocked pc register for ID stage
         pc_synch  : out ADDRESS_TYPE   --! asynchronous PC for instruction memory
    );
end entity instruction_fetch;
