--!@file    branch_checker.vhdl
--!@brief This file is part of the ach-ne procekt at the HAW Hamburg
--!@details Check: https://gitlab.informatik.haw-hamburg.de/lehr-cpu-bs/ach-ne-2017-2018 for more information
--!@author Jonas Fuhrmann
--!@author Sebastian Brückner
--!@date    2017 - 2018

library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;

use WORK.riscv_pack.all;

--!@brief   Checks if this operation is a branch and 
--!         furthermore sets control bits for Memory Access Stage
--!@details The branch_checker has two functionalities:
--!         1. Determine if a branch should be taken
--!             Compares conditional branch conditions with the FLAGS given from the ALU. 
--!             Determine whether a branch should be taken or not.
--!         2. Set control bits for following MA Stage
--!             When loading a signed byte or halfword, they need to be sign extended.
--!             If this is necessary, it is determined here
entity branch_checker is
    port(
        FUNCT3      : in FUNCT3_TYPE;      --!determins operation type in combination with OP_CODE
        OP_CODE     : in OP_CODE_BIT_TYPE; --!is used to determine if branch, load or store instruction
        FLAGS       : in FLAGS_TYPE;       --!is used to check the conditional branches, see FLAGS_TYPE

        WORD_CNTRL  : out WORD_CNTRL_TYPE; --!see WORD_CNTRL_TYPE
        SIGN_EN     : out std_logic;       --!determins if the load instruction needs to perform an sign extension
        
        BRANCH      : out std_logic        --!determins if branch should be taken
    );
end entity branch_checker;


--!@brief branch_checker.beh see entity documentation
architecture beh of branch_checker is

begin

    check:
    process(FUNCT3, OP_CODE, FLAGS) is

    variable funct3_v  : FUNCT3_TYPE;
    variable op_bits_v: OP_CODE_BIT_TYPE;
    variable op_code_v: OP_CODE_TYPE;
    variable flags_v  : FLAGS_TYPE;
    
    variable branch_v : std_logic;
    variable word_cntrl_v : WORD_CNTRL_TYPE;
    variable sign_enable_v : std_logic;
    begin
        funct3_v            := FUNCT3;
        op_bits_v           := OP_CODE;
        op_code_v           := BITS_TO_OP_CODE_TYPE(op_bits_v);
        flags_v             := FLAGS;        
        
        case op_code_v is
            when brancho =>                
                case funct3_v is
                    when "000" => -- BEQ
                        if flags_v(2) = '1' then -- check Z = 1
                            branch_v := '1';
                        else
                            branch_v := '0';
                         end if;
                    when "001" => -- BNE
                        if flags_v(2) = '0' then -- check Z = 0
                            branch_v := '1';
                        else
                            branch_v := '0';
                        end if;
                    when "100" => -- BLT
                        if flags_v(1) /= flags_v(3) then -- check N /= V
                            branch_v := '1';
                        else
                            branch_v := '0';
                        end if;
                    when "101" => -- BGE
                        if flags_v(1) = flags_v(3) then -- check N = V
                            branch_v := '1';
                        else
                            branch_v := '0';
                        end if;
                    when "110" => -- BLTU
                        if flags_v(0) = '0' then -- check C = 0
                            branch_v := '1';
                        else
                            branch_v := '0';
                        end if;
                    when "111" => -- BGEU
                        if flags_v(0) = '1' or flags_v(2) = '1' then
                            branch_v := '1';
                        else
                            branch_v := '0';
                        end if;
                        
                    when others =>
                        report "Unknown branch command!" severity warning;
                        branch_v            := '0';                                               
                end case;
                word_cntrl_v        := WORD;
                sign_enable_v       := '0'; 
            when loado =>
                case funct3_v is
                    when "000" => -- lb
                        word_cntrl_v := BYTE;
                        sign_enable_v:= '1';
                    when "001" => -- lh
                        word_cntrl_v := HALF;
                        sign_enable_v:= '1';
                    when "010" => -- lw
                        word_cntrl_v := WORD;
                        sign_enable_v:= '0';
                    when "100" => -- lbu
                        word_cntrl_v := BYTE;
                        sign_enable_v:= '0';
                    when "101" => -- lhu
                        word_cntrl_v := HALF;
                        sign_enable_v:= '0';
                    when others =>
                        report "Unknown word length on load!" severity warning;
                        word_cntrl_v        := WORD;
                        sign_enable_v       := '0';
                end case;
                branch_v            := '0';                        
            when storeo =>
                case funct3_v is
                    when "000" => -- sb
                        word_cntrl_v := BYTE;
                    when "001" => -- sh
                        word_cntrl_v := HALF;
                    when "010" => -- sw
                        word_cntrl_v := WORD;
                    when others =>
                        report "Unknown word length on store!" severity warning;
                        word_cntrl_v        := WORD;
                end case;
                branch_v            := '0';
                sign_enable_v       := '0';
            when others =>
                report "Maybe unknown branch/word cntrl!" severity note;
                branch_v            := '0';
                word_cntrl_v        := WORD;
                sign_enable_v       := '0';
        end case;
        
        BRANCH <= branch_v;
        WORD_CNTRL <= word_cntrl_v;
        SIGN_EN <= sign_enable_v;
    end process check;

end architecture beh;