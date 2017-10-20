-- RISC-V package
-- created by Felix Lorenz
-- project: ach ne! @ HAW-Hamburg

library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all

package riscv_pack is

-- list of instructions (last i stands for "instruction"):
type INSTRUCTION_TYPE is (  luii, auipci, jali, jalri,
                            beqi, bnei, blti, bgei, bltui, bgeui,
                            lbi, lhi, lwi, lbui, lhui,
                            sbi, shi, swi,
                            addii, sltii, sltiui, xorii, orii, andii, sllii, srlii, sraii,
                            addi, subi, slli, slti, sltui, xori, srli, srai, ori, andi,
                            --fence, ecall and csr instructions not implemented at the moment
                            );
                            
type OPCODE_TYPE is (   luio, auipco, jalo, jalro,
                        brancho, loado, storeo, opimmo, opo,
                        --misc-mem and system not implemented at the moment
                        );
                        
constant DATA_WIDTH : natural := 32;
constant REGISTER_ADDRESS_WIDTH : natural := 5;
constant REGISTER_COUNT : natural := 32;

subtype DATA_TYPE is std_logic_vector(DATA_WIDTH-1 downto 0);
subtype REGISTER_ADDRESS_TYPE is std_logic_vector(REGISTER_ADDRESS_WIDTH-1 downto 0);

end riscv_pack;