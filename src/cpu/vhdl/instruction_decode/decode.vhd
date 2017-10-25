--! @brief register_select.vhd
--! @author Jonas Fuhrmann + Felix Lorenz
--! project: ach ne! @ HAW-Hamburg

use WORK.riscv_pack.all;
library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;
    
entity decode is
	port(
		--clk, reset  :  in std_logic;  --neccessary?? TO DO: delete?
		branch      :  in std_logic;
		IFR	        :  in INSTRUCTION_BIT_TYPE;
		----------------------------------------
		IF_CNTRL    : out IF_CNTRL_TYPE;
		ID_CNTRL    : out ID_CNTRL_TYPE;
		WB_CNTRL    : out WB_CNTRL_TYPE;
		MA_CNTRL    : out MA_CNTRL_TYPE;
		EX_CNTRL    : out EX_CNTRL_TYPE;
		Imm         : out DATA_TYPE
	);
end entity decode;

architecture beh of decode is

begin
    
    --! @brief decode unit for ID stage
    --! @detail controls the PC flow IF stage and operand selection for EX stage
    decode:
    process(branch, IFR) is
    begin
    
    end process decode;
    
    --! @brief extracts the immediate in the IFR and sign extends it
    imm_constr:
    process(IFR) is
        variable op_code   : OP_CODE_TYPE;
        variable imm_bits  : std_logic_vector( INSTRUCTION_WIDTH-1 downto OP_CODE_WIDTH );
        
        variable immediate : DATA_TYPE;
    begin
        op_code := BITS_TO_OP_CODE_TYPE(IFR(OP_CODE_WIDTH-1 downto 0));
        imm_bits := IFR(imm_bits'range);
        immediate := (others => imm_bits(imm_bits'left)); --MSB is always the sign bit if immediate is available
        
        case op_code is
            when opimmo | jalro | loado | opo => -- I-Type  / opo has R-Type, no immediate so it does not matter where it goes
                immediate(10 downto 0) := imm_bits(30 downto 20);
            
            when luio | auipco => -- U-Type
                immediate(30 downto 12) := imm_bits(30 downto 12);
            
            when jalo => -- J-Type
                immediate(19 downto 12) := imm_bits(19 downto 12);
                immediate(11) := imm_bits(20);
                immediate(10 downto 1) := imm_bits(30 downto 21);
                immediate(0) := '0';
            
            when brancho => -- B-Type
                immediate(11) := imm_bits(7);
                immediate(10 downto 5) := imm_bits(30 downto 25);
                immediate(4 downto 1) := imm_bits(11 downto 8);
                immediate(0) := '0';
            
            when storeo => -- S-Type
                immediate(10 downto 5) := imm_bits(30 downto 25);
                immediate(4 downto 1) := imm_bits(11 downto 8);
                immediate(0) := imm_bits(7);

        end case;
        
        Imm <= immediate;
        
    end process imm_constr;

    
    
end architecture beh;