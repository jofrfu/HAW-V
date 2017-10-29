--! RISC-V package
--! @author Felix Lorenz
--! @author Sebastian Brueckner
--! project: ach ne! @ HAW-Hamburg

library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;

package riscv_pack is

	--! @brief list of instructions
	--! @detail last i stands for "instruction"
	type INSTRUCTION_TYPE is (  luii, auipci, jali, jalri,
	                            beqi, bnei, blti, bgei, bltui, bgeui,
	                            lbi, lhi, lwi, lbui, lhui,
	                            sbi, shi, swi,
	                            addii, sltii, sltiui, xorii, orii, andii, sllii, srlii, sraii,
	                            addi, subi, slli, slti, sltui, xori, srli, srai, ori, andi
	                            --fencei, ecalli csri
	                            );
		
	--! @brief list of op codes
	--! @detail last o stands for "opcode"                    
	type OP_CODE_TYPE is (   luio, auipco, jalo, jalro,
	                        brancho, loado, storeo, opimmo, opo
	                        --miscmemo,systemo
	                        );
	                        
	constant DATA_WIDTH : natural := 32;
	constant ADDRESS_WIDTH : natural := 32;
	constant REGISTER_ADDRESS_WIDTH : natural := 5;
	constant REGISTER_COUNT : natural := 32;
	constant INSTRUCTION_WIDTH : natural := 32;
	constant OP_CODE_WIDTH : natural := 7;
	constant FUNCT3_WIDTH : natural := 3;
	constant FUNCT7_WIDTH : natural := 7;
	
	subtype DATA_TYPE is std_logic_vector(DATA_WIDTH-1 downto 0);
	subtype ADDRESS_TYPE is DATA_TYPE;
	subtype REGISTER_ADDRESS_TYPE is std_logic_vector(REGISTER_ADDRESS_WIDTH-1 downto 0);
	subtype REGISTER_COUNT_WIDTH is std_logic_vector(REGISTER_COUNT-1 downto 0);
	subtype INSTRUCTION_BIT_TYPE is std_logic_vector(INSTRUCTION_WIDTH-1 downto 0);
	subtype OP_CODE_BIT_TYPE is std_logic_vector(OP_CODE_WIDTH-1 downto 0);
	subtype FUNCT3_TYPE is std_logic_vector(FUNCT3_WIDTH-1 downto 0);
	subtype FUNCT7_TYPE is std_logic_vector(FUNCT7_WIDTH-1 downto 0);
	
	type REG_OUT_TYPE is array(REGISTER_COUNT-1 downto 0) of DATA_TYPE;
	
	--! @brief Instruction Fetch Constants
	constant STD_PC_ADD : DATA_TYPE := std_logic_vector(to_unsigned(4, DATA_WIDTH)); --! PC must be increased by 4 every clock cycle 
	constant IF_CNTRL_WIDTH : natural := 2;
	subtype IF_CNTRL_TYPE is std_logic_vector(IF_CNTRL_WIDTH-1 downto 0);
	
	--! @brief Instruction Decode
	constant WB_CNTRL_WIDTH : natural := 5;
	constant MA_CNTRL_WIDTH : natural := 2;
	constant EX_CNTRL_WIDTH : natural := 17;
	constant ID_CNTRL_WIDTH : natural := 12;
	subtype WB_CNTRL_TYPE is std_logic_vector(WB_CNTRL_WIDTH-1 downto 0);
	subtype MA_CNTRL_TYPE is std_logic_vector(MA_CNTRL_WIDTH-1 downto 0);
	subtype EX_CNTRL_TYPE is std_logic_vector(EX_CNTRL_WIDTH-1 downto 0);
	subtype ID_CNTRL_TYPE is std_logic_vector(ID_CNTRL_WIDTH-1 downto 0);
	constant IF_CNTRL_NOP : IF_CNTRL_TYPE := "00"; --PC + 4 as usual
	constant ID_CNTRL_NOP : ID_CNTRL_TYPE := "000000000000"; -- select r0 and r0 as operands
	constant EX_CNTRL_NOP : EX_CNTRL_TYPE := "00000000000110011"; --add registers
	constant MA_CNTRL_NOP : MA_CNTRL_TYPE := "00"; --no memory access
	constant WB_CNTRL_NOP : WB_CNTRL_TYPE := "00000"; --write result to r0
	
	--! @brief functions 
	--! @brief LUT as function to convert op_code as std_logic_vector to OP_CODE_TYPE
    function BITS_TO_OP_CODE_TYPE (bitvector : OP_CODE_BIT_TYPE) return OP_CODE_TYPE;

end riscv_pack;

package body riscv_pack is

	function BITS_TO_OP_CODE_TYPE (bitvector : OP_CODE_BIT_TYPE) return OP_CODE_TYPE is
	begin
	    case bitvector is
	        when "0010011" => return opimmo;
	        --when "0001111" => return miscmemo;
	        --when "1110011" => return systemo;
	        when "1100111" => return jalro;
	        when "0000011" => return loado;
	        when "0110111" => return luio;
	        when "0010111" => return auipco;
	        when "0110011" => return opo;
	        when "1101111" => return jalo;
	        when "1100011" => return brancho;
	        when "0100011" => return storeo;
	        when others => 
	           report "unknown OP_CODE" severity error;
	    end case;
    end function BITS_TO_OP_CODE_TYPE;
    
--! @brief execute
constant FLAGS_WIDTH : natural := 4;
subtype FLAGS_TYPE is std_logic_vector(FLAGS_WIDTH-1 downto 0);
    
end package body;