--!@file 	branch_checker_TB.vhdl
--!@brief 	This file contains the branch checker
--!@author 	Matthis Keppner, Jonas Fuhrmann
--!@date 	2017

library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;

use WORK.riscv_pack.all;

entity branch_checker_TB is
end entity branch_checker_TB;

architecture TB of branch_checker_TB is

component dut is
    port (
        FUNCT3      : in FUNCT3_TYPE;
        OP_CODE     : in OP_CODE_BIT_TYPE;
        FLAGS       : in FLAGS_TYPE;

        WORD_CNTRL  : out WORD_CNTRL_TYPE;
        SIGN_EN     : out std_logic;
        
        BRANCH      : out std_logic
    );
end component branch_checker;

for all : dut use entity work.branch_checker(beh);

    signal FUNCT3_s     : FUNCT3_TYPE := (others => '0');
    signal OP_BITS_s    : OP_CODE_BIT_TYPE := (others => '0');
    signal op_CODE_s    : OP_CODE_TYPE := (others => '0');
    signal FLAGS_s      : FLAGS_TYPE := (others => '0');
    signal WORD_CNTRL_s : WORD_CNTRL_TYPE;
    signal sign_en_s    : std_logic;
    signal BRANCH_s     : std_logic;

    signal simulation_running : boolean := false;
    
begin

    dut_i : dut
    port map(
        FUNCT3_s,
        OP_BITS_s,
        FLAGS_s,
        WORD_CNTRL_s,
        sign_en_s,
        BRANCH_s
        );
    
    test:
    process is
        begin
            simulation_running <= true;
            
            --test1  BEQ 
            --OP_CODE       : BRANCH
            --FUNCT3        : 000
            --FLAGS(V Z N C): 0100
            OP_CODE
