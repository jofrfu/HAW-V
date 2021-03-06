--! RISC-V package
--! @author Felix Lorenz
--! @author Sebastian Brueckner
--! @author Jonas Fuhrmann
--! @author Matthis Keppner
--! @author Sebastian Brueckner
--! @date 2017-2018
--! project: ach ne! @ HAW-Hamburg

library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;

--! @brief Mainly contains auxiliary functions and constants defined by the risv-v instruction set, as well as processor specific constants
--! @details Most functions and constants aren't explained in detail here, because values and/or usage can be easily deducted from the risc v specification
package riscv_pack is

	--! @brief list of instructions
	--! @details last i stands for "instruction"
	type INSTRUCTION_TYPE is (  luii, auipci, jali, jalri,
	                            beqi, bnei, blti, bgei, bltui, bgeui,
	                            lbi, lhi, lwi, lbui, lhui,
	                            sbi, shi, swi,
	                            addii, sltii, sltiui, xorii, orii, andii, sllii, srlii, sraii,
	                            addi, subi, slli, slti, sltui, xori, srli, srai, ori, andi
	                            --fencei, ecalli csri
	                            );
                               
    
		
	--! @brief list of op codes
	--! @details last o stands for "opcode", testerror indicates error for sim and test                    
	type OP_CODE_TYPE is (   luio, auipco, jalo, jalro,
	                        brancho, loado, storeo, opimmo, opo,
	                        --miscmemo,systemo
                            testerror
	                        );
    
    -- funct3 definitions
    constant NO_FUNCT3     : std_logic_vector(2 downto 0) := "000";
    constant BEQ_FUNCT3    : std_logic_vector(2 downto 0) := "000";
    constant BNE_FUNCT3    : std_logic_vector(2 downto 0) := "001";
    constant BLT_FUNCT3    : std_logic_vector(2 downto 0) := "100";
    constant BGE_FUNCT3    : std_logic_vector(2 downto 0) := "101";
    constant BLTU_FUNCT3   : std_logic_vector(2 downto 0) := "110";
    constant BGEU_FUNCT3   : std_logic_vector(2 downto 0) := "111";
    constant LB_FUNCT3     : std_logic_vector(2 downto 0) := "000";
    constant LH_FUNCT3     : std_logic_vector(2 downto 0) := "001";
    constant LW_FUNCT3     : std_logic_vector(2 downto 0) := "010";
    constant LBU_FUNCT3    : std_logic_vector(2 downto 0) := "100";
    constant LHU_FUNCT3    : std_logic_vector(2 downto 0) := "101";
    constant SB_FUNCT3     : std_logic_vector(2 downto 0) := "000";
    constant SH_FUNCT3     : std_logic_vector(2 downto 0) := "001";
    constant SW_FUNCT3     : std_logic_vector(2 downto 0) := "010";
    constant ADDI_FUNCT3   : std_logic_vector(2 downto 0) := "000";
    constant SLTI_FUNCT3   : std_logic_vector(2 downto 0) := "010";
    constant SLTIU_FUNCT3  : std_logic_vector(2 downto 0) := "011";
    constant XORI_FUNCT3   : std_logic_vector(2 downto 0) := "100";
    constant ORI_FUNCT3    : std_logic_vector(2 downto 0) := "110";
    constant ANDI_FUNCT3   : std_logic_vector(2 downto 0) := "111";
    constant SLLI_FUNCT3   : std_logic_vector(2 downto 0) := "001";
    constant SRLI_SRAI_FUNCT3   : std_logic_vector(2 downto 0) := "101";
    constant ADD_FUNCT3    : std_logic_vector(2 downto 0) := "000";
    constant SUB_FUNCT3    : std_logic_vector(2 downto 0) := "000";
    constant SLL_FUNCT3    : std_logic_vector(2 downto 0) := "001";
    constant SLT_FUNCT3    : std_logic_vector(2 downto 0) := "010";
    constant SLTU_FUNCT3   : std_logic_vector(2 downto 0) := "011";
    constant XOR_FUNCT3    : std_logic_vector(2 downto 0) := "100";
    constant SRL_FUNCT3    : std_logic_vector(2 downto 0) := "101";
    constant SRA_FUNCT3    : std_logic_vector(2 downto 0) := "101";
    constant OR_FUNCT3     : std_logic_vector(2 downto 0) := "110";
    constant AND_FUNCT3    : std_logic_vector(2 downto 0) := "111";
    constant FENCE_FUNCT3  : std_logic_vector(2 downto 0) := "000";
    constant FENCEI_FUNCT3 : std_logic_vector(2 downto 0) := "001";
    constant ECALL_FUNCT3  : std_logic_vector(2 downto 0) := "000";
    constant EBREAK_FUNCT3 : std_logic_vector(2 downto 0) := "000";
    constant CSRRW_FUNCT3  : std_logic_vector(2 downto 0) := "001";
    constant CSRRS_FUNCT3  : std_logic_vector(2 downto 0) := "010";
    constant CSRRC_FUNCT3  : std_logic_vector(2 downto 0) := "011";
    constant CSRRWI_FUNCT3 : std_logic_vector(2 downto 0) := "101";
    constant CSRRSI_FUNCT3 : std_logic_vector(2 downto 0) := "110";
    constant CSRRCI_FUNCT3 : std_logic_vector(2 downto 0) := "111";
    
    --funct7 definitions
    constant NO_FUNCT7     : std_logic_vector(6 downto 0) := "0000000";
    constant SLLI_FUNCT7   : std_logic_vector(6 downto 0) := "0000000";
    constant SRLI_FUNCT7   : std_logic_vector(6 downto 0) := "0000000";
    constant SRAI_FUNCT7   : std_logic_vector(6 downto 0) := "0100000";
    constant ADD_FUNCT7    : std_logic_vector(6 downto 0) := "0000000";
    constant SUB_FUNCT7    : std_logic_vector(6 downto 0) := "0100000";
    constant SLL_FUNCT7    : std_logic_vector(6 downto 0) := "0000000";
    constant SLT_FUNCT7    : std_logic_vector(6 downto 0) := "0000000";
    constant SLTU_FUNCT7   : std_logic_vector(6 downto 0) := "0000000";
    constant XOR_FUNCT7    : std_logic_vector(6 downto 0) := "0000000";
    constant SRL_FUNCT7    : std_logic_vector(6 downto 0) := "0000000";
    constant SRA_FUNCT7    : std_logic_vector(6 downto 0) := "0100000";
    constant OR_FUNCT7     : std_logic_vector(6 downto 0) := "0000000";
    constant AND_FUNCT7    : std_logic_vector(6 downto 0) := "0000000";                        
	                        
	constant DATA_WIDTH : natural := 32;            --! 32Bit standard width of data
	constant ADDRESS_WIDTH : natural := 32;         --! Address width
	constant REGISTER_ADDRESS_WIDTH : natural := 5; --! 5 bit to adress 32 registers
	constant REGISTER_COUNT : natural := 32;        --! Number of registers used in this processor
	constant INSTRUCTION_WIDTH : natural := 32;     --!32bit architecture
	constant OP_CODE_WIDTH : natural := 7;  --!see risc-v spec
	constant FUNCT3_WIDTH : natural := 3;   --!see risc-v spec
	constant FUNCT7_WIDTH : natural := 7;   --!see risc-v spec
    constant WRITE_EN_WIDTH: natural := 4;  --!
    constant BYTE_WIDTH    : natural := 8;  --!a byte has 8 bits
    constant IO_BYTE_COUNT : natural := 6;    -- 6 Bytes at the moment (just GPIOs)
    constant PERIPH_IO_WIDTH : natural := 24; -- 24 Bit for in and output (3 GPIO Bytes)
    constant GPIO_WIDTH : natural := 3;       -- 3 GPIO Bytes with 3 Bytes of configuration
	
	subtype DATA_TYPE is std_logic_vector(DATA_WIDTH-1 downto 0);
	subtype ADDRESS_TYPE is DATA_TYPE;
	subtype REGISTER_ADDRESS_TYPE is std_logic_vector(REGISTER_ADDRESS_WIDTH-1 downto 0);
	subtype REGISTER_COUNT_WIDTH is std_logic_vector(REGISTER_COUNT-1 downto 0);
	subtype INSTRUCTION_BIT_TYPE is std_logic_vector(INSTRUCTION_WIDTH-1 downto 0);
	subtype OP_CODE_BIT_TYPE is std_logic_vector(OP_CODE_WIDTH-1 downto 0);
	subtype FUNCT3_TYPE is std_logic_vector(FUNCT3_WIDTH-1 downto 0);
	subtype FUNCT7_TYPE is std_logic_vector(FUNCT7_WIDTH-1 downto 0);
    subtype WRITE_EN_TYPE is std_logic_vector(WRITE_EN_WIDTH-1 downto 0);
	subtype BYTE_TYPE is std_logic_vector(BYTE_WIDTH-1 downto 0);
    subtype PERIPH_IO_TYPE is std_logic_vector(PERIPH_IO_WIDTH-1 downto 0);
    
	type REG_OUT_TYPE is array(REGISTER_COUNT-1 downto 0) of DATA_TYPE;
    type IO_BYTE_TYPE is array(0 to IO_BYTE_COUNT-1) of BYTE_TYPE;
    type IO_ENABLE_TYPE is array(0 to IO_BYTE_COUNT-1) of BYTE_TYPE;
    type GPIO_TYPE is array(GPIO_WIDTH-1 downto 0) of BYTE_TYPE;
	
	--! @brief Instruction Fetch Constants
	constant STD_PC_ADD : DATA_TYPE := std_logic_vector(to_unsigned(4, DATA_WIDTH)); --! PC must be increased by 4 every clock cycle 
	constant IF_CNTRL_WIDTH : natural := 2;
	subtype IF_CNTRL_TYPE is std_logic_vector(IF_CNTRL_WIDTH-1 downto 0);
	
	--! @brief Instruction Decode
	constant WB_CNTRL_WIDTH : natural := 6;
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
	constant WB_CNTRL_NOP : WB_CNTRL_TYPE := "000000"; --write result to r0
    constant NOP_INSTRUCT : INSTRUCTION_BIT_TYPE := "00000000000000000000000000110011";
    constant IF_CNTRL_BUB : IF_CNTRL_TYPE := "10"; --PC + rel => rel must be 0 then
	constant ID_CNTRL_BUB : ID_CNTRL_TYPE := ID_CNTRL_NOP;
	constant EX_CNTRL_BUB : EX_CNTRL_TYPE := EX_CNTRL_NOP;
	constant MA_CNTRL_BUB : MA_CNTRL_TYPE := MA_CNTRL_NOP;
	constant WB_CNTRL_BUB : WB_CNTRL_TYPE := WB_CNTRL_NOP;
	
	--! @brief execute
	constant FLAGS_WIDTH : natural := 4;
	constant WORD_CNTRL_WIDTH  : natural := 2;
    subtype FLAGS_TYPE is std_logic_vector(FLAGS_WIDTH-1 downto 0);
	subtype WORD_CNTRL_TYPE  is std_logic_vector(WORD_CNTRL_WIDTH-1 downto 0);
    constant BYTE : WORD_CNTRL_TYPE := "00";
    constant HALF : WORD_CNTRL_TYPE := "01";
    constant WORD : WORD_CNTRL_TYPE := "10";
    constant DOUBLE : WORD_CNTRL_TYPE := "11";
    
	
	
	--functions 
	--! @brief LUT as function to convert op_code as std_logic_vector to OP_CODE_TYPE
    function BITS_TO_OP_CODE_TYPE (bitvector : OP_CODE_BIT_TYPE) return OP_CODE_TYPE;
    
    --!@brief LUT as function to convert OP_CODE_TYPE to OP_CODE_BIT_TYPE
    function OP_CODE_TYPE_TO_BITS(op_code : OP_CODE_TYPE) return OP_CODE_BIT_TYPE;
    
    
    -------------------------------
    -- IFR consruction functions --
    -------------------------------
    
    --!@brief create IFR R-Type
    function IFR_R_TYPE(
        funct7  : FUNCT7_TYPE;
        rs2     : integer range 0 to REGISTER_COUNT-1; 
        rs1     : integer range 0 to REGISTER_COUNT-1; 
        funct3  : FUNCT3_TYPE; 
        rd      : integer range 0 to REGISTER_COUNT-1; 
        op_code : OP_CODE_TYPE
    ) 
    return INSTRUCTION_BIT_TYPE; 
    
    --!@brief create IFR I-Type
    function IFR_I_TYPE(
        imm     : integer; --TODO: range
        rs1     : integer range 0 to REGISTER_COUNT-1; 
        funct3  : FUNCT3_TYPE; 
        rd      : integer range 0 to REGISTER_COUNT-1; 
        op_code : OP_CODE_TYPE
    ) 
    return INSTRUCTION_BIT_TYPE;
    
    --!@brief create IFR I-Type special for shift operation
    --!@details immediate(11 downto 5) is funct7 and immediate(4 downto 0) the shift amount
    function IFR_I_TYPE_SHIFT(
        funct7  : FUNCT7_TYPE;
        shamt   : integer; --TODO: range
        rs1     : integer range 0 to REGISTER_COUNT-1; 
        funct3  : FUNCT3_TYPE; 
        rd      : integer range 0 to REGISTER_COUNT-1; 
        op_code : OP_CODE_TYPE
    ) 
    return INSTRUCTION_BIT_TYPE;
    
    --!@brief create IFR S-Type
    function IFR_S_TYPE(
        imm     : integer; --TODO: range
        rs2     : integer range 0 to REGISTER_COUNT-1;        
        rs1     : integer range 0 to REGISTER_COUNT-1; 
        funct3  : FUNCT3_TYPE; 
        op_code : OP_CODE_TYPE
    ) 
    return INSTRUCTION_BIT_TYPE;
    
    --!@brief create IFR B-Type
    --!@details only even numbers shall be used for immediate
    function IFR_B_TYPE(
        imm     : integer;
        rs2     : integer range 0 to REGISTER_COUNT-1;        
        rs1     : integer range 0 to REGISTER_COUNT-1; 
        funct3  : FUNCT3_TYPE; 
        op_code : OP_CODE_TYPE
    ) 
    return INSTRUCTION_BIT_TYPE;
    
    --!@brief create IFR U-Type
    function IFR_U_TYPE(
            imm     : integer;             
            rd      : integer range 0 to REGISTER_COUNT-1; 
            op_code : OP_CODE_TYPE
    ) 
    return INSTRUCTION_BIT_TYPE;
    
    --!@brief create IFR J-Type
    --!@details only even numbers shall be used for immediate
    function IFR_J_TYPE(
            imm     : integer;             
            rd      : integer range 0 to REGISTER_COUNT-1; 
            op_code : OP_CODE_TYPE
    ) 
    return INSTRUCTION_BIT_TYPE;
    
    

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
               return testerror;
	    end case;
    end function BITS_TO_OP_CODE_TYPE;
    
    function OP_CODE_TYPE_TO_BITS(op_code : OP_CODE_TYPE) return OP_CODE_BIT_TYPE is
    begin
        case op_code is
            when opimmo  => return "0010011";
            --when miscmemo => return "0001111";
            --when systemo => return "1110011";
            when jalro   => return "1100111";
            when loado   => return "0000011";
            when luio    => return "0110111";
            when auipco  => return "0010111";
            when opo     => return "0110011";
            when jalo    => return "1101111";
            when brancho => return "1100011";
            when storeo  => return "0100011";
            when others => 
	           report "riscv_pack.vhd: unknown OP_CODE" severity error;
               return "0000000";
        end case;
    end function OP_CODE_TYPE_TO_BITS;
    
    function IFR_R_TYPE(
        funct7  : FUNCT7_TYPE;
        rs2     : integer range 0 to REGISTER_COUNT-1; 
        rs1     : integer range 0 to REGISTER_COUNT-1; 
        funct3  : FUNCT3_TYPE; 
        rd      : integer range 0 to REGISTER_COUNT-1; 
        op_code : OP_CODE_TYPE
    ) 
    return INSTRUCTION_BIT_TYPE is
    begin
        return funct7
             & std_logic_vector(to_unsigned(rs2, REGISTER_ADDRESS_WIDTH)) 
             & std_logic_vector(to_unsigned(rs1, REGISTER_ADDRESS_WIDTH)) 
             & funct3
             & std_logic_vector(to_unsigned(rd, REGISTER_ADDRESS_WIDTH)) 
             & OP_CODE_TYPE_TO_BITS(op_code);
    end function IFR_R_TYPE;
    
    function IFR_I_TYPE(
        imm     : integer; 
        rs1     : integer range 0 to REGISTER_COUNT-1; 
        funct3  : FUNCT3_TYPE; 
        rd      : integer range 0 to REGISTER_COUNT-1; 
        op_code : OP_CODE_TYPE
    ) 
    return INSTRUCTION_BIT_TYPE is
    begin
        return std_logic_vector(to_signed(imm, 12)) 
             & std_logic_vector(to_unsigned(rs1, REGISTER_ADDRESS_WIDTH)) 
             & funct3 
             & std_logic_vector(to_unsigned(rd, REGISTER_ADDRESS_WIDTH)) 
             & OP_CODE_TYPE_TO_BITS(op_code);
    end function IFR_I_TYPE;
    
    function IFR_I_TYPE_SHIFT(
        funct7  : FUNCT7_TYPE;
        shamt   : integer; --TODO: range
        rs1     : integer range 0 to REGISTER_COUNT-1; 
        funct3  : FUNCT3_TYPE; 
        rd      : integer range 0 to REGISTER_COUNT-1; 
        op_code : OP_CODE_TYPE
    ) 
    return INSTRUCTION_BIT_TYPE is
    begin
        return funct7
             & std_logic_vector(to_unsigned(shamt, REGISTER_ADDRESS_WIDTH)) 
             & std_logic_vector(to_unsigned(rs1, REGISTER_ADDRESS_WIDTH)) 
             & funct3 
             & std_logic_vector(to_unsigned(rd, REGISTER_ADDRESS_WIDTH)) 
             & OP_CODE_TYPE_TO_BITS(op_code);
    end function IFR_I_TYPE_SHIFT;
    
    
    function IFR_S_TYPE(
        imm     : integer; --TODO: range
        rs2     : integer range 0 to REGISTER_COUNT-1;        
        rs1     : integer range 0 to REGISTER_COUNT-1; 
        funct3  : FUNCT3_TYPE; 
        op_code : OP_CODE_TYPE
    ) 
    return INSTRUCTION_BIT_TYPE is
        variable imm_v : std_logic_vector(11 downto 0);
    begin
        imm_v := std_logic_vector(to_signed(imm, 12));
        return imm_v(11 downto 5) 
             & std_logic_vector(to_unsigned(rs2, REGISTER_ADDRESS_WIDTH)) 
             & std_logic_vector(to_unsigned(rs1, REGISTER_ADDRESS_WIDTH))
             & funct3
             & imm_v(4 downto 0) 
             & OP_CODE_TYPE_TO_BITS(op_code);
    end function IFR_S_TYPE;
    
    function IFR_B_TYPE(
        imm     : integer;
        rs2     : integer range 0 to REGISTER_COUNT-1;        
        rs1     : integer range 0 to REGISTER_COUNT-1; 
        funct3  : FUNCT3_TYPE; 
        op_code : OP_CODE_TYPE
    ) 
    return INSTRUCTION_BIT_TYPE is
        variable imm_v : std_logic_vector(12 downto 0);
    begin
        imm_v := std_logic_vector(to_signed(imm, 13));
        return imm_v(12) 
             & imm_v(10 downto 5)
             & std_logic_vector(to_unsigned(rs2, REGISTER_ADDRESS_WIDTH)) 
             & std_logic_vector(to_unsigned(rs1, REGISTER_ADDRESS_WIDTH))
             & funct3
             & imm_v(4 downto 1) 
             & imm_v(11)
             & OP_CODE_TYPE_TO_BITS(op_code);
    end function IFR_B_TYPE;
    
    function IFR_U_TYPE(
            imm     : integer;             
            rd      : integer range 0 to REGISTER_COUNT-1; 
            op_code : OP_CODE_TYPE
    ) 
    return INSTRUCTION_BIT_TYPE is
        variable imm_v : std_logic_vector(31 downto 0);
    begin
        imm_v := std_logic_vector(to_signed(imm, 32));
        return imm_v(31 downto 12)
             & std_logic_vector(to_unsigned(rd, REGISTER_ADDRESS_WIDTH)) 
             & OP_CODE_TYPE_TO_BITS(op_code);
    end function IFR_U_TYPE;
    
    function IFR_J_TYPE(
            imm     : integer;             
            rd      : integer range 0 to REGISTER_COUNT-1; 
            op_code : OP_CODE_TYPE
    ) 
    return INSTRUCTION_BIT_TYPE is
        variable imm_v : std_logic_vector(20 downto 0);
    begin
        imm_v := std_logic_vector(to_signed(imm, 21));
        return imm_v(20)
             & imm_v(10 downto 1)
             & imm_v(11)
             & imm_v(19 downto 12)
             & std_logic_vector(to_unsigned(rd, REGISTER_ADDRESS_WIDTH)) 
             & OP_CODE_TYPE_TO_BITS(op_code);
    end function IFR_J_TYPE;
    
end package body;