--!@file 	PC_log.vhdl
--!@biref 	This file contains the programm counter entity of the CPU
--!@author 	Sebastian Brückner
--!@date 	2017

--!@biref 	Programm counter of the CPU
--!@details Contains the Programm counter logic
--!@author 	Sebastian Brückner
--!@date 	2017
entity PC_log is
	port(
		 clk, reset : in std_logic;
		 
		 cntrl  : in IF_CNTRL_TYPE; --! Control the operation mode of the PC logic
		 rel	: in DATA_TYPE;		--! relative branch adress
		 abso	: in DATA_TYPE;		--! absolute branch adress, or base for relative jump
		 
		 pc : out ADRESS_TYPE;		--! programm counter output
	);
end entity PC_log;
