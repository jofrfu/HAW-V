--!@file 	execute_arch.vhdl
--!@brief 	This file contains the execute stage architecture of the CPU
--!@author 	Matthis Keppner
--!@date 	2017

library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;

use WORK.riscv_pack.all;

architecture std_impl of execute_stage is


    component Branch_Checker is
        port(
            clk, reset : in std_logic;
            
            Func3    : in FUNCT3_TYPE;
            OP_Code  : in OP_CODE_BIT_TYPE;
            Flags    : in FLAGS_TYPE;

            Branch   : out std_logic
        );
    end component Branch_Checker;

    component ALU is
        port(
            clk, reset : in std_logic; --???? realy
            
            OPB         : in DATA_TYPE;
            OPA         : in DATA_TYPE;
            EX_CNTRL_IN : in EX_CNTRL_TYPE;
            
            Flags       : out FLAGS_TYPE;
            Resu        : out DATA_TYPE
        );
    end component ALU;