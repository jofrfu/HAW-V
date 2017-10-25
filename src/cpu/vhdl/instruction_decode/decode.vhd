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
		IFR	        :  in INSTRUCTION_TYPE;
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
        op_code := opCodeBitsToOpCodeType(IFR(OP_CODE_WIDTH-1 downto 0));
        imm_bits := IFR(imm_bits'range);
        immediate := (others => imm_bits'high) --MSB is always the sign bit if immediate is available
        
        case op_code is
            when opimmo | jalro | loado => -- I-Type
            
            
            when luio | auipco => -- U-Type
            
            
            when opo => -- R-Type
                -- no immediate, only register operations -> do nothing
            
            when jalo => -- J-Type
            
            
            when brancho => -- B-Type
            
            
            when storeo => -- S-Type
            

        end case;
        
        Imm <= immediate;
        
    end process imm_constr

    
    
end architecture beh;