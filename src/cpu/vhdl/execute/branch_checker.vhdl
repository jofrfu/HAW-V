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
        FUNCT3      : in FUNCT3_TYPE;
        OP_CODE     : in OP_CODE_BIT_TYPE;
        FLAGS       : in FLAGS_TYPE;

        WORD_CNTRL  : out WORD_CNTRL_TYPE;
        SIGN_EN     : out std_logic;
        
        BRANCH      : out std_logic
    );
end entity branch_checker;

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
                        report "Unkown word length on load!" severity warning;
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