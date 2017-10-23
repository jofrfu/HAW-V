--! RISC-V package
--! @author Felix Lorenz
--! project: ach ne! @ HAW-Hamburg

library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.all;

package riscv_pack is

--! @brief list of instructions
--! @detail last i stands for "instruction"
type INSTRUCTION_TYPE is (  luii, auipci, jali, jalri,
                            beqi, bnei, blti, bgei, bltui, bgeui,
                            lbi, lhi, lwi, lbui, lhui,
                            sbi, shi, swi,
                            addii, sltii, sltiui, xorii, orii, andii, sllii, srlii, sraii,
                            addi, subi, slli, slti, sltui, xori, srli, srai, ori, andi
                            --! fence, ecall and csr instructions not implemented at the moment
                            );
                            
type OPCODE_TYPE is (   luio, auipco, jalo, jalro,
                        brancho, loado, storeo, opimmo, opo
                        --! misc-mem and system not implemented at the moment
                        );
                        
constant DATA_WIDTH : natural := 32;
constant ADDRESS_WIDTH : natural := 32;
constant REGISTER_ADDRESS_WIDTH : natural := 5;
constant REGISTER_COUNT : natural := 32;
constant INSTRUCTION_WIDTH : natural := 32;

subtype DATA_TYPE is std_logic_vector(DATA_WIDTH-1 downto 0);
subtype ADDRESS_TYPE is std_logic_vector(ADDRESS_WIDTH-1 downto 0);
subtype REGISTER_ADDRESS_TYPE is std_logic_vector(REGISTER_ADDRESS_WIDTH-1 downto 0);
subtype REGISTER_COUNT_WIDTH is std_logic_vector(REGISTER_COUNT-1 downto 0);
subtype INSTRUCTION_TYPE is std_logic_vector(INSTRUCTION_WIDTH-1 downto 0);

--! @brief Instruction Fetch Constants
constant STD_PC_ADD : DATA_TYPE := TO_STDLOGICVECTOR(4); --! PC must be increased by 4 every clock cycle 
constant IF_CNTRL_WIDTH : natural := 2;
subtype IF_CNTRL_TYPE is std_logic_vector(IF_CNTRL_WIDTH-1 downto 0);

--! @brief Instruction Decode
constant WB_CNTRL_WIDTH : natural := 5;
constant MA_CNTRL_WIDTH : natural := 2;
constant EX_CNTRL_WIDTH : natural := 17;
constant ID_CNTRL_WIDTH : natural := 11;
subtype WB_CNTRL_TYPE is std_logic_vector(WB_CNTRL_WIDTH-1 downto 0);
subtype MA_CNTRL_TYPE is std_logic_vector(MA_CNTRL_WIDTH-1 downto 0);
subtype EX_CNTRL_TYPE is std_logic_vector(EX_CNTRL_WIDTH-1 downto 0);
subtype ID_CNTRL_TYPE is std_logic_vector(ID_CNTRL_WIDTH-1 downto 0);

type reg_out_type is array(REGISTER_COUNT-1 downto 0) of DATA_TYPE;

end riscv_pack;