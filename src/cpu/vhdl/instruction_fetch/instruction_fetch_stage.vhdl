--!@file 	instruction_fetch_stage.vhdl
--!@biref 	This file contains the instruction fetch stage entity of the CPU
--!@author 	Sebastian Brückner
--!@date 	2017

library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;

use WORK.riscv_pack.all;

--!@biref 	This is the instruction fetch stage of the CPU
--!@details This Stage sets the programm counterm and loads the new Instructions.
--!@author 	Sebastian Brückner
--!@date 	2017
entity instruction_fetch is
	port(
		 clk, reset : in std_logic;
		 
		 cntrl  : in IF_CNTRL_TYPE; --! Control the operation mode of the PC logic
		 rel	: in DATA_TYPE;		--! relative branch adress
		 abso	: in DATA_TYPE;		--! absolute branch adress, or base for relative jump
		 ins 	: in DATA_TYPE;		--! the new instruction is loaded from here
		 
		 IFR	: out DATA_TYPE;	--! Instruction fetch register contents
		 pc : out DATA_TYPE;		--! programm counter output
	);
end entity instruction_fetch;
