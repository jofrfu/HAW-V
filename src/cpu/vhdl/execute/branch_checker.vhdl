--!@file 	execute_arch.vhdl
--!@brief 	This file contains the branch checker
--!@author 	Jonas Fuhrmann
--!@date 	2017

library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;

use WORK.riscv_pack.all;

entity branch_checker is
    port(
        clk, reset : in std_logic;
        
        FUNC3    : in FUNCT3_TYPE;
        OP_CODE  : in OP_CODE_BIT_TYPE;
        FLAGS    : in FLAGS_TYPE;

        WORD_CNTRL  : out WORD_CNTRL_TYPE;
        BRANCH      : out std_logic
    );
end entity branch_checker;